"""Builds docs/ASO-Research.md from the collected data (no hand-entered numbers).

python3 tools/aso/report.py
"""
from __future__ import annotations

import json
from pathlib import Path

import name_check
from markets import MARKETS

HERE = Path(__file__).resolve().parent
DATA = HERE / "data"
OUT = HERE.parent.parent / "docs/ASO-Research.md"

SOURCES = [
    ("iTunes Search API (`itunes.apple.com/search`)", "Bepul", "Ilova nomi, ishlab chiquvchi, reyting, reyting soni, narx, janr; so'rov bo'yicha ≤200 ilova (raqobatchilar soni)", "Popularity, haqiqiy qidiruv tartibi", "Ha"),
    ("iTunes Lookup API (`itunes.apple.com/lookup`)", "Bepul", "Top-10 ilovalarning har bir do'kondagi reyting soni → qiyinlik", "—", "Ha"),
    ("App Store search hints (`MZSearchHints`)", "Bepul", "Apple autocomplete takliflari (mamlakat bo'yicha, Apple tartibida)", "Raqamli popularity yo'q", "Ha"),
    ("App Store web qidiruv (`apps.apple.com/<cc>/iphone/search`)", "Bepul", "Haqiqiy, tartiblangan iPhone qidiruv natijalari → top-10 raqobatchilar, nom bandligi", "Popularity", "Ha"),
    ("USPTO TM Search (`tmsearch.uspto.gov`)", "Bepul", "AQSh trademark'lari: so'z belgisi, holati (faol/bekor), sinflar", "EU/WIPO bazalari", "Ha"),
    ("Sonar API, kalitsiz bepul tarif", "Bepul (5 so'z/kun/IP)", "**Apple Search Ads popularity (5–100)**, qiyinlik", "Hajm juda kichik", "Ha (kalibrlash va asosiy so'zlar)"),
    ("Sonar API, prepaid", "Pullik: $10 = 1000 kredit", "Apple popularity barcha so'zlar uchun, 72 bozor", "—", "Yo'q (foydalanuvchi bepul variantni tanladi)"),
    ("Apple Ads Platform API (`api.ads.apple.com/v1`)", "Bepul, lekin Apple Ads hisobi va API kaliti kerak", "Rasmiy search-term popularity (1–100), kalit so'z takliflari", "—", "Yo'q (hisob yo'q)"),
    ("AppTweak API", "Pullik: ~$166/oy; 7 kunlik trial (ro'yxatdan o'tish kerak)", "Volume, difficulty (1–100), reach, rankings", "—", "Yo'q"),
    ("Astro (Mac ilova)", "Pullik: $9/oy", "Apple Search Ads popularity, difficulty, rank tracking", "API yo'q", "Yo'q"),
    ("Appfigures API", "Pullik: ~$9/oy dan; popularity yuqori tariflarda", "O'z modeliga asoslangan popularity/competitiveness", "Apple'ning raqami emas", "Yo'q"),
]


def load_market(cc):
    path = DATA / f"candidates_{cc}.json"
    return json.loads(path.read_text()) if path.exists() else []


def sonar(cc):
    path = DATA / "sonar" / f"{cc.lower()}.json"
    return json.loads(path.read_text()) if path.exists() else {}


def autocomplete(c):
    if not c.get("letters"):
        return "taklif qilinmaydi"
    return f"{c['letters']} harfda, #{c['rank']}"


def keyword_rows(cc, limit=25):
    apple = sonar(cc)
    rows = [c for c in load_market(cc) if c.get("selected")]
    # Real Apple popularity first, then relevance, then how early autocomplete suggests it.
    rows.sort(key=lambda c: (-(apple.get(c["term"], {}).get("popularity") or 0), -c["relevance"],
                             c.get("letters") or 99, c.get("rank") or 99))
    return rows[:limit], apple


