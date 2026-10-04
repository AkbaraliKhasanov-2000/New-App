# ASO tadqiqoti: PDF skaner + OCR (to'liq ma'lumotlar bilan)

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
| scan documents | 48 | 4 harfda, #5 |
| ocr | 5 | 3 harfda, #4 |
| text scanner | 5 | 6 harfda, #4 |
| image to text | 5 | 7 harfda, #10 |
| pdf scanner free | 5 | 13 harfda, #1 |
| document scanner app | 5 | 18 harfda, #3 |
| receipt scanner | 5 | 3 harfda, #8 |
| sign pdf | 5 | 6 harfda, #3 |
| ocr scanner | 5 | 5 harfda, #1 |

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
| scan documents | 48 | 4 harfda, #5 | 60 | 186 | Scanner App. JPG, Photo to PDF (74,632); CamScanner - PDF Scanner App (1,931,971); Adobe Scan: PDF & Doc Scanner (1,596,205) | 3 |
| receipt scanner | 5 | 3 harfda, #8 | 63 | 186 | SimplyWise: Receipts, Expenses (37,802); Fetch: Earn Rewards Every Day (7,725,034); Receipt Scanner・Track Expenses (3,855) | 2 |
| ocr scanner | 5 | 5 harfda, #1 | 28 | 185 | QuickScan:PDF OCR Text Scanner (4,035); Adobe Scan: PDF & Doc Scanner (1,596,205); CamScanner - PDF Scanner App (1,931,971) | 2 |
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
| pdf scanner | — | 2 harfda, #2 | 80 | 188 | CamScanner - PDF Scanner App (161,357); Adobe Scan: PDF & OCR Scanner (250,437); PDF Scanner \| Document Scan (257) | 3 |
| scanner app free | — | 2 harfda, #6 | 56 | 190 | CamScanner - PDF Scanner App (161,357); iScanner: PDF Docs Scanner App (165,556); Adobe Scan: PDF & OCR Scanner (250,437) | 3 |
| scanner | — | 2 harfda, #8 | 86 | 187 | CamScanner - PDF Scanner App (161,357); Adobe Scan: PDF & OCR Scanner (250,437); iScanner: PDF Docs Scanner App (165,556) | 3 |
| scan document | — | 3 harfda, #3 | 65 | 187 | CamScanner - PDF Scanner App (161,357); Adobe Scan: PDF & OCR Scanner (250,437); Scanner App: Genius Scan (132,594) | 3 |
| document scanner | — | 3 harfda, #4 | 65 | 186 | CamScanner - PDF Scanner App (161,357); Adobe Scan: PDF & OCR Scanner (250,437); Document Scanner by Lufick (827) | 3 |
| scan | — | 3 harfda, #4 | 86 | 184 | CamScanner - PDF Scanner App (161,357); Adobe Scan: PDF & OCR Scanner (250,437); Scanner App: Genius Scan (132,594) | 3 |
| scan to pdf free | — | 3 harfda, #5 | 48 | 185 | Adobe Scan: PDF & OCR Scanner (250,437); CamScanner - PDF Scanner App (161,357); iScanner: PDF Docs Scanner App (165,556) | 3 |
| iphone scanner free | — | 3 harfda, #9 | 51 | 191 | Scanner App for iPhone (35); CamScanner - PDF Scanner App (161,357); PDF Scanner App: Free Scan Doc (31) | 3 |
| scan pdf | — | 3 harfda, #9 | 72 | 193 | Adobe Scan: PDF & OCR Scanner (250,437); CamScanner - PDF Scanner App (161,357); Scanner App: Genius Scan (132,594) | 3 |
| pdf scanner app free | — | 5 harfda, #2 | 50 | 188 | Adobe Scan: PDF & OCR Scanner (250,437); CamScanner - PDF Scanner App (161,357); Scanner App: Genius Scan (132,594) | 3 |
| pdf scanner gratuit | — | 5 harfda, #8 | 47 | 187 | Adobe Scan: PDF & OCR Scanner (250,437); iScanner: PDF Docs Scanner App (165,556); PDF Scanner・Document Scanner (249) | 3 |
| scanner gratuit | — | 5 harfda, #10 | 51 | 169 | CamScanner - PDF Scanner App (161,357); Adobe Scan: PDF & OCR Scanner (250,437); Scanner – Scan PDF & Document (34,365) | 3 |
| scan gratuit | — | 6 harfda, #1 | 53 | 175 | Adobe Scan: PDF & OCR Scanner (250,437); Scanner App: Genius Scan (132,594); Scanner – Scan PDF & Document (34,365) | 3 |
| scan scanner | — | 6 harfda, #1 | 44 | 183 | CamScanner - PDF Scanner App (161,357); Lite PDF - OCR Scan Edit (2); QR & Barcode Scan (0) | 3 |
| scan app | — | 6 harfda, #1 | 69 | 188 | CamScanner - PDF Scanner App (161,357); Scanner App: Genius Scan (132,594); Adobe Scan: PDF & OCR Scanner (250,437) | 3 |
| scan document free | — | 6 harfda, #2 | 53 | 187 | Adobe Scan: PDF & OCR Scanner (250,437); CamScanner - PDF Scanner App (161,357); EasyScan: Document Scanner (119) | 3 |
| scan photos | — | 6 harfda, #2 | 45 | 187 | PhotoScan by Google Photos (9,529); Photo Scanner App by Photomyne (14,520); CamScanner - PDF Scanner App (161,357) | 3 |
| scan to pdf | — | 6 harfda, #2 | 52 | 189 | Adobe Scan: PDF & OCR Scanner (250,437); CamScanner - PDF Scanner App (161,357); Scanner App: Genius Scan (132,594) | 3 |
| scan free | — | 6 harfda, #2 | 52 | 186 | CamScanner - PDF Scanner App (161,357); Scanner App: Genius Scan (132,594); Adobe Scan: PDF & OCR Scanner (250,437) | 3 |
| scan pro | — | 6 harfda, #3 | 40 | 180 | Scanner Pro: Document Scanning (34,996); SwiftScan AI Document Scanner (3,481); CamScanner - PDF Scanner App (161,357) | 3 |
| scan document gratuit | — | 6 harfda, #5 | 46 | 183 | Scanner – Scan PDF & Document (34,365); CamScanner - PDF Scanner App (161,357); Mobile Scanner App - Scan PDF (12,335) | 3 |
| scan pdf gratuit | — | 6 harfda, #5 | 38 | 183 | Adobe Scan: PDF & OCR Scanner (250,437); PDF Scanner・Document Scanner (249); CamScanner - PDF Scanner App (161,357) | 3 |
| free document scanner | — | 6 harfda, #6 | 42 | 193 | Adobe Scan: PDF & OCR Scanner (250,437); CamScanner - PDF Scanner App (161,357); EasyScan: Document Scanner (119) | 3 |
| free pdf scanner | — | 6 harfda, #6 | 39 | 194 | Adobe Scan: PDF & OCR Scanner (250,437); FreePDF: PDF Converter & Scan (0); CamScanner - PDF Scanner App (161,357) | 3 |
| scan pictures | — | 6 harfda, #7 | 32 | 186 | PhotoScan by Google Photos (9,529); Photo Scanner App by Photomyne (14,520); CamScanner - PDF Scanner App (161,357) | 3 |

