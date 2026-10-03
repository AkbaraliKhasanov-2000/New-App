#!/usr/bin/env python3
"""Validates translations in tools/i18n/<lang>.json against tools/i18n/source.json.

Checks, per language:
  • every key is translated, no unknown keys
  • placeholders (%@, %lld, %1$@ …) match the English source exactly
  • plural variations contain the CLDR categories the language needs
  • LENGTH: a translation may not be much longer than the English text, so
    buttons, chips and titles never wrap onto 2–3 lines. If a literal
    translation is too long, use a shorter synonym with the same meaning.

Also validates App Store metadata in fastlane/metadata/<locale>/ (Apple limits).

Usage:  python3 tools/i18n/check.py            # all languages
        python3 tools/i18n/check.py de fr      # selected languages
Exit code 1 when anything fails.
"""
import json
import math
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parent.parent
SOURCE = json.loads((ROOT / "source.json").read_text())

# CLDR cardinal plural categories required for integer counts.
PLURAL_CATEGORIES = {
    "en": {"one", "other"}, "de": {"one", "other"}, "nl": {"one", "other"}, "sv": {"one", "other"},
    "da": {"one", "other"}, "nb": {"one", "other"}, "fi": {"one", "other"}, "el": {"one", "other"},
    "hu": {"one", "other"}, "tr": {"one", "other"}, "uz": {"one", "other"}, "bg": {"one", "other"},
    "it": {"one", "many", "other"}, "es": {"one", "many", "other"}, "fr": {"one", "many", "other"},
    "pt-PT": {"one", "many", "other"}, "pt-BR": {"one", "many", "other"},
    "ro": {"one", "few", "other"}, "hr": {"one", "few", "other"},
    "pl": {"one", "few", "many", "other"}, "uk": {"one", "few", "many", "other"},
    "ru": {"one", "few", "many", "other"}, "cs": {"one", "few", "many", "other"},
    "sk": {"one", "few", "many", "other"},
}

PLACEHOLDER = re.compile(r"%(?:\d+\$)?(?:lld|ld|d|@|lf|f)|%%")

# Brand and format words that stay as they are.
UNTRANSLATED_OK = {"PDF", "JPG", "OK", "A4", "US Letter", "US Legal", "PRO", "Scanlet Pro", "Face ID", "Touch ID", "Optic ID"}


def placeholders(text):
    found = []
    for match in PLACEHOLDER.findall(text):
        if match == "%%":
            found.append("%%")
        else:
            found.append(re.sub(r"\d+\$", "", match))
    return sorted(found)


def visible_length(text):
    # Count a placeholder as 3 characters (e.g. "12", "$4.99" varies; keep it neutral).
    return len(PLACEHOLDER.sub("xxx", text))


def max_length(english):
    """Longest allowed translation.

    Short strings are buttons, chips, tabs and titles that must stay on one line,
    so they get a tight budget. Long strings are footers and descriptions that
    already wrap, so they get a little more room.
    """
    n = visible_length(english)
    if n <= 6:
        return max(n + 6, 10)     # "Done", "Share", "Cancel"
    if n <= 14:
        return n + 6              # "Page Size", "Restore Purchases"
    if n <= 40:
        return math.ceil(n * 1.3)
    return math.ceil(n * 1.4)


def english_forms(value):
    return value if isinstance(value, dict) else {"other": value}


def check_language(lang):
    path = ROOT / f"{lang}.json"
    if not path.exists():
        return [f"{lang}: missing file {path.name}"]
    data = json.loads(path.read_text())
    strings = data.get("strings", {})
    errors = []

    for key in SOURCE["strings"].keys() - strings.keys():
        errors.append(f"missing: {key!r}")
    for key in strings.keys() - SOURCE["strings"].keys():
        errors.append(f"unknown key: {key!r}")

    for key, entry in SOURCE["strings"].items():
        if key not in strings:
            continue
        english = entry["en"]
        value = strings[key]
        if isinstance(english, dict):
            if not isinstance(value, dict):
                errors.append(f"{key!r}: needs plural forms {sorted(PLURAL_CATEGORIES.get(lang, {'one', 'other'}))}")
                continue
            required = PLURAL_CATEGORIES.get(lang, {"one", "other"})
            if missing := required - value.keys():
                errors.append(f"{key!r}: missing plural categories {sorted(missing)}")
            limit = max_length(english["other"])
            for category, text in value.items():
                if placeholders(text) != placeholders(english["other"]):
                    errors.append(f"{key!r} [{category}]: placeholders {placeholders(text)} ≠ {placeholders(english['other'])}")
                if visible_length(text) > limit:
                    errors.append(f"TOO LONG {key!r} [{category}]: {text!r} ({visible_length(text)} > {limit})")
        else:
            if not isinstance(value, str) or not value.strip():
                errors.append(f"{key!r}: empty")
                continue
            if placeholders(value) != placeholders(english):
                errors.append(f"{key!r}: placeholders {placeholders(value)} ≠ {placeholders(english)}: {value!r}")
            limit = max_length(english)
            if visible_length(value) > limit:
                errors.append(f"TOO LONG {key!r}: {value!r} ({visible_length(value)} > {limit}, English {visible_length(english)})")
            if value != value.strip():
                errors.append(f"{key!r}: leading/trailing whitespace")

    info = data.get("infoPlist", {})
    for key in SOURCE["infoPlist"]:
        if not info.get(key):
            errors.append(f"infoPlist missing: {key}")
    return errors


METADATA_LIMITS = {"name.txt": 30, "subtitle.txt": 30, "promotional_text.txt": 170, "description.txt": 4000, "release_notes.txt": 4000}


def check_metadata(locale_dir):
    errors = []
    for name, limit in METADATA_LIMITS.items():
        path = locale_dir / name
        if not path.exists():
            errors.append(f"missing {name}")
            continue
        text = path.read_text().strip()
        if len(text) > limit:
            errors.append(f"{name}: {len(text)} > {limit} characters")
    keywords = (locale_dir / "keywords.txt")
    if not keywords.exists():
        errors.append("missing keywords.txt")
    else:
        text = keywords.read_text().strip()
        if len(text.encode()) > 100:
            errors.append(f"keywords.txt: {len(text.encode())} > 100 bytes")
        if ", " in text:
            errors.append("keywords.txt: no spaces after commas")
        name_words = set(re.findall(r"\w+", ((locale_dir / "name.txt").read_text() + " " + (locale_dir / "subtitle.txt").read_text()).lower())) if (locale_dir / "name.txt").exists() and (locale_dir / "subtitle.txt").exists() else set()
        dupes = [w for w in text.lower().split(",") if w in name_words]
        if dupes:
            errors.append(f"keywords.txt repeats words from name/subtitle: {dupes}")
    return errors


def main():
    languages = sys.argv[1:] or sorted(p.stem for p in ROOT.glob("*.json") if p.stem != "source")
    failed = False
    for lang in languages:
        errors = check_language(lang)
        status = "OK" if not errors else f"{len(errors)} problem(s)"
        print(f"[{lang}] {status}")
        for error in errors:
            print("   ", error)
        failed |= bool(errors)

    metadata_root = REPO / "fastlane/metadata"
    for locale_dir in sorted(p for p in metadata_root.iterdir() if p.is_dir() and p.name != "review_information"):
        errors = check_metadata(locale_dir)
        if errors:
            print(f"[metadata {locale_dir.name}] " + "; ".join(errors))
            failed = True
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
