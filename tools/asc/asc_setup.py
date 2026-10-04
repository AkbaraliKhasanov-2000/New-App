"""App Store Connect setup through the official API (api.appstoreconnect.apple.com/v1).

What the API can and cannot do:
  ✅ register the bundle ID                      (POST /v1/bundleIds)
  ❌ create the app record itself                 (Apple has no POST /v1/apps — done once in the web UI)
  ✅ subscription group, both subscriptions, localizations, prices in every territory,
     availability and the 3-day free trial         (subscription* resources)
  ✅ name/subtitle/keywords/description/promo     (fastlane deliver, see fastlane/Deliverfile)

Credentials (never committed): ASC_KEY_ID, ASC_ISSUER_ID and ASC_KEY_P8 (the .p8 text) or ASC_KEY_PATH.

  pip install pyjwt cryptography requests
  python3 tools/asc/asc_setup.py status          # what exists, what is missing (read-only)
  python3 tools/asc/asc_setup.py bundle          # register com.scanlet.app if missing
  python3 tools/asc/asc_setup.py subscriptions   # create/complete Scanmuse Pro (idempotent)
"""
from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path

import jwt
import requests

API = "https://api.appstoreconnect.apple.com/v1"
ROOT = Path(__file__).resolve().parents[2]
STOREKIT = json.loads((ROOT / "Scanlet/Resources/Products.storekit").read_text())

BUNDLE_ID = "com.scanlet.app"
APP_NAME = "Scanmuse: PDF Document Scanner"
GROUP_NAME = STOREKIT["subscriptionGroups"][0]["name"]          # "Scanmuse Pro"
PERIODS = {"P1W": "ONE_WEEK", "P1M": "ONE_MONTH"}
TRIAL = {"P3D": "THREE_DAYS", "P1W": "ONE_WEEK"}


def token() -> str:
    key = os.environ.get("ASC_KEY_P8") or Path(os.environ["ASC_KEY_PATH"]).read_text()
    now = int(time.time())
    return jwt.encode({"iss": os.environ["ASC_ISSUER_ID"], "iat": now, "exp": now + 1200,
                       "aud": "appstoreconnect-v1"}, key, algorithm="ES256",
                      headers={"kid": os.environ["ASC_KEY_ID"], "typ": "JWT"})


SESSION = requests.Session()


def call(method: str, path: str, body: dict | None = None, **params) -> dict:
    url = path if path.startswith("http") else API + path
    for attempt in range(5):
        r = SESSION.request(method, url, json=body, params=params or None,
                            headers={"Authorization": f"Bearer {token()}"}, timeout=60)
        if r.status_code == 429 or r.status_code >= 500:
            time.sleep(2 ** attempt)
            continue
        if r.status_code >= 400:
            raise SystemExit(f"{method} {path} → {r.status_code}\n{r.text[:1500]}")
        return r.json() if r.content else {}
    raise SystemExit(f"{method} {path}: gave up after retries")


def all_pages(path: str, **params) -> list[dict]:
    out, data = [], call("GET", path, **params)
    while True:
        out += data["data"]
        nxt = data.get("links", {}).get("next")
        if not nxt:
            return out
        data = call("GET", nxt)


def find_bundle():
    data = call("GET", "/bundleIds", **{"filter[identifier]": BUNDLE_ID})["data"]
    return next((b for b in data if b["attributes"]["identifier"] == BUNDLE_ID), None)


def find_app():
    data = call("GET", "/apps", **{"filter[bundleId]": BUNDLE_ID})["data"]
    return data[0] if data else None


def bundle():
    existing = find_bundle()
    if existing:
        print("bundle ID exists:", BUNDLE_ID)
        return existing
    created = call("POST", "/bundleIds", {"data": {"type": "bundleIds", "attributes": {
        "identifier": BUNDLE_ID, "name": "Scanmuse", "platform": "IOS"}}})["data"]
    print("bundle ID registered:", BUNDLE_ID)
    return created


def status():
    print("bundle ID:", "✅" if find_bundle() else "❌ missing (run: bundle)")
    app = find_app()
    if not app:
        print("app record: ❌ missing — create it once in App Store Connect → Apps → + → New App "
              "(see docs/ASC-Setup.md)")
        return
    print("app record: ✅", app["attributes"]["name"], app["id"], "primary locale", app["attributes"]["primaryLocale"])
    groups = all_pages(f"/apps/{app['id']}/subscriptionGroups", include="subscriptions")
    for g in groups:
        subs = all_pages(f"/subscriptionGroups/{g['id']}/subscriptions")
        print("  group", g["attributes"]["referenceName"], "→",
              [(s["attributes"]["productId"], s["attributes"]["state"]) for s in subs])
    if not groups:
        print("  subscriptions: ❌ none (run: subscriptions)")