### AU — App Store tili: `en` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| pdf scanner | — | 2 harfda, #1 | 74 | 181 | Adobe Scan: PDF & OCR Scanner (131,533); CamScanner - PDF Scanner App (85,843); PDF Scanner \| Document Scan (68) | 3 |
| scanner app | — | 2 harfda, #2 | 69 | 184 | CamScanner - PDF Scanner App (85,843); Adobe Scan: PDF & OCR Scanner (131,533); Scanner App: Genius Scan (78,957) | 3 |
| scanner app free | — | 2 harfda, #8 | 52 | 184 | Adobe Scan: PDF & OCR Scanner (131,533); CamScanner - PDF Scanner App (85,843); iScanner: PDF Docs Scanner App (108,720) | 3 |
| pdf scanner free | — | 2 harfda, #9 | 49 | 190 | Adobe Scan: PDF & OCR Scanner (131,533); CamScanner - PDF Scanner App (85,843); DocScanner: PDF Scan (7) | 3 |
| scan documents | — | 3 harfda, #3 | 53 | 185 | Adobe Scan: PDF & OCR Scanner (131,533); CamScanner - PDF Scanner App (85,843); ScanMe - PDF Scanner App (70) | 3 |
| document scanner | — | 3 harfda, #4 | 50 | 185 | CamScanner - PDF Scanner App (85,843); Document Scanner by Lufick (654); Adobe Scan: PDF & OCR Scanner (131,533) | 3 |
| scan | — | 3 harfda, #5 | 81 | 187 | CamScanner - PDF Scanner App (85,843); Adobe Scan: PDF & OCR Scanner (131,533); Scanner App: Genius Scan (78,957) | 3 |
| document scanner free | — | 3 harfda, #10 | 39 | 195 | Adobe Scan: PDF & OCR Scanner (131,533); CamScanner - PDF Scanner App (85,843); Free PDF Scanner App for Doc (64) | 3 |
| scanner app pdf | — | 5 harfda, #6 | 18 | 191 | Adobe Scan: PDF & OCR Scanner (131,533); CamScanner - PDF Scanner App (85,843); Scanner – Scan PDF & Document (17,930) | 3 |
| pdf scanner document convert | — | 5 harfda, #9 | 21 | 197 | PDF Scanner Document Converter (10); Adobe Scan: PDF & OCR Scanner (131,533); PDF Scanner \| Document Scan (68) | 3 |
| scan to pdf free | — | 6 harfda, #1 | 47 | 189 | Adobe Scan: PDF & OCR Scanner (131,533); CamScanner - PDF Scanner App (85,843); iScanner: PDF Docs Scanner App (108,720) | 3 |
| scan scanner | — | 6 harfda, #1 | 58 | 185 | CamScanner - PDF Scanner App (85,843); Document PDF Scanner. (1); QR & Barcode Scan (0) | 3 |
| scan free | — | 6 harfda, #1 | 52 | 186 | Free PDF Scanner App for Doc (64); Adobe Scan: PDF & OCR Scanner (131,533); CamScanner - PDF Scanner App (85,843) | 3 |
| scan documents free | — | 6 harfda, #2 | 49 | 193 | Adobe Scan: PDF & OCR Scanner (131,533); Free PDF Scanner App for Doc (64); CamScanner - PDF Scanner App (85,843) | 3 |
| scan photos free | — | 6 harfda, #2 | 21 | 197 | PhotoScan by Google Photos (8,023); Photo Scanner App by Photomyne (15,867); Photo Scanner: Scan old Albums (706) | 3 |
| scan to pdf | — | 6 harfda, #2 | 50 | 191 | Adobe Scan: PDF & OCR Scanner (131,533); CamScanner - PDF Scanner App (85,843); iScanner: PDF Docs Scanner App (108,720) | 3 |
| scan photos | — | 6 harfda, #3 | 47 | 186 | PhotoScan by Google Photos (8,023); Photo Scanner App by Photomyne (15,867); CamScanner - PDF Scanner App (85,843) | 3 |
| free document scanner apps | — | 6 harfda, #5 | 24 | 193 | Free PDF Scanner App for Doc (64); Adobe Scan: PDF & OCR Scanner (131,533); CamScanner - PDF Scanner App (85,843) | 3 |
| scanner to pdf | — | 6 harfda, #5 | 44 | 190 | CamScanner - PDF Scanner App (85,843); Adobe Scan: PDF & OCR Scanner (131,533); PDF Scanner App: TapScanner (3,722) | 3 |
| scan pdf free | — | 6 harfda, #5 | 25 | 189 | Adobe Scan: PDF & OCR Scanner (131,533); CamScanner - PDF Scanner App (85,843); Scanner App: Genius Scan (78,957) | 3 |
| free scanner app free | — | 6 harfda, #6 | 53 | 183 | Free PDF Scanner App for Doc (64); CamScanner - PDF Scanner App (85,843); Scanner App for iPhone (5) | 3 |
| scanner app for documents | — | 6 harfda, #7 | 47 | 192 | iScanner: PDF Docs Scanner App (108,720); Adobe Scan: PDF & OCR Scanner (131,533); CamScanner - PDF Scanner App (85,843) | 3 |
| free pdf scanner app | — | 7 harfda, #2 | 50 | 187 | Adobe Scan: PDF & OCR Scanner (131,533); CamScanner - PDF Scanner App (85,843); Free PDF Scanner App for Doc (64) | 3 |
| pdf document scanner editor | — | 8 harfda, #10 | 25 | 194 | PDF Document Scanner Editor (1); PDF Reader - OCR Scan Edit (71); PDF Reader: Edit & OCR Scan (0) | 3 |
| mobile document scanner ocr | — | 9 harfda, #6 | 48 | 192 | iScanner: PDF Docs Scanner App (108,720); Scanner – Scan PDF & Document (17,930); Mobile Scanner App - Scan PDF (7,580) | 3 |

### IN — App Store tili: `en` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| doc scanner | — | 1 harfda, #8 | 68 | 174 | Document Scanner by Lufick (132,403); Doc Scanner . (3,207); Adobe Scan: PDF & OCR Scanner (1,084,699) | 3 |
| scanner for iphone | — | 2 harfda, #2 | 52 | 172 | Cam Scan for PDF & Doc Scanner (51,983); Adobe Scan: PDF & OCR Scanner (1,084,699); Document Scanner by Lufick (132,403) | 3 |
| pdf scanner | — | 2 harfda, #2 | 71 | 171 | Document Scanner by Lufick (132,403); Adobe Scan: PDF & OCR Scanner (1,084,699); PDF Scanner・Document Scanner (4,353) | 3 |
| scanner | — | 2 harfda, #3 | 82 | 175 | Cam Scan for PDF & Doc Scanner (51,983); Adobe Scan: PDF & OCR Scanner (1,084,699); Document Scanner by Lufick (132,403) | 3 |
| pdf scanner for iphone | — | 2 harfda, #7 | 51 | 167 | Cam Scan for PDF & Doc Scanner (51,983); Adobe Scan: PDF & OCR Scanner (1,084,699); Document Scanner by Lufick (132,403) | 3 |
| document scanner | — | 2 harfda, #8 | 63 | 176 | Document Scanner by Lufick (132,403); Adobe Scan: PDF & OCR Scanner (1,084,699); Cam Scan for PDF & Doc Scanner (51,983) | 3 |
| scan document | — | 3 harfda, #6 | 64 | 175 | Document Scanner by Lufick (132,403); Adobe Scan: PDF & OCR Scanner (1,084,699); Cam Scan for PDF & Doc Scanner (51,983) | 3 |
| scanner for iphone free | — | 4 harfda, #7 | 52 | 174 | Document Scanner by Lufick (132,403); Adobe Scan: PDF & OCR Scanner (1,084,699); Scanner App for iPhone (15) | 3 |
| document scanner, pdf scanner | — | 4 harfda, #8 | 48 | 176 | Document Scanner by Lufick (132,403); Adobe Scan: PDF & OCR Scanner (1,084,699); Cam Scan for PDF & Doc Scanner (51,983) | 3 |
| pdf scanner free | — | 5 harfda, #4 | 53 | 179 | Document Scanner by Lufick (132,403); Adobe Scan: PDF & OCR Scanner (1,084,699); PDF Scanner・Document Scanner (4,353) | 3 |
| document scanner pdf creator | — | 5 harfda, #9 | 37 | 183 | Document Scanner by Lufick (132,403); Adobe Scan: PDF & OCR Scanner (1,084,699); PDF Scanner : Maker & Editor • (19,208) | 3 |
| scan and pdf maker | — | 6 harfda, #1 | 43 | 173 | Document Scanner by Lufick (132,403); Adobe Scan: PDF & OCR Scanner (1,084,699); PDF Scanner : Maker & Editor • (19,208) | 3 |
| scan my document | — | 6 harfda, #1 | 44 | 163 | Scan My Document - PDF Scanner (38); Scan My Document (0); My Scanner: Scan to PDF & Edit (485) | 3 |
| scan to pdf free | — | 6 harfda, #1 | 53 | 177 | Adobe Scan: PDF & OCR Scanner (1,084,699); Cam Scan for PDF & Doc Scanner (51,983); Document Scanner by Lufick (132,403) | 3 |
| scan scanner | — | 6 harfda, #1 | 27 | 175 | Cam Scan for PDF & Doc Scanner (51,983); Document Scanner by Lufick (132,403); Clear Scan: Doc Scanner App (32,384) | 3 |
| scan camera | — | 6 harfda, #1 | 38 | 170 | Cam Scan for PDF & Doc Scanner (51,983); CamScanner - Scan Document (26); Hidden Camera Detector - Peek (9,541) | 3 |
| scan document to pdf | — | 6 harfda, #2 | 53 | 171 | Document Scanner by Lufick (132,403); Adobe Scan: PDF & OCR Scanner (1,084,699); Cam Scan for PDF & Doc Scanner (51,983) | 3 |
| scan pdf maker | — | 6 harfda, #2 | 52 | 172 | Cam Scan for PDF & Doc Scanner (51,983); Adobe Scan: PDF & OCR Scanner (1,084,699); Document Scanner by Lufick (132,403) | 3 |
| scan to pdf | — | 6 harfda, #2 | 43 | 179 | Cam Scan for PDF & Doc Scanner (51,983); Adobe Scan: PDF & OCR Scanner (1,084,699); PDF Scanner : Maker & Editor • (19,208) | 3 |
| scan image | — | 6 harfda, #2 | 47 | 181 | iScanner: PDF Doc Scanner App (202,427); Adobe Scan: PDF & OCR Scanner (1,084,699); PDF Scanner : Maker & Editor • (19,208) | 3 |
| scan and make pdf | — | 6 harfda, #3 | 3 | 119 | Cam Scan for PDF & Doc Scanner (51,983); Adobe Scan: PDF & OCR Scanner (1,084,699); PDF Scanner : Maker & Editor • (19,208) | 3 |
| scan image to pdf | — | 6 harfda, #3 | 47 | 185 | Adobe Scan: PDF & OCR Scanner (1,084,699); Cam Scan for PDF & Doc Scanner (51,983); Image to PDF Converter & Edit (4,491) | 3 |
| scan photo to pdf | — | 6 harfda, #3 | 63 | 182 | Cam Scan for PDF & Doc Scanner (51,983); Photos PDF Scanner & Converter (57,734); Adobe Scan: PDF & OCR Scanner (1,084,699) | 3 |
| scan document free | — | 6 harfda, #4 | 44 | 174 | Cam Scan for PDF & Doc Scanner (51,983); Adobe Scan: PDF & OCR Scanner (1,084,699); Cam Scan for PDF Scanner (9,373) | 3 |
| scan pdf free | — | 6 harfda, #4 | 42 | 171 | Adobe Scan: PDF & OCR Scanner (1,084,699); Document Scanner by Lufick (132,403); iScanner: PDF Doc Scanner App (202,427) | 3 |

