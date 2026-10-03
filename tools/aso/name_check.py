"""Name uniqueness check across every live App Store storefront + USPTO trademarks.

For each candidate brand and each storefront:
  • iTunes Search API (term = brand, 50 results) → app titles in that storefront
  • the brand part of every title (text before ":" "-" "–" "|") is compared with the candidate:
        exact      → identical brand (case/diacritics-insensitive)
        similar    → difflib ratio ≥ 0.75, or edit distance ≤ 1 (≤ 2 for names > 8 letters),
                     or one brand starts with the other; plain dictionary words are ignored
USPTO (tmsearch.uspto.gov public search backend): live marks with the same/similar word mark
in IC 009 (software) or IC 042 (SaaS) → trademark risk.

Verdict per name:
  band   (taken)  – an app with the identical brand exists in any storefront, or a live US mark in IC 009/042 is identical
  xavfli (risky)  – similar app brands or similar live marks exist
  toza   (clean)  – none of the above
Output: data/name_check.json and data/name_check.md
"""
from __future__ import annotations

import difflib
import json
import re
import sys
import unicodedata
import urllib.request
from pathlib import Path

import appstore

HERE = Path(__file__).resolve().parent
CANDIDATES = [
    "Scanlet", "Scanova", "Pagelet", "Docuvia", "Inkwise", "Paperlark", "Scanbird", "Pagefold",
    "Lumipage", "Docsmith", "Scanvault", "Papyro", "Scanmuse", "Clearleaf", "Scanfinch",
    "Docnest", "Pagewise", "Scanaro", "Folioscan", "Quillscan",
]
TITLE_SUFFIX = ": PDF Scanner & OCR"
SPLIT = re.compile(r"\s*[:\-–—|·•(]\s*")
# Dictionary words are not brands: "Scanner App" does not conflict with "Scanlet".
GENERIC = {
    "scan", "scans", "scanner", "scanners", "scanning", "scanned", "scanit", "scanapp", "skanner", "skanna",
    "escaner", "escanear", "page", "pages", "paper", "papers", "doc", "docs", "document", "documents",
    "pdf", "notes", "note", "folio", "ink", "leaf", "nest", "vault", "bird", "smith", "wise", "muse",
}


def norm(text: str) -> str:
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]", "", text.lower())


def edit_distance(a: str, b: str) -> int:
    prev = list(range(len(b) + 1))
    for i, ca in enumerate(a, 1):
        cur = [i]
        for j, cb in enumerate(b, 1):
            cur.append(min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (ca != cb)))
        prev = cur
    return prev[-1]


def compare(candidate: str, title: str) -> str | None:
    brand = norm(SPLIT.split(title.strip())[0])
    cand = norm(candidate)
    if not brand:
        return None
    if brand == cand:
        return "exact"
    first_word = norm(title.split()[0]) if title.split() else ""
    for b in {brand, first_word}:
        if not b or b in GENERIC:
            continue
        if b == cand:
            return "exact"
        ratio = difflib.SequenceMatcher(None, cand, b).ratio()
        if ratio >= 0.75 or edit_distance(cand, b) <= (1 if len(cand) <= 8 else 2) or (
                len(b) >= 6 and (b.startswith(cand) or cand.startswith(b))):
            return "similar"
    return None


