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
    r"\bcar\b", r"obd", r"elm", r"hair", r"allerg", r"antique", r"\bcat\b", r"\bdog\b", r"breed", r"banknote",
    r"comic", r"\bart\b", r"bluetooth", r"\bble\b", r"device", r"kiosk", r"\bage\b", r"identif", r"value",
    r"apprais", r"health", r"calculat", r"otc", r"detect", r"verify", r"wine", r"vinyl", r"record", r"stamp",
    r"rock", r"stone", r"crystal", r"mushroom", r"insect", r"bug", r"bird", r"tree", r"flower", r"pill", r"drug",
    r"medic", r"blood", r"heart", r"tooth", r"teeth", r"eye", r"ticket", r"event", r"inventory", r"lager", r"warehouse",
    r"label", r"ingredi", r"makeup", r"cosmetic", r"barcod", r"isbn", r"pantry", r"license", r"driver", r"passport photo",
]


def is_search_term(term: str) -> bool:
    """Autocomplete also suggests app titles ("Doc Fuse: PDF Scanner & Maker"); keep real search phrases only."""
    return not any(ch in term for ch in ":&|()•·–—!?+") and " - " not in term and len(term.split()) <= 4


def relevance(term: str) -> int:
    t = term.lower()
    if any(re.search(p, t) for p in EXCLUDE) or not all_words_known(t):
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

# Every word of a relevant term must be a scanning/PDF concept or one of these generic words.
GENERIC_WORDS = set("""
app apps application free pro best fast easy quick simple smart mobile phone iphone for to into and with my me the a of
online offline new ai camera cam doc docs document documents file files paper papers page pages image images photo photos
picture pictures pic jpg jpeg png maker creator converter convert editor edit reader make print scanner scanners scan scans
scanning scanned text ocr pdf pdfs sign signature receipt receipts id ids card cards recognition extract extractor copy
kostenlos gratis dokument dokumente dokumenten scannen zu in für mit und bild bilder foto fotos datei dateien
texterkennung erstellen umwandeln konvertieren handy beste unterschrift unterschreiben kassenbon beleg belege
gratuit gratuite de en pour et avec fichier fichiers texte convertir numériser numérisation numériseur meilleur signer
scanneur reçu reçus
escáner escaner escanear documentos documento a para y con imagen imágenes archivo convertir aplicación mejor firmar
firma recibo recibos texto
scansione scansiona scansionare documenti da per e immagine immagini testo convertire applicazione firma ricevuta ricevute
grátis escanear arquivo arquivos digitalizar digitalizador aplicativo assinar assinatura imagem com
scannen documenten van naar voor met afbeelding bestand tekst ondertekenen bon bonnen
aplikacja darmowy darmowa darmowe skaner skanowanie skanuj skanować dokumentów dokumenty dokument do z na i zdjęcie
zdjęcia zdjęć plik tekst tekstu podpis paragon paragony
skanner skanna till och bild fil kvitto kvitton
приложение бесплатно бесплатный сканер сканирование скан документов документы документ в и с для фото текст текста
файл камера подпись чек чеки распознавание
uygulama ücretsiz tarayıcı belge belgeler fotoğraf fotoğraftan metin metne dosya tarama tara ve ile için imza fiş
tanıma
アプリ 無料 スキャン スキャナー 書類 文書 文字 認識 読み取り 写真 カメラ 変換 署名 レシート
앱 무료 스캔 스캐너 문서 텍스트 문자 인식 사진 카메라 변환 추출 서명 영수증
""".split())


def all_words_known(term: str) -> bool:
    return all(word in GENERIC_WORDS for word in term.lower().replace(",", " ").split())
