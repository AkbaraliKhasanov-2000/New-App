"""Markets, seed terms and relevance rules for Scanlet keyword research.

Relevance (0–3) is a rule-based judgement of how well a search term matches what
Scanlet actually does (scan → PDF, OCR, sign, organize, share):
  3 core     – document/PDF scanner, scan to PDF
  2 feature  – OCR / image-to-text, sign PDF, receipt / ID scanning, photo/JPG → PDF
  1 adjacent – PDF converter/editor, generic "pdf", camera-to-text
  0 none     – competitor brands, QR/barcode, food/3D/plant/coin scanners, unrelated apps
"""
import re

# code: (App Store language, our app localized?, seeds)
MARKETS = {
    "US": ("en", True, ["scanner", "pdf scanner", "document scanner", "scan", "scanner app", "ocr", "text scanner",
                         "image to text", "sign pdf", "receipt scanner", "pdf", "scan to pdf", "jpg to pdf", "cam scanner"]),
    "GB": ("en", True, ["scanner", "pdf scanner", "document scanner", "scan", "ocr", "image to text", "sign pdf", "receipt scanner"]),
    "CA": ("en", True, ["scanner", "pdf scanner", "document scanner", "scan", "ocr", "image to text", "scanneur", "numériser"]),
    "AU": ("en", True, ["scanner", "pdf scanner", "document scanner", "scan", "ocr", "image to text", "receipt scanner"]),
    "IN": ("en", True, ["scanner", "pdf scanner", "document scanner", "scan", "cam scanner", "image to text", "pdf maker"]),
    "DE": ("de", True, ["scanner", "pdf scanner", "dokumente scannen", "scan", "scannen", "texterkennung", "ocr",
                         "bild zu text", "unterschrift", "kassenbon scanner", "pdf"]),
    "FR": ("fr", True, ["scanner", "scanner pdf", "scan", "scanner document", "numériser", "ocr", "image en texte",
                         "signature pdf", "pdf"]),
    "ES": ("es", True, ["escaner", "escáner", "escaner pdf", "escanear", "escanear documentos", "scanner", "ocr",
                         "imagen a texto", "firmar pdf", "pdf"]),
    "IT": ("it", True, ["scanner", "scanner pdf", "scansione", "scansiona documenti", "scanner documenti", "ocr",
                         "da foto a testo", "firma pdf", "pdf"]),
    "BR": ("pt", True, ["scanner", "scanner pdf", "escanear", "escanear documentos", "digitalizar", "ocr",
                         "foto para texto", "assinar pdf", "pdf"]),
    "MX": ("es", True, ["escaner", "escáner", "escaner pdf", "escanear", "escanear documentos", "scanner", "ocr",
                         "imagen a texto", "pdf"]),
    "JP": ("ja", False, ["スキャン", "スキャナー", "スキャナー アプリ", "pdf", "pdf スキャン", "書類 スキャン", "文字認識",
                          "ocr", "文字 読み取り", "電子署名"]),
    "KR": ("ko", False, ["스캔", "스캐너", "스캐너 앱", "pdf", "pdf 스캔", "문서 스캔", "문자 인식", "ocr", "텍스트 추출", "서명"]),
    "RU": ("ru", True, ["сканер", "сканер документов", "сканер pdf", "сканирование", "скан", "pdf", "распознавание текста",
                         "ocr", "текст с фото", "подпись"]),
    "TR": ("tr", True, ["tarayıcı", "belge tarayıcı", "pdf tarayıcı", "tarama", "scanner", "pdf", "metin tanıma", "ocr",
                         "fotoğraftan metne", "imza"]),
    "NL": ("nl", True, ["scanner", "scanner pdf", "scannen", "documenten scannen", "scan", "ocr", "tekst herkenning", "pdf"]),
    "PL": ("pl", True, ["skaner", "skaner pdf", "skaner dokumentów", "skanowanie", "skanuj", "scanner", "ocr", "pdf",
                         "tekst ze zdjęcia"]),
    "SE": ("sv", True, ["skanner", "scanner", "skanna", "skanna dokument", "pdf", "pdf scanner", "ocr", "text från bild"]),
}

# Roots that make a term relevant (lower-case substrings).
CORE = [
    r"scan", r"skan", r"escan", r"escán", r"numéris", r"digitaliz", r"scansi", r"tarayıc", r"tarama", r"tara\b",
    r"スキャ", r"스캔", r"스캐너", r"скан", r"сканир",
]
FEATURE = [
    r"ocr", r"to text", r"zu text", r"en texte", r"a texto", r"para texto", r"a testo", r"naar tekst", r"från bild",
    r"text", r"texto", r"testo", r"texte", r"tekst", r"metin", r"текст", r"文字", r"텍스트", r"문자",
    r"sign", r"unterschr", r"firma", r"assina", r"imza", r"podpis", r"подпис", r"署名", r"서명",
    r"receipt", r"kassenbon", r"beleg", r"recibo", r"ricevut", r"reçu", r"bon\b", r"fiş", r"чек", r"レシート", r"영수증",
    r"jpg", r"jpeg", r"photo to pdf", r"foto", r"bild", r"фото", r"写真", r"사진",
]
ADJACENT = [r"pdf", r"document", r"dokument", r"documento", r"belge", r"документ", r"書類", r"문서", r"converter", r"konvert"]
# Competitor brands and unrelated scanner niches.
EXCLUDE = [
    r"camscanner", r"cam scanner", r"adobe", r"acrobat", r"genius", r"iscanner", r"tiny ?scan", r"turbo ?scan",
    r"scanner pro", r"swift ?scan", r"microsoft", r"lens", r"evernote", r"scanbot", r"vflat", r"clear ?scan",
    r"qr", r"barcode", r"bar code", r"code", r"código", r"kod", r"код", r"バーコード", r"바코드", r"3d", r"lidar",
    r"food", r"ingredient", r"inhalts", r"ingred", r"plant", r"coin", r"münz", r"card", r"karte", r"carta", r"pokemon",
    r"pokémon", r"face", r"body", r"room", r"radio", r"police", r"wifi", r"network", r"port", r"virus", r"malware",
    r"skin", r"film", r"negative", r"photo scan", r"photoscan", r"fotoscan", r"slide", r"book ?scan", r"price",
    r"grocery", r"yuka", r"nutri", r"calorie", r"kalorie", r"scandinav", r"scandlines", r"scandal", r"scandi",
    r"скандал", r"translate", r"übersetz", r"tradu", r"çevir", r"переводч", r"翻訳", r"번역", r"homework", r"math",
    r"answer", r"gauth", r"photomath", r"fax", r"printer", r"drucker", r"imprim", r"hp\b", r"canon", r"epson",
    r"brother", r"scaniverse", r"polycam", r"magnifier", r"lupe", r"fingerprint", r"thermal", r"wärme",
]


def relevance(term: str) -> int:
    t = term.lower()
    if any(re.search(p, t) for p in EXCLUDE):
        return 0
    core = any(re.search(p, t) for p in CORE)
    feature = any(re.search(p, t) for p in FEATURE)
    adjacent = any(re.search(p, t) for p in ADJACENT)
    if core:
        # "scanner", "pdf scanner", "scan to pdf" are core; "text scanner", "receipt scanner" are features.
        return 2 if feature and not adjacent else 3
    if re.search(r"ocr", t) or (feature and (adjacent or len(t.split()) >= 2)):
        return 2
    if feature or adjacent:
        return 1
    return 0
