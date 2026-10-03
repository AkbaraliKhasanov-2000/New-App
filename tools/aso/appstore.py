"""Free, public App Store data sources with caching and polite rate limiting.

Sources (all free, no account):
  1. iTunes Search API      https://itunes.apple.com/search , /lookup
     → app metadata: name, developer, rating, rating count, price, genre, release date.
     → candidate list for a term (max 200 results; NOT the App Store search order).
  2. App Store search hints https://search.itunes.apple.com/WebObjects/MZSearchHints.woa/wa/hints
     → the autocomplete suggestions Apple shows while typing, per storefront,
       ordered by Apple. Used as a popularity proxy (see keywords.py).
  3. App Store web search   https://apps.apple.com/<cc>/iphone/search?term=…
     → the real, ordered iPhone search results Apple serves for a term in a storefront
       (server-rendered JSON), i.e. the true top-10 competitors.

Every response is cached in tools/aso/.cache so re-runs are free and reproducible.
"""
from __future__ import annotations

import hashlib
import json
import os
import re
import ssl
import time
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path

HERE = Path(__file__).resolve().parent
CACHE = HERE / ".cache"
CACHE.mkdir(exist_ok=True)
STOREFRONT_IDS: dict[str, int] = json.loads((HERE / "data/storefront_ids.json").read_text())

_CA = "/root/.ccr/ca-bundle.crt"
_CTX = ssl.create_default_context(cafile=_CA) if os.path.exists(_CA) else ssl.create_default_context()
_UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_0) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
_last_call: dict[str, float] = {}
# Minimum seconds between requests per host (iTunes Search API documents ~20 requests/minute).
_MIN_INTERVAL = {"itunes.apple.com": 3.1, "search.itunes.apple.com": 0.6, "apps.apple.com": 1.2}


def _fetch(url: str, headers: dict | None = None, retries: int = 6) -> bytes:
    key = hashlib.sha1((url + json.dumps(headers or {}, sort_keys=True)).encode()).hexdigest()
    path = CACHE / key
    if path.exists():
        return path.read_bytes()

    host = urllib.parse.urlparse(url).hostname or ""
    for attempt in range(retries):
        wait = _MIN_INTERVAL.get(host, 1.0) - (time.time() - _last_call.get(host, 0))
        if wait > 0:
            time.sleep(wait)
        _last_call[host] = time.time()
        request = urllib.request.Request(url, headers={"User-Agent": _UA, **(headers or {})})
        try:
            with urllib.request.urlopen(request, context=_CTX, timeout=40) as response:
                body = response.read()
            path.write_bytes(body)
            return body
        except urllib.error.HTTPError as error:
            if error.code in (403, 429, 500, 502, 503, 504):
                time.sleep(min(120, 5 * 2 ** attempt))
                continue
            if error.code in (400, 404):
                path.write_bytes(b"")
                return b""
            raise
        except (urllib.error.URLError, TimeoutError, ConnectionError):
            time.sleep(min(60, 3 * 2 ** attempt))
    raise RuntimeError(f"giving up on {url}")


# ---------------------------------------------------------------- iTunes Search API

def itunes_search(term: str, country: str, limit: int = 200, lang: str | None = None) -> list[dict]:
    params = {"term": term, "country": country, "entity": "software", "limit": limit}
    if lang:
        params["lang"] = lang
    body = _fetch("https://itunes.apple.com/search?" + urllib.parse.urlencode(params))
    if not body.strip():
        return []
    try:
        return json.loads(body).get("results", [])
    except json.JSONDecodeError:
        return []


def itunes_lookup(ids: list[int | str], country: str) -> dict[str, dict]:
    out: dict[str, dict] = {}
    for start in range(0, len(ids), 100):
        chunk = ",".join(str(i) for i in ids[start:start + 100])
        body = _fetch(f"https://itunes.apple.com/lookup?id={chunk}&country={country}&entity=software")
        if body.strip():
            for app in json.loads(body).get("results", []):
                out[str(app.get("trackId"))] = app
    return out


def storefront_exists(country: str) -> bool:
    """A country code is a live App Store storefront if the Search API accepts it."""
    body = _fetch("https://itunes.apple.com/search?" + urllib.parse.urlencode(
        {"term": "calculator", "country": country, "entity": "software", "limit": 1}))
    if not body.strip():
        return False
    try:
        return json.loads(body).get("resultCount", 0) > 0
    except json.JSONDecodeError:
        return False


# ---------------------------------------------------------------- Search hints (autocomplete)

def hints(prefix: str, country: str) -> list[str]:
    sf = STOREFRONT_IDS.get(country.upper())
    if sf is None:
        raise KeyError(f"no storefront id for {country}")
    url = ("https://search.itunes.apple.com/WebObjects/MZSearchHints.woa/wa/hints?"
           + urllib.parse.urlencode({"clientApplication": "Software", "term": prefix}))
    body = _fetch(url, {"X-Apple-Store-Front": f"{sf}-1,29"})
    if not body.strip():
        return []
    try:
        root = ET.fromstring(body)
    except ET.ParseError:
        return []
    terms = []
    for d in root.iter("dict"):
        children = list(d)
        for i, el in enumerate(children[:-1]):
            if el.tag == "key" and el.text == "term" and children[i + 1].tag == "string":
                terms.append(children[i + 1].text or "")
    return terms


# ---------------------------------------------------------------- Real App Store search order

def search_ranking(term: str, country: str) -> list[dict]:
    """Ordered organic iPhone search results (apps only, editorial cards removed)."""
    url = f"https://apps.apple.com/{country.lower()}/iphone/search?" + urllib.parse.urlencode({"term": term})
    body = _fetch(url).decode("utf-8", "replace")
    match = re.search(r'id="serialized-server-data">(.*?)</script>', body, re.S)
    if not match:
        return []
    data = json.loads(match.group(1))
    results = []
    try:
        shelves = data["data"][0]["data"]["shelves"]
    except (KeyError, IndexError, TypeError):
        return []
    for shelf in shelves:
        for item in shelf.get("items", []):
            fields = (item.get("impressionMetrics") or {}).get("fields") or {}
            kind = item.get("$kind", "")
            if "Editorial" in kind:
                continue
            app_id = None
            if fields.get("kind") == "inAppEvent":
                related = fields.get("relatedSubjectIds") or []
                app_id = related[0] if related else None
            elif fields.get("idType") == "its_id":
                app_id = fields.get("id")
            lockup = item.get("lockup") or {}
            app_id = app_id or lockup.get("adamId")
            title = (item.get("clickAction") or {}).get("title") or lockup.get("title") or fields.get("name")
            if app_id and str(app_id).isdigit() and all(r["id"] != str(app_id) for r in results):
                results.append({"id": str(app_id), "name": title})
    return results