def market_table(cc):
    lang, localized, _ = MARKETS[cc]
    rows, apple = keyword_rows(cc)
    lines = [
        f"### {cc} — App Store tili: `{lang}` · ilova lokalizatsiyasi: {'✅ bor' if localized else '❌ yo‘q (tavsiya: qo‘shish)'}",
        "",
        "| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |",
        "|---|---|---|---|---|---|---|",
    ]
    for c in rows:
        pop = apple.get(c["term"], {}).get("popularity")
        top = "; ".join(f"{a['name']} ({a.get('ratings', 0):,})" for a in (c.get("top10") or [])[:3]).replace("|", "\\|")
        apps = c.get("apps")
        apps_text = "≥200" if apps == 200 else (str(apps) if apps is not None else "—")
        lines.append(f"| {c['term']} | {pop if pop is not None else '—'} | {autocomplete(c)} | {c.get('dif', '—')} | "
                     f"{apps_text} | {top} | {c['relevance']} |")
    return "\n".join(lines)


def build():
    storefronts = json.loads((DATA / "storefronts.json").read_text())
    out = ["# ASO tadqiqoti: PDF skaner + OCR (to'liq ma'lumotlar bilan)", "",
           "> Har bir raqam `tools/aso/` skriptlari orqali ochiq manbalardan olingan. So'rov javoblari "
           "`tools/aso/.cache` da saqlanadi, shuning uchun natijalarni qayta tekshirish mumkin.", ""]

    out += ["## 1. Ma'lumot manbalari", "",
            "| Manba | Narx | Beradigan ma'lumot | Bermaydigan | Ishlatildi |", "|---|---|---|---|---|"]
    out += [f"| {a} | {b} | {c} | {d} | {e} |" for a, b, c, d, e in SOURCES]
    out += ["", "**Popularity haqida.** Apple'ning popularity raqami (5–100) faqat Apple Search Ads orqali keladi. "
            "Bepul autocomplete ma'lumotidan popularity hisoblashga urinib ko'rdim, lekin u Apple raqamlariga mos "
            "kelmadi (kalibrlash pastda). Shuning uchun popularity faqat Apple raqami bor joylarda ko'rsatilgan. "
            "Qolgan kalit so'zlar uchun xom fakt beriladi: Apple bu so'zni autocomplete'da nechta harfdan keyin va "
            "nechanchi o'rinda taklif qiladi.", ""]
    calib = sonar("US")
    us = {c["term"]: c for c in load_market("US")}
    out += ["### Kalibrlash (AQSh): autocomplete va Apple popularity", "",
            "| Kalit so'z | Apple popularity | Autocomplete |", "|---|---|---|"]
    for term, v in sorted(calib.items(), key=lambda i: -(i[1]["popularity"] or 0)):
        out.append(f"| {term} | {v['popularity']} | {autocomplete(us.get(term, {}))} |")
    out += ["", "Xulosa: autocomplete'da erta chiqish yuqori popularity'ni kafolatlamaydi. Masalan, \"text scanner\" "
            "6 harfda taklif qilinadi, lekin popularity'si 5. Shuning uchun autocomplete faqat talab borligining "
            "belgisi sifatida ishlatildi.", ""]

    out += ["**Qiyinlik (1–100)** = 0,7 × top-10 ilovalar reyting sonining mediani (log shkala, 1 mln reyting = 100) "
            "+ 0,3 × nomida kalit so'zning barcha so'zlari bor top-10 ilovalar ulushi.  "
            "**Ilovalar** = iTunes Search API qaytargan ilovalar soni (Apple 200 dan ortig'ini qaytarmaydi).  "
            "**Relevantlik**: 3 = asosiy funksiya, 2 = qo'shimcha funksiya, 1 = yaqin mavzu.", ""]

    out += [f"## 2. Nom unikalligi ({len(storefronts)} ta storefront + USPTO)", ""]
    out += [(DATA / "name_check.md").read_text()]
    out += ["", "Izoh: 174 ta storefront iTunes Search API orqali barcha ISO-3166 kodlarini tekshirib topildi. "
            "Apple 175 deydi; farq Apple'ning maxsus storefront'lari bilan bog'liq bo'lishi mumkin. "
            "EUIPO va WIPO bazalarida ochiq API yo'q, ularni qo'lda tekshirish kerak: "
            "[TMview](https://www.tmdn.org/tmview/), [WIPO Global Brand Database](https://branddb.wipo.int/).", ""]

    out += ["## 3. Kalit so'zlar (bozorlar bo'yicha)", ""]
    for cc in MARKETS:
        if load_market(cc):
            out += [market_table(cc), ""]
    OUT.write_text("\n".join(out) + "\n")
    print("written", OUT)


if __name__ == "__main__":
    build()