def ensure_group(app_id: str) -> dict:
    for g in all_pages(f"/apps/{app_id}/subscriptionGroups"):
        if g["attributes"]["referenceName"] == GROUP_NAME:
            return g
    g = call("POST", "/subscriptionGroups", {"data": {"type": "subscriptionGroups",
             "attributes": {"referenceName": GROUP_NAME},
             "relationships": {"app": {"data": {"type": "apps", "id": app_id}}}}})["data"]
    call("POST", "/subscriptionGroupLocalizations", {"data": {"type": "subscriptionGroupLocalizations",
         "attributes": {"locale": "en-US", "name": GROUP_NAME},
         "relationships": {"subscriptionGroup": {"data": {"type": "subscriptionGroups", "id": g["id"]}}}}})
    print("group created:", GROUP_NAME)
    return g


def ensure_subscription(group_id: str, spec: dict, level: int) -> dict:
    for s in all_pages(f"/subscriptionGroups/{group_id}/subscriptions"):
        if s["attributes"]["productId"] == spec["productID"]:
            return s
    s = call("POST", "/subscriptions", {"data": {"type": "subscriptions", "attributes": {
        "name": spec["referenceName"], "productId": spec["productID"], "familySharable": False,
        "subscriptionPeriod": PERIODS[spec["recurringSubscriptionPeriod"]], "groupLevel": level},
        "relationships": {"group": {"data": {"type": "subscriptionGroups", "id": group_id}}}}})["data"]
    for loc in spec["localizations"]:
        call("POST", "/subscriptionLocalizations", {"data": {"type": "subscriptionLocalizations",
             "attributes": {"locale": loc["locale"].replace("_", "-"), "name": loc["displayName"],
                            "description": loc["description"]},
             "relationships": {"subscription": {"data": {"type": "subscriptions", "id": s["id"]}}}}})
    print("subscription created:", spec["productID"])
    return s


def ensure_prices(sub: dict, usd: str) -> list[str]:
    """US price + Apple's equalized price in every other territory. Returns territory ids."""
    if call("GET", f"/subscriptions/{sub['id']}/prices", limit=1)["data"]:
        print("  prices already set")
        return [t["id"] for t in all_pages("/territories", limit=200)]
    points = all_pages(f"/subscriptions/{sub['id']}/pricePoints", **{"filter[territory]": "USA", "limit": 200})
    usa = next(p for p in points if p["attributes"]["customerPrice"] == usd)
    equal = all_pages(f"/subscriptionPricePoints/{usa['id']}/equalizations", include="territory", limit=200)
    territories = ["USA"]
    for point in [usa] + equal:
        territory = point["relationships"]["territory"]["data"]["id"] if point is not usa else "USA"
        call("POST", "/subscriptionPrices", {"data": {"type": "subscriptionPrices",
             "attributes": {"preserveCurrentPrice": False},
             "relationships": {"subscription": {"data": {"type": "subscriptions", "id": sub["id"]}},
                               "subscriptionPricePoint": {"data": {"type": "subscriptionPricePoints", "id": point["id"]}},
                               "territory": {"data": {"type": "territories", "id": territory}}}}})
        if point is not usa:
            territories.append(territory)
    print(f"  prices set: ${usd} in USA + {len(territories) - 1} equalized territories")
    return territories


def ensure_availability(sub: dict, territories: list[str]):
    try:
        if call("GET", f"/subscriptions/{sub['id']}/subscriptionAvailability").get("data"):
            return
    except SystemExit:
        pass
    call("POST", "/subscriptionAvailabilities", {"data": {"type": "subscriptionAvailabilities",
         "attributes": {"availableInNewTerritories": True},
         "relationships": {"subscription": {"data": {"type": "subscriptions", "id": sub["id"]}},
                           "availableTerritories": {"data": [{"type": "territories", "id": t} for t in territories]}}}})
    print("  available in", len(territories), "territories")


def ensure_trial(sub: dict, spec: dict, territories: list[str]):
    offer = spec.get("introductoryOffer")
    if not offer or offer.get("paymentMode") != "free":
        return
    if call("GET", f"/subscriptions/{sub['id']}/introductoryOffers", limit=1)["data"]:
        print("  free trial already set")
        return
    for t in territories:
        call("POST", "/subscriptionIntroductoryOffers", {"data": {"type": "subscriptionIntroductoryOffers",
             "attributes": {"duration": TRIAL[offer["subscriptionPeriod"]], "offerMode": "FREE_TRIAL",
                            "numberOfPeriods": offer["numberOfPeriods"]},
             "relationships": {"subscription": {"data": {"type": "subscriptions", "id": sub["id"]}},
                               "territory": {"data": {"type": "territories", "id": t}}}}})
    print("  3-day free trial in", len(territories), "territories")


def subscriptions():
    app = find_app()
    if not app:
        raise SystemExit("App record is missing. Create it in App Store Connect first (docs/ASC-Setup.md).")
    group = ensure_group(app["id"])
    for level, spec in enumerate(STOREKIT["subscriptionGroups"][0]["subscriptions"], start=1):
        sub = ensure_subscription(group["id"], spec, level)
        territories = ensure_prices(sub, spec["displayPrice"])
        ensure_availability(sub, territories)
        ensure_trial(sub, spec, territories)
    print("Done. Still manual in the web UI: a review screenshot per subscription, then submit them "
          "together with the first app version.")


if __name__ == "__main__":
    {"status": status, "bundle": bundle, "subscriptions": subscriptions}[sys.argv[1] if len(sys.argv) > 1 else "status"]()