### DE — App Store tili: `de` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| pdf scanner | — | 2 harfda, #2 | 74 | 165 | Adobe Scan: PDF Scanner App (327,337); PDF Maker: Document Scanner (17,778); CamScanner - PDF Scanner App (89,657) | 3 |
| scanner app | — | 2 harfda, #2 | 73 | 155 | Scanner – PDF & Dokumente (40,266); CamScanner - PDF Scanner App (89,657); Adobe Scan: PDF Scanner App (327,337) | 3 |
| scanner app kostenlos | — | 2 harfda, #5 | 58 | 161 | Adobe Scan: PDF Scanner App (327,337); iScanner - Dokumenten Scanner (220,726); QR Code Scanner · (291,670) | 3 |
| pdf scanner kostenlos | — | 2 harfda, #6 | 55 | 176 | PDF Scanner App - Scan & Sign (1,477); PDF Maker: Document Scanner (17,778); Adobe Scan: PDF Scanner App (327,337) | 3 |
| dokumente scannen | — | 3 harfda, #2 | 64 | 164 | Adobe Scan: PDF Scanner App (327,337); iScanner - Dokumenten Scanner (220,726); ScanMe - PDF-Scanner-App (133) | 3 |
| dokumente scannen kostenlos | — | 3 harfda, #10 | 48 | 183 | Adobe Scan: PDF Scanner App (327,337); iScanner - Dokumenten Scanner (220,726); CamScanner - PDF Scanner App (89,657) | 3 |
| scan to pdf | — | 4 harfda, #5 | 52 | 169 | Adobe Scan: PDF Scanner App (327,337); CamScanner - PDF Scanner App (89,657); Scanner App: Genius Scan (119,080) | 3 |
| quick scan kostenlos | — | 4 harfda, #8 | 54 | 185 | OCR Scanner - QuickScan (17,313); QR Code & Barcode Scanner (229,010); QuickScan: Dokumenten Scanner (27) | 3 |
| scannen kostenlos | — | 5 harfda, #4 | 55 | 180 | Adobe Scan: PDF Scanner App (327,337); QR Code Scanner · (291,670); iScanner - Dokumenten Scanner (220,726) | 3 |
| pdf scanner app kostenlos | — | 5 harfda, #5 | 55 | 181 | Adobe Scan: PDF Scanner App (327,337); CamScanner - PDF Scanner App (89,657); iScanner - Dokumenten Scanner (220,726) | 3 |
| scanner app gratis | — | 5 harfda, #5 | 58 | 174 | QR Code & Barcode Scanner (229,010); iScanner - Dokumenten Scanner (220,726); Adobe Scan: PDF Scanner App (327,337) | 3 |
| document scanner free | — | 5 harfda, #6 | 50 | 179 | CamScanner - PDF Scanner App (89,657); Adobe Scan: PDF Scanner App (327,337); EasyScan: Document Scanner (59) | 3 |
| pdf scanner gratis | — | 5 harfda, #8 | 50 | 176 | CamScanner - PDF Scanner App (89,657); Adobe Scan: PDF Scanner App (327,337); iScanner - Dokumenten Scanner (220,726) | 3 |
| pdf scanner free | — | 5 harfda, #9 | 53 | 173 | iScanner - Dokumenten Scanner (220,726); CamScanner - PDF Scanner App (89,657); Adobe Scan: PDF Scanner App (327,337) | 3 |
| scan app kostenlos | — | 6 harfda, #1 | 56 | 175 | Adobe Scan: PDF Scanner App (327,337); Scanner App: Genius Scan (119,080); CamScanner - PDF Scanner App (89,657) | 3 |
| scan documents | — | 6 harfda, #1 | 56 | 170 | Adobe Scan: PDF Scanner App (327,337); Scanner – PDF & Dokumente (40,266); CamScanner - PDF Scanner App (89,657) | 3 |
| scan pdf free | — | 6 harfda, #1 | 51 | 175 | Adobe Scan: PDF Scanner App (327,337); CamScanner - PDF Scanner App (89,657); iScanner - Dokumenten Scanner (220,726) | 3 |
| scan to pdf kostenlos | — | 6 harfda, #3 | 55 | 180 | PDF Maker: Document Scanner (17,778); iScanner - Dokumenten Scanner (220,726); Adobe Scan: PDF Scanner App (327,337) | 3 |
| scan kostenlos | — | 6 harfda, #3 | 58 | 179 | Adobe Scan: PDF Scanner App (327,337); Scanner App: Genius Scan (119,080); iScanner - Dokumenten Scanner (220,726) | 3 |
| scan scanner | — | 6 harfda, #3 | 68 | 162 | CamScanner - PDF Scanner App (89,657); Scanner PDF: dokumente scannen (3,172); Scanner App, Digitale Unterschrift & PDF Form Filler. Dokumente Scannen & Bearbeiten (0) | 3 |
| scan photos | — | 6 harfda, #4 | 47 | 175 | Fotoscanner von Google Fotos (11,370); Fotoscanner von Photomyne (8,991); CamScanner - PDF Scanner App (89,657) | 3 |
| pdf scan kostenlos | — | 6 harfda, #5 | 57 | 188 | Adobe Scan: PDF Scanner App (327,337); PDF Maker: Document Scanner (17,778); CamScanner - PDF Scanner App (89,657) | 3 |
| pdf scanner document | — | 6 harfda, #6 | 49 | 183 | Scanner – PDF & Dokumente (40,266); CamScanner - PDF Scanner App (89,657); PDF Scanner: Document Scan PDF (33) | 3 |
| scannen pdf kostenlos | — | 9 harfda, #2 | 53 | 189 | Adobe Scan: PDF Scanner App (327,337); PDF Maker: Document Scanner (17,778); Scanner – PDF & Dokumente (40,266) | 3 |
| scannen pdf dokumenten scanner | — | 9 harfda, #5 | 45 | 187 | Scanner – PDF & Dokumente (40,266); Scanner App dokumente scannen (2,130); Scannen von Dokumenten als PDF (3,518) | 3 |

### FR — App Store tili: `fr` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| scanner gratuit | — | 2 harfda, #1 | 61 | 167 | Scanner – Scan PDF & Document (182,970); CamScanner - PDF Scanner App (189,732); iScanner - Scanner document (287,722) | 3 |
| pdf scanner gratuit | — | 2 harfda, #2 | 59 | 180 | Scanner PDF・Scanner Document (12,678); CamScanner - PDF Scanner App (189,732); Scanner – Scan PDF & Document (182,970) | 3 |
| scanner pdf | — | 2 harfda, #4 | 74 | 161 | Scanner – Scan PDF & Document (182,970); CamScanner - PDF Scanner App (189,732); Scanner PDF・Scanner Document (12,678) | 3 |
| scan | — | 2 harfda, #6 | 88 | 174 | CamScanner - PDF Scanner App (189,732); Scanner – Scan PDF & Document (182,970); Scanner App: Genius Scan (174,868) | 3 |
| scan pdf gratuit | — | 3 harfda, #5 | 62 | 180 | Scanner PDF・Scanner Document (12,678); CamScanner - PDF Scanner App (189,732); Scanner – Scan PDF & Document (182,970) | 3 |
| scanner | — | 3 harfda, #6 | 91 | 168 | Scanner – Scan PDF & Document (182,970); CamScanner - PDF Scanner App (189,732); iScanner - Scanner document (287,722) | 3 |
| scan document | — | 4 harfda, #7 | 69 | 172 | iScanner - Scanner document (287,722); CamScanner - PDF Scanner App (189,732); Scanner – Scan PDF & Document (182,970) | 3 |
| scan pdf | — | 4 harfda, #8 | 78 | 174 | Scanner – Scan PDF & Document (182,970); Adobe Scan : Scanner PDF, OCR (233,393); CamScanner - PDF Scanner App (189,732) | 3 |
| pdf scanner app | — | 5 harfda, #2 | 51 | 169 | Scanner PDF・Scanner Document (12,678); CamScanner - PDF Scanner App (189,732); Adobe Scan : Scanner PDF, OCR (233,393) | 3 |
| scanner gratuit iphone | — | 5 harfda, #5 | 57 | 170 | iScanner - Scanner document (287,722); CamScanner - PDF Scanner App (189,732); Scanner – Scan PDF & Document (182,970) | 3 |
| scan document gratuit | — | 6 harfda, #1 | 53 | 179 | Scanner – Scan PDF & Document (182,970); CamScanner - PDF Scanner App (189,732); iScanner - Scanner document (287,722) | 3 |
| scan gratuit | — | 6 harfda, #1 | 56 | 176 | PDF Scanner : Scan Document (2,753); CamScanner - PDF Scanner App (189,732); Scanner App: Genius Scan (174,868) | 3 |
| scan scanner | — | 6 harfda, #1 | 91 | 166 | CamScanner - PDF Scanner App (189,732); Clear Scan: scanner document (20,451); Scanner App: Genius Scan (174,868) | 3 |
| scan en pdf | — | 6 harfda, #1 | 62 | 187 | Scanner – Scan PDF & Document (182,970); CamScanner - PDF Scanner App (189,732); Scanner PDF・Scanner Document (12,678) | 3 |
| scan scanner gratuit | — | 6 harfda, #2 | 51 | 190 | CamScanner - PDF Scanner App (189,732); Adobe Scan : Scanner PDF, OCR (233,393); Clear Scan: scanner document (20,451) | 3 |
| scan to pdf | — | 6 harfda, #2 | 63 | 169 | CamScanner - PDF Scanner App (189,732); iScanner - Scanner document (287,722); Scanner – Scan PDF & Document (182,970) | 3 |
| scan photo | — | 6 harfda, #2 | 58 | 175 | PhotoScan, par Google Photos (4,377); CamScanner - PDF Scanner App (189,732); Scanner Photo de Photomyne (5,800) | 3 |
| scan document pdf gratuit | — | 6 harfda, #3 | 54 | 186 | iScanner - Scanner document (287,722); Adobe Scan : Scanner PDF, OCR (233,393); Lecteur PDF Gratuit. Scanner, Convertir, Modifier et Signer des Documents (0) | 3 |
| scan to pdf gratuit | — | 6 harfda, #4 | 51 | 187 | Scanner PDF・Scanner Document (12,678); CamScanner - PDF Scanner App (189,732); Mobile Scanner - Scan to PDF (15,132) | 3 |
| scan document pdf | — | 6 harfda, #4 | 59 | 181 | CamScanner - PDF Scanner App (189,732); Scanner – Scan PDF & Document (182,970); Adobe Scan : Scanner PDF, OCR (233,393) | 3 |
| scan fichier | — | 6 harfda, #4 | 29 | 179 | PDFgear Scan: PDF Scanner App (627); CamScanner - PDF Scanner App (189,732); Adobe Acrobat Reader: Lire PDF (89,185) | 3 |
| scan doc gratuit | — | 6 harfda, #7 | 57 | 186 | Scanner App: Genius Scan (174,868); iScanner - Scanner document (287,722); Clear Scan: scanner document (20,451) | 3 |
| paper scanner document scan | — | 8 harfda, #5 | 57 | 190 | Scanner – Scan PDF & Document (182,970); CamScanner - PDF Scanner App (189,732); Adobe Scan : Scanner PDF, OCR (233,393) | 3 |
| scanner document | — | 9 harfda, #1 | 67 | 168 | Scanner – Scan PDF & Document (182,970); CamScanner - PDF Scanner App (189,732); iScanner - Scanner document (287,722) | 3 |
| scanner document gratuit | — | 9 harfda, #2 | 54 | 177 | Scanner – Scan PDF & Document (182,970); CamScanner - PDF Scanner App (189,732); Scanner Pro: Scanner documents (30,582) | 3 |