def uspto(candidate: str) -> list[dict]:
    query = {
        "query": {"bool": {"should": [
            {"match_phrase": {"wordmark": {"query": candidate, "boost": 5}}},
            {"fuzzy": {"wordmark": {"value": candidate.lower(), "fuzziness": 2}}},
        ]}},
        "size": 50,
        "_source": ["wordmark", "alive", "ownerName", "internationalClass", "statusCode", "id"],
    }
    request = urllib.request.Request(
        "https://tmsearch.uspto.gov/prod-stage-v1-0-0/tmsearch",
        data=json.dumps(query).encode(), headers={"Content-Type": "application/json", "User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(request, context=appstore._CTX, timeout=40) as response:
        hits = json.load(response)["hits"]["hits"]
    marks = []
    for hit in hits:
        source = hit["source"]
        word = source.get("wordmark") or ""
        classes = source.get("internationalClass") or []
        marks.append({
            "serial": source.get("id"), "wordmark": word, "alive": bool(source.get("alive")),
            "classes": classes, "owner": (source.get("ownerName") or [""])[0],
            "software": any(c in ("IC 009", "IC 042") for c in classes),
            "match": "exact" if norm(word) == norm(candidate) else ("similar" if compare(candidate, word) else None),
        })
    return [m for m in marks if m["match"]]


def main(storefront_codes: list[str]):
    results = {}
    out_path = HERE / "data/name_check.json"
    if out_path.exists():
        results = json.loads(out_path.read_text())
    for name in CANDIDATES:
        entry = results.get(name) or {"name": name, "titleLength": len(name + TITLE_SUFFIX), "apps": {}, "marks": None}
        entry["marks"] = entry["marks"] if entry["marks"] is not None else uspto(name)
        for cc in storefront_codes:
            if cc in entry["apps"]:
                continue
            hits = []
            for app in appstore.itunes_search(name, cc.lower(), limit=50):
                kind = compare(name, app.get("trackName", ""))
                if kind:
                    hits.append({"kind": kind, "id": app["trackId"], "title": app["trackName"],
                                 "seller": app.get("sellerName"), "ratings": app.get("userRatingCount", 0)})
            entry["apps"][cc] = hits
            results[name] = entry
            out_path.write_text(json.dumps(results, indent=1, ensure_ascii=False))
        print(name, "done", flush=True)
    write_report(results, storefront_codes)


def verdict(entry) -> tuple[str, str]:
    exact = {(h["id"], h["title"]) for hits in entry["apps"].values() for h in hits if h["kind"] == "exact"}
    similar = {(h["id"], h["title"]) for hits in entry["apps"].values() for h in hits if h["kind"] == "similar"}
    live_soft = [m for m in entry["marks"] if m["alive"] and m["software"]]
    if exact or any(m["match"] == "exact" for m in live_soft):
        reason = "; ".join(sorted({t for _, t in exact})[:3]) or "USPTO: " + ", ".join(m["wordmark"] for m in live_soft if m["match"] == "exact")
        return "band", reason
    if similar or live_soft:
        parts = sorted({t for _, t in similar})[:3] + [f"TM {m['wordmark']} ({'/'.join(m['classes'])})" for m in live_soft][:2]
        return "xavfli", "; ".join(parts)
    return "toza", "—"


def write_report(results, storefront_codes):
    lines = [
        f"| Nom | {TITLE_SUFFIX.strip(': ')} bilan uzunlik | Aynan bir xil (do'konlar) | O'xshash (do'konlar) | USPTO faol (9/42-sinf) | Xulosa | Sabab |",
        "|---|---|---|---|---|---|---|",
    ]
    for name in CANDIDATES:
        entry = results.get(name)
        if not entry:
            continue
        exact_sf = sorted(cc for cc, hits in entry["apps"].items() if any(h["kind"] == "exact" for h in hits))
        similar_sf = sorted(cc for cc, hits in entry["apps"].items() if any(h["kind"] == "similar" for h in hits))
        live = [m for m in entry["marks"] if m["alive"] and m["software"]]
        status, reason = verdict(entry)
        lines.append(f"| **{name}** | {entry['titleLength']}/30 | {len(exact_sf)} | {len(similar_sf)} | {len(live)} | "
                     f"{ {'toza': '✅ toza', 'xavfli': '⚠️ xavfli', 'band': '❌ band'}[status] } | {reason} |")
    lines.append(f"\nTekshirilgan do'konlar: {len(storefront_codes)}.")
    (HERE / "data/name_check.md").write_text("\n".join(lines) + "\n")


if __name__ == "__main__":
    storefronts = [s["code"] for s in json.loads((HERE / "data/storefronts.json").read_text())]
    if len(sys.argv) > 1:
        storefronts = sys.argv[1:]
    main(storefronts)
