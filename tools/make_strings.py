#!/usr/bin/env python3
"""Builds Scanlet/Resources/Localizable.xcstrings and InfoPlist.xcstrings
from tools/i18n/source.json (English) and tools/i18n/<lang>.json (translations).

Validate first:  python3 tools/i18n/check.py
Then generate:   python3 tools/make_strings.py
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
I18N = ROOT / "i18n"
RESOURCES = ROOT.parent / "Scanlet/Resources"


def unit(value):
    return {"stringUnit": {"state": "translated", "value": value}}


def localized(value):
    if isinstance(value, dict):
        return {"variations": {"plural": {category: unit(text) for category, text in value.items()}}}
    return unit(value)


def build():
    source = json.loads((I18N / "source.json").read_text())
    languages = {
        path.stem: json.loads(path.read_text())
        for path in sorted(I18N.glob("*.json"))
        if path.stem != "source"
    }

    strings = {}
    for key, entry in source["strings"].items():
        localizations = {}
        if isinstance(entry["en"], dict):
            localizations["en"] = localized(entry["en"])
        for lang, data in languages.items():
            if key in data["strings"]:
                localizations[lang] = localized(data["strings"][key])
        strings[key] = {"localizations": localizations}

    catalog = {"sourceLanguage": "en", "strings": dict(sorted(strings.items(), key=lambda i: i[0].lower())), "version": "1.0"}
    (RESOURCES / "Localizable.xcstrings").write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + "\n")

    info = {}
    for key, english in source["infoPlist"].items():
        localizations = {"en": unit(english)}
        for lang, data in languages.items():
            if value := data.get("infoPlist", {}).get(key):
                localizations[lang] = unit(value)
        info[key] = {"extractionState": "manual", "localizations": localizations}
    (RESOURCES / "InfoPlist.xcstrings").write_text(
        json.dumps({"sourceLanguage": "en", "strings": info, "version": "1.0"}, ensure_ascii=False, indent=2) + "\n")

    print(f"{len(strings)} strings × {len(languages) + 1} languages ({', '.join(['en', *languages])})")
    return sorted(languages)


if __name__ == "__main__":
    build()