### ES — App Store tili: `es` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| escanear documentos | — | 2 harfda, #1 | 59 | 172 | CamScanner:Escanear Documentos (148,380); Scanner – Escanear PDF & Docs (45,241); Adobe Scan: Escáner PDF y OCR (112,357) | 3 |
| escaner gratis | — | 2 harfda, #2 | 54 | 163 | CamScanner:Escanear Documentos (148,380); Lector código QR y barras (60,160); Adobe Scan: Escáner PDF y OCR (112,357) | 3 |
| pdf scanner | — | 2 harfda, #3 | 56 | 169 | CamScanner:Escanear Documentos (148,380); Escanear Documentos PDF (674); Adobe Scan: Escáner PDF y OCR (112,357) | 3 |
| scanner | — | 2 harfda, #3 | 74 | 160 | CamScanner:Escanear Documentos (148,380); Scanner – Escanear PDF & Docs (45,241); Adobe Scan: Escáner PDF y OCR (112,357) | 3 |
| escaner | — | 2 harfda, #5 | 53 | 162 | CamScanner:Escanear Documentos (148,380); Lector código QR y barras (60,160); Scanner – Escanear PDF & Docs (45,241) | 3 |
| escanear documentos gratis | — | 3 harfda, #6 | 49 | 182 | Escanear Documentos: Escáner (80); CamScanner:Escanear Documentos (148,380); Adobe Scan: Escáner PDF y OCR (112,357) | 3 |
| scanner gratis | — | 3 harfda, #6 | 53 | 169 | CamScanner:Escanear Documentos (148,380); Scanner – Escanear PDF & Docs (45,241); Adobe Scan: Escáner PDF y OCR (112,357) | 3 |
| escanear | — | 3 harfda, #7 | 58 | 166 | CamScanner:Escanear Documentos (148,380); Lector código QR y barras (60,160); Escanear Documentos: Escáner (80) | 3 |
| escaner pdf | — | 3 harfda, #9 | 45 | 165 | CamScanner:Escanear Documentos (148,380); Adobe Scan: Escáner PDF y OCR (112,357); Escanear Documentos PDF (674) | 3 |
| escáner documentos | — | 4 harfda, #1 | 52 | 170 | CamScanner:Escanear Documentos (148,380); Adobe Scan: Escáner PDF y OCR (112,357); Escanear Documentos: Escáner (80) | 3 |
| escáner documentos gratis | — | 4 harfda, #2 | 46 | 186 | CamScanner:Escanear Documentos (148,380); Adobe Scan: Escáner PDF y OCR (112,357); Escanear Documentos TapScanner (4,547) | 3 |
| pdf scanner gratis | — | 5 harfda, #2 | 52 | 180 | CamScanner:Escanear Documentos (148,380); Escanear Documentos: Escáner (80); Adobe Scan: Escáner PDF y OCR (112,357) | 3 |
| pdf scanner free | — | 5 harfda, #4 | 47 | 176 | CamScanner:Escanear Documentos (148,380); Adobe Scan: Escáner PDF y OCR (112,357); Scanner App: Genius Scan (29,798) | 3 |
| pdf scan gratis | — | 5 harfda, #5 | 51 | 190 | CamScanner:Escanear Documentos (148,380); Scan Hero: Escáner PDF (21,042); Mobile Scanner - Escáner PDF (4,853) | 3 |
| escaner pdf gratis | — | 5 harfda, #8 | 44 | 178 | CamScanner:Escanear Documentos (148,380); Adobe Scan: Escáner PDF y OCR (112,357); Escanear Documentos: Escáner (80) | 3 |
| pdf editor y escáner | — | 5 harfda, #9 | 38 | 168 | PDF Editor y Escáner (688); Paquete Office Document Suite - Word, XLS, PDF Editor (0); CamScanner:Escanear Documentos (148,380) | 3 |
| free pdf scan | — | 6 harfda, #4 | 50 | 188 | CamScanner:Escanear Documentos (148,380); Scanner – Escanear PDF & Docs (45,241); Adobe Scan: Escáner PDF y OCR (112,357) | 3 |
| pdf escanear documentos scan | — | 6 harfda, #7 | 47 | 177 | CamScanner:Escanear Documentos (148,380); PDF escanear documentos scan (16); Escaner Documentos PDF Scanner (2,027) | 3 |
| escanear documentos pdf | — | 7 harfda, #9 | 54 | 170 | Escanear Documentos PDF (674); CamScanner:Escanear Documentos (148,380); Adobe Scan: Escáner PDF y OCR (112,357) | 3 |
| mobile scanner pdf app | — | 8 harfda, #3 | 48 | 166 | Mobile Scanner - Escáner PDF (4,853); Adobe Scan: Escáner PDF y OCR (112,357); Adobe Acrobat Reader Firma PDF (69,667) | 3 |
| scanner documentos | — | 9 harfda, #1 | 56 | 183 | CamScanner:Escanear Documentos (148,380); Scanner – Escanear PDF & Docs (45,241); Escaner Documentos PDF Scanner (2,027) | 3 |
| escaner de documentos | — | 9 harfda, #5 | 46 | 158 | CamScanner:Escanear Documentos (148,380); Adobe Scan: Escáner PDF y OCR (112,357); Scan Shot: Escanear Documentos (6,470) | 3 |
| escáner fotos y pdf | — | 9 harfda, #6 | 52 | 185 | Scanner Mini – Escanea a PDF (4,697); Scanner App: PDF y documentos (2,488); CamScanner:Escanear Documentos (148,380) | 3 |
| escanear pdf gratis | — | 10 harfda, #1 | 50 | 188 | CamScanner:Escanear Documentos (148,380); Adobe Scan: Escáner PDF y OCR (112,357); iLovePDF- Editor PDF y Escáner (25,309) | 3 |
| escanear fotos a pdf | — | 10 harfda, #3 | 43 | 184 | CamScanner:Escanear Documentos (148,380); Escanear & Convertir PDF App (406); Adobe Scan: Escáner PDF y OCR (112,357) | 3 |

