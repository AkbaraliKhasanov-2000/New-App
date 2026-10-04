"""Stage 4: App Store metadata per localization, checked against Apple's limits.

python3 tools/aso/metadata.py            → validate, write fastlane/metadata/<locale>/ and docs/ASO-Metadata.md
python3 tools/aso/metadata.py --check    → validate only

Every keyword choice is traced to data in data/candidates_<CC>.json (autocomplete position, difficulty)
or data/sonar/<cc>.json (Apple popularity). The "why" column of the report names the evidence.

Limits (App Store Connect): name ≤ 30 characters, subtitle ≤ 30 characters, keywords ≤ 100 bytes
(UTF-8, comma separated, no spaces needed), promotional text ≤ 170 characters.
Apple indexes name + subtitle + keywords of every localization that a storefront indexes, so a word
used in the name is never repeated in the keyword field of the same localization.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
FASTLANE = ROOT / "fastlane/metadata"
OUT = ROOT / "docs/ASO-Metadata.md"

# Recommended clean name from Stage 2 (0 identical / similar apps in 174 storefronts, no close USPTO mark).
# "Scanlet" is taken (identical app name in 55 storefronts) and cannot be used.
BRAND = "Scanmuse"
OLD_BRAND = "Scanlet"

# Which localizations each storefront indexes for search
# (developer.apple.com/help/app-store-connect/reference/app-store-localizations).
INDEX = {
    "US": ["en-US", "es-MX", "pt-BR", "fr-FR", "ru", "ko", "ar-SA", "zh-Hans", "zh-Hant", "vi"],
    "GB": ["en-GB"],
    "CA": ["en-CA", "fr-CA"],
    "AU": ["en-AU", "en-GB"],
    "IN": ["en-GB", "hi"],
    "DE": ["de-DE", "en-GB"],
    "FR": ["fr-FR", "en-GB"],
    "ES": ["es-ES", "ca", "en-GB"],
    "IT": ["it", "en-GB"],
    "BR": ["pt-BR", "en-GB"],
    "MX": ["es-MX", "en-GB"],
    "JP": ["ja", "en-US"],
    "KR": ["ko", "en-GB"],
    "RU": ["ru", "en-GB", "uk"],
    "TR": ["tr", "en-GB"],
    "NL": ["nl-NL", "en-GB"],
    "PL": ["pl", "en-GB"],
    "SE": ["sv", "en-GB"],
}

# Short connector words Apple ignores for ranking; repeating them is not a waste.
STOP = {"&", "and", "to", "of", "for", "with", "a", "the", "de", "y", "e", "et", "en", "und", "zu", "in", "di",
        "da", "di", "и", "с", "з", "ve", "ile", "i", "och", "en", "van", "naar", "la", "le", "des", "du", "per",
        "para", "con", "mit", "z", "ze", "w", "·", "・"}

TITLE_ = "{brand}"

# name / subtitle may contain {brand}. "why" cites the evidence (market data file: term → letters typed
# before Apple suggests it in autocomplete "Lx", difficulty "Dx", Apple popularity "Px").
LOCALES: dict[str, dict] = {
    # ---------- English ----------
    "en-US": dict(
        markets="US (+JP)",
        name="{brand}: PDF Document Scanner",
        subtitle="Scan App: OCR Text & Signature",
        keywords="receipt,sign,signer,jpg,converter,photo,image,camera,cam,doc,id,card,paper,translate,copy,extract",
        promo="Scan documents to PDF in seconds, recognize text with on-device OCR and sign anything. "
              "Private by design: no account, no cloud.",
        why="US Apple popularity: scanner app free P66, scanner P62, pdf scanner P59, scan to pdf P59, scan P58, "
            "document scanner P55, scanner app P49, scan documents P48 — every word sits in name/subtitle. "
            "ocr/text/image to text/receipt/sign pdf are P5 (low volume, low difficulty: pdf signer D12, "
            "sign pdf free D17, ocr scan D29) → subtitle + keywords. 'free' is excluded: App Review Guideline "
            "2.3.7 forbids pricing terms in metadata.",
    ),
    "en-GB": dict(
        markets="GB, AU, IN + English searches in DE FR ES IT BR MX KR RU TR NL PL SE",
        name="{brand}: PDF Document Scanner",
        subtitle="Scan App: OCR Text & Signature",
        keywords="receipt,sign,signer,jpg,converter,photo,image,camera,maker,doc,id,card,paper,translate,copy,extract",
        promo="Scan documents to PDF in seconds, recognise text with on-device OCR and sign anything. "
              "Private by design: no account, no cloud.",
        why="GB autocomplete: pdf scanner L2, scanner app L2, scan documents L3, ocr text scanner L3, receipt "
            "scanner L4 (D34), document scanner L4, ocr copy L5 (D21), sign pdf free L6. IN: doc scanner L1 (D68), pdf scanner L2, document scanner L2, scan and pdf maker L6, scan pdf maker L6, scan receipt L6 (D21), scan signature L6 (D23). English 'scanner' / "
            "'pdf scanner' are also top-3 autocomplete terms in BR, MX, TR, KR (see their tables) — en-GB is "
            "indexed there, so the English core stays in this name.",
    ),
    "en-AU": dict(
        markets="AU (en-GB also indexed)",
        name="{brand}: PDF Document Scanner",
        subtitle="Scan Documents & Image to Text",
        keywords="receipts,app,ocr,photos,pictures,picture,files,handwriting,notes,lock,password,print,reader,maker",
        promo="Scan documents to PDF in seconds, recognise text with on-device OCR and sign anything. "
              "Private by design: no account, no cloud.",
        why="AU autocomplete: pdf scanner L2, scanner app L2, scan documents L3, document scanner L3, receipt "
            "scanner L4, scan to text L6, image to text L7. en-GB (also indexed in AU) already holds receipt/"
            "sign/jpg/…, so en-AU adds plurals and different words instead of repeating them.",
    ),
    "en-CA": dict(
        markets="CA (fr-CA also indexed)",
        name="{brand}: PDF Document Scanner",
        subtitle="Scan App: OCR Text & Signature",
        keywords="receipt,sign,signer,jpg,converter,photo,image,camera,cam,doc,id,card,paper,translate,copy,extract",
        promo="Scan documents to PDF in seconds, recognize text with on-device OCR and sign anything. "
              "Private by design: no account, no cloud.",
        why="CA autocomplete: pdf scanner L2, scanner app free L2, scanner L2, ocr scanner L3 (D46), scan "
            "document L3, document scanner L3, scan pdf L3, scan receipt L6, image to text L7.",
    ),
    # ---------- Extra English slots indexed only in the US (app is not localized in these languages,
    # so users of these storefronts see English anyway). Optional: adds 4 × 100 bytes of US keywords.
    "ar-SA": dict(
        markets="US (extra slot)", extra=True,
        name="{brand}: PDF Document Scanner",
        subtitle="Scan Receipts, IDs & Contracts",
        keywords="handwriting,notes,files,print,share,reader,phone,mobile,batch,multipage",
        promo="Scan documents to PDF in seconds, recognize text with on-device OCR and sign anything. "
              "Private by design: no account, no cloud.",
        why="US long-tail: receipt scanner L3, scan receipts L6, pdf mobile scanner L5. Words not used in en-US.",
    ),
    "vi": dict(
        markets="US (extra slot)", extra=True,
        name="{brand}: PDF Document Scanner",
        subtitle="Pictures & Photos to Text",
        keywords="picture,images,png,jpeg,convert,documents,pages,quick,crop,enhance,filter",
        promo="Scan documents to PDF in seconds, recognize text with on-device OCR and sign anything. "
              "Private by design: no account, no cloud.",
        why="US: jpg to pdf photos L5, pdf to jpg converter L5 (D22), scan documents P48 (plural form).",
    ),
    "zh-Hans": dict(
        markets="US (extra slot)", extra=True,
        name="{brand}: PDF Document Scanner",
        subtitle="E-Sign & Password Lock",
        keywords="esign,initials,agreement,draw,autograph,secure,private,faceid,protect,signed",
        promo="Scan documents to PDF in seconds, recognize text with on-device OCR and sign anything. "
              "Private by design: no account, no cloud.",
        why="US: pdf signature L5 (D24), pdf signer L5 (D12), sign pdf free L6 (D17), sign pdf documents L6 (D24).",
    ),
    "zh-Hant": dict(
        markets="US (extra slot)", extra=True,
        name="{brand}: PDF Document Scanner",
        subtitle="Searchable Docs & Text Capture",
        keywords="recognition,recognize,extractor,words,letters,language,languages,offline,scanning,scanned",
        promo="Scan documents to PDF in seconds, recognize text with on-device OCR and sign anything. "
              "Private by design: no account, no cloud.",
        why="US: ocr text scanner L3 (D53), ocr scan L3 (D29), ocr pdf L3 (D31), ocr scanner L5 (D28).",
    ),
    # ---------- Native-language storefronts ----------
    "tr": dict(
        markets="TR",
        name="{brand}: PDF Belge Tarayıcı",
        subtitle="Tarama, OCR Metin Tanıma, İmza",
        keywords="scanner,tara,evrak,fiş,kimlik,fotoğraf,fotoğraftan,metne,resim,yazı,jpg,çeviri,şifre",
        promo="Belgeleri saniyeler içinde PDF olarak tarayın, cihaz üzerinde OCR ile metni tanıyın ve imzalayın. "
              "Hesap yok, bulut yok — tamamen gizli.",
        why="TR autocomplete: belge tarama L3 (D14), belge tarayıcı L3 (D7), ocr metin tarayıcı L3 (D4), "
            "tarayıcı L3, tarama L4, pdf tarayıcı L5 (D20), pdf imza L5 (D13), fotoğraftan metne (D1). "
            "English 'scanner' L2 / 'pdf scanner' L5 come from en-GB; 'scanner' kept here for 'scanner pdf' combos.",
    ),
    "ru": dict(
        markets="RU (+US)",
        name="{brand}: Сканер документов",
        subtitle="PDF, скан текста и подпись",
        keywords="сканирование,чек,фото,текст,jpg,конвертер,паспорт",
        promo="Сканируйте документы в PDF за секунды, распознавайте текст на устройстве и подписывайте. "
              "Без аккаунта и облака — всё остаётся у вас.",
        why="RU autocomplete: сканер документов L1 (D71), pdf сканер L2, сканер L2, подпись документов L4 (D34), "
            "скан документов L4, сканирование документов L4, pdf подпись L5 (D32), чек скан L1, скан текста с "
            "фото L6, скан текста L6 (D30). 'PDF Сканер документов' does not fit 30 with the brand → PDF moved "
            "to the subtitle (Apple combines words across name+subtitle+keywords).",
    ),
    "uk": dict(
        markets="UA (+RU)",
        name="{brand}: Сканер документів",
        subtitle="PDF, текст із фото, підпис",
        keywords="скан,сканування,чек,паспорт,jpg,конвертер,переклад",
        promo="Скануйте документи в PDF за секунди, розпізнавайте текст на пристрої та підписуйте. "
              "Без акаунта й хмари — усе лишається у вас.",
        why="RU storefront also indexes uk. No separate UA keyword study (not in the requested market list); "
            "words mirror the RU findings in Ukrainian.",
    ),
    "pt-BR": dict(
        markets="BR (+US)",
        name="{brand}: Escanear Documentos",
        subtitle="Digitalizar PDF, Assinar e OCR",
        keywords="scanner,documento,texto,imagem,foto,assinatura,recibo,nota,fiscal,rg,cnh,jpg,converter",
        promo="Digitalize documentos em PDF em segundos, reconheça texto com OCR no aparelho e assine. "
              "Sem conta e sem nuvem — tudo fica com você.",
        why="BR autocomplete: scanner L2 (D79), pdf scanner L2, digitalizar documentos pdf L2 (D52), escanear "
            "documentos L3 (D33), digitalizar L3, escanear L4, escanear documentos gratis L4 (D21), pdf scanner "
            "de documentos L5 (D8), escanear pdf L5 (D16), assinar pdf L5 (D33), escanear para pdf L10.",
    ),
    "es-MX": dict(
        markets="MX (+US)",
        name="{brand}: Escáner PDF y OCR",
        subtitle="Escanear documentos y firmar",
        keywords="escaner,scanner,fotos,texto,imagen,firma,recibo,factura,convertir,jpg,traducir,cámara,ine",
        promo="Escanea documentos a PDF en segundos, reconoce texto con OCR en tu iPhone y firma. "
              "Sin cuenta y sin nube: todo se queda contigo.",
        why="MX autocomplete: escaner pdf L2 (D52), scanner L2, pdf scanner L2, escanear documentos L2 (D57), "
            "escanear fotos L3 (D24), escanear L3 (D33), escáner documentos L4 (D31), ocr escaner de texto L5 "
            "(D30), escaner de documentos L5 (D20), escanear pdf L7 (D21), escanear fotos a pdf L7 (D21). "
            "Both spellings 'escáner' and 'escaner' appear as separate autocomplete terms, so both are indexed.",
    ),
    "de-DE": dict(
        markets="DE (+AT, CH)",
        name="{brand}: Dokumente Scannen",
        subtitle="PDF Scanner, OCR, Unterschrift",
        keywords="kassenbon,beleg,unterschreiben,erstellen,app,foto,bild,jpg,umwandeln,texterkennung,ausweis,scan",
        promo="Scanne Dokumente in Sekunden als PDF, erkenne Text per OCR direkt auf dem iPhone und unterschreibe. "
              "Kein Konto, keine Cloud – alles bleibt bei dir.",
        why="DE autocomplete: pdf scanner L2 (D74), scanner app L2, ocr scanner L3 (D70), dokumente scannen L3 "
            "(D64), kassenbon scanner app L3 (D25), unterschrift erstellen L3 (D29), scan to pdf L4, pdf "
            "unterschreiben L5 (D30), pdf zu bild L5, pdf in jpg umwandeln L5 (D39), unterschrift pdf L6 (D41).",
    ),
    "fr-FR": dict(
        markets="FR (+US, BE, CH)",
        name="{brand}: Scanner PDF Document",
        subtitle="Scan, OCR, Signature & Texte",
        keywords="numériser,image,photo,jpg,fichier,doc,reçu,facture,identité,carte,convertisseur,traduire,caméra",
        promo="Numérisez vos documents en PDF en quelques secondes, reconnaissez le texte par OCR sur l'iPhone "
              "et signez. Sans compte ni cloud.",
        why="FR autocomplete: scanner pdf L2 (D74), scan L2, ocr scanner L3 (D68), signature pdf L3 (D36), "
            "scanner L3, scan document L4 (D69), scan pdf L4, pdf jpg L5, scan texte L6 (D52), scan fichier L6 "
            "(D29), scan signature L6 (D45), image en texte L8 (D42). 'gratuit' terms excluded (pricing, 2.3.7).",
    ),
    "fr-CA": dict(
        markets="CA (with en-CA)",
        name="{brand}: Numériser Documents",
        subtitle="Scanneur PDF, OCR et signature",
        keywords="texte,image,photo,reçu,facture,carte,jpg,convertisseur,traduire,caméra,fichier,scan,numérisation",
        promo="Numérisez vos documents en PDF en quelques secondes, reconnaissez le texte par OCR sur l'iPhone "
              "et signez. Sans compte ni nuage.",
        why="CA French autocomplete returns 'numériser' and 'scanneur' (seed terms) plus 'scanner gratuit', "
            "'scan document gratuit', 'scanner document gratuit' (L5–L9). English core comes from en-CA.",
    ),
    "sv": dict(
        markets="SE",
        name="{brand}: Skanna dokument",
        subtitle="PDF skanner, OCR och signatur",
        keywords="skanning,bilder,bild,text,kvitto,id,kort,foto,kamera,jpg,konvertera,översätt,lösenord,fil",
        promo="Skanna dokument till PDF på några sekunder, känn igen text med OCR direkt i iPhone och signera. "
              "Inget konto, inget moln.",
        why="SE autocomplete: pdf scanner L2 (D55), scanner L2 (D67), ocr L3 (D43), skanna dokument L4 (D25), "
            "skanner L5 (D52), pdf signer L5 (D30), skanna bilder L5 (D38), ocr id L5 (D43), pdf fil L5. "
            "English core comes from en-GB.",
    ),
    "pl": dict(
        markets="PL",
        name="{brand}: Skaner dokumentów",
        subtitle="Skanuj PDF, tekst OCR, podpis",
        keywords="skanowanie,dokumenty,dokument,zdjęcia,zdjęcie,paragon,dowód,jpg,konwerter,faktura,hasło,skan",
        promo="Skanuj dokumenty do PDF w kilka sekund, rozpoznawaj tekst przez OCR na iPhonie i podpisuj. "
              "Bez konta i chmury — wszystko zostaje u Ciebie.",
        why="PL autocomplete: pdf scanner L2 (D65), scanner L2, ocr scanner L3 (D48), skaner L3 (D43), darmowy "
            "skaner pdf L4 (D9), skanuj dokumenty L5 (D17), skanuj L5, skanuj dokument L5 (D20), skanowanie L5 "
            "(D44), skaner pdf L5 (D34), pdf to jpg convert L5 (D18). English core comes from en-GB.",
    ),
    "nl-NL": dict(
        markets="NL",
        name="{brand}: Documenten Scannen",
        subtitle="PDF Scanner, OCR, Ondertekenen",
        keywords="scan,document,foto,tekst,bon,kassabon,handtekening,afbeelding,jpg,vertalen,wachtwoord,id",
        promo="Scan documenten in enkele seconden naar PDF, herken tekst met OCR op je iPhone en onderteken. "
              "Geen account, geen cloud — alles blijft bij jou.",
        why="NL autocomplete: pdf scanner L2 (D63), ocr scanner L3 (D38), document scanner L3, scanner L3, scan "
            "pdf L3, documenten scannen L4 (D57), document scannen L4, pdf to jpg L5 (D22), pdf sign L5, ocr text "
            "L5 (D28), foto naar pdf gratis L6 (D18), scan document L6. English core also comes from en-GB.",
    ),
    "ja": dict(
        markets="JP", localize_app=True,
        name="{brand}: 書類スキャン・PDFスキャナー",
        subtitle="写真から文字読み取り・OCR・署名",
        keywords="アプリ,カメラ,画像,変換,レシート,文書,テキスト,認識,翻訳,サイン,jpg",
        promo="書類を数秒でPDFにスキャン。端末内のOCRで文字を読み取り、署名もできます。アカウント不要、クラウド不要で安心。",
        why="JP autocomplete: 書類 スキャン 無料 L1 (D50), スキャン L2 (D64), pdf スキャン L2 (D53), スキャナー L2, "
            "ocr L2 (D50), 書類 スキャン pdf L2 (D28), スキャナー 無料 L4 (D31), 写真 スキャナー L4, スキャン アプリ L6, "
            "スキャン カメラ pdf L6, 文字 読み取り (D44). en-US is also indexed in JP ('pdf scanner' L5, D34).",
    ),
    "ko": dict(
        markets="KR (+US)", localize_app=True,
        name="{brand}: 문서 스캔·PDF 스캐너",
        subtitle="사진 텍스트 추출, 문자 인식 OCR",
        keywords="앱,서명,영수증,카메라,변환,이미지,jpg,번역,스캐너앱,스캔앱,전자서명",
        promo="문서를 몇 초 만에 PDF로 스캔하고, 기기 내 OCR로 텍스트를 추출하고, 서명하세요. 계정도 클라우드도 필요 없습니다.",
        why="KR autocomplete: 문서 스캔 L1 (D31), 텍스트 추출 L1 (D49), 스캐너 L2, 스캔 L2, pdf 스캔 L2, pdf scanner "
            "L2 (D24), 문서 스캔 무료 L2 (D16), 스캔 앱 L4 (D18), 사진 텍스트 추출 L4 (D8), pdf 서명 L5 (D19), 문자 인식 (D31).",
    ),
}

PENDING_NOTE = "Ma'lumot yig'ilmoqda"


def words(text: str) -> list[str]:
    text = text.replace("{brand}", BRAND).lower()
    return [w for w in re.split(r"[\s,:;&/·・\-–—!?.()]+", text) if w and w not in STOP]


def render(text: str) -> str:
    return text.replace("{brand}", BRAND)


def validate() -> list[str]:
    problems = []
    for loc, m in LOCALES.items():
        name, subtitle, keywords = render(m["name"]), render(m["subtitle"]), m["keywords"]
        if len(name) > 30:
            problems.append(f"{loc}: name {len(name)} > 30: {name}")
        if len(subtitle) > 30:
            problems.append(f"{loc}: subtitle {len(subtitle)} > 30: {subtitle}")
        if len(keywords.encode()) > 100:
            problems.append(f"{loc}: keywords {len(keywords.encode())} bytes > 100")
        if " ," in keywords or ", " in keywords:
            problems.append(f"{loc}: spaces around commas waste bytes")
        if len(m["promo"]) > 170:
            problems.append(f"{loc}: promo {len(m['promo'])} > 170")
        seen = words(name) + words(subtitle)
        for kw in keywords.split(","):
            for w in words(kw):
                if w in seen:
                    problems.append(f"{loc}: keyword '{w}' repeats name/subtitle or another keyword")
                seen.append(w)
        title_dupes = {w for w in words(name) if words(subtitle).count(w)}
        if title_dupes:
            problems.append(f"{loc}: subtitle repeats name words {sorted(title_dupes)}")
    return problems


def storefront_waste() -> dict[str, list[str]]:
    """Keyword-field words that repeat a word already indexed from another localization of the same storefront."""
    waste = {}
    for cc, locs in INDEX.items():
        present = [l for l in locs if l in LOCALES]
        for loc in present:
            others = set()
            for other in present:
                if other != loc:
                    m = LOCALES[other]
                    others |= set(words(m["name"]) + words(m["subtitle"]) + words(m["keywords"]))
            dupes = [w for w in words(LOCALES[loc]["keywords"]) if w in others]
            if dupes and LOCALES[loc].get("extra"):
                waste[f"{cc}/{loc}"] = dupes
    return waste


# Localizations without their own description file reuse one (descriptions are not indexed for search).
DESCRIPTION_FROM = {"en-AU": "en-US", "en-CA": "en-US", "ar-SA": "en-US", "vi": "en-US", "zh-Hans": "en-US",
                    "zh-Hant": "en-US", "fr-CA": "fr-FR"}
COPY_FILES = ["description.txt", "release_notes.txt", "privacy_url.txt", "support_url.txt", "promotional_text.txt"]


def rebrand(text: str) -> str:
    return text.replace(OLD_BRAND, BRAND).replace(OLD_BRAND.upper(), BRAND.upper())


def write_fastlane():
    for loc, m in LOCALES.items():
        folder = FASTLANE / loc
        if not folder.exists():
            folder.mkdir()
            source = FASTLANE / DESCRIPTION_FROM.get(loc, "en-US")
            for f in COPY_FILES:
                if (source / f).exists() and not (folder / f).exists():
                    (folder / f).write_text((source / f).read_text())
        (folder / "name.txt").write_text(render(m["name"]) + "\n")
        (folder / "subtitle.txt").write_text(render(m["subtitle"]) + "\n")
        (folder / "keywords.txt").write_text(m["keywords"] + "\n")
        (folder / "promotional_text.txt").write_text(m["promo"] + "\n")
    # Every localization (researched or not) gets the new brand.
    for folder in sorted(p for p in FASTLANE.iterdir() if p.is_dir() and p.name != "review_information"):
        for f in folder.glob("*.txt"):
            f.write_text(rebrand(f.read_text()))
        name = (folder / "name.txt").read_text().strip()
        if len(name) > 30:
            print("TOO LONG", folder.name, name)


def esc(text: str) -> str:
    return text.replace("|", "\\|")


def write_report():
    out = [f"# {BRAND} — App Store metadata (4-bosqich)", "",
           "> Har bir qator `tools/aso/metadata.py` da saqlanadi va Apple limitlari bo'yicha avtomatik tekshiriladi "
           "(nom ≤ 30, subtitle ≤ 30, keywords ≤ 100 bayt, promo ≤ 170, bir lokalizatsiya ichida so'z takrorlanmaydi). "
           "\"Asos\" ustunidagi raqamlar `docs/ASO-Research.md` jadvallaridan: **Lx** = Apple autocomplete bu so'zni "
           "x-harfdan keyin taklif qiladi (kichik = ko'p qidiriladi), **Dx** = qiyinlik 1–100, **Px** = Apple popularity.", "",
           f"**Brend:** `{BRAND}` — 2-bosqichda 174 do'konning birortasida aynan bir xil yoki o'xshash ilova yo'q, USPTO'da "
           f"yaqin faol belgi yo'q. `{OLD_BRAND}` band (55 do'konda aynan shu nomli ilova bor).", "",
           "## 1. Qaysi do'kon qaysi lokalizatsiyalarni indekslaydi (cross-localization)", "",
           "Manba: [Apple — App Store localizations](https://developer.apple.com/help/app-store-connect/reference/app-store-localizations)", "",
           "| Do'kon | Indekslanadigan lokalizatsiyalar | Jami kalit so'z joyi |", "|---|---|---|"]
    for cc, locs in INDEX.items():
        have = [l for l in locs if l in LOCALES]
        out.append(f"| {cc} | {', '.join(f'**{l}**' if l in LOCALES else l for l in locs)} | "
                   f"{len(have)} × (30+30+100) |")
    out += ["", "Qalin = bizda to'ldirilgan. en-GB bitta o'zi 13 ta asosiy bozorda qo'shimcha indekslanadi, shuning uchun "
            "unga inglizcha asosiy so'zlar qo'yildi (BR, MX, TR, KR, RU'da ham inglizcha \"scanner\", \"pdf scanner\" "
            "autocomplete'da birinchi 2 harfda chiqadi).", "",
            "## 2. Metadata (App Store Connect'ga kiritiladigan qiymatlar)", "",
            "| Lokalizatsiya | Bozor | App nomi (30) | Subtitle (30) | Keywords (100 bayt) | Uzunlik n/s/k |",
            "|---|---|---|---|---|---|"]
    for loc, m in LOCALES.items():
        name, sub = render(m["name"]), render(m["subtitle"])
        out.append(f"| `{loc}` | {m['markets']} | {esc(name)} | {esc(sub)} | `{m['keywords']}` | "
                   f"{len(name)}/{len(sub)}/{len(m['keywords'].encode())} |")
    out += ["", "## 3. Promotional text (170)", "", "| Lokalizatsiya | Matn | Uzunlik |", "|---|---|---|"]
    out += [f"| `{loc}` | {esc(m['promo'])} | {len(m['promo'])} |" for loc, m in LOCALES.items()]
    out += ["", "## 4. Har bir tanlovning asosi", "", "| Lokalizatsiya | Asos (ma'lumot) |", "|---|---|"]
    out += [f"| `{loc}` | {esc(m['why'])} |" for loc, m in LOCALES.items()]
    others = sorted(p.name for p in FASTLANE.iterdir() if p.is_dir() and p.name not in LOCALES
                    and p.name != "review_information")
    out += ["", "## 5. Description", "",
            "Apple description matnini qidiruvda indekslamaydi, shuning uchun u konversiya uchun yozilgan: "
            "`fastlane/metadata/<locale>/description.txt` (har bir tilda alohida). Yangi lokalizatsiyalar "
            f"({', '.join(DESCRIPTION_FROM)}) mos tildagi matndan nusxa oladi.", "",
            "## 6. Tadqiq qilinmagan, lekin mavjud lokalizatsiyalar", "",
            "Quyidagilar ilova tiliga mos ravishda saqlanib qoldi, faqat brend yangilandi; ular uchun alohida keyword "
            f"tadqiqoti qilinmagan: {', '.join(f'`{o}`' for o in others)}.", "",
            "## 7. Ilova lokalizatsiyasi bo'yicha tavsiya", "",
            "| Bozor | Do'kon tili | Ilova shu tilda | Tavsiya |", "|---|---|---|---|"]
    for loc, m in LOCALES.items():
        if m.get("localize_app"):
            out.append(f"| {m['markets']} | {loc} | ❌ | Ilova interfeysini {loc} ga tarjima qilish (metadata tayyor) |")
    OUT.write_text("\n".join(out) + "\n")
    print("written", OUT)


if __name__ == "__main__":
    issues = validate()
    print("\n".join(issues) or "OK: all limits and duplicate rules pass")
    for key, dupes in storefront_waste().items():
        print("cross-localization repeat", key, dupes)
    if "--check" in sys.argv or issues:
        sys.exit(1 if issues else 0)
    write_fastlane()
    write_report()
