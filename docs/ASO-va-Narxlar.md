# Scanlet: ASO va narx strategiyasi

> Tadqiqot sanasi: 2026-yil 29-sentabr. Ma'lumotlar App Store (US) sahifalari va ASO manbalaridan olingan.

## 1. Nom tanlash tahlili

### Tekshirilgan nomlar

| Nom | Holati | Xulosa |
|---|---|---|
| Scanly | Band: "PDF Scanner - Scanly", "Scanly AI: PDF Scanner" | ❌ |
| Scanora | Band: "Scanora OCR", "Scanora – PDF Scan & Sign" | ❌ |
| ScanZen | Band: AI mahsulot skaneri, Fujitsu ScanZen | ❌ |
| Scanvio | Band: ScanVio AI PDF Scanner (Google Play) | ❌ |
| ScanPilot | Band: iOS va Google Play'da | ❌ |
| ScanMint | Mint (karta skaneri) bilan chalkashadi | ❌ |
| Docora | Band: PDF Scanner, Editor & AI | ❌ |
| Paperwise / ScanWise | Band | ❌ |
| **Scanlet** | **App Store'da bir xil nomli ilova yo'q** | ✅ **Tanlandi** |

### Nega aynan "Scanlet"?
- **Qisqa**: 7 harf. Yodda qolishi, yozilishi va aytilishi oson.
- **Mazmunli**: "scan" o'zagi + "-let" kichraytiruvchi qo'shimchasi ("cho'ntakdagi skaner" ma'nosi).
- **Noyob**: App Store'da to'qnashuv yo'q, shuning uchun brend so'rovida birinchi o'rinni olish oson.
- **Xalqaro**: rus, ingliz va o'zbek tillarida bir xil o'qiladi.

## 2. App Store metama'lumotlari (ASO)

Apple qidiruvda **Name**, **Subtitle** va **Keywords** maydonlarini indekslaydi va ulardagi so'zlarni o'zaro birlashtiradi. Shuning uchun bitta so'zni ikki marta yozish joyni behuda sarflaydi.

### en-US (asosiy)

| Maydon | Qiymat | Limit |
|---|---|---|
| Name | `Scanlet: PDF Doc Scanner & OCR` | 30/30 |
| Subtitle | `Scan Documents & Image to Text` | 30/30 |
| Keywords | `converter,sign,signature,receipt,id,card,photo,camera,paper,notes,jpg,editor,translate,cam,picture` | 98/100 |

Qamrab olinadigan asosiy so'rovlar: *pdf scanner, doc scanner, document scanner, scanner app, scan documents, image to text, ocr, text scanner, pdf converter, receipt scanner, id card scanner, photo to pdf, camera scanner, signature, jpg to pdf*.

### Qo'shimcha lokalizatsiyalar
- **es-MX**: AQSh do'koni es-MX metama'lumotlarini ham indekslaydi. Bu kalit so'zlarga qo'shimcha 100 belgi joy beradi.
- **ru**: Rossiya, O'zbekiston va MDH do'konlari uchun. Rus tilidagi kalit so'zlar **100 baytdan** oshmasligi kerak. Kirill harfi 2 bayt oladi, shuning uchun eng kuchli so'zlar tanlandi.

> App Store'da o'zbek tili lokalizatsiyasi yo'q. O'zbekiston do'konida ilova rus yoki ingliz metama'lumotlari bilan ko'rinadi. Ilovaning o'zi esa o'zbek tiliga to'liq tarjima qilingan.

Barcha matnlar `fastlane/metadata/` papkasida tayyor. Ularni `fastlane deliver` yordamida yuklash yoki App Store Connect'ga qo'lda nusxalash mumkin.

### Kategoriya va boshqa sozlamalar
- **Asosiy kategoriya**: Productivity. **Qo'shimcha**: Business.
- **Yosh reytingi**: 4+.
- **App Privacy**: "Data Not Collected". Ilova hech qanday ma'lumot yig'maydi.

### Skrinshotlar rejasi (6.9" va 6.5")
1. "Scan Documents in Seconds": skaner kamerasi va chegaralarni aniqlash.
2. "Image to Text with OCR": ajratilgan matn ekrani.
3. "Searchable, Shareable PDFs": eksport oynasi.
4. "Sign Anything": imzo qo'yish.
5. "Organize with Folders": kutubxona (grid ko'rinishi).
6. "Private. On-Device. Face ID": qulf ekrani.

## 3. Narxlar tahlili

### Raqobatchilar (AQSh App Store, 2026-yil sentabr)

| Ilova | Reyting | Haftalik | Oylik | Yillik |
|---|---|---|---|---|
| iScanner | 4.8 (1.4M) | $3.99–$4.99 | — | $19.99–$20.99 |
| Scanner App – Scan PDF & Docs | 4.6 (35K) | $3.99–$14.99 (asosan $9.99) | — | $19.99 |
| Scanner – Scan PDF, ID & Docs | 4.7 (223K) | — | $9.99 dan | — |
| CamScanner+ | 4.9 | — | $4.99 | $49.99 |
| Adobe Scan | 4.9 (1.6M) | — | $4.99 (Plus) / $9.99 (Premium) | $19.99–$69.99 |
| PDF Scanner・Scan Documents | 4.7 | — | $14.99 | $24.99–$49.99 |
| Genius Scan+ | 4.9 | — | — | $29.99 |

**Bozor medianasi**: haftalik ≈ **$4.99–$9.99**, oylik ≈ **$9.99**.

### Scanlet Pro narxlari

| Tarif | Narx | Sinov muddati | Nega |
|---|---|---|---|
| **Weekly** | **$4.99 / hafta** | **3 kun bepul** | Bozor yetakchisi iScanner darajasida. $9.99 ga qaraganda salbiy sharhlar va pulni qaytarish so'rovlari kamroq bo'ladi. Bepul sinov konversiyani oshiradi. |
| **Monthly** | **$9.99 / oy** | Yo'q | Adobe Scan va Scanner bilan bir xil. Haftalik tarifga nisbatan **53% tejam** (4.99 × 52 / 12 = $21.62). Paywall'da "SAVE 53%" belgisi avtomatik hisoblanadi. |

- Ikkala tarif ham bitta obuna guruhida ("Scanlet Pro"). Foydalanuvchi ular orasida o'tishi mumkin, oylik tarif darajasi yuqoriroq.
- Mahalliy narxlarni App Store Connect avtomatik tenglashtiradi (O'zbekiston, Rossiya va boshqa do'konlar uchun).
- **Kelajak uchun tavsiya**: 1–2 oy ma'lumot to'plangandan keyin yillik tarifni ($29.99) A/B test qilib ko'rish mumkin.

### Bepul va Pro imkoniyatlar

| Imkoniyat | Bepul | Pro |
|---|---|---|
| Skanerlash, filtrlar, kesish, burish | ✅ Cheksiz | ✅ |
| Kutubxona, jildlar, qidiruv, birlashtirish | ✅ | ✅ |
| PDF / JPG eksport | ✅ ("Scanned with Scanlet" yozuvi bilan) | ✅ Yozuvsiz |
| OCR matnni ko'rish, nusxalash, tarjima | 3 ta hujjat | ✅ Cheksiz |
| Qidiriladigan (searchable) PDF | — | ✅ |
| Elektron imzo | — | ✅ |
| Parolli PDF | — | ✅ |
| Face ID qulfi | — | ✅ |

Asosiy funksiyalar bepul qoldirilgan, shuning uchun foydalanuvchi ilovani sinab ko'rib, yaxshi baho qoldiradi. Pul to'lanadigan qism esa professional ehtiyojlarga qaratilgan.