### IT — App Store tili: `it` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| scanner | — | 2 harfda, #5 | 84 | 169 | CamScanner - PDF Scanner App (113,936); Scanner - Scansiona Documenti (34,061); Adobe Scan: Scansione PDF, OCR (223,884) | 3 |
| scanner pdf | — | 2 harfda, #6 | 70 | 161 | CamScanner - PDF Scanner App (113,936); Scanner - Scansiona Documenti (34,061); Adobe Scan: Scansione PDF, OCR (223,884) | 3 |
| scanner gratis | — | 2 harfda, #8 | 55 | 171 | CamScanner - PDF Scanner App (113,936); Scanner - Scansiona Documenti (34,061); Adobe Scan: Scansione PDF, OCR (223,884) | 3 |
| scansione documenti | — | 3 harfda, #9 | 46 | 174 | Adobe Scan: Scansione PDF, OCR (223,884); CamScanner - PDF Scanner App (113,936); iScanner - Scanner PDF (163,783) | 3 |
| scanner pdf gratis iphone | — | 4 harfda, #10 | 55 | 171 | CamScanner - PDF Scanner App (113,936); Adobe Scan: Scansione PDF, OCR (223,884); iScanner - Scanner PDF (163,783) | 3 |
| pdf scanner app | — | 5 harfda, #1 | 53 | 174 | CamScanner - PDF Scanner App (113,936); Scanner PDF・Document Scanner (1,096); Adobe Scan: Scansione PDF, OCR (223,884) | 3 |
| scansione documenti gratis | — | 5 harfda, #2 | 49 | 187 | CamScanner - PDF Scanner App (113,936); Scanner App・ documenti in PDF (52); Adobe Scan: Scansione PDF, OCR (223,884) | 3 |
| scansiona documenti pdf | — | 5 harfda, #4 | 42 | 172 | CamScanner - PDF Scanner App (113,936); Adobe Scan: Scansione PDF, OCR (223,884); iScanner - Scanner PDF (163,783) | 3 |
| pdf scanner | — | 5 harfda, #4 | 67 | 170 | CamScanner - PDF Scanner App (113,936); Scanner PDF・Document Scanner (1,096); Adobe Scan: Scansione PDF, OCR (223,884) | 3 |
| pdf scanner documenti | — | 5 harfda, #5 | 50 | 184 | Scanner PDF – scan documents (4,116); CamScanner - PDF Scanner App (113,936); Scanner PDF: Foto e Documenti (3,480) | 3 |
| scanner documenti | — | 5 harfda, #7 | 58 | 166 | CamScanner - PDF Scanner App (113,936); Scanner - Scansiona Documenti (34,061); Adobe Scan: Scansione PDF, OCR (223,884) | 3 |
| scansione | — | 5 harfda, #7 | 66 | 169 | CamScanner - PDF Scanner App (113,936); Adobe Scan: Scansione PDF, OCR (223,884); iScanner - Scanner PDF (163,783) | 3 |
| scansiona documenti | — | 5 harfda, #10 | 55 | 174 | CamScanner - PDF Scanner App (113,936); Adobe Scan: Scansione PDF, OCR (223,884); Scan Shot: Scanner Documenti (8,440) | 3 |
| app scanner gratis | — | 6 harfda, #6 | 55 | 171 | CamScanner - PDF Scanner App (113,936); Adobe Scan: Scansione PDF, OCR (223,884); iScanner - Scanner PDF (163,783) | 3 |
| app scansione documenti | — | 7 harfda, #2 | 46 | 172 | Adobe Scan: Scansione PDF, OCR (223,884); CamScanner - PDF Scanner App (113,936); iScanner - Scanner PDF (163,783) | 3 |
| mobile scanner pdf app | — | 8 harfda, #2 | 52 | 172 | Mobile Scanner - Scan to PDF (7,787); Adobe Scan: Scansione PDF, OCR (223,884); CamScanner - PDF Scanner App (113,936) | 3 |
| scanner gratis per iphone | — | 9 harfda, #1 | 55 | 175 | CamScanner - PDF Scanner App (113,936); Adobe Scan: Scansione PDF, OCR (223,884); iScanner - Scanner PDF (163,783) | 3 |
| scanner iphone | — | 9 harfda, #1 | 55 | 189 | CamScanner - PDF Scanner App (113,936); Adobe Scan: Scansione PDF, OCR (223,884); Scanner - Scansiona Documenti (34,061) | 3 |
| scansiona documenti pdf gratis | — | 9 harfda, #2 | 48 | 179 | Adobe Scan: Scansione PDF, OCR (223,884); CamScanner - PDF Scanner App (113,936); iScanner - Scanner PDF (163,783) | 3 |
| scanner documenti gratis | — | 9 harfda, #2 | 49 | 185 | Scanner - Scansiona Documenti (34,061); CamScanner - PDF Scanner App (113,936); Adobe Scan: Scansione PDF, OCR (223,884) | 3 |
| scanner immagini | — | 9 harfda, #2 | 46 | 183 | Scanner - Scansiona Documenti (34,061); CamScanner - PDF Scanner App (113,936); Adobe Scan: Scansione PDF, OCR (223,884) | 3 |
| scanner document pdf | — | 9 harfda, #3 | 58 | 173 | CamScanner - PDF Scanner App (113,936); Scanner - Scansiona Documenti (34,061); Adobe Scan: Scansione PDF, OCR (223,884) | 3 |
| scansione documenti pdf | — | 9 harfda, #4 | 52 | 180 | Scan Hero: Scanner PDF (21,601); Adobe Scan: Scansione PDF, OCR (223,884); CamScanner - PDF Scanner App (113,936) | 3 |
| scanner pdf gratis | — | 9 harfda, #4 | 55 | 166 | CamScanner - PDF Scanner App (113,936); Adobe Scan: Scansione PDF, OCR (223,884); iScanner - Scanner PDF (163,783) | 3 |
| scansione pdf gratis | — | 11 harfda, #1 | 45 | 189 | Mobile Scanner - Scan to PDF (7,787); CamScanner - PDF Scanner App (113,936); Adobe Scan: Scansione PDF, OCR (223,884) | 3 |

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
| escaner pdf | — | 2 harfda, #2 | 52 | 170 | CamScanner - PDF Scanner App (332,125); Escanear Documentos PDF (11,678); Adobe Scan: Escáner de PDF (265,977) | 3 |
| scanner | — | 2 harfda, #3 | 73 | 171 | CamScanner - PDF Scanner App (332,125); Adobe Scan: Escáner de PDF (265,977); Scanner – Escanear PDF & Docs (78,977) | 3 |
| pdf scanner | — | 2 harfda, #4 | 54 | 175 | CamScanner - PDF Scanner App (332,125); Escanear Documentos PDF (11,678); Adobe Scan: Escáner de PDF (265,977) | 3 |
| escanear documentos | — | 2 harfda, #7 | 57 | 173 | CamScanner - PDF Scanner App (332,125); Escanear Documentos PDF (11,678); Adobe Scan: Escáner de PDF (265,977) | 3 |
| escaner pdf gratis | — | 3 harfda, #3 | 52 | 177 | CamScanner - PDF Scanner App (332,125); Escanear Documentos PDF (11,678); Adobe Scan: Escáner de PDF (265,977) | 3 |
| scanner gratis | — | 3 harfda, #4 | 55 | 170 | CamScanner - PDF Scanner App (332,125); Adobe Scan: Escáner de PDF (265,977); Escanear Documentos - PDF Scan (6,283) | 3 |
| escanear | — | 3 harfda, #8 | 33 | 170 | CamScanner - PDF Scanner App (332,125); Adobe Scan: Escáner de PDF (265,977); Lector código QR y barras (69,292) | 3 |
| escáner documentos gratis | — | 4 harfda, #1 | 43 | 186 | CamScanner - PDF Scanner App (332,125); Scanner Pro: Escáner PDF y Fax (23,138); Adobe Scan: Escáner de PDF (265,977) | 3 |
| escáner documentos | — | 4 harfda, #2 | 31 | 167 | CamScanner - PDF Scanner App (332,125); Escanear Documentos PDF (11,678); Adobe Scan: Escáner de PDF (265,977) | 3 |
| scanner pdf escanear documento | — | 4 harfda, #10 | 48 | 175 | CamScanner - PDF Scanner App (332,125); Escanear Documentos PDF (11,678); Adobe Scan: Escáner de PDF (265,977) | 3 |
| cam escáner | — | 5 harfda, #1 | 48 | 174 | CamScanner - PDF Scanner App (332,125); CamScanner - Scan Document (2); Clear Scan: Escáner de PDF (4,408) | 3 |
| pdf scanner gratis | — | 5 harfda, #2 | 57 | 180 | Escanear Documentos PDF (11,678); CamScanner - PDF Scanner App (332,125); Adobe Scan: Escáner de PDF (265,977) | 3 |
| escaner de documentos | — | 5 harfda, #8 | 20 | 166 | CamScanner - PDF Scanner App (332,125); Adobe Scan: Escáner de PDF (265,977); Scan Shot: Escanear Documentos (4,953) | 3 |
| pdf scanner free | — | 6 harfda, #4 | 9 | 179 | Escanear Documentos PDF (11,678); CamScanner - PDF Scanner App (332,125); PDF Scanner  ‎ (7) | 3 |
| escanear pdf | — | 7 harfda, #3 | 21 | 174 | CamScanner - PDF Scanner App (332,125); Escanear Documentos PDF (11,678); Adobe Scan: Escáner de PDF (265,977) | 3 |
| escanear fotos a pdf | — | 7 harfda, #5 | 21 | 183 | CamScanner - PDF Scanner App (332,125); Escanear documentos・Foto a PDF (3,742); Convertidor a PDF: Imagen PDF (2) | 3 |
| escanear documentos pdf | — | 7 harfda, #9 | 30 | 167 | Escanear Documentos PDF (11,678); CamScanner - PDF Scanner App (332,125); Escanear Documentos, PDF Scan (54) | 3 |
| escanear documentos gratis | — | 7 harfda, #10 | 18 | 181 | CamScanner - PDF Scanner App (332,125); Escanear Documentos \| Scanner. (201); Adobe Scan: Escáner de PDF (265,977) | 3 |
| scanner de documentos | — | 9 harfda, #1 | 28 | 181 | CamScanner - PDF Scanner App (332,125); Escanear documentos・Foto a PDF (3,742); Escanear Documentos PDF (11,678) | 3 |
| escaner imagen | — | 9 harfda, #1 | 2 | 185 | CamScanner - PDF Scanner App (332,125); Escáner PDF Docs & Imágenes (828); Fotos PDF: Escáner y Conversor (23,513) | 3 |
| scanner iphone | — | 9 harfda, #1 | 14 | 184 | CamScanner - PDF Scanner App (332,125); Scanner – Escanear PDF & Docs (78,977); Adobe Scan: Escáner de PDF (265,977) | 3 |
| scanner documentos | — | 9 harfda, #3 | 18 | 186 | CamScanner - PDF Scanner App (332,125); Scanner – Escanear PDF & Docs (78,977); Escanear Documentos PDF (11,678) | 3 |
| escanear pdf gratis | — | 10 harfda, #2 | 41 | 186 | CamScanner - PDF Scanner App (332,125); Escanear Documentos PDF (11,678); Creador de PDF - Escáner (919) | 3 |
| escanear a pdf gratis | — | 10 harfda, #3 | 41 | 186 | CamScanner - PDF Scanner App (332,125); Escanear Documentos PDF (11,678); Convertidor a PDF: Imagen PDF (2) | 3 |
| escanear imagen a pdf | — | 10 harfda, #3 | 39 | 186 | CamScanner - PDF Scanner App (332,125); Conversor PDF - Imagen a PDF (1,846); Creador de PDF - Escáner (919) | 3 |

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
| сканер документов | — | 1 harfda, #9 | 71 | 161 | iScanner - Сканер документов (125,980); CamScanner - Сканер документов (38,075); Сканер Документов в PDF . (11,999) | 3 |
| pdf сканер | — | 2 harfda, #3 | 57 | 168 | Сканер Документов・Сканер пдф (9,343); Adobe Scan: сканер PDF (81,432); PDF Сканер Документов Плюс (454) | 3 |
| сканер | — | 2 harfda, #8 | 76 | 157 | CamScanner - Сканер документов (38,075); Сканер Документов в PDF . (11,999); QR code и Штрих код сканер (51,132) | 3 |
| сканер документов бесплатно | — | 2 harfda, #10 | 47 | 168 | Сканер документов & фото в PDF (26,235); Сканер Документов в PDF . (11,999); Adobe Scan: сканер PDF (81,432) | 3 |
| скан документов | — | 4 harfda, #7 | 60 | 165 | iScanner - Сканер документов (125,980); Сканер Документов в PDF . (11,999); CamScanner - Сканер документов (38,075) | 3 |
| сканирование документов | — | 4 harfda, #10 | 45 | 167 | iScanner - Сканер документов (125,980); Сканер Документов в PDF . (11,999); CamScanner - Сканер документов (38,075) | 3 |
| pdf сканер бесплатно | — | 5 harfda, #2 | 8 | 185 | Сканер Документов в PDF . (11,999); Сканер Документов・Сканер пдф (9,343); Adobe Scan: сканер PDF (81,432) | 3 |
| сканирование документов бесплатно | — | 5 harfda, #4 | 47 | 179 | Adobe Scan: сканер PDF (81,432); CamScanner - Сканер документов (38,075); Сканер Документов в PDF . (11,999) | 3 |
| pdf сканер бесплатный | — | 5 harfda, #4 | 40 | 46 | Сканер Документов в PDF . (11,999); PDF Scanner Сканер документов (101); Сканер PDF: сканировать фото (1,670) | 3 |
| pdf ocr сканер документов | — | 5 harfda, #6 | 50 | 173 | PDF Scanner Сканер документов (101); Adobe Scan: сканер PDF (81,432); PDF OCR Сканер Документов (0) | 3 |
| сканер документов бесплатно pdf | — | 5 harfda, #7 | 46 | 172 | CamScanner - Сканер документов (38,075); Adobe Scan: сканер PDF (81,432); Сканер Документов в PDF . (11,999) | 3 |
| pdf и сканер документов | — | 5 harfda, #8 | 38 | 172 | PDF и сканер документов (10); PDF: ПДФ Файл Редактор, Сканер (9); Сканер Документов в PDF . (11,999) | 3 |
| сканирование | — | 5 harfda, #8 | 38 | 166 | Сканер Документов в PDF . (11,999); CamScanner - Сканер документов (38,075); QR code и Штрих код сканер (51,132) | 3 |
| скан документов бесплатно | — | 6 harfda, #1 | 46 | 172 | Сканер документов & фото в PDF (26,235); Сканер Документов в PDF . (11,999); CamScanner - Сканер документов (38,075) | 3 |
| скан бесплатный | — | 6 harfda, #1 | 31 | 71 | Сканер документов - TapScanner (4,587); Сканер Документов в PDF . (11,999); Adobe Scan: сканер PDF (81,432) | 3 |
| скан сканер | — | 6 harfda, #1 | 53 | 178 | CamScanner - Сканер документов (38,075); Car Scanner ELM OBD2 (64,434); PDF Scanner Сканер документов (101) | 3 |
| скан бесплатно | — | 6 harfda, #3 | 48 | 174 | PDF Сканер Документов Плюс (454); Сканер Документов в PDF . (11,999); CamScanner - Сканер документов (38,075) | 3 |
| скан для документов | — | 6 harfda, #5 | 24 | 170 | CamScanner - Сканер документов (38,075); iScanner - Сканер документов (125,980); Сканер документов & фото в PDF (26,235) | 3 |
| скан камера | — | 6 harfda, #5 | 53 | 169 | CamScanner - Сканер документов (38,075); Adobe Scan: сканер PDF (81,432); Сканер документов - TapScanner (4,587) | 3 |
| сканер бесплатно | — | 8 harfda, #2 | 50 | 185 | Cканер документов в ПДФ файл (12,000); Adobe Scan: сканер PDF (81,432); Сканер Документов в PDF . (11,999) | 3 |
| сканер фото в pdf | — | 8 harfda, #3 | 29 | 185 | Сканер документов & фото в PDF (26,235); CamScanner - Сканер документов (38,075); Сканер Документов в PDF . (11,999) | 3 |
| сканер документов pdf | — | 8 harfda, #6 | 57 | 172 | Сканер Документов・Сканер пдф (9,343); Сканер Документов в PDF . (11,999); CamScanner - Сканер документов (38,075) | 3 |
| сканер для документов | — | 8 harfda, #8 | 26 | 176 | CamScanner - Сканер документов (38,075); Сканер документов & фото в PDF (26,235); Сканер Документов в PDF . (11,999) | 3 |
| сканер pdf подпись документ | — | 12 harfda, #2 | 37 | 184 | Сканер Документов・Сканер пдф (9,343); Сканер документов & фото в PDF (26,235); eSign ‐ Электронная Подпись (3,875) | 3 |
| сканер pdf документов | — | 12 harfda, #3 | 57 | 178 | Сканер PDF-документов (5); Сканер PDF документов (0); Сканер Документов・Сканер пдф (9,343) | 3 |

