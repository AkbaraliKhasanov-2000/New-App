"""Keyword research per market, from free App Store data only.

Stages (each resumable thanks to the request cache):
  python3 keywords.py collect   – candidates from App Store autocomplete (seed, seed+" ", seed+" a…z")
  python3 keywords.py measure   – autocomplete index + real top-10 search results per keyword
  python3 keywords.py itunes    – rating counts of the top-10 apps + result counts (iTunes Search API)
  python3 keywords.py report    – data/keywords_<CC>.json + data/keywords.md

Metrics (all reproducible from tools/aso/.cache):
  ACI  Autocomplete Index 5–100 (popularity proxy). Apple orders search hints by search
       volume. The fewer letters needed before Apple suggests the full term, and the higher
       it ranks there, the more people search it:
           ACI = 100 · (1 − (n − 1) / L) · (1 − 0.05 · r)      (min 5)
       n = letters typed when the term first appears, L = term length, r = its 0-based rank.
       Terms Apple never suggests get 5 (the same floor Apple uses for its own popularity).
  DIF  Difficulty 1–100 from the real top-10 (App Store web search, same order as the app):
           DIF = 0.7 · min(100, 100 · median(log10(1 + ratings)) / 6) + 0.3 · 100 · titleMatchShare
       ratings = rating count in that storefront (iTunes lookup); titleMatchShare = share of the
       top-10 whose title contains every word of the term.
  APPS Number of apps the iTunes Search API returns for the term (capped at 200 by Apple).
  REL  Relevance 0–3 (rules in markets.py).
  POP  Apple Search Ads popularity 5–100 where available (Sonar free tier, calibration only).
"""
from __future__ import annotations

import json
import math
import statistics
import string
import sys
from pathlib import Path

import appstore
from markets import MARKETS, relevance

HERE = Path(__file__).resolve().parent
DATA = HERE / "data"
MAX_KEYWORDS_PER_MARKET = 45
ALPHABETS = {
    "ja": [], "ko": [],  # suggestions for CJK seeds come from the seeds themselves
    "ru": list("абвгдежзиклмнопрстуфхцчшэюя"),
}


def candidates_path(cc):
    return DATA / f"candidates_{cc}.json"


def collect(cc: str):
    lang, _, seeds = MARKETS[cc]
    found: dict[str, dict] = {}
    letters = ALPHABETS.get(lang, list(string.ascii_lowercase))
    for seed in seeds:
        prefixes = [seed, seed + " "] + ([seed + " " + ch for ch in letters] if len(seed.split()) <= 2 else [])
        for prefix in prefixes:
            for rank, term in enumerate(appstore.hints(prefix, cc)):
                term = term.strip().lower()
                if not term or term in found:
                    continue
                found[term] = {"term": term, "seed": seed, "relevance": relevance(term)}
        found.setdefault(seed.lower(), {"term": seed.lower(), "seed": seed, "relevance": relevance(seed)})
    candidates = sorted((c for c in found.values() if c["relevance"] > 0), key=lambda c: (-c["relevance"], c["term"]))
    candidates_path(cc).write_text(json.dumps(candidates, indent=1, ensure_ascii=False))
    print(cc, "candidates:", len(candidates), "of", len(found), flush=True)


def autocomplete_index(term: str, cc: str) -> dict:
    length = len(term)
    for n in range(1, length + 1):
        prefix = term[:n]
        if prefix.endswith(" "):
            continue
        suggestions = [s.strip().lower() for s in appstore.hints(prefix, cc)]
        if term in suggestions:
            rank = suggestions.index(term)
            score = 100 * (1 - (n - 1) / length) * (1 - 0.05 * rank)
            return {"aci": max(5, round(score)), "letters": n, "rank": rank + 1}
    return {"aci": 5, "letters": None, "rank": None}


def measure(cc: str):
    candidates = json.loads(candidates_path(cc).read_text())
    for c in candidates:
        if "aci" not in c:
            c.update(autocomplete_index(c["term"], cc))
    # Keep the most promising terms for the expensive steps.
    candidates.sort(key=lambda c: (-(c["relevance"] >= 2), -c["aci"]))
    selected = candidates[:MAX_KEYWORDS_PER_MARKET]
    for c in selected:
        if "top10" not in c:
            c["top10"] = appstore.search_ranking(c["term"], cc)[:10]
    for c in candidates:
        c["selected"] = c in selected
    candidates_path(cc).write_text(json.dumps(candidates, indent=1, ensure_ascii=False))
    print(cc, "measured", len(selected), flush=True)


def itunes(cc: str):
    candidates = json.loads(candidates_path(cc).read_text())
    selected = [c for c in candidates if c.get("selected")]
    ids = sorted({a["id"] for c in selected for a in c.get("top10", [])})
    details = appstore.itunes_lookup(ids, cc.lower())
    for c in selected:
        for a in c.get("top10", []):
            info = details.get(a["id"], {})
            a["ratings"] = info.get("userRatingCount", 0)
            a["rating"] = round(info.get("averageUserRating", 0) or 0, 2)
            a["seller"] = info.get("sellerName")
        if "apps" not in c:
            c["apps"] = len(appstore.itunes_search(c["term"], cc.lower(), limit=200))
        c["dif"] = difficulty(c)
    candidates_path(cc).write_text(json.dumps(candidates, indent=1, ensure_ascii=False))
    print(cc, "itunes done", flush=True)


def difficulty(c) -> int | None:
    top = c.get("top10") or []
    if not top:
        return None
    logs = [math.log10(1 + a.get("ratings", 0)) for a in top]
    strength = min(100, 100 * statistics.median(logs) / 6)
    words = [w for w in c["term"].split() if w]
    matches = sum(all(w in (a.get("name") or "").lower() for w in words) for a in top) / len(top)
    return max(1, round(0.7 * strength + 0.3 * 100 * matches))


def run(stage: str, markets: list[str]):
    for cc in markets:
        try:
            {"collect": collect, "measure": measure, "itunes": itunes}[stage](cc)
        except Exception as error:  # keep going; the cache makes reruns cheap
            print(cc, stage, "ERROR", error, flush=True)


if __name__ == "__main__":
    stage = sys.argv[1]
    markets = sys.argv[2:] or list(MARKETS)
    run(stage, markets)
