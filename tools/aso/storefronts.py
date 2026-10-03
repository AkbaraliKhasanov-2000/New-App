"""Finds every live App Store storefront by probing all ISO-3166 country codes
against the iTunes Search API. Output: data/storefronts.json"""
import json
from pathlib import Path

import pycountry

import appstore

if __name__ == "__main__":
    live = []
    for country in sorted(pycountry.countries, key=lambda c: c.alpha_2):
        if appstore.storefront_exists(country.alpha_2.lower()):
            live.append({"code": country.alpha_2, "name": country.name,
                         "storefrontId": appstore.STOREFRONT_IDS.get(country.alpha_2)})
            print(country.alpha_2, flush=True)
    out = Path(__file__).parent / "data/storefronts.json"
    out.write_text(json.dumps(live, indent=1, ensure_ascii=False))
    print(f"{len(live)} live storefronts")