### TR — App Store tili: `tr` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| scanner | — | 2 harfda, #5 | 74 | 168 | CamScanner - PDF Scanner App (85,808); Adobe Scan: PDF & OCR Scanner (89,095); Scanner App - Scan PDF & Docs (1,926) | 3 |
| tarayıcı | — | 3 harfda, #2 | 51 | 184 | Opera Browser with VPN (55,221); CamScanner - PDF Scanner App (85,808); Firefox Fast & Private Browser (3,078) | 3 |
| belge tarama | — | 3 harfda, #4 | 14 | 179 | Adobe Scan: PDF & OCR Scanner (89,095); CamScanner - PDF Scanner App (85,808); Doc Scanner - PDF Maker (10) | 3 |
| belge tarayıcı | — | 3 harfda, #9 | 7 | 187 | Adobe Scan: PDF & OCR Scanner (89,095); CamScanner - PDF Scanner App (85,808); PDF Scanner・Document Scanner (243) | 3 |
| tarama | — | 4 harfda, #4 | 45 | 181 | CamScanner - PDF Scanner App (85,808); Adobe Scan: PDF & OCR Scanner (89,095); Scan Hero: PDF Scanner (25,447) | 3 |
| scanner ücretsiz | — | 4 harfda, #6 | 45 | 182 | CamScanner - PDF Scanner App (85,808); Adobe Scan: PDF & OCR Scanner (89,095); Scan Hero: PDF Scanner (25,447) | 3 |
| belge tarayıcı ücretsiz | — | 4 harfda, #9 | 20 | 111 | Scan Documents to PDF l by TSP (15); CamScanner - PDF Scanner App (85,808); Adobe Scan: PDF & OCR Scanner (89,095) | 3 |
| pdf tarayıcı | — | 5 harfda, #1 | 20 | 183 | Adobe Scan: PDF & OCR Scanner (89,095); CamScanner - PDF Scanner App (85,808); PDF Scanner・Document Scanner (243) | 3 |
| pdf scanner | — | 5 harfda, #1 | 40 | 177 | CamScanner - PDF Scanner App (85,808); Adobe Scan: PDF & OCR Scanner (89,095); PDF Scanner ⊟ (461) | 3 |
| pdf tarama ücretsiz | — | 5 harfda, #2 | 20 | 178 | CamScanner - PDF Scanner App (85,808); Adobe Scan: PDF & OCR Scanner (89,095); PDF Scanner - Fax, Sign & Edit (1) | 3 |
| pdf scan | — | 5 harfda, #4 | 36 | 176 | Adobe Scan: PDF & OCR Scanner (89,095); CamScanner - PDF Scanner App (85,808); PDF Scan (43) | 3 |
| pdf tarayıcı ücretsiz | — | 5 harfda, #5 | 35 | 175 | CamScanner - PDF Scanner App (85,808); Doc Scanner - PDF Maker (10); Adobe Scan: PDF & OCR Scanner (89,095) | 3 |
| pdf scanner ücretsiz | — | 5 harfda, #6 | 12 | 190 | CamScanner - PDF Scanner App (85,808); Adobe Scan: PDF & OCR Scanner (89,095); PDF Scanner Pro * (18) | 3 |
| scanner app pdf | — | 5 harfda, #7 | 36 | 186 | Scanner App - Scan PDF & Docs (1,926); CamScanner - PDF Scanner App (85,808); Doc Scanner - PDF Maker (10) | 3 |
| pdf tarama | — | 5 harfda, #7 | 17 | 183 | CamScanner - PDF Scanner App (85,808); Adobe Scan: PDF & OCR Scanner (89,095); Scan Hero: PDF Scanner (25,447) | 3 |
| pdf scanner free | — | 5 harfda, #9 | 16 | 180 | CamScanner - PDF Scanner App (85,808); Adobe Scan: PDF & OCR Scanner (89,095); Doc Scanner - PDF Maker (10) | 3 |
| scan pdf tarayıcı | — | 6 harfda, #2 | 2 | 188 | CamScanner - PDF Scanner App (85,808); Adobe Scan: PDF & OCR Scanner (89,095); Scan Hero: PDF Scanner (25,447) | 3 |
| mobile scanner app | — | 6 harfda, #9 | 32 | 190 | Mobile Scanner App - Scan PDF (690); CamScanner - PDF Scanner App (85,808); Adobe Scan: PDF & OCR Scanner (89,095) | 3 |
| belge tarama pdf | — | 7 harfda, #3 | 11 | 184 | CamScanner - PDF Scanner App (85,808); Doc Scanner - PDF Maker (10); Adobe Scan: PDF & OCR Scanner (89,095) | 3 |
| scanner app | — | 9 harfda, #2 | 35 | 166 | Scanner App - Scan PDF & Docs (1,926); CamScanner - PDF Scanner App (85,808); Scanner App: Genius Scan (7,569) | 3 |
| scanner document pdf | — | 9 harfda, #5 | 44 | 195 | Scanner Document PDF (0); Document PDF Scanner. (0); CamScanner - PDF Scanner App (85,808) | 3 |
| scanner to pdf | — | 9 harfda, #7 | 29 | 189 | CamScanner - PDF Scanner App (85,808); Adobe Scan: PDF & OCR Scanner (89,095); Scan to PDF & Document Scanner (22) | 3 |
| ücretsiz belge tarama | — | 10 harfda, #7 | 20 | 182 | PDF Scanner・Document Scan App (11); Adobe Scan: PDF & OCR Scanner (89,095); CamScanner - PDF Scanner App (85,808) | 3 |
| ocr metin tarayıcı | — | 3 harfda, #1 | 4 | 170 | Text Scanner OCR Scan Image (26); Text Scanner - OCR Scan Text (94); OCR Text Scanner: Extract Text (0) | 2 |
| ocr | — | 3 harfda, #3 | 44 | 182 | CamScanner - PDF Scanner App (85,808); Adobe Scan: PDF & OCR Scanner (89,095); Text Scanner - OCR Scan Text (94) | 2 |

