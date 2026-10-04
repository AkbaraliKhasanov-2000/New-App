# Scanlet ASO tadqiqoti (to'liq ma'lumotlar bilan)

> Har bir raqam `tools/aso/` skriptlari orqali ochiq manbalardan olingan. So'rov javoblari `tools/aso/.cache` da saqlanadi, shuning uchun natijalarni qayta tekshirish mumkin.

## 1. Ma'lumot manbalari

| Manba | Narx | Beradigan ma'lumot | Bermaydigan | Ishlatildi |
|---|---|---|---|---|
| iTunes Search API (`itunes.apple.com/search`) | Bepul | Ilova nomi, ishlab chiquvchi, reyting, reyting soni, narx, janr; so'rov bo'yicha ≤200 ilova (raqobatchilar soni) | Popularity, haqiqiy qidiruv tartibi | Ha |
| iTunes Lookup API (`itunes.apple.com/lookup`) | Bepul | Top-10 ilovalarning har bir do'kondagi reyting soni → qiyinlik | — | Ha |
| App Store search hints (`MZSearchHints`) | Bepul | Apple autocomplete takliflari (mamlakat bo'yicha, Apple tartibida) | Raqamli popularity yo'q | Ha |
| App Store web qidiruv (`apps.apple.com/<cc>/iphone/search`) | Bepul | Haqiqiy, tartiblangan iPhone qidiruv natijalari → top-10 raqobatchilar, nom bandligi | Popularity | Ha |
| USPTO TM Search (`tmsearch.uspto.gov`) | Bepul | AQSh trademark'lari: so'z belgisi, holati (faol/bekor), sinflar | EU/WIPO bazalari | Ha |
| Sonar API, kalitsiz bepul tarif | Bepul (5 so'z/kun/IP) | **Apple Search Ads popularity (5–100)**, qiyinlik | Hajm juda kichik | Ha (kalibrlash va asosiy so'zlar) |
| Sonar API, prepaid | Pullik: $10 = 1000 kredit | Apple popularity barcha so'zlar uchun, 72 bozor | — | Yo'q (foydalanuvchi bepul variantni tanladi) |
| Apple Ads Platform API (`api.ads.apple.com/v1`) | Bepul, lekin Apple Ads hisobi va API kaliti kerak | Rasmiy search-term popularity (1–100), kalit so'z takliflari | — | Yo'q (hisob yo'q) |
| AppTweak API | Pullik: ~$166/oy; 7 kunlik trial (ro'yxatdan o'tish kerak) | Volume, difficulty (1–100), reach, rankings | — | Yo'q |
| Astro (Mac ilova) | Pullik: $9/oy | Apple Search Ads popularity, difficulty, rank tracking | API yo'q | Yo'q |
| Appfigures API | Pullik: ~$9/oy dan; popularity yuqori tariflarda | O'z modeliga asoslangan popularity/competitiveness | Apple'ning raqami emas | Yo'q |

**Popularity haqida.** Apple'ning popularity raqami (5–100) faqat Apple Search Ads orqali keladi. Bepul autocomplete ma'lumotidan popularity hisoblashga urinib ko'rdim, lekin u Apple raqamlariga mos kelmadi (kalibrlash pastda). Shuning uchun popularity faqat Apple raqami bor joylarda ko'rsatilgan. Qolgan kalit so'zlar uchun xom fakt beriladi: Apple bu so'zni autocomplete'da nechta harfdan keyin va nechanchi o'rinda taklif qiladi.

### Kalibrlash (AQSh): autocomplete va Apple popularity

| Kalit so'z | Apple popularity | Autocomplete |
|---|---|---|
| scanner app free | 66 | 2 harfda, #4 |
| scanner | 62 | 3 harfda, #2 |
| pdf scanner | 59 | 2 harfda, #3 |
| scan to pdf | 59 | 3 harfda, #3 |
| scan | 58 | 3 harfda, #6 |
| document scanner | 55 | 3 harfda, #4 |
| scanner app | 49 | 9 harfda, #2 |
| ocr | 5 | 3 harfda, #4 |
| text scanner | 5 | 6 harfda, #4 |
| image to text | 5 | 7 harfda, #10 |
| pdf scanner free | 5 | 13 harfda, #1 |
| document scanner app | 5 | 18 harfda, #3 |

Xulosa: autocomplete'da erta chiqish yuqori popularity'ni kafolatlamaydi. Masalan, "text scanner" 6 harfda taklif qilinadi, lekin popularity'si 5. Shuning uchun autocomplete faqat talab borligining belgisi sifatida ishlatildi.

**Qiyinlik (1–100)** = 0,7 × top-10 ilovalar reyting sonining mediani (log shkala, 1 mln reyting = 100) + 0,3 × nomida kalit so'zning barcha so'zlari bor top-10 ilovalar ulushi.  **Ilovalar** = iTunes Search API qaytargan ilovalar soni (Apple 200 dan ortig'ini qaytarmaydi).  **Relevantlik**: 3 = asosiy funksiya, 2 = qo'shimcha funksiya, 1 = yaqin mavzu.

## 2. Nom unikalligi (174 ta storefront + USPTO)

| Nom | PDF Scanner & OCR bilan uzunlik | Aynan bir xil (do'konlar) | O'xshash (do'konlar) | USPTO faol, ≤1 harf farq (9/42-sinf) | Xulosa | Sabab |
|---|---|---|---|---|---|---|
| **Scanlet** | 26/30 | 55 | 119 | 2 | ❌ band | Scanlet |
| **Scanova** | 26/30 | 174 | 172 | 3 | ❌ band | Scanova - AI Scan Manager; Scanova Docs |
| **Pagelet** | 26/30 | 173 | 0 | 0 | ❌ band | Pagelet - Delete PDF Pages; Pagelet - PDF Print Layout; Pagelet Eliminar y organizar, |
| **Docuvia** | 26/30 | 168 | 0 | 0 | ❌ band | Docuvia |
| **Inkwise** | 26/30 | 0 | 0 | 0 | ✅ toza | — |
| **Paperlark** | 28/30 | 0 | 118 | 2 | ⚠️ xavfli | Paperbark; TM PAPERMARK (IC 009); TM PAPERMARK (IC 042) |
| **Scanbird** | 27/30 | 56 | 1 | 0 | ❌ band | ScanBird |
| **Pagefold** | 27/30 | 172 | 0 | 0 | ❌ band | Page Fold; Pagefold - Scan to PDF; Pagefold: PDF Scanner OCR |
| **Lumipage** | 27/30 | 0 | 0 | 0 | ✅ toza | — |
| **Docsmith** | 27/30 | 170 | 4 | 0 | ❌ band | Docsmith : Scanner PDF; Docsmith: Edit PDF Text; Docsmith: Escáner PDF |
| **Scanvault** | 28/30 | 174 | 141 | 0 | ❌ band | Scan Vault; ScanVault; ScanVault - PDF Scanner |
| **Papyro** | 25/30 | 171 | 174 | 1 | ❌ band | Papyro: Legal News |
| **Scanmuse** | 27/30 | 0 | 0 | 0 | ✅ toza | — |
| **Clearleaf** | 28/30 | 174 | 0 | 0 | ❌ band | Clear Leaf; ClearLeaf: Quit Cannabis; ClearLeaf: Quit Weed |
| **Scanfinch** | 28/30 | 0 | 0 | 0 | ✅ toza | — |
| **Docnest** | 26/30 | 0 | 1 | 0 | ⚠️ xavfli | DocuNet Viewer (Phone) |
| **Pagewise** | 27/30 | 174 | 0 | 4 | ❌ band | PageWise — Book Tracker & TBR; PageWise: Book Summaries; Pagewise |
| **Scanaro** | 26/30 | 0 | 157 | 5 | ⚠️ xavfli | ScanAR Partner; ScanarX Smart Receipt Scanner; Scania Manual; TM SCANAR (IC 009/IC 042); TM SCANPRO (IC 009) |
| **Folioscan** | 28/30 | 169 | 0 | 0 | ❌ band | Folio Scan |
| **Quillscan** | 28/30 | 169 | 0 | 0 | ❌ band | QuillScan |

Tekshirilgan do'konlar: 174.


Izoh: 174 ta storefront iTunes Search API orqali barcha ISO-3166 kodlarini tekshirib topildi. Apple 175 deydi; farq Apple'ning maxsus storefront'lari bilan bog'liq bo'lishi mumkin. EUIPO va WIPO bazalarida ochiq API yo'q, ularni qo'lda tekshirish kerak: [TMview](https://www.tmdn.org/tmview/), [WIPO Global Brand Database](https://branddb.wipo.int/).

## 3. Kalit so'zlar (bozorlar bo'yicha)

### US — App Store tili: `en` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| scanner app free | 66 | 2 harfda, #4 | 69 | 185 | CamScanner - PDF Scanner App (1,931,971); Scanner App: Genius Scan (1,366,703); Police Scanner Radio & Fire (534,625) | 3 |
| scanner | 62 | 3 harfda, #2 | 94 | 177 | CamScanner - PDF Scanner App (1,931,971); Police Scanner Radio & Fire (534,625); iScanner: PDF Document Scanner (1,404,384) | 3 |
| pdf scanner | 59 | 2 harfda, #3 | 86 | 186 | Adobe Scan: PDF & Doc Scanner (1,596,205); CamScanner - PDF Scanner App (1,931,971); PDF Scanner \| Document Scan (1,912) | 3 |
| scan to pdf | 59 | 3 harfda, #3 | 66 | 184 | Adobe Scan: PDF & Doc Scanner (1,596,205); CamScanner - PDF Scanner App (1,931,971); Scanner App: Genius Scan (1,366,703) | 3 |
| document scanner | 55 | 3 harfda, #4 | 75 | 185 | Scanner App. JPG, Photo to PDF (74,632); CamScanner - PDF Scanner App (1,931,971); Adobe Scan: PDF & Doc Scanner (1,596,205) | 3 |
| scan documents | — | 4 harfda, #5 | 60 | 186 | Scanner App. JPG, Photo to PDF (74,632); CamScanner - PDF Scanner App (1,931,971); Adobe Scan: PDF & Doc Scanner (1,596,205) | 3 |
| document scanner app free | — | 4 harfda, #8 | 59 | 185 | CamScanner - PDF Scanner App (1,931,971); Adobe Scan: PDF & Doc Scanner (1,596,205); Document Scanner, Scan to PDF (98) | 3 |
| pdf document scanner | — | 5 harfda, #3 | 34 | 188 | PDF Document Scanner App ° (6,341); PDF Document Scanner: ScaniX (103); ScanGuru: PDF Scanner App (93,238) | 3 |
| pdf mobile scanner | — | 5 harfda, #4 | 52 | 180 | Mobile Scanner App - Scan PDF (56,860); TurboScan™ Pro: PDF scanner (296,770); PDF Scanner AI: Scan Documents (6,606) | 3 |
| pdf scanner document converter | — | 5 harfda, #5 | 38 | 194 | Scan to PDF: Converter Scanner (24,289); Adobe Scan: PDF & Doc Scanner (1,596,205); CamScanner - PDF Scanner App (1,931,971) | 3 |
| scan photos to phone | — | 6 harfda, #1 | 58 | 163 | PhotoScan by Google Photos (90,214); Photo Scan App by Photomyne (96,179); CamScanner - PDF Scanner App (1,931,971) | 3 |
| scan scanner | — | 6 harfda, #1 | 84 | 189 | CamScanner - PDF Scanner App (1,931,971); Clear Scan: Doc Scanner App (18,121); Scanner – Scan PDF, ID & Docs (222,759) | 3 |
| pdf scanner documents | — | 6 harfda, #2 | 48 | 184 | CamScanner - PDF Scanner App (1,931,971); PDF Scanner & Document Scan (21); Adobe Scan: PDF & Doc Scanner (1,596,205) | 3 |
| scan apps free | — | 6 harfda, #3 | 66 | 184 | iScanner: PDF Document Scanner (1,404,384); Free PDF Scanner App For Doc (529); Scanner App: Genius Scan (1,366,703) | 3 |
| scan documents free | — | 6 harfda, #4 | 59 | 192 | Adobe Scan: PDF & Doc Scanner (1,596,205); CamScanner - PDF Scanner App (1,931,971); Scan Me Document (0) | 3 |
| pdf scanner gratuit | — | 6 harfda, #7 | 39 | 182 | PDF Scanner・Document Scanner (2,026); CamScanner - PDF Scanner App (1,931,971); Scanner – Scan PDF, ID & Docs (222,759) | 3 |
| the document scanner free | — | 6 harfda, #8 | 47 | 180 | CamScanner - PDF Scanner App (1,931,971); Adobe Scan: PDF & Doc Scanner (1,596,205); Free PDF Scanner App For Doc (529) | 3 |
| paper scanner document scan | — | 7 harfda, #1 | 31 | 194 | CamScanner - PDF Scanner App (1,931,971); Scanner App: Genius Scan (1,366,703); Adobe Scan: PDF & Doc Scanner (1,596,205) | 3 |
| free pdf scanner app | — | 7 harfda, #1 | 47 | 189 | CamScanner - PDF Scanner App (1,931,971); Free PDF Scanner App For Doc (529); Adobe Scan: PDF & Doc Scanner (1,596,205) | 3 |
| scanner free pdf scan | — | 9 harfda, #1 | 62 | 188 | CamScanner - PDF Scanner App (1,931,971); Scanner – Scan PDF, ID & Docs (222,759); Adobe Scan: PDF & Doc Scanner (1,596,205) | 3 |
| pdf scanner for free | — | 9 harfda, #2 | 59 | 193 | CamScanner - PDF Scanner App (1,931,971); Adobe Scan: PDF & Doc Scanner (1,596,205); PDF Scanner・Document Scanner (2,026) | 3 |
| scanner for iphone | — | 9 harfda, #2 | 47 | 180 | Doc Scanner PDF, Convert & OCR (478); QR Reader for iPhone (1,437,433); CamScanner - PDF Scanner App (1,931,971) | 3 |
| scanner pdf for iphone | — | 9 harfda, #3 | 47 | 185 | CamScanner - PDF Scanner App (1,931,971); Adobe Scan: PDF & Doc Scanner (1,596,205); Mobile Scanner App - Scan PDF (56,860) | 3 |
| scanner for documents | — | 9 harfda, #4 | 64 | 183 | CamScanner - PDF Scanner App (1,931,971); Adobe Scan: PDF & Doc Scanner (1,596,205); iScanner: PDF Document Scanner (1,404,384) | 3 |
| document scanner to pdf | — | 10 harfda, #4 | 13 | 187 | CamScanner - PDF Scanner App (1,931,971); Adobe Scan: PDF & Doc Scanner (1,596,205); FreePDF: PDF Converter & Scan (0) | 3 |

### GB — App Store tili: `en` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| pdf scanner | — | 2 harfda, #4 | 74 | 181 | CamScanner - PDF Scanner App (126,473); Adobe Scan: PDF & OCR Scanner (195,149); PDF Scanner \| Document Scan (108) | 3 |
| scanner app | — | 2 harfda, #4 | 71 | 181 | CamScanner - PDF Scanner App (126,473); iScanner: PDF Doc Scanner App (163,951); Adobe Scan: PDF & OCR Scanner (195,149) | 3 |
| pdf scanner free | — | 2 harfda, #6 | 50 | 189 | Adobe Scan: PDF & OCR Scanner (195,149); CamScanner - PDF Scanner App (126,473); iScanner: PDF Doc Scanner App (163,951) | 3 |
| scanner app free | — | 3 harfda, #2 | 55 | 187 | CamScanner - PDF Scanner App (126,473); iScanner: PDF Doc Scanner App (163,951); Adobe Scan: PDF & OCR Scanner (195,149) | 3 |
| scan documents | — | 3 harfda, #3 | 55 | 185 | CamScanner - PDF Scanner App (126,473); ScanMe - PDF Scanner App (244); Adobe Scan: PDF & OCR Scanner (195,149) | 3 |
| document scanner | — | 4 harfda, #3 | 59 | 184 | iScanner: PDF Doc Scanner App (163,951); CamScanner - PDF Scanner App (126,473); Adobe Scan: PDF & OCR Scanner (195,149) | 3 |
| doc scanner free | — | 5 harfda, #2 | 32 | 188 | Doc Scanner . (8); CamScanner - PDF Scanner App (126,473); Scanner – Scan PDF, ID & Docs (34,010) | 3 |
| scanner app for documents | — | 5 harfda, #6 | 53 | 190 | CamScanner - PDF Scanner App (126,473); Adobe Scan: PDF & OCR Scanner (195,149); Scanner App: Genius Scan (100,577) | 3 |
| scan scanner | — | 6 harfda, #1 | 47 | 182 | CamScanner - PDF Scanner App (126,473); Clear Scan: Doc Scanner App (4,045); QR Code: Scan QR & Barcode (1) | 3 |
| scan photos | — | 6 harfda, #1 | 27 | 192 | PhotoScan by Google Photos (10,827); Photo Scan App by Photomyne (15,052); Photo Scanner: Scan old Albums (853) | 3 |
| scan documents free | — | 6 harfda, #2 | 53 | 190 | CamScanner - PDF Scanner App (126,473); Adobe Scan: PDF & OCR Scanner (195,149); EasyScan: Document Scanner (2,655) | 3 |
| scan to pdf free | — | 6 harfda, #2 | 50 | 190 | Adobe Scan: PDF & OCR Scanner (195,149); CamScanner - PDF Scanner App (126,473); Scan to PDF & Document Scanner (5) | 3 |
| scan app free | — | 6 harfda, #3 | 51 | 192 | iScanner: PDF Doc Scanner App (163,951); QR Pro - Code Scanner & Maker (45,601); CamScanner - PDF Scanner App (126,473) | 3 |
| scan to pdf | — | 6 harfda, #3 | 37 | 186 | Adobe Scan: PDF & OCR Scanner (195,149); Scan to PDF & Document Scanner (5); CamScanner - PDF Scanner App (126,473) | 3 |
| scan pdf free | — | 6 harfda, #4 | 31 | 190 | CamScanner - PDF Scanner App (126,473); Adobe Scan: PDF & OCR Scanner (195,149); Scan Hero: PDF Scanner (32,064) | 3 |
| free document scanner | — | 6 harfda, #7 | 50 | 193 | EasyScan: Document Scanner (2,655); CamScanner - PDF Scanner App (126,473); Adobe Scan: PDF & OCR Scanner (195,149) | 3 |
| scan a document | — | 6 harfda, #7 | 37 | 192 | iScanner: PDF Doc Scanner App (163,951); Scanner App: Genius Scan (100,577); Adobe Scan: PDF & OCR Scanner (195,149) | 3 |
| scan picture | — | 6 harfda, #7 | 38 | 188 | PhotoScan by Google Photos (10,827); Photo Scan App by Photomyne (15,052); CamScanner - PDF Scanner App (126,473) | 3 |
| scan my phone | — | 6 harfda, #8 | 18 | 185 | Clear Scan: Doc Scanner App (4,045); YouTube (6,213,050); McAfee: Stay Secure & Private (29,402) | 3 |
| free pdf scanner app | — | 7 harfda, #3 | 53 | 188 | CamScanner - PDF Scanner App (126,473); Adobe Scan: PDF & OCR Scanner (195,149); PDF Scanner・Document Scanner (258) | 3 |
| mobile scanner pdf app | — | 8 harfda, #1 | 53 | 185 | Mobile Scanner App - Scan PDF (11,867); Adobe Scan: PDF & OCR Scanner (195,149); CamScanner - PDF Scanner App (126,473) | 3 |
| scanner to pdf | — | 9 harfda, #2 | 8 | 188 | CamScanner - PDF Scanner App (126,473); Adobe Scan: PDF & OCR Scanner (195,149); Scanner – Scan PDF, ID & Docs (34,010) | 3 |
| scanner app for photos | — | 9 harfda, #6 | 34 | 187 | PhotoScan by Google Photos (10,827); Photo Scan App by Photomyne (15,052); Photo Scanner : Doc Scanner (178) | 3 |
| mobile document scanner ocr | — | 9 harfda, #9 | 46 | 192 | Scanner – Scan PDF, ID & Docs (34,010); Mobile Scanner App - Scan PDF (11,867); Scan Shot・PDF Document Scanner (9,972) | 3 |
| document scanner app free | — | 10 harfda, #3 | 42 | 190 | CamScanner - PDF Scanner App (126,473); Adobe Scan: PDF & OCR Scanner (195,149); iScanner: PDF Doc Scanner App (163,951) | 3 |

### CA — App Store tili: `en` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| pdf scanner | — | 2 harfda, #2 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); PDF Scanner \| Document Scan (0) | 3 |
| scanner app free | — | 2 harfda, #6 | — | — | CamScanner - PDF Scanner App (0); iScanner: PDF Docs Scanner App (0); Adobe Scan: PDF & OCR Scanner (0) | 3 |
| scanner | — | 2 harfda, #8 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); iScanner: PDF Docs Scanner App (0) | 3 |
| scan document | — | 3 harfda, #3 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); Scanner App: Genius Scan (0) | 3 |
| document scanner | — | 3 harfda, #4 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); Document Scanner by Lufick (0) | 3 |
| scan | — | 3 harfda, #4 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); Scanner App: Genius Scan (0) | 3 |
| scan to pdf free | — | 3 harfda, #5 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); iScanner: PDF Docs Scanner App (0) | 3 |
| iphone scanner free | — | 3 harfda, #9 | — | — | Scanner App for iPhone (0); CamScanner - PDF Scanner App (0); PDF Scanner App: Free Scan Doc (0) | 3 |
| scan pdf | — | 3 harfda, #9 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); Scanner App: Genius Scan (0) | 3 |
| pdf scanner app free | — | 5 harfda, #2 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); Scanner App: Genius Scan (0) | 3 |
| pdf scanner gratuit | — | 5 harfda, #8 | — | — | Adobe Scan: PDF & OCR Scanner (0); iScanner: PDF Docs Scanner App (0); PDF Scanner・Document Scanner (0) | 3 |
| scanner gratuit | — | 5 harfda, #10 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); Scanner – Scan PDF & Document (0) | 3 |
| scan gratuit | — | 6 harfda, #1 | — | — | Adobe Scan: PDF & OCR Scanner (0); Scanner App: Genius Scan (0); Scanner – Scan PDF & Document (0) | 3 |
| scan scanner | — | 6 harfda, #1 | — | — | CamScanner - PDF Scanner App (0); Lite PDF - OCR Scan Edit (0); QR & Barcode Scan (0) | 3 |
| scan app | — | 6 harfda, #1 | — | — | CamScanner - PDF Scanner App (0); Scanner App: Genius Scan (0); Adobe Scan: PDF & OCR Scanner (0) | 3 |
| scan document free | — | 6 harfda, #2 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); EasyScan: Document Scanner (0) | 3 |
| scan photos | — | 6 harfda, #2 | — | — | PhotoScan by Google Photos (0); Photo Scanner App by Photomyne (0); CamScanner - PDF Scanner App (0) | 3 |
| scan to pdf | — | 6 harfda, #2 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); Scanner App: Genius Scan (0) | 3 |
| scan free | — | 6 harfda, #2 | — | — | CamScanner - PDF Scanner App (0); Scanner App: Genius Scan (0); Adobe Scan: PDF & OCR Scanner (0) | 3 |
| scan pro | — | 6 harfda, #3 | — | — | Scanner Pro: Document Scanning (0); SwiftScan AI Document Scanner (0); CamScanner - PDF Scanner App (0) | 3 |
| scan document gratuit | — | 6 harfda, #5 | — | — | Scanner – Scan PDF & Document (0); CamScanner - PDF Scanner App (0); Mobile Scanner App - Scan PDF (0) | 3 |
| scan pdf gratuit | — | 6 harfda, #5 | — | — | Adobe Scan: PDF & OCR Scanner (0); PDF Scanner・Document Scanner (0); CamScanner - PDF Scanner App (0) | 3 |
| free document scanner | — | 6 harfda, #6 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); EasyScan: Document Scanner (0) | 3 |
| free pdf scanner | — | 6 harfda, #6 | — | — | Adobe Scan: PDF & OCR Scanner (0); FreePDF: PDF Converter & Scan (0); CamScanner - PDF Scanner App (0) | 3 |
| scan pictures | — | 6 harfda, #7 | — | — | PhotoScan by Google Photos (0); Photo Scanner App by Photomyne (0); CamScanner - PDF Scanner App (0) | 3 |

### AU — App Store tili: `en` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| pdf scanner | — | 2 harfda, #1 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); PDF Scanner \| Document Scan (0) | 3 |
| scanner app | — | 2 harfda, #2 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); Scanner App: Genius Scan (0) | 3 |
| scanner app free | — | 2 harfda, #8 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); iScanner: PDF Docs Scanner App (0) | 3 |
| pdf scanner free | — | 2 harfda, #9 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); DocScanner: PDF Scan (0) | 3 |
| scan documents | — | 3 harfda, #3 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); ScanMe - PDF Scanner App (0) | 3 |
| document scanner | — | 3 harfda, #4 | — | — | CamScanner - PDF Scanner App (0); Document Scanner by Lufick (0); Adobe Scan: PDF & OCR Scanner (0) | 3 |
| scan | — | 3 harfda, #5 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); Scanner App: Genius Scan (0) | 3 |
| document scanner free | — | 3 harfda, #10 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); Free PDF Scanner App for Doc (0) | 3 |
| scanner app pdf | — | 5 harfda, #6 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); Scanner – Scan PDF & Document (0) | 3 |
| pdf scanner document convert | — | 5 harfda, #9 | — | — | PDF Scanner Document Converter (0); Adobe Scan: PDF & OCR Scanner (0); PDF Scanner \| Document Scan (0) | 3 |
| scan to pdf free | — | 6 harfda, #1 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); iScanner: PDF Docs Scanner App (0) | 3 |
| scan scanner | — | 6 harfda, #1 | — | — | CamScanner - PDF Scanner App (0); Document PDF Scanner. (0); QR & Barcode Scan (0) | 3 |
| scan free | — | 6 harfda, #1 | — | — | Free PDF Scanner App for Doc (0); Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0) | 3 |
| scan documents free | — | 6 harfda, #2 | — | — | Adobe Scan: PDF & OCR Scanner (0); Free PDF Scanner App for Doc (0); CamScanner - PDF Scanner App (0) | 3 |
| scan photos free | — | 6 harfda, #2 | — | — | PhotoScan by Google Photos (0); Photo Scanner App by Photomyne (0); Photo Scanner: Scan old Albums (0) | 3 |
| scan to pdf | — | 6 harfda, #2 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); iScanner: PDF Docs Scanner App (0) | 3 |
| scan photos | — | 6 harfda, #3 | — | — | PhotoScan by Google Photos (0); Photo Scanner App by Photomyne (0); CamScanner - PDF Scanner App (0) | 3 |
| free document scanner apps | — | 6 harfda, #5 | — | — | Free PDF Scanner App for Doc (0); Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0) | 3 |
| scanner to pdf | — | 6 harfda, #5 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); PDF Scanner App: TapScanner (0) | 3 |
| scan pdf free | — | 6 harfda, #5 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); Scanner App: Genius Scan (0) | 3 |
| free scanner app free | — | 6 harfda, #6 | — | — | Free PDF Scanner App for Doc (0); CamScanner - PDF Scanner App (0); Scanner App for iPhone (0) | 3 |
| scanner app for documents | — | 6 harfda, #7 | — | — | iScanner: PDF Docs Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0) | 3 |
| free pdf scanner app | — | 7 harfda, #2 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); Free PDF Scanner App for Doc (0) | 3 |
| pdf document scanner editor | — | 8 harfda, #10 | — | — | PDF Document Scanner Editor (0); PDF Reader - OCR Scan Edit (0); PDF Reader: Edit & OCR Scan (0) | 3 |
| mobile document scanner ocr | — | 9 harfda, #6 | — | — | iScanner: PDF Docs Scanner App (0); Scanner – Scan PDF & Document (0); Mobile Scanner App - Scan PDF (0) | 3 |

### IN — App Store tili: `en` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| doc scanner | — | 1 harfda, #8 | — | — | Document Scanner by Lufick (0); Doc Scanner . (0); Adobe Scan: PDF & OCR Scanner (0) | 3 |
| scanner for iphone | — | 2 harfda, #2 | — | — | Cam Scan for PDF & Doc Scanner (0); Adobe Scan: PDF & OCR Scanner (0); Document Scanner by Lufick (0) | 3 |
| pdf scanner | — | 2 harfda, #2 | — | — | Document Scanner by Lufick (0); Adobe Scan: PDF & OCR Scanner (0); PDF Scanner・Document Scanner (0) | 3 |
| scanner | — | 2 harfda, #3 | — | — | Cam Scan for PDF & Doc Scanner (0); Adobe Scan: PDF & OCR Scanner (0); Document Scanner by Lufick (0) | 3 |
| pdf scanner for iphone | — | 2 harfda, #7 | — | — | Cam Scan for PDF & Doc Scanner (0); Adobe Scan: PDF & OCR Scanner (0); Document Scanner by Lufick (0) | 3 |
| document scanner | — | 2 harfda, #8 | — | — | Document Scanner by Lufick (0); Adobe Scan: PDF & OCR Scanner (0); Cam Scan for PDF & Doc Scanner (0) | 3 |
| scan document | — | 3 harfda, #6 | — | — | Document Scanner by Lufick (0); Adobe Scan: PDF & OCR Scanner (0); Cam Scan for PDF & Doc Scanner (0) | 3 |
| scanner for iphone free | — | 4 harfda, #7 | — | — | Document Scanner by Lufick (0); Adobe Scan: PDF & OCR Scanner (0); Scanner App for iPhone (0) | 3 |
| document scanner, pdf scanner | — | 4 harfda, #8 | — | — | Document Scanner by Lufick (0); Adobe Scan: PDF & OCR Scanner (0); Cam Scan for PDF & Doc Scanner (0) | 3 |
| pdf scanner free | — | 5 harfda, #4 | — | — | Document Scanner by Lufick (0); Adobe Scan: PDF & OCR Scanner (0); PDF Scanner・Document Scanner (0) | 3 |
| document scanner pdf creator | — | 5 harfda, #9 | — | — | Document Scanner by Lufick (0); Adobe Scan: PDF & OCR Scanner (0); PDF Scanner : Maker & Editor • (0) | 3 |
| scan and pdf maker | — | 6 harfda, #1 | — | — | Document Scanner by Lufick (0); Adobe Scan: PDF & OCR Scanner (0); PDF Scanner : Maker & Editor • (0) | 3 |
| scan my document | — | 6 harfda, #1 | — | — | Scan My Document - PDF Scanner (0); Scan My Document (0); My Scanner: Scan to PDF & Edit (0) | 3 |
| scan to pdf free | — | 6 harfda, #1 | — | — | Adobe Scan: PDF & OCR Scanner (0); Cam Scan for PDF & Doc Scanner (0); Document Scanner by Lufick (0) | 3 |
| scan scanner | — | 6 harfda, #1 | — | — | Cam Scan for PDF & Doc Scanner (0); Document Scanner by Lufick (0); Clear Scan: Doc Scanner App (0) | 3 |
| scan camera | — | 6 harfda, #1 | — | — | Cam Scan for PDF & Doc Scanner (0); CamScanner - Scan Document (0); Hidden Camera Detector - Peek (0) | 3 |
| scan document to pdf | — | 6 harfda, #2 | — | — | Document Scanner by Lufick (0); Adobe Scan: PDF & OCR Scanner (0); Cam Scan for PDF & Doc Scanner (0) | 3 |
| scan pdf maker | — | 6 harfda, #2 | — | — | Cam Scan for PDF & Doc Scanner (0); Adobe Scan: PDF & OCR Scanner (0); Document Scanner by Lufick (0) | 3 |
| scan to pdf | — | 6 harfda, #2 | — | — | Cam Scan for PDF & Doc Scanner (0); Adobe Scan: PDF & OCR Scanner (0); PDF Scanner : Maker & Editor • (0) | 3 |
| scan image | — | 6 harfda, #2 | — | — | iScanner: PDF Doc Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); PDF Scanner : Maker & Editor • (0) | 3 |
| scan and make pdf | — | 6 harfda, #3 | — | — | Cam Scan for PDF & Doc Scanner (0); Adobe Scan: PDF & OCR Scanner (0); PDF Scanner : Maker & Editor • (0) | 3 |
| scan image to pdf | — | 6 harfda, #3 | — | — | Adobe Scan: PDF & OCR Scanner (0); Cam Scan for PDF & Doc Scanner (0); Image to PDF Converter & Edit (0) | 3 |
| scan photo to pdf | — | 6 harfda, #3 | — | — | Cam Scan for PDF & Doc Scanner (0); Photos PDF Scanner & Converter (0); Adobe Scan: PDF & OCR Scanner (0) | 3 |
| scan document free | — | 6 harfda, #4 | — | — | Cam Scan for PDF & Doc Scanner (0); Adobe Scan: PDF & OCR Scanner (0); Cam Scan for PDF Scanner (0) | 3 |
| scan pdf free | — | 6 harfda, #4 | — | — | Adobe Scan: PDF & OCR Scanner (0); Document Scanner by Lufick (0); iScanner: PDF Doc Scanner App (0) | 3 |

### DE — App Store tili: `de` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| pdf scanner | — | 2 harfda, #2 | — | — | Adobe Scan: PDF Scanner App (0); PDF Maker: Document Scanner (0); CamScanner - PDF Scanner App (0) | 3 |
| scanner app | — | 2 harfda, #2 | — | — | Scanner – PDF & Dokumente (0); CamScanner - PDF Scanner App (0); Adobe Scan: PDF Scanner App (0) | 3 |
| scanner app kostenlos | — | 2 harfda, #5 | — | — | Adobe Scan: PDF Scanner App (0); iScanner - Dokumenten Scanner (0); QR Code Scanner · (0) | 3 |
| pdf scanner kostenlos | — | 2 harfda, #6 | — | — | PDF Scanner App - Scan & Sign (0); PDF Maker: Document Scanner (0); Adobe Scan: PDF Scanner App (0) | 3 |
| dokumente scannen | — | 3 harfda, #2 | — | — | Adobe Scan: PDF Scanner App (0); iScanner - Dokumenten Scanner (0); ScanMe - PDF-Scanner-App (0) | 3 |
| dokumente scannen kostenlos | — | 3 harfda, #10 | — | — | Adobe Scan: PDF Scanner App (0); iScanner - Dokumenten Scanner (0); CamScanner - PDF Scanner App (0) | 3 |
| scan to pdf | — | 4 harfda, #5 | — | — | Adobe Scan: PDF Scanner App (0); CamScanner - PDF Scanner App (0); Scanner App: Genius Scan (0) | 3 |
| quick scan kostenlos | — | 4 harfda, #8 | — | — | OCR Scanner - QuickScan (0); QR Code & Barcode Scanner (0); QuickScan: Dokumenten Scanner (0) | 3 |
| scannen kostenlos | — | 5 harfda, #4 | — | — | Adobe Scan: PDF Scanner App (0); QR Code Scanner · (0); iScanner - Dokumenten Scanner (0) | 3 |
| pdf scanner app kostenlos | — | 5 harfda, #5 | — | — | Adobe Scan: PDF Scanner App (0); CamScanner - PDF Scanner App (0); iScanner - Dokumenten Scanner (0) | 3 |
| scanner app gratis | — | 5 harfda, #5 | — | — | QR Code & Barcode Scanner (0); iScanner - Dokumenten Scanner (0); Adobe Scan: PDF Scanner App (0) | 3 |
| document scanner free | — | 5 harfda, #6 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF Scanner App (0); EasyScan: Document Scanner (0) | 3 |
| pdf scanner gratis | — | 5 harfda, #8 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF Scanner App (0); iScanner - Dokumenten Scanner (0) | 3 |
| pdf scanner free | — | 5 harfda, #9 | — | — | iScanner - Dokumenten Scanner (0); CamScanner - PDF Scanner App (0); Adobe Scan: PDF Scanner App (0) | 3 |
| scan app kostenlos | — | 6 harfda, #1 | — | — | Adobe Scan: PDF Scanner App (0); Scanner App: Genius Scan (0); CamScanner - PDF Scanner App (0) | 3 |
| scan documents | — | 6 harfda, #1 | — | — | Adobe Scan: PDF Scanner App (0); Scanner – PDF & Dokumente (0); CamScanner - PDF Scanner App (0) | 3 |
| scan pdf free | — | 6 harfda, #1 | — | — | Adobe Scan: PDF Scanner App (0); CamScanner - PDF Scanner App (0); iScanner - Dokumenten Scanner (0) | 3 |
| scan to pdf kostenlos | — | 6 harfda, #3 | — | — | PDF Maker: Document Scanner (0); iScanner - Dokumenten Scanner (0); Adobe Scan: PDF Scanner App (0) | 3 |
| scan kostenlos | — | 6 harfda, #3 | — | — | Adobe Scan: PDF Scanner App (0); Scanner App: Genius Scan (0); iScanner - Dokumenten Scanner (0) | 3 |
| scan scanner | — | 6 harfda, #3 | — | — | CamScanner - PDF Scanner App (0); Scanner PDF: dokumente scannen (0); Scanner App, Digitale Unterschrift & PDF Form Filler. Dokumente Scannen & Bearbeiten (0) | 3 |
| scan photos | — | 6 harfda, #4 | — | — | Fotoscanner von Google Fotos (0); Fotoscanner von Photomyne (0); CamScanner - PDF Scanner App (0) | 3 |
| pdf scan kostenlos | — | 6 harfda, #5 | — | — | Adobe Scan: PDF Scanner App (0); PDF Maker: Document Scanner (0); CamScanner - PDF Scanner App (0) | 3 |
| pdf scanner document | — | 6 harfda, #6 | — | — | Scanner – PDF & Dokumente (0); CamScanner - PDF Scanner App (0); PDF Scanner: Document Scan PDF (0) | 3 |
| scannen pdf kostenlos | — | 9 harfda, #2 | — | — | Adobe Scan: PDF Scanner App (0); PDF Maker: Document Scanner (0); Scanner – PDF & Dokumente (0) | 3 |
| scannen pdf dokumenten scanner | — | 9 harfda, #5 | — | — | Scanner – PDF & Dokumente (0); Scanner App dokumente scannen (0); Scannen von Dokumenten als PDF (0) | 3 |

### FR — App Store tili: `fr` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| scanner gratuit | — | 2 harfda, #1 | — | — | Scanner – Scan PDF & Document (0); CamScanner - PDF Scanner App (0); iScanner - Scanner document (0) | 3 |
| pdf scanner gratuit | — | 2 harfda, #2 | — | — | Scanner PDF・Scanner Document (0); CamScanner - PDF Scanner App (0); Scanner – Scan PDF & Document (0) | 3 |
| scanner pdf | — | 2 harfda, #4 | — | — | Scanner – Scan PDF & Document (0); CamScanner - PDF Scanner App (0); Scanner PDF・Scanner Document (0) | 3 |
| scan | — | 2 harfda, #6 | — | — | CamScanner - PDF Scanner App (0); Scanner – Scan PDF & Document (0); Scanner App: Genius Scan (0) | 3 |
| scan pdf gratuit | — | 3 harfda, #5 | — | — | Scanner PDF・Scanner Document (0); CamScanner - PDF Scanner App (0); Scanner – Scan PDF & Document (0) | 3 |
| scanner | — | 3 harfda, #6 | — | — | Scanner – Scan PDF & Document (0); CamScanner - PDF Scanner App (0); iScanner - Scanner document (0) | 3 |
| scan document | — | 4 harfda, #7 | — | — | iScanner - Scanner document (0); CamScanner - PDF Scanner App (0); Scanner – Scan PDF & Document (0) | 3 |
| scan pdf | — | 4 harfda, #8 | — | — | Scanner – Scan PDF & Document (0); Adobe Scan : Scanner PDF, OCR (0); CamScanner - PDF Scanner App (0) | 3 |
| pdf scanner app | — | 5 harfda, #2 | — | — | Scanner PDF・Scanner Document (0); CamScanner - PDF Scanner App (0); Adobe Scan : Scanner PDF, OCR (0) | 3 |
| scanner gratuit iphone | — | 5 harfda, #5 | — | — | iScanner - Scanner document (0); CamScanner - PDF Scanner App (0); Scanner – Scan PDF & Document (0) | 3 |
| scan document gratuit | — | 6 harfda, #1 | — | — | Scanner – Scan PDF & Document (0); CamScanner - PDF Scanner App (0); iScanner - Scanner document (0) | 3 |
| scan gratuit | — | 6 harfda, #1 | — | — | PDF Scanner : Scan Document (0); CamScanner - PDF Scanner App (0); Scanner App: Genius Scan (0) | 3 |
| scan scanner | — | 6 harfda, #1 | — | — | CamScanner - PDF Scanner App (0); Clear Scan: scanner document (0); Scanner App: Genius Scan (0) | 3 |
| scan en pdf | — | 6 harfda, #1 | — | — | Scanner – Scan PDF & Document (0); CamScanner - PDF Scanner App (0); Scanner PDF・Scanner Document (0) | 3 |
| scan scanner gratuit | — | 6 harfda, #2 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan : Scanner PDF, OCR (0); Clear Scan: scanner document (0) | 3 |
| scan to pdf | — | 6 harfda, #2 | — | — | CamScanner - PDF Scanner App (0); iScanner - Scanner document (0); Scanner – Scan PDF & Document (0) | 3 |
| scan photo | — | 6 harfda, #2 | — | — | PhotoScan, par Google Photos (0); CamScanner - PDF Scanner App (0); Scanner Photo de Photomyne (0) | 3 |
| scan document pdf gratuit | — | 6 harfda, #3 | — | — | iScanner - Scanner document (0); Adobe Scan : Scanner PDF, OCR (0); Lecteur PDF Gratuit. Scanner, Convertir, Modifier et Signer des Documents (0) | 3 |
| scan to pdf gratuit | — | 6 harfda, #4 | — | — | Scanner PDF・Scanner Document (0); CamScanner - PDF Scanner App (0); Mobile Scanner - Scan to PDF (0) | 3 |
| scan document pdf | — | 6 harfda, #4 | — | — | CamScanner - PDF Scanner App (0); Scanner – Scan PDF & Document (0); Adobe Scan : Scanner PDF, OCR (0) | 3 |
| scan fichier | — | 6 harfda, #4 | — | — | PDFgear Scan: PDF Scanner App (0); CamScanner - PDF Scanner App (0); Adobe Acrobat Reader: Lire PDF (0) | 3 |
| scan doc gratuit | — | 6 harfda, #7 | — | — | Scanner App: Genius Scan (0); iScanner - Scanner document (0); Clear Scan: scanner document (0) | 3 |
| paper scanner document scan | — | 8 harfda, #5 | — | — | Scanner – Scan PDF & Document (0); CamScanner - PDF Scanner App (0); Adobe Scan : Scanner PDF, OCR (0) | 3 |
| scanner document | — | 9 harfda, #1 | — | — | Scanner – Scan PDF & Document (0); CamScanner - PDF Scanner App (0); iScanner - Scanner document (0) | 3 |
| scanner document gratuit | — | 9 harfda, #2 | — | — | Scanner – Scan PDF & Document (0); CamScanner - PDF Scanner App (0); Scanner Pro: Scanner documents (0) | 3 |

### ES — App Store tili: `es` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| escanear documentos | — | 2 harfda, #1 | — | — | CamScanner:Escanear Documentos (0); Scanner – Escanear PDF & Docs (0); Adobe Scan: Escáner PDF y OCR (0) | 3 |
| escaner gratis | — | 2 harfda, #2 | — | — | CamScanner:Escanear Documentos (0); Lector código QR y barras (0); Adobe Scan: Escáner PDF y OCR (0) | 3 |
| pdf scanner | — | 2 harfda, #3 | — | — | CamScanner:Escanear Documentos (0); Escanear Documentos PDF (0); Adobe Scan: Escáner PDF y OCR (0) | 3 |
| scanner | — | 2 harfda, #3 | — | — | CamScanner:Escanear Documentos (0); Scanner – Escanear PDF & Docs (0); Adobe Scan: Escáner PDF y OCR (0) | 3 |
| escaner | — | 2 harfda, #5 | — | — | CamScanner:Escanear Documentos (0); Lector código QR y barras (0); Scanner – Escanear PDF & Docs (0) | 3 |
| escanear documentos gratis | — | 3 harfda, #6 | — | — | Escanear Documentos: Escáner (0); CamScanner:Escanear Documentos (0); Adobe Scan: Escáner PDF y OCR (0) | 3 |
| scanner gratis | — | 3 harfda, #6 | — | — | CamScanner:Escanear Documentos (0); Scanner – Escanear PDF & Docs (0); Adobe Scan: Escáner PDF y OCR (0) | 3 |
| escanear | — | 3 harfda, #7 | — | — | CamScanner:Escanear Documentos (0); Lector código QR y barras (0); Escanear Documentos: Escáner (0) | 3 |
| escaner pdf | — | 3 harfda, #9 | — | — | CamScanner:Escanear Documentos (0); Adobe Scan: Escáner PDF y OCR (0); Escanear Documentos PDF (0) | 3 |
| escáner documentos | — | 4 harfda, #1 | — | — | CamScanner:Escanear Documentos (0); Adobe Scan: Escáner PDF y OCR (0); Escanear Documentos: Escáner (0) | 3 |
| escáner documentos gratis | — | 4 harfda, #2 | — | — | CamScanner:Escanear Documentos (0); Adobe Scan: Escáner PDF y OCR (0); Escanear Documentos TapScanner (0) | 3 |
| pdf scanner gratis | — | 5 harfda, #2 | — | — | CamScanner:Escanear Documentos (0); Escanear Documentos: Escáner (0); Adobe Scan: Escáner PDF y OCR (0) | 3 |
| pdf scanner free | — | 5 harfda, #4 | — | — | CamScanner:Escanear Documentos (0); Adobe Scan: Escáner PDF y OCR (0); Scanner App: Genius Scan (0) | 3 |
| pdf scan gratis | — | 5 harfda, #5 | — | — | CamScanner:Escanear Documentos (0); Scan Hero: Escáner PDF (0); Mobile Scanner - Escáner PDF (0) | 3 |
| escaner pdf gratis | — | 5 harfda, #8 | — | — | CamScanner:Escanear Documentos (0); Adobe Scan: Escáner PDF y OCR (0); Escanear Documentos: Escáner (0) | 3 |
| pdf editor y escáner | — | 5 harfda, #9 | — | — | PDF Editor y Escáner (0); Paquete Office Document Suite - Word, XLS, PDF Editor (0); CamScanner:Escanear Documentos (0) | 3 |
| free pdf scan | — | 6 harfda, #4 | — | — | CamScanner:Escanear Documentos (0); Scanner – Escanear PDF & Docs (0); Adobe Scan: Escáner PDF y OCR (0) | 3 |
| pdf escanear documentos scan | — | 6 harfda, #7 | — | — | CamScanner:Escanear Documentos (0); PDF escanear documentos scan (0); Escaner Documentos PDF Scanner (0) | 3 |
| escanear documentos pdf | — | 7 harfda, #9 | — | — | Escanear Documentos PDF (0); CamScanner:Escanear Documentos (0); Adobe Scan: Escáner PDF y OCR (0) | 3 |
| mobile scanner pdf app | — | 8 harfda, #3 | — | — | Mobile Scanner - Escáner PDF (0); Adobe Scan: Escáner PDF y OCR (0); Adobe Acrobat Reader Firma PDF (0) | 3 |
| scanner documentos | — | 9 harfda, #1 | — | — | CamScanner:Escanear Documentos (0); Scanner – Escanear PDF & Docs (0); Escaner Documentos PDF Scanner (0) | 3 |
| escaner de documentos | — | 9 harfda, #5 | — | — | CamScanner:Escanear Documentos (0); Adobe Scan: Escáner PDF y OCR (0); Scan Shot: Escanear Documentos (0) | 3 |
| escáner fotos y pdf | — | 9 harfda, #6 | — | — | Scanner Mini – Escanea a PDF (0); Scanner App: PDF y documentos (0); CamScanner:Escanear Documentos (0) | 3 |
| escanear pdf gratis | — | 10 harfda, #1 | — | — | CamScanner:Escanear Documentos (0); Adobe Scan: Escáner PDF y OCR (0); iLovePDF- Editor PDF y Escáner (0) | 3 |
| escanear fotos a pdf | — | 10 harfda, #3 | — | — | CamScanner:Escanear Documentos (0); Escanear & Convertir PDF App (0); Adobe Scan: Escáner PDF y OCR (0) | 3 |

### IT — App Store tili: `it` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| scanner | — | 2 harfda, #5 | — | — | CamScanner - PDF Scanner App (0); Scanner - Scansiona Documenti (0); Adobe Scan: Scansione PDF, OCR (0) | 3 |
| scanner pdf | — | 2 harfda, #6 | — | — | CamScanner - PDF Scanner App (0); Scanner - Scansiona Documenti (0); Adobe Scan: Scansione PDF, OCR (0) | 3 |
| scanner gratis | — | 2 harfda, #8 | — | — | CamScanner - PDF Scanner App (0); Scanner - Scansiona Documenti (0); Adobe Scan: Scansione PDF, OCR (0) | 3 |
| scansione documenti | — | 3 harfda, #9 | — | — | Adobe Scan: Scansione PDF, OCR (0); CamScanner - PDF Scanner App (0); iScanner - Scanner PDF (0) | 3 |
| scanner pdf gratis iphone | — | 4 harfda, #10 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: Scansione PDF, OCR (0); iScanner - Scanner PDF (0) | 3 |
| pdf scanner app | — | 5 harfda, #1 | — | — | CamScanner - PDF Scanner App (0); Scanner PDF・Document Scanner (0); Adobe Scan: Scansione PDF, OCR (0) | 3 |
| scansione documenti gratis | — | 5 harfda, #2 | — | — | CamScanner - PDF Scanner App (0); Scanner App・ documenti in PDF (0); Adobe Scan: Scansione PDF, OCR (0) | 3 |
| scansiona documenti pdf | — | 5 harfda, #4 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: Scansione PDF, OCR (0); iScanner - Scanner PDF (0) | 3 |
| pdf scanner | — | 5 harfda, #4 | — | — | CamScanner - PDF Scanner App (0); Scanner PDF・Document Scanner (0); Adobe Scan: Scansione PDF, OCR (0) | 3 |
| pdf scanner documenti | — | 5 harfda, #5 | — | — | Scanner PDF – scan documents (0); CamScanner - PDF Scanner App (0); Scanner PDF: Foto e Documenti (0) | 3 |
| scanner documenti | — | 5 harfda, #7 | — | — | CamScanner - PDF Scanner App (0); Scanner - Scansiona Documenti (0); Adobe Scan: Scansione PDF, OCR (0) | 3 |
| scansione | — | 5 harfda, #7 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: Scansione PDF, OCR (0); iScanner - Scanner PDF (0) | 3 |
| scansiona documenti | — | 5 harfda, #10 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: Scansione PDF, OCR (0); Scan Shot: Scanner Documenti (0) | 3 |
| app scanner gratis | — | 6 harfda, #6 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: Scansione PDF, OCR (0); iScanner - Scanner PDF (0) | 3 |
| app scansione documenti | — | 7 harfda, #2 | — | — | Adobe Scan: Scansione PDF, OCR (0); CamScanner - PDF Scanner App (0); iScanner - Scanner PDF (0) | 3 |
| mobile scanner pdf app | — | 8 harfda, #2 | — | — | Mobile Scanner - Scan to PDF (0); Adobe Scan: Scansione PDF, OCR (0); CamScanner - PDF Scanner App (0) | 3 |
| scanner gratis per iphone | — | 9 harfda, #1 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: Scansione PDF, OCR (0); iScanner - Scanner PDF (0) | 3 |
| scanner iphone | — | 9 harfda, #1 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: Scansione PDF, OCR (0); Scanner - Scansiona Documenti (0) | 3 |
| scansiona documenti pdf gratis | — | 9 harfda, #2 | — | — | Adobe Scan: Scansione PDF, OCR (0); CamScanner - PDF Scanner App (0); iScanner - Scanner PDF (0) | 3 |
| scanner documenti gratis | — | 9 harfda, #2 | — | — | Scanner - Scansiona Documenti (0); CamScanner - PDF Scanner App (0); Adobe Scan: Scansione PDF, OCR (0) | 3 |
| scanner immagini | — | 9 harfda, #2 | — | — | Scanner - Scansiona Documenti (0); CamScanner - PDF Scanner App (0); Adobe Scan: Scansione PDF, OCR (0) | 3 |
| scanner document pdf | — | 9 harfda, #3 | — | — | CamScanner - PDF Scanner App (0); Scanner - Scansiona Documenti (0); Adobe Scan: Scansione PDF, OCR (0) | 3 |
| scansione documenti pdf | — | 9 harfda, #4 | — | — | Scan Hero: Scanner PDF (0); Adobe Scan: Scansione PDF, OCR (0); CamScanner - PDF Scanner App (0) | 3 |
| scanner pdf gratis | — | 9 harfda, #4 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: Scansione PDF, OCR (0); iScanner - Scanner PDF (0) | 3 |
| scansione pdf gratis | — | 11 harfda, #1 | — | — | Mobile Scanner - Scan to PDF (0); CamScanner - PDF Scanner App (0); Adobe Scan: Scansione PDF, OCR (0) | 3 |

### BR — App Store tili: `pt` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| scanner | — | 2 harfda, #2 | 79 | 166 | CamScanner - PDF Scanner App (655,215); Adobe Scan: PDF Scanner e OCR (344,367); iScanner - Digitalizador PDF (327,056) | 3 |
| pdf scanner | — | 2 harfda, #4 | 72 | 172 | CamScanner - PDF Scanner App (655,215); Digitalizador Documentos PDF (8,196); PDF Scanner  ‎ (11) | 3 |
| digitalizar documentos pdf | — | 2 harfda, #6 | 52 | 177 | CamScanner - PDF Scanner App (655,215); Adobe Scan: PDF Scanner e OCR (344,367); iScanner - Digitalizador PDF (327,056) | 3 |
| scanner gratis | — | 3 harfda, #5 | 53 | 177 | CamScanner - PDF Scanner App (655,215); Adobe Scan: PDF Scanner e OCR (344,367); iScanner - Digitalizador PDF (327,056) | 3 |
| escanear documentos | — | 3 harfda, #6 | 33 | 181 | CamScanner - PDF Scanner App (655,215); Adobe Scan: PDF Scanner e OCR (344,367); Scanner de Documentos em PDF (19,304) | 3 |
| digitalizar | — | 3 harfda, #8 | 56 | 168 | CamScanner - PDF Scanner App (655,215); iScanner - Digitalizador PDF (327,056); Adobe Scan: PDF Scanner e OCR (344,367) | 3 |
| escanear | — | 4 harfda, #4 | 58 | 176 | CamScanner - PDF Scanner App (655,215); Adobe Scan: PDF Scanner e OCR (344,367); Scanner de Documentos em PDF (19,304) | 3 |
| escanear documentos gratis | — | 4 harfda, #7 | 21 | 183 | CamScanner - PDF Scanner App (655,215); Adobe Scan: PDF Scanner e OCR (344,367); Digitalizar Documentos em PDF (49) | 3 |
| scanner pdf gratis | — | 4 harfda, #7 | 48 | 168 | CamScanner - PDF Scanner App (655,215); Digitalizador Documentos PDF (8,196); Adobe Scan: PDF Scanner e OCR (344,367) | 3 |
| pdf scanner de documentos | — | 5 harfda, #3 | 8 | 184 | Digitalizador Documentos PDF (8,196); CamScanner - PDF Scanner App (655,215); PDF: Scanner de documentos (140) | 3 |
| pdf scanner free | — | 5 harfda, #4 | 12 | 178 | CamScanner - PDF Scanner App (655,215); Adobe Scan: PDF Scanner e OCR (344,367); Digitalizador Documentos PDF (8,196) | 3 |
| escanear pdf | — | 5 harfda, #5 | 16 | 185 | CamScanner - PDF Scanner App (655,215); Adobe Scan: PDF Scanner e OCR (344,367); Digitalizador Documentos PDF (8,196) | 3 |
| app scanner grátis | — | 6 harfda, #2 | 48 | 180 | CamScanner - PDF Scanner App (655,215); Scanner - PDF Scaner · (47,882); Adobe Scan: PDF Scanner e OCR (344,367) | 3 |
| escanear pdf gratis | — | 8 harfda, #4 | 36 | 169 | CamScanner - PDF Scanner App (655,215); Converter para PDF: Imagem PDF (0); Digitalizador Documentos PDF (8,196) | 3 |
| digitalizar documentos pdf gratis | — | 8 harfda, #9 | 48 | 181 | CamScanner - PDF Scanner App (655,215); PDF Scanner \| Digitalizador. (95); PDF Scanner: Digitalizar \| (16) | 3 |
| scanner documento | — | 9 harfda, #2 | 51 | 171 | CamScanner - PDF Scanner App (655,215); Scanner – Digitalizar & PDF (7,301); Scanner de Documentos em PDF (19,304) | 3 |
| app de escanear documento | — | 9 harfda, #3 | 49 | 176 | CamScanner - PDF Scanner App (655,215); Adobe Scan: PDF Scanner e OCR (344,367); Scanner de Documentos em PDF (19,304) | 3 |
| escanear para pdf | — | 10 harfda, #1 | 36 | 180 | Digitalizador Documentos PDF (8,196); CamScanner - PDF Scanner App (655,215); Conversor & Escaner para PDF (115) | 3 |
| escanear documento pdf | — | 10 harfda, #2 | 14 | 182 | CamScanner - PDF Scanner App (655,215); Scanner App: Digitalizador PDF (12); Digitalizador Documentos PDF (8,196) | 3 |
| escanear foto para pdf | — | 10 harfda, #2 | 14 | 190 | CamScanner - PDF Scanner App (655,215); Converter para PDF: Imagem PDF (0); Scanner - PDF Scaner · (47,882) | 3 |
| app para digitalizar documento | — | 10 harfda, #6 | 47 | 169 | CamScanner - PDF Scanner App (655,215); Conversor de PDF - PDF em Word (22,001); Fotos PDF: Scanner e Conversor (14,272) | 3 |
| escanear pdf e documentos | — | 10 harfda, #6 | 30 | 178 | Escanear PDF e Documentos (0); Converter para PDF: Imagem PDF (0); Scan Shot: Scanner Documentos (14,151) | 3 |
| digitalizar documentos gratis | — | 11 harfda, #7 | 49 | 182 | CamScanner - PDF Scanner App (655,215); Digitalizador Documentos PDF (8,196); Adobe Scan: PDF Scanner e OCR (344,367) | 3 |
| scanner pdf, assinatura | — | 12 harfda, #2 | 52 | 187 | Scanner PDF, assinatura (29); eSign: Assinatura Digital PDF (12,048); Assinar PDF – Scan Assinatura (0) | 3 |
| scanner pdf para documentos | — | 13 harfda, #1 | 27 | 186 | Converter para PDF: Imagem PDF (0); PDF Scanner: Escanear, Editar (188); Digitalizador Documentos PDF (8,196) | 3 |

### MX — App Store tili: `es` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|

### JP — App Store tili: `ja` · ilova lokalizatsiyasi: ❌ yo‘q (tavsiya: qo‘shish)

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| 書類 スキャン 無料 | — | 1 harfda, #4 | 50 | 181 | Adobe Scan: OCR付モバイルスキャナーアプリ (319,433); CamScanner- スキャン、PDF 変換、翻訳 カメラ (72,553); 簡単スキャナー 〜こまかめ〜 (461) | 3 |
| スキャン | — | 2 harfda, #2 | 64 | 176 | CamScanner- スキャン、PDF 変換、翻訳 カメラ (72,553); Adobe Scan: OCR付モバイルスキャナーアプリ (319,433); フォトスキャン by Google フォト (51,733) | 3 |
| pdf スキャン | — | 2 harfda, #5 | 53 | 176 | Adobe Scan: OCR付モバイルスキャナーアプリ (319,433); CamScanner- スキャン、PDF 変換、翻訳 カメラ (72,553); スキャナー プロ (Scanner Pro) (15,550) | 3 |
| スキャナー | — | 2 harfda, #5 | 67 | 171 | CamScanner- スキャン、PDF 変換、翻訳 カメラ (72,553); Adobe Scan: OCR付モバイルスキャナーアプリ (319,433); スキャナー プロ (Scanner Pro) (15,550) | 3 |
| スキャン 無料 | — | 2 harfda, #8 | 52 | 177 | Adobe Scan: OCR付モバイルスキャナーアプリ (319,433); CamScanner- スキャン、PDF 変換、翻訳 カメラ (72,553); らくらくスキャン - OCR＆書類をスキャン (0) | 3 |
| 書類 スキャン pdf | — | 2 harfda, #10 | 28 | 185 | PDFスキャナー: 写真をPDFに変換 & 書類スキャン (392); Adobe Scan: OCR付モバイルスキャナーアプリ (319,433); CamScanner- スキャン、PDF 変換、翻訳 カメラ (72,553) | 3 |
| スキャナー 無料 | — | 4 harfda, #3 | 31 | 180 | CamScanner- スキャン、PDF 変換、翻訳 カメラ (72,553); Adobe Scan: OCR付モバイルスキャナーアプリ (319,433); スキャナー プロ (Scanner Pro) (15,550) | 3 |
| pdf scanner | — | 5 harfda, #1 | 34 | 175 | CamScanner- スキャン、PDF 変換、翻訳 カメラ (72,553); Adobe Scan: OCR付モバイルスキャナーアプリ (319,433); スキャナーアプリ PDF・カメラスキャナー・文書 スキャン (27) | 3 |
| pdf スキャン 無料 | — | 5 harfda, #2 | 45 | 177 | Adobe Scan: OCR付モバイルスキャナーアプリ (319,433); CamScanner- スキャン、PDF 変換、翻訳 カメラ (72,553); スキャナー プロ (Scanner Pro) (15,550) | 3 |
| スキャン カメラ pdf | — | 6 harfda, #1 | 37 | 186 | Adobe Scan: OCR付モバイルスキャナーアプリ (319,433); CamScanner- スキャン、PDF 変換、翻訳 カメラ (72,553); Mobile Scanner - 書類やフォトスキャン (6,885) | 3 |
| スキャン アプリ | — | 6 harfda, #1 | 50 | 177 | Adobe Scan: OCR付モバイルスキャナーアプリ (319,433); CamScanner- スキャン、PDF 変換、翻訳 カメラ (72,553); フォトスキャン by Google フォト (51,733) | 3 |
| スキャナー アプリ | — | taklif qilinmaydi | 32 | 191 | スキャナーアプリ (2,035); プリンター: AIスキャナー・PDF (12); OBD2スキャナー エンジン音付き (1) | 3 |
| 書類 スキャン | — | taklif qilinmaydi | 50 | 179 | Adobe Scan: OCR付モバイルスキャナーアプリ (319,433); CamScanner- スキャン、PDF 変換、翻訳 カメラ (72,553); 書類スキャン - OCR・文字認識・領収書・名刺 (6) | 3 |
| ocr | — | 2 harfda, #7 | 50 | 184 | Adobe Scan: OCR付モバイルスキャナーアプリ (319,433); 撮るだけ文字認識 (2,576); CamScanner- スキャン、PDF 変換、翻訳 カメラ (72,553) | 2 |
| 写真 スキャナー | — | 4 harfda, #6 | 49 | 182 | フォトスキャン by Google フォト (51,733); CamScanner- スキャン、PDF 変換、翻訳 カメラ (72,553); Adobe Scan: OCR付モバイルスキャナーアプリ (319,433) | 2 |
| pdf ocr | — | 5 harfda, #1 | 43 | 188 | Adobe Scan: OCR付モバイルスキャナーアプリ (319,433); Adobe Acrobat Reader：PDFの編集と変換 (107,564); vFlat Scan - PDF Scanner (13,341) | 2 |
| スキャン jpeg | — | 6 harfda, #1 | 41 | 176 | ScanGuru ドキュメント スキャン、PDF変換、OCR (11,999); Lens Document Scan & Editor (1); Adobe Scan: OCR付モバイルスキャナーアプリ (319,433) | 2 |
| 文字 読み取り | — | taklif qilinmaydi | 44 | 181 | 撮るだけ文字認識 (2,576); 文字読み取り - フォトスキャン、PDF 変換、翻訳 カメラ (465); 文字スキャン - OCR認識画像文字起こし (3,476) | 2 |
| pdf | — | 2 harfda, #1 | 71 | 166 | Adobe Acrobat Reader：PDFの編集と変換 (107,564); CamScanner- スキャン、PDF 変換、翻訳 カメラ (72,553); Adobe Scan: OCR付モバイルスキャナーアプリ (319,433) | 1 |
| pdf 変換 | — | 2 harfda, #2 | 65 | 178 | Adobe Acrobat Reader：PDFの編集と変換 (107,564); PDF変換 写真画像をPDF変換。オフラインでカメラスキャン (2,277); Adobe Scan: OCR付モバイルスキャナーアプリ (319,433) | 1 |
| pdf 無料 | — | 2 harfda, #3 | 55 | 175 | Adobe Acrobat Reader：PDFの編集と変換 (107,564); PDF変換 写真画像をPDF変換。オフラインでカメラスキャン (2,277); Adobe Scan: OCR付モバイルスキャナーアプリ (319,433) | 1 |
| pdf 変換 無料 | — | 3 harfda, #9 | 47 | 180 | PDF変換 写真画像をPDF変換。オフラインでカメラスキャン (2,277); Adobe Acrobat Reader：PDFの編集と変換 (107,564); Adobe Scan: OCR付モバイルスキャナーアプリ (319,433) | 1 |
| pdf reader | — | 5 harfda, #1 | 39 | 170 | PDFリーダー＆エディタ (45); Adobe Acrobat Reader：PDFの編集と変換 (107,564); PDF Reader: Edit & Sign (7) | 1 |

### KR — App Store tili: `ko` · ilova lokalizatsiyasi: ❌ yo‘q (tavsiya: qo‘shish)

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| 문서 스캔 | — | 1 harfda, #7 | 31 | 181 | vFlat Scan - PDF 스캐너 (64,578); CamScanner - 문서 스캔 & PDF 변환 (71,719); Adobe Scan: OCR & PDF 스캐너 (123,821) | 3 |
| 스캐너 | — | 2 harfda, #1 | 60 | 176 | CamScanner - 문서 스캔 & PDF 변환 (71,719); Adobe Scan: OCR & PDF 스캐너 (123,821); vFlat Scan - PDF 스캐너 (64,578) | 3 |
| 스캔 | — | 2 harfda, #2 | 63 | 183 | vFlat Scan - PDF 스캐너 (64,578); CamScanner - 문서 스캔 & PDF 변환 (71,719); Adobe Scan: OCR & PDF 스캐너 (123,821) | 3 |
| pdf 스캔 | — | 2 harfda, #4 | 56 | 178 | vFlat Scan - PDF 스캐너 (64,578); Adobe Scan: OCR & PDF 스캐너 (123,821); CamScanner - 문서 스캔 & PDF 변환 (71,719) | 3 |
| pdf scanner | — | 2 harfda, #6 | 24 | 182 | CamScanner - 문서 스캔 & PDF 변환 (71,719); Adobe Scan: OCR & PDF 스캐너 (123,821); PDF 스캐너 - 문서 스캔 및 OCR 문자 인식 (51) | 3 |
| 문서 스캔 무료 | — | 2 harfda, #7 | 16 | 190 | Adobe Scan: OCR & PDF 스캐너 (123,821); CamScanner - 문서 스캔 & PDF 변환 (71,719); 스캐너 모바일 - 문서, 사진 스캔 (473) | 3 |
| 무료 스캔 | — | 4 harfda, #1 | 18 | 183 | Adobe Scan: OCR & PDF 스캐너 (123,821); vFlat Scan - PDF 스캐너 (64,578); 스캐너 모바일 - 문서, 사진 스캔 (473) | 3 |
| 스캔 앱 | — | 4 harfda, #1 | 18 | 183 | vFlat Scan - PDF 스캐너 (64,578); CamScanner - 문서 스캔 & PDF 변환 (71,719); Adobe Scan: OCR & PDF 스캐너 (123,821) | 3 |
| 스캐너 앱 | — | 5 harfda, #1 | 33 | 189 | CamScanner - 문서 스캔 & PDF 변환 (71,719); Adobe Scan: OCR & PDF 스캐너 (123,821); vFlat Scan - PDF 스캐너 (64,578) | 3 |
| pdf 스캔 무료 | — | 5 harfda, #3 | 29 | 192 | CamScanner - 문서 스캔 & PDF 변환 (71,719); Adobe Scan: OCR & PDF 스캐너 (123,821); vFlat Scan - PDF 스캐너 (64,578) | 3 |
| 텍스트 추출 | — | 1 harfda, #8 | 49 | 185 | 스캔 및 번역 - 사진을 텍스트로 변환 (1,923); Adobe Scan: OCR & PDF 스캐너 (123,821); vFlat Scan - PDF 스캐너 (64,578) | 2 |
| ocr | — | 2 harfda, #7 | 34 | 188 | Adobe Scan: OCR & PDF 스캐너 (123,821); vFlat Scan - PDF 스캐너 (64,578); CamScanner - 문서 스캔 & PDF 변환 (71,719) | 2 |
| 사진 스캔 | — | 4 harfda, #3 | 37 | 182 | vFlat Scan - PDF 스캐너 (64,578); 포토스캐너 - Google 포토 (1,070); CamScanner - 문서 스캔 & PDF 변환 (71,719) | 2 |
| 사진 문자 인식 ocr | — | 4 harfda, #4 | 19 | 172 | 사진 문자 인식 OCR (3); 사진을글자로 - OCR (문자인식) (3); PDF 스캐너 - 문서 스캔 및 OCR 문자 인식 (51) | 2 |
| 사진 텍스트 추출 | — | 4 harfda, #5 | 8 | 159 | 사진 텍스트 추출・이미지 글자 복사 (0); OCR 텍스트 스캐너:문서 스캔 및 pdf 변환 (20); 텍스트 스캐너:인식 스캐너 필기, 추출 텍스트를 (1) | 2 |
| pdf ocr | — | 5 harfda, #1 | 26 | 189 | Adobe Scan: OCR & PDF 스캐너 (123,821); vFlat Scan - PDF 스캐너 (64,578); PDF OCR Pro (9) | 2 |
| pdf 서명 | — | 5 harfda, #1 | 19 | 186 | Adobe Acrobat Reader: PDF 편집 (27,189); PDF서명 - 문서 서명 (3); PDF Viewer by Nutrient (903) | 2 |
| 문자 인식 | — | taklif qilinmaydi | 31 | 185 | 티티리더 - 텍스트 뷰어, 이미지 문자인식 (185); PDF 스캐너 - 문서 스캔 및 OCR 문자 인식 (51); QS Scanner - 문자 인식 카메라 번역 (2) | 2 |
| pdf | — | 2 harfda, #1 | 81 | 171 | Adobe Acrobat Reader: PDF 편집 (27,189); 폴라리스 오피스 - 한글, PDF, MS문서, GPT (87,694); CamScanner - 문서 스캔 & PDF 변환 (71,719) | 1 |
| pdf 변환 | — | 2 harfda, #3 | 62 | 189 | vFlat Scan - PDF 스캐너 (64,578); Adobe Acrobat Reader: PDF 편집 (27,189); CamScanner - 문서 스캔 & PDF 변환 (71,719) | 1 |
| 서명 | — | 2 harfda, #5 | 32 | 189 | eSign: 전자서명·PDF 스캐너 (83); Adobe Acrobat Reader: PDF 편집 (27,189); PDF 문서 서명 (0) | 1 |
| pdf maker | — | 2 harfda, #10 | 21 | 178 | PDF Maker - Convert to PDF (24); PDF Maker: Scan & Edit (0); CamScanner - 문서 스캔 & PDF 변환 (71,719) | 1 |
| pdf reader | — | 5 harfda, #1 | 30 | 177 | Adobe Acrobat Reader: PDF 편집 (27,189); PDF Reader - PDF Viewer, Edit (34); PDF 리더기 및 PDF 편집기 (15) | 1 |

### RU — App Store tili: `ru` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| сканер документов | — | 1 harfda, #9 | — | — | iScanner - Сканер документов (0); CamScanner - Сканер документов (0); Сканер Документов в PDF . (0) | 3 |
| pdf сканер | — | 2 harfda, #3 | — | — | Сканер Документов・Сканер пдф (0); Adobe Scan: сканер PDF (0); PDF Сканер Документов Плюс (0) | 3 |
| сканер | — | 2 harfda, #8 | — | — | CamScanner - Сканер документов (0); Сканер Документов в PDF . (0); QR code и Штрих код сканер (0) | 3 |
| сканер документов бесплатно | — | 2 harfda, #10 | — | — | Сканер документов & фото в PDF (0); Сканер Документов в PDF . (0); Adobe Scan: сканер PDF (0) | 3 |
| скан документов | — | 4 harfda, #7 | — | — | iScanner - Сканер документов (0); Сканер Документов в PDF . (0); CamScanner - Сканер документов (0) | 3 |
| сканирование документов | — | 4 harfda, #10 | — | — | iScanner - Сканер документов (0); Сканер Документов в PDF . (0); CamScanner - Сканер документов (0) | 3 |
| pdf сканер бесплатно | — | 5 harfda, #2 | — | — | Сканер Документов в PDF . (0); Сканер Документов・Сканер пдф (0); Adobe Scan: сканер PDF (0) | 3 |
| сканирование документов бесплатно | — | 5 harfda, #4 | — | — | Adobe Scan: сканер PDF (0); CamScanner - Сканер документов (0); Сканер Документов в PDF . (0) | 3 |
| pdf сканер бесплатный | — | 5 harfda, #4 | — | — | Сканер Документов в PDF . (0); PDF Scanner Сканер документов (0); Сканер PDF: сканировать фото (0) | 3 |
| pdf ocr сканер документов | — | 5 harfda, #6 | — | — | PDF Scanner Сканер документов (0); Adobe Scan: сканер PDF (0); PDF OCR Сканер Документов (0) | 3 |
| сканер документов бесплатно pdf | — | 5 harfda, #7 | — | — | CamScanner - Сканер документов (0); Adobe Scan: сканер PDF (0); Сканер Документов в PDF . (0) | 3 |
| pdf и сканер документов | — | 5 harfda, #8 | — | — | PDF и сканер документов (0); PDF: ПДФ Файл Редактор, Сканер (0); Сканер Документов в PDF . (0) | 3 |
| сканирование | — | 5 harfda, #8 | — | — | Сканер Документов в PDF . (0); CamScanner - Сканер документов (0); QR code и Штрих код сканер (0) | 3 |
| скан документов бесплатно | — | 6 harfda, #1 | — | — | Сканер документов & фото в PDF (0); Сканер Документов в PDF . (0); CamScanner - Сканер документов (0) | 3 |
| скан бесплатный | — | 6 harfda, #1 | — | — | Сканер документов - TapScanner (0); Сканер Документов в PDF . (0); Adobe Scan: сканер PDF (0) | 3 |
| скан сканер | — | 6 harfda, #1 | — | — | CamScanner - Сканер документов (0); Car Scanner ELM OBD2 (0); PDF Scanner Сканер документов (0) | 3 |
| скан бесплатно | — | 6 harfda, #3 | — | — | PDF Сканер Документов Плюс (0); Сканер Документов в PDF . (0); CamScanner - Сканер документов (0) | 3 |
| скан для документов | — | 6 harfda, #5 | — | — | CamScanner - Сканер документов (0); iScanner - Сканер документов (0); Сканер документов & фото в PDF (0) | 3 |
| скан камера | — | 6 harfda, #5 | — | — | CamScanner - Сканер документов (0); Adobe Scan: сканер PDF (0); Сканер документов - TapScanner (0) | 3 |
| сканер бесплатно | — | 8 harfda, #2 | — | — | Cканер документов в ПДФ файл (0); Adobe Scan: сканер PDF (0); Сканер Документов в PDF . (0) | 3 |
| сканер фото в pdf | — | 8 harfda, #3 | — | — | Сканер документов & фото в PDF (0); CamScanner - Сканер документов (0); Сканер Документов в PDF . (0) | 3 |
| сканер документов pdf | — | 8 harfda, #6 | — | — | Сканер Документов・Сканер пдф (0); Сканер Документов в PDF . (0); CamScanner - Сканер документов (0) | 3 |
| сканер для документов | — | 8 harfda, #8 | — | — | CamScanner - Сканер документов (0); Сканер документов & фото в PDF (0); Сканер Документов в PDF . (0) | 3 |
| сканер pdf подпись документ | — | 12 harfda, #2 | — | — | Сканер Документов・Сканер пдф (0); Сканер документов & фото в PDF (0); eSign ‐ Электронная Подпись (0) | 3 |
| сканер pdf документов | — | 12 harfda, #3 | — | — | Сканер PDF-документов (0); Сканер PDF документов (0); Сканер Документов・Сканер пдф (0) | 3 |

### TR — App Store tili: `tr` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| scanner | — | 2 harfda, #5 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); Scanner App - Scan PDF & Docs (0) | 3 |
| tarayıcı | — | 3 harfda, #2 | — | — | Opera Browser with VPN (0); CamScanner - PDF Scanner App (0); Firefox Fast & Private Browser (0) | 3 |
| belge tarama | — | 3 harfda, #4 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); Doc Scanner - PDF Maker (0) | 3 |
| belge tarayıcı | — | 3 harfda, #9 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); PDF Scanner・Document Scanner (0) | 3 |
| tarama | — | 4 harfda, #4 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); Scan Hero: PDF Scanner (0) | 3 |
| scanner ücretsiz | — | 4 harfda, #6 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); Scan Hero: PDF Scanner (0) | 3 |
| belge tarayıcı ücretsiz | — | 4 harfda, #9 | — | — | Scan Documents to PDF l by TSP (0); CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0) | 3 |
| pdf tarayıcı | — | 5 harfda, #1 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); PDF Scanner・Document Scanner (0) | 3 |
| pdf scanner | — | 5 harfda, #1 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); PDF Scanner ⊟ (0) | 3 |
| pdf tarama ücretsiz | — | 5 harfda, #2 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); PDF Scanner - Fax, Sign & Edit (0) | 3 |
| pdf scan | — | 5 harfda, #4 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); PDF Scan (0) | 3 |
| pdf tarayıcı ücretsiz | — | 5 harfda, #5 | — | — | CamScanner - PDF Scanner App (0); Doc Scanner - PDF Maker (0); Adobe Scan: PDF & OCR Scanner (0) | 3 |
| pdf scanner ücretsiz | — | 5 harfda, #6 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); PDF Scanner Pro * (0) | 3 |
| scanner app pdf | — | 5 harfda, #7 | — | — | Scanner App - Scan PDF & Docs (0); CamScanner - PDF Scanner App (0); Doc Scanner - PDF Maker (0) | 3 |
| pdf tarama | — | 5 harfda, #7 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); Scan Hero: PDF Scanner (0) | 3 |
| pdf scanner free | — | 5 harfda, #9 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); Doc Scanner - PDF Maker (0) | 3 |
| scan pdf tarayıcı | — | 6 harfda, #2 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); Scan Hero: PDF Scanner (0) | 3 |
| mobile scanner app | — | 6 harfda, #9 | — | — | Mobile Scanner App - Scan PDF (0); CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0) | 3 |
| belge tarama pdf | — | 7 harfda, #3 | — | — | CamScanner - PDF Scanner App (0); Doc Scanner - PDF Maker (0); Adobe Scan: PDF & OCR Scanner (0) | 3 |
| scanner app | — | 9 harfda, #2 | — | — | Scanner App - Scan PDF & Docs (0); CamScanner - PDF Scanner App (0); Scanner App: Genius Scan (0) | 3 |
| scanner document pdf | — | 9 harfda, #5 | — | — | Scanner Document PDF (0); Document PDF Scanner. (0); CamScanner - PDF Scanner App (0) | 3 |
| scanner to pdf | — | 9 harfda, #7 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); Scan to PDF & Document Scanner (0) | 3 |
| ücretsiz belge tarama | — | 10 harfda, #7 | — | — | PDF Scanner・Document Scan App (0); Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0) | 3 |
| ocr metin tarayıcı | — | 3 harfda, #1 | — | — | Text Scanner OCR Scan Image (0); Text Scanner - OCR Scan Text (0); OCR Text Scanner: Extract Text (0) | 2 |
| ocr | — | 3 harfda, #3 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); Text Scanner - OCR Scan Text (0) | 2 |

### NL — App Store tili: `nl` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| pdf scanner | — | 2 harfda, #2 | — | — | Adobe Scan: PDF- & OCR-scanner (0); PDF Scanner・Documenten scannen (0); CamScanner\|Documenten scannen (0) | 3 |
| scanner gratis | — | 2 harfda, #3 | — | — | Scanner – Scan PDF & Document (0); Adobe Scan: PDF- & OCR-scanner (0); QR Code Scanner ϟ (0) | 3 |
| document scanner | — | 3 harfda, #3 | — | — | Adobe Scan: PDF- & OCR-scanner (0); iScanner - PDF-Scanner (0); Scanner App: Genius Scan (0) | 3 |
| scanner | — | 3 harfda, #4 | — | — | Adobe Scan: PDF- & OCR-scanner (0); CamScanner\|Documenten scannen (0); Scanner App: Genius Scan (0) | 3 |
| scan pdf | — | 3 harfda, #5 | — | — | Adobe Scan: PDF- & OCR-scanner (0); CamScanner\|Documenten scannen (0); Scanner App: Genius Scan (0) | 3 |
| pdf scanner gratis | — | 3 harfda, #6 | — | — | Adobe Scan: PDF- & OCR-scanner (0); Adobe Acrobat Reader PDF-maker (0); iScanner - PDF-Scanner (0) | 3 |
| document scanner gratis | — | 4 harfda, #7 | — | — | Adobe Scan: PDF- & OCR-scanner (0); Mobile Scanner - Scan to PDF (0); iScanner - PDF-Scanner (0) | 3 |
| documenten scannen | — | 4 harfda, #9 | — | — | Adobe Scan: PDF- & OCR-scanner (0); Scanner App: Genius Scan (0); CamScanner\|Documenten scannen (0) | 3 |
| document scannen | — | 4 harfda, #10 | — | — | Adobe Scan: PDF- & OCR-scanner (0); CamScanner\|Documenten scannen (0); iScanner - PDF-Scanner (0) | 3 |
| ocr pdf scanners gratis | — | 5 harfda, #1 | — | — | OCR PDF Scanners Gratis (0); CamScanner\|Documenten scannen (0); Adobe Scan: PDF- & OCR-scanner (0) | 3 |
| pdf scanner free | — | 5 harfda, #4 | — | — | CamScanner\|Documenten scannen (0); Adobe Scan: PDF- & OCR-scanner (0); Open Scan: PDF Scanner (0) | 3 |
| pdf documenten scannen editor | — | 5 harfda, #5 | — | — | PDF documenten scannen editor (0); Adobe Acrobat Reader PDF-maker (0); CamScanner\|Documenten scannen (0) | 3 |
| scannen gratis | — | 5 harfda, #5 | — | — | Adobe Scan: PDF- & OCR-scanner (0); QR Code & Barcode Scanner (0); iScanner - PDF-Scanner (0) | 3 |
| pdf ai scanner | — | 5 harfda, #6 | — | — | PDF AI Scanner (0); Scanner – Scan PDF & Document (0); Adobe Scan: PDF- & OCR-scanner (0) | 3 |
| documenten scannen gratis | — | 5 harfda, #7 | — | — | Adobe Scan: PDF- & OCR-scanner (0); Scanner App: Genius Scan (0); iScanner - PDF-Scanner (0) | 3 |
| scan app gratis | — | 6 harfda, #1 | — | — | Adobe Scan: PDF- & OCR-scanner (0); QR Code & Barcode Scanner (0); iScanner - PDF-Scanner (0) | 3 |
| scan pdf gratis | — | 6 harfda, #1 | — | — | Adobe Scan: PDF- & OCR-scanner (0); CamScanner\|Documenten scannen (0); PDF Scanner・Documenten scannen (0) | 3 |
| scan document | — | 6 harfda, #1 | — | — | Adobe Scan: PDF- & OCR-scanner (0); ScanMe - pdf-scanner app (0); CamScanner\|Documenten scannen (0) | 3 |
| scan gratis | — | 6 harfda, #1 | — | — | Scanner App: Genius Scan (0); iScanner - PDF-Scanner (0); Adobe Scan: PDF- & OCR-scanner (0) | 3 |
| scan to pdf | — | 6 harfda, #1 | — | — | Adobe Scan: PDF- & OCR-scanner (0); Mobile Scanner - Scan to PDF (0); Scanner App: Genius Scan (0) | 3 |
| scan document gratis | — | 6 harfda, #2 | — | — | Scanner App: Genius Scan (0); Adobe Acrobat Reader PDF-maker (0); Scanner Pro: Document Scanning (0) | 3 |
| scan free | — | 6 harfda, #2 | — | — | Adobe Scan: PDF- & OCR-scanner (0); Free PDF Scanner App For Doc (0); iScanner - PDF-Scanner (0) | 3 |
| scan app | — | 6 harfda, #2 | — | — | Scanner App: Genius Scan (0); Adobe Scan: PDF- & OCR-scanner (0); CamScanner\|Documenten scannen (0) | 3 |
| pdf ocr document scanner | — | 6 harfda, #3 | — | — | Scanner – Scan PDF & Document (0); iScanner - PDF-Scanner (0); PDF OCR Document Scanner (0) | 3 |
| scanner documents | — | 6 harfda, #4 | — | — | CamScanner\|Documenten scannen (0); Adobe Scan: PDF- & OCR-scanner (0); Scanner – Scan PDF & Document (0) | 3 |

### PL — App Store tili: `pl` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| pdf scanner | — | 2 harfda, #2 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); PDF Scanner・Document Scanner (0) | 3 |
| scanner | — | 2 harfda, #3 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); Scanner – Scan PDF, ID & Docs (0) | 3 |
| skaner | — | 3 harfda, #3 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); Scan to PDF & Document Scanner (0) | 3 |
| pdf scanner free | — | 3 harfda, #10 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); Tiny Scanner - PDF Scanner App (0) | 3 |
| darmowy skaner pdf | — | 4 harfda, #5 | — | — | Adobe Scan: PDF & OCR Scanner (0); Scanner App. Scan PDF Document (0); PDF Scanner & Editor ++ (0) | 3 |
| scanner free | — | 4 harfda, #6 | — | — | CamScanner - PDF Scanner App (0); Scan to PDF & Document Scanner (0); Adobe Scan: PDF & OCR Scanner (0) | 3 |
| skanuj dokumenty | — | 5 harfda, #2 | — | — | Scan Documents to PDF l by TSP (0); Scanner App - Scan PDF & Docs (0); Photo to PDF - Scan Documents (0) | 3 |
| skanuj | — | 5 harfda, #3 | — | — | ScanMe - PDF Scanner App (0); Scan Hero: PDF Scanner (0); Scanner App - Scan PDF & Docs (0) | 3 |
| pdf scanner darmowy | — | 5 harfda, #4 | — | — | Adobe Scan: PDF & OCR Scanner (0); Scanner App. Scan PDF Document (0); PDF Editor－Scan & Converter (0) | 3 |
| skanuj dokument | — | 5 harfda, #5 | — | — | PDF Scanner・Document Scan App (0); Doc PDF Scanner: Scan Document (0); Mobile Scanner App - Scan PDF (0) | 3 |
| pdf ai scanner | — | 5 harfda, #7 | — | — | PDF AI Scanner (0); CamScanner - PDF Scanner App (0); PDF Scanner, Scan Documents (0) | 3 |
| skanowanie | — | 5 harfda, #7 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); QR Code Reader ϟ (0) | 3 |
| skaner pdf | — | 5 harfda, #8 | — | — | PDF Scanner・Document Scanner (0); Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0) | 3 |
| scan pdf free | — | 6 harfda, #3 | — | — | CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0); iScanner: PDF Doc Scanner App (0) | 3 |
| skaner free | — | 8 harfda, #1 | — | — | Scan Hero: PDF Scanner (0); CamScanner - PDF Scanner App (0); Adobe Scan: PDF & OCR Scanner (0) | 3 |
| mobile scanner pdf app | — | 8 harfda, #2 | — | — | Mobile Scanner App - Scan PDF (0); Mobile Scanner PDF App (0); Adobe Scan: PDF & OCR Scanner (0) | 3 |
| skaner darmowy | — | 8 harfda, #2 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); PDF Scanner ⊟ (0) | 3 |
| skaner do pdf | — | 8 harfda, #8 | — | — | iScanner: PDF Doc Scanner App (0); PDF Scanner・Document Scan App (0); PDF Scanner・Document Scanner (0) | 3 |
| scanner app | — | 9 harfda, #1 | — | — | Scanner App - Scan PDF & Docs (0); Scanner App: Genius Scan (0); CamScanner - PDF Scanner App (0) | 3 |
| scanner document pdf | — | 9 harfda, #5 | — | — | CamScanner - PDF Scanner App (0); Scanner Document PDF (0); iScanner: PDF Doc Scanner App (0) | 3 |
| skaner dokumentów | — | 9 harfda, #10 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); PDF Scanner App: TapScanner (0) | 3 |
| ocr scanner | — | 3 harfda, #1 | — | — | Adobe Scan: PDF & OCR Scanner (0); OCR Scanner - Paper to Text (0); OCR Scanner - Scan PDF & Image (0) | 2 |
| ocr | — | 3 harfda, #3 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); Text Scanner - OCR Scan Text (0) | 2 |
| pdf to jpg convert | — | 5 harfda, #3 | — | — | PDF To JPG Convert (0); iLovePDF - PDF Editor & Scan (0); Convert PDF to JPG,PDF to PNG (0) | 2 |
| pdf ocr pro | — | 5 harfda, #5 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF Scanner App (0); Adobe Acrobat Reader: Edit PDF (0) | 2 |

### SE — App Store tili: `sv` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| pdf scanner | — | 2 harfda, #2 | — | — | PDF Scanner ⊟ (0); Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF-skanner (0) | 3 |
| scanner | — | 2 harfda, #3 | — | — | Scanner App: Genius Scan (0); CamScanner - PDF-skanner (0); Spiris Scanner (0) | 3 |
| pdf scanner free | — | 2 harfda, #6 | — | — | Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF-skanner (0); iScanner - PDF-skanner (0) | 3 |
| pdf scanner gratis | — | 2 harfda, #7 | — | — | Adobe Scan: PDF & OCR Scanner (0); Mobile Scanner - Skanna PDF (0); iScanner - PDF-skanner (0) | 3 |
| scanner gratis | — | 3 harfda, #3 | — | — | Adobe Scan: PDF & OCR Scanner (0); QR Reader for iPhone (0); Scanner App: Genius Scan (0) | 3 |
| skanna dokument | — | 4 harfda, #4 | — | — | iScanner - PDF-skanner (0); Adobe Scan: PDF & OCR Scanner (0); Scanna Dokument till PDF (0) | 3 |
| ocr pdf scanners gratis | — | 5 harfda, #1 | — | — | OCR PDF Scanners gratis (0); Adobe Scan: PDF & OCR Scanner (0); Adobe-dokumentpaket: Visa, kommentera, dela PDF och skanna dokument (0) | 3 |
| pdf ai scanner | — | 5 harfda, #3 | — | — | PDF AI Scanner (0); Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF-skanner (0) | 3 |
| skanner | — | 5 harfda, #3 | — | — | ScanMe - App för PDF-skanning (0); QR Reader for iPhone (0); iScanner - PDF-skanner (0) | 3 |
| scanner free | — | 5 harfda, #6 | — | — | Scanna dokument till PDF: OCR (0); iScanner - PDF-skanner (0); CamScanner - PDF-skanner (0) | 3 |
| skanna | — | 5 harfda, #8 | — | — | ScanMe - App för PDF-skanning (0); QR Reader for iPhone (0); Scanna dokument till PDF: OCR (0) | 3 |
| scanner app | — | 9 harfda, #1 | — | — | Scanner App: Genius Scan (0); Skanner-app: Skanna PDF & dok (0); Adobe Scan: PDF & OCR Scanner (0) | 3 |
| scanner document pdf converter | — | 9 harfda, #4 | — | — | Scanner Document PDF Converter (0); CamScanner - PDF-skanner (0); PDF Reader & Scanner: Edit, Sign, Fill, Convert & Scan any documents. Free PDF Viewer (0) | 3 |
| pdf scanner, editor, converter | — | 12 harfda, #2 | — | — | PDF Scanner, Editor, Converter (0); PDF Skanner: Scanna, Redigera (0); File Manager & Scanner: Edit, Sign, Convert, Scan any PDF Documents. Fax & Printer (0) | 3 |
| pdf scanner, converter, editor | — | 12 harfda, #4 | — | — | PDF Scanner : Converter,Editor (0); File Manager & Scanner: Edit, Sign, Convert, Scan any PDF Documents. Fax & Printer (0); CamScanner - PDF-skanner (0) | 3 |
| pdf scanner, convert document | — | 12 harfda, #6 | — | — | CamScanner - PDF-skanner (0); PDF Reader & Scanner: Edit, Sign, Fill, Convert & Scan any documents. Free PDF Viewer (0); File Manager & Scanner: Edit, Sign, Convert, Scan any PDF Documents. Fax & Printer (0) | 3 |
| pdf scanner documents | — | 13 harfda, #3 | — | — | CamScanner - PDF-skanner (0); iScanner - PDF-skanner (0); Adobe Scan: PDF & OCR Scanner (0) | 3 |
| pdf scanner for me | — | 13 harfda, #4 | — | — | Scan Hero: PDF-skanner (0); CamScanner - PDF-skanner (0); PDF Scanner For Me (0) | 3 |
| pdf scanner document converter | — | 13 harfda, #7 | — | — | CamScanner - PDF-skanner (0); Scan to PDF: Converter Scanner (0); PDF Scanner Document Converter (0) | 3 |
| pdf scanner file converter | — | 13 harfda, #9 | — | — | File Manager & Scanner: Edit, Sign, Convert, Scan any PDF Documents. Fax & Printer (0); Adobe Scan: PDF & OCR Scanner (0); CamScanner - PDF-skanner (0) | 3 |
| pdf scanner easy | — | 13 harfda, #9 | — | — | PDF Scanner - Lätt att scanna! (0); Document PDF Scanner. (0); Adobe Scan: PDF & OCR Scanner (0) | 3 |
| pdf scanner document scanner | — | 13 harfda, #10 | — | — | PDF Skanner・Document Scanner (0); PDF Scanner - PDF Skapare, OCR (0); Adobe Scan: PDF & OCR Scanner (0) | 3 |
| ocr | — | 3 harfda, #2 | — | — | QR Reader for iPhone (0); Adobe Scan: PDF & OCR Scanner (0); OCR Textscanner - Skanna Text (0) | 2 |
| pdf signer | — | 5 harfda, #4 | — | — | PDF Signer - Signing Documents (0); Adobe Acrobat Reader PDF-filer (0); Docusign - Upload & Sign Docs (0) | 2 |
| skanna bilder | — | 5 harfda, #6 | — | — | Fotoskanner från Google Foto (0); Fotoskanner av Photomyne (0); Scan Hero: PDF-skanner (0) | 2 |

