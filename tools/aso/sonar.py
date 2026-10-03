"""Apple Search Ads popularity (5–100) via Sonar's free keyless API (https://trysonar.app/aso-api).

Free tier: a few keyword metrics per IP per day — used only to CALIBRATE the free
Autocomplete Index against Apple's own popularity. Results are stored permanently in
data/sonar/<cc>.json so they are never requested twice. Stops at the first rate-limit.
"""
import json
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

import appstore

DIR = Path(__file__).resolve().parent / "data/sonar"
DIR.mkdir(parents=True, exist_ok=True)


def load(cc: str) -> dict:
    path = DIR / f"{cc.lower()}.json"
    return json.loads(path.read_text()) if path.exists() else {}


def fetch(terms: list[str], cc: str) -> dict:
    store = load(cc)
    for term in terms:
        if term in store:
            continue
        url = "https://trysonar.app/api/v1/keywords/metrics?" + urllib.parse.urlencode(
            {"q": term, "country": cc.lower(), "store": "ios"})
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": "scanlet-aso/1.0"}),
                                        context=appstore._CTX, timeout=60) as response:
                data = json.load(response)["data"]
        except urllib.error.HTTPError as error:
            print("sonar stopped:", error.code, error.read()[:200])
            break
        store[term] = {k: data.get(k) for k in ("popularity", "popularity_source", "difficulty", "results_count")}
        store[term]["fetched"] = time.strftime("%Y-%m-%d")
        (DIR / f"{cc.lower()}.json").write_text(json.dumps(store, indent=1, ensure_ascii=False))
        print(cc, term, store[term], flush=True)
        time.sleep(2.5)
    return store


if __name__ == "__main__":
    cc = sys.argv[1]
    fetch(sys.argv[2:], cc)