### NL — App Store tili: `nl` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| pdf scanner | — | 2 harfda, #2 | 63 | 166 | Adobe Scan: PDF- & OCR-scanner (55,779); PDF Scanner・Documenten scannen (296); CamScanner\|Documenten scannen (11,799) | 3 |
| scanner gratis | — | 2 harfda, #3 | 53 | 176 | Scanner – Scan PDF & Document (3,346); Adobe Scan: PDF- & OCR-scanner (55,779); QR Code Scanner ϟ (43,347) | 3 |
| document scanner | — | 3 harfda, #3 | 57 | 162 | Adobe Scan: PDF- & OCR-scanner (55,779); iScanner - PDF-Scanner (43,732); Scanner App: Genius Scan (28,838) | 3 |
| scanner | — | 3 harfda, #4 | 80 | 172 | Adobe Scan: PDF- & OCR-scanner (55,779); CamScanner\|Documenten scannen (11,799); Scanner App: Genius Scan (28,838) | 3 |
| scan pdf | — | 3 harfda, #5 | 67 | 176 | Adobe Scan: PDF- & OCR-scanner (55,779); CamScanner\|Documenten scannen (11,799); Scanner App: Genius Scan (28,838) | 3 |
| pdf scanner gratis | — | 3 harfda, #6 | 47 | 183 | Adobe Scan: PDF- & OCR-scanner (55,779); Adobe Acrobat Reader PDF-maker (21,298); iScanner - PDF-Scanner (43,732) | 3 |
| document scanner gratis | — | 4 harfda, #7 | 45 | 185 | Adobe Scan: PDF- & OCR-scanner (55,779); Mobile Scanner - Scan to PDF (3,922); iScanner - PDF-Scanner (43,732) | 3 |
| documenten scannen | — | 4 harfda, #9 | 57 | 172 | Adobe Scan: PDF- & OCR-scanner (55,779); Scanner App: Genius Scan (28,838); CamScanner\|Documenten scannen (11,799) | 3 |
| document scannen | — | 4 harfda, #10 | 55 | 180 | Adobe Scan: PDF- & OCR-scanner (55,779); CamScanner\|Documenten scannen (11,799); iScanner - PDF-Scanner (43,732) | 3 |
| ocr pdf scanners gratis | — | 5 harfda, #1 | 49 | 181 | OCR PDF Scanners Gratis (0); CamScanner\|Documenten scannen (11,799); Adobe Scan: PDF- & OCR-scanner (55,779) | 3 |
| pdf scanner free | — | 5 harfda, #4 | 46 | 177 | CamScanner\|Documenten scannen (11,799); Adobe Scan: PDF- & OCR-scanner (55,779); Open Scan: PDF Scanner (0) | 3 |
| pdf documenten scannen editor | — | 5 harfda, #5 | 50 | 148 | PDF documenten scannen editor (11); Adobe Acrobat Reader PDF-maker (21,298); CamScanner\|Documenten scannen (11,799) | 3 |
| scannen gratis | — | 5 harfda, #5 | 51 | 188 | Adobe Scan: PDF- & OCR-scanner (55,779); QR Code & Barcode Scanner (55,944); iScanner - PDF-Scanner (43,732) | 3 |
| pdf ai scanner | — | 5 harfda, #6 | 47 | 185 | PDF AI Scanner (0); Scanner – Scan PDF & Document (3,346); Adobe Scan: PDF- & OCR-scanner (55,779) | 3 |
| documenten scannen gratis | — | 5 harfda, #7 | 45 | 155 | Adobe Scan: PDF- & OCR-scanner (55,779); Scanner App: Genius Scan (28,838); iScanner - PDF-Scanner (43,732) | 3 |
| scan app gratis | — | 6 harfda, #1 | 50 | 180 | Adobe Scan: PDF- & OCR-scanner (55,779); QR Code & Barcode Scanner (55,944); iScanner - PDF-Scanner (43,732) | 3 |
| scan pdf gratis | — | 6 harfda, #1 | 43 | 185 | Adobe Scan: PDF- & OCR-scanner (55,779); CamScanner\|Documenten scannen (11,799); PDF Scanner・Documenten scannen (296) | 3 |
| scan document | — | 6 harfda, #1 | 57 | 173 | Adobe Scan: PDF- & OCR-scanner (55,779); ScanMe - pdf-scanner app (48); CamScanner\|Documenten scannen (11,799) | 3 |
| scan gratis | — | 6 harfda, #1 | 50 | 185 | Scanner App: Genius Scan (28,838); iScanner - PDF-Scanner (43,732); Adobe Scan: PDF- & OCR-scanner (55,779) | 3 |
| scan to pdf | — | 6 harfda, #1 | 48 | 175 | Adobe Scan: PDF- & OCR-scanner (55,779); Mobile Scanner - Scan to PDF (3,922); Scanner App: Genius Scan (28,838) | 3 |
| scan document gratis | — | 6 harfda, #2 | 45 | 183 | Scanner App: Genius Scan (28,838); Adobe Acrobat Reader PDF-maker (21,298); Scanner Pro: Document Scanning (11,664) | 3 |
| scan free | — | 6 harfda, #2 | 49 | 175 | Adobe Scan: PDF- & OCR-scanner (55,779); Free PDF Scanner App For Doc (1); iScanner - PDF-Scanner (43,732) | 3 |
| scan app | — | 6 harfda, #2 | 56 | 158 | Scanner App: Genius Scan (28,838); Adobe Scan: PDF- & OCR-scanner (55,779); CamScanner\|Documenten scannen (11,799) | 3 |
| pdf ocr document scanner | — | 6 harfda, #3 | 48 | 183 | Scanner – Scan PDF & Document (3,346); iScanner - PDF-Scanner (43,732); PDF OCR Document Scanner (0) | 3 |
| scanner documents | — | 6 harfda, #4 | 45 | 181 | CamScanner\|Documenten scannen (11,799); Adobe Scan: PDF- & OCR-scanner (55,779); Scanner – Scan PDF & Document (3,346) | 3 |

### PL — App Store tili: `pl` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| pdf scanner | — | 2 harfda, #2 | 65 | 169 | Adobe Scan: PDF & OCR Scanner (61,512); CamScanner - PDF Scanner App (22,048); PDF Scanner・Document Scanner (441) | 3 |
| scanner | — | 2 harfda, #3 | 70 | 168 | CamScanner - PDF Scanner App (22,048); Adobe Scan: PDF & OCR Scanner (61,512); Scanner – Scan PDF, ID & Docs (1,168) | 3 |
| skaner | — | 3 harfda, #3 | 43 | 184 | Adobe Scan: PDF & OCR Scanner (61,512); CamScanner - PDF Scanner App (22,048); Scan to PDF & Document Scanner (41) | 3 |
| pdf scanner free | — | 3 harfda, #10 | 43 | 177 | Adobe Scan: PDF & OCR Scanner (61,512); CamScanner - PDF Scanner App (22,048); Tiny Scanner - PDF Scanner App (3,464) | 3 |
| darmowy skaner pdf | — | 4 harfda, #5 | 9 | 65 | Adobe Scan: PDF & OCR Scanner (61,512); Scanner App. Scan PDF Document (1,077); PDF Scanner & Editor ++ (0) | 3 |
| scanner free | — | 4 harfda, #6 | 40 | 169 | CamScanner - PDF Scanner App (22,048); Scan to PDF & Document Scanner (41); Adobe Scan: PDF & OCR Scanner (61,512) | 3 |
| skanuj dokumenty | — | 5 harfda, #2 | 17 | 95 | Scan Documents to PDF l by TSP (22); Scanner App - Scan PDF & Docs (1,599); Photo to PDF - Scan Documents (5) | 3 |
| skanuj | — | 5 harfda, #3 | 37 | 186 | ScanMe - PDF Scanner App (41); Scan Hero: PDF Scanner (6,756); Scanner App - Scan PDF & Docs (1,599) | 3 |
| pdf scanner darmowy | — | 5 harfda, #4 | 20 | 56 | Adobe Scan: PDF & OCR Scanner (61,512); Scanner App. Scan PDF Document (1,077); PDF Editor－Scan & Converter (1) | 3 |
| skanuj dokument | — | 5 harfda, #5 | 20 | 86 | PDF Scanner・Document Scan App (91); Doc PDF Scanner: Scan Document (0); Mobile Scanner App - Scan PDF (1,239) | 3 |
| pdf ai scanner | — | 5 harfda, #7 | 41 | 180 | PDF AI Scanner (0); CamScanner - PDF Scanner App (22,048); PDF Scanner, Scan Documents (360) | 3 |
| skanowanie | — | 5 harfda, #7 | 44 | 191 | Adobe Scan: PDF & OCR Scanner (61,512); CamScanner - PDF Scanner App (22,048); QR Code Reader ϟ (19,512) | 3 |
| skaner pdf | — | 5 harfda, #8 | 34 | 173 | PDF Scanner・Document Scanner (441); Adobe Scan: PDF & OCR Scanner (61,512); CamScanner - PDF Scanner App (22,048) | 3 |
| scan pdf free | — | 6 harfda, #3 | 43 | 179 | CamScanner - PDF Scanner App (22,048); Adobe Scan: PDF & OCR Scanner (61,512); iScanner: PDF Doc Scanner App (13,908) | 3 |
| skaner free | — | 8 harfda, #1 | 47 | 191 | Scan Hero: PDF Scanner (6,756); CamScanner - PDF Scanner App (22,048); Adobe Scan: PDF & OCR Scanner (61,512) | 3 |
| mobile scanner pdf app | — | 8 harfda, #2 | 44 | 171 | Mobile Scanner App - Scan PDF (1,239); Mobile Scanner PDF App (1); Adobe Scan: PDF & OCR Scanner (61,512) | 3 |
| skaner darmowy | — | 8 harfda, #2 | 36 | 170 | Adobe Scan: PDF & OCR Scanner (61,512); CamScanner - PDF Scanner App (22,048); PDF Scanner ⊟ (1,274) | 3 |
| skaner do pdf | — | 8 harfda, #8 | 35 | 157 | iScanner: PDF Doc Scanner App (13,908); PDF Scanner・Document Scan App (91); PDF Scanner・Document Scanner (441) | 3 |
| scanner app | — | 9 harfda, #1 | 62 | 158 | Scanner App - Scan PDF & Docs (1,599); Scanner App: Genius Scan (12,076); CamScanner - PDF Scanner App (22,048) | 3 |
| scanner document pdf | — | 9 harfda, #5 | 51 | 187 | CamScanner - PDF Scanner App (22,048); Scanner Document PDF (8); iScanner: PDF Doc Scanner App (13,908) | 3 |
| skaner dokumentów | — | 9 harfda, #10 | 38 | 187 | Adobe Scan: PDF & OCR Scanner (61,512); CamScanner - PDF Scanner App (22,048); PDF Scanner App: TapScanner (2,426) | 3 |
| ocr scanner | — | 3 harfda, #1 | 48 | 178 | Adobe Scan: PDF & OCR Scanner (61,512); OCR Scanner - Paper to Text (0); OCR Scanner - Scan PDF & Image (3) | 2 |
| ocr | — | 3 harfda, #3 | 53 | 185 | Adobe Scan: PDF & OCR Scanner (61,512); CamScanner - PDF Scanner App (22,048); Text Scanner - OCR Scan Text (51) | 2 |
| pdf to jpg convert | — | 5 harfda, #3 | 18 | 190 | PDF To JPG Convert (10); iLovePDF - PDF Editor & Scan (1,948); Convert PDF to JPG,PDF to PNG (17) | 2 |
| pdf ocr pro | — | 5 harfda, #5 | 48 | 182 | Adobe Scan: PDF & OCR Scanner (61,512); CamScanner - PDF Scanner App (22,048); Adobe Acrobat Reader: Edit PDF (12,322) | 2 |

### SE — App Store tili: `sv` · ilova lokalizatsiyasi: ✅ bor

| Kalit so'z | Apple popularity | Autocomplete | Qiyinlik | Ilovalar | Top-3 raqobatchi | Relevantlik |
|---|---|---|---|---|---|---|
| pdf scanner | — | 2 harfda, #2 | 55 | 163 | PDF Scanner ⊟ (906); Adobe Scan: PDF & OCR Scanner (26,155); CamScanner - PDF-skanner (5,923) | 3 |
| scanner | — | 2 harfda, #3 | 67 | 167 | Scanner App: Genius Scan (18,151); CamScanner - PDF-skanner (5,923); Spiris Scanner (3,176) | 3 |
| pdf scanner free | — | 2 harfda, #6 | 44 | 174 | Adobe Scan: PDF & OCR Scanner (26,155); CamScanner - PDF-skanner (5,923); iScanner - PDF-skanner (15,569) | 3 |
| pdf scanner gratis | — | 2 harfda, #7 | 41 | 177 | Adobe Scan: PDF & OCR Scanner (26,155); Mobile Scanner - Skanna PDF (1,235); iScanner - PDF-skanner (15,569) | 3 |
| scanner gratis | — | 3 harfda, #3 | 46 | 176 | Adobe Scan: PDF & OCR Scanner (26,155); QR Reader for iPhone (36,803); Scanner App: Genius Scan (18,151) | 3 |
| skanna dokument | — | 4 harfda, #4 | 25 | 174 | iScanner - PDF-skanner (15,569); Adobe Scan: PDF & OCR Scanner (26,155); Scanna Dokument till PDF (0) | 3 |
| ocr pdf scanners gratis | — | 5 harfda, #1 | 42 | 183 | OCR PDF Scanners gratis (0); Adobe Scan: PDF & OCR Scanner (26,155); Adobe-dokumentpaket: Visa, kommentera, dela PDF och skanna dokument (0) | 3 |
| pdf ai scanner | — | 5 harfda, #3 | 37 | 178 | PDF AI Scanner (0); Adobe Scan: PDF & OCR Scanner (26,155); CamScanner - PDF-skanner (5,923) | 3 |
| skanner | — | 5 harfda, #3 | 52 | 166 | ScanMe - App för PDF-skanning (88); QR Reader for iPhone (36,803); iScanner - PDF-skanner (15,569) | 3 |
| scanner free | — | 5 harfda, #6 | 46 | 172 | Scanna dokument till PDF: OCR (9); iScanner - PDF-skanner (15,569); CamScanner - PDF-skanner (5,923) | 3 |
| skanna | — | 5 harfda, #8 | 47 | 186 | ScanMe - App för PDF-skanning (88); QR Reader for iPhone (36,803); Scanna dokument till PDF: OCR (9) | 3 |
| scanner app | — | 9 harfda, #1 | 45 | 165 | Scanner App: Genius Scan (18,151); Skanner-app: Skanna PDF & dok (391); Adobe Scan: PDF & OCR Scanner (26,155) | 3 |
| scanner document pdf converter | — | 9 harfda, #4 | 29 | 186 | Scanner Document PDF Converter (0); CamScanner - PDF-skanner (5,923); PDF Reader & Scanner: Edit, Sign, Fill, Convert & Scan any documents. Free PDF Viewer (0) | 3 |
| pdf scanner, editor, converter | — | 12 harfda, #2 | 14 | 187 | PDF Scanner, Editor, Converter (5); PDF Skanner: Scanna, Redigera (3); File Manager & Scanner: Edit, Sign, Convert, Scan any PDF Documents. Fax & Printer (0) | 3 |
| pdf scanner, converter, editor | — | 12 harfda, #4 | 25 | 187 | PDF Scanner : Converter,Editor (1); File Manager & Scanner: Edit, Sign, Convert, Scan any PDF Documents. Fax & Printer (0); CamScanner - PDF-skanner (5,923) | 3 |
| pdf scanner, convert document | — | 12 harfda, #6 | 25 | 187 | CamScanner - PDF-skanner (5,923); PDF Reader & Scanner: Edit, Sign, Fill, Convert & Scan any documents. Free PDF Viewer (0); File Manager & Scanner: Edit, Sign, Convert, Scan any PDF Documents. Fax & Printer (0) | 3 |
| pdf scanner documents | — | 13 harfda, #3 | 39 | 192 | CamScanner - PDF-skanner (5,923); iScanner - PDF-skanner (15,569); Adobe Scan: PDF & OCR Scanner (26,155) | 3 |
| pdf scanner for me | — | 13 harfda, #4 | 39 | 77 | Scan Hero: PDF-skanner (4,442); CamScanner - PDF-skanner (5,923); PDF Scanner For Me (0) | 3 |
| pdf scanner document converter | — | 13 harfda, #7 | 44 | 195 | CamScanner - PDF-skanner (5,923); Scan to PDF: Converter Scanner (7); PDF Scanner Document Converter (1) | 3 |
| pdf scanner file converter | — | 13 harfda, #9 | 36 | 184 | File Manager & Scanner: Edit, Sign, Convert, Scan any PDF Documents. Fax & Printer (0); Adobe Scan: PDF & OCR Scanner (26,155); CamScanner - PDF-skanner (5,923) | 3 |
| pdf scanner easy | — | 13 harfda, #9 | 19 | 154 | PDF Scanner - Lätt att scanna! (143); Document PDF Scanner. (1); Adobe Scan: PDF & OCR Scanner (26,155) | 3 |
| pdf scanner document scanner | — | 13 harfda, #10 | 28 | 192 | PDF Skanner・Document Scanner (24); PDF Scanner - PDF Skapare, OCR (1); Adobe Scan: PDF & OCR Scanner (26,155) | 3 |
| ocr | — | 3 harfda, #2 | 43 | 173 | QR Reader for iPhone (36,803); Adobe Scan: PDF & OCR Scanner (26,155); OCR Textscanner - Skanna Text (19) | 2 |
| pdf signer | — | 5 harfda, #4 | 30 | 175 | PDF Signer - Signing Documents (2); Adobe Acrobat Reader PDF-filer (8,903); Docusign - Upload & Sign Docs (1,381) | 2 |
| skanna bilder | — | 5 harfda, #6 | 38 | 177 | Fotoskanner från Google Foto (2,772); Fotoskanner av Photomyne (2,407); Scan Hero: PDF-skanner (4,442) | 2 |

