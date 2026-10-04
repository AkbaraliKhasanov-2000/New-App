# Scanmuse: PDF Document Scanner

iPhone uchun PDF skaner va OCR ilovasi. SwiftUI'da yozilgan, iOS 26+ da Liquid Glass dizaynidan foydalanadi va iOS 17 dan boshlab qo'llab-quvvatlanadi. Apple Human Interface Guidelines asosida qurilgan.

## Imkoniyatlar

- **Skanerlash**: VisionKit hujjat kamerasi. Chegaralarni avtomatik aniqlaydi, perspektivani tuzatadi va bir necha sahifani ketma-ket suratga oladi.
- **Import**: Photos va Files'dan rasm va PDF olish. Rasmdagi hujjat avtomatik kesiladi (Vision document segmentation).
- **Filtrlar**: Original, Auto (soya olib tashlash), Vivid, Grayscale, B&W. Asl rasm saqlanib qoladi, shuning uchun filtrni istalgan vaqtda sifat yo'qotmasdan almashtirish mumkin.
- **Tahrirlash**: 4 burchakli qo'lda kesish, burish, zoom, sahifalarni tartiblash va o'chirish, sahifa qo'shish.
- **OCR**: Vision orqali, faqat qurilmada. Matnni nusxalash, ulashish, tarjima qilish (iOS 17.4+) va barcha hujjatlar bo'yicha to'liq matnli qidiruv.
- **Qidiriladigan PDF**: sahifaga ko'rinmas matn qatlami qo'shiladi, shuning uchun matnni istalgan PDF ilovada topish va belgilash mumkin.
- **Eksport**: PDF (A4, Letter, Legal yoki rasm o'lchamida; 3 xil sifat), JPG, TXT. Parolli PDF ham yaratiladi.
- **Imzo**: PencilKit orqali chiziladi, saqlanadi, sahifaga sudrab joylashtiriladi va o'lchami o'zgartiriladi.
- **Kutubxona**: jildlar, sevimlilar, saralash, grid va list ko'rinishlari, bir nechtasini tanlash, birlashtirish, ko'chirish.
- **Maxfiylik**: Face ID, Touch ID yoki parol bilan qulflash, App Switcher'da kontentni yashirish. Ma'lumotlar faqat qurilmada saqlanadi.
- **Siri va Shortcuts**: "Scan a document with Scanmuse" va "Convert photos to PDF with Scanmuse" buyruqlari.
- **Obuna**: StoreKit 2 asosida haftalik ($4.99, 3 kun bepul) va oylik ($9.99) tariflar, sinov muddatiga huquqni tekshirish va xaridlarni tiklash.
- **Tillar**: English, Русский, O'zbekcha (String Catalog, ko'plik shakllari bilan).
- **Accessibility**: VoiceOver belgilari, Dynamic Type, haptic javoblar.

## Talablar

- Xcode 26 yoki yangiroq (iOS 26 SDK Liquid Glass uchun kerak).
- Deployment target: **iOS 17.0**, faqat iPhone.

## Ishga tushirish

1. `Scanlet.xcodeproj` ni Xcode'da oching.
   (Ichki loyiha, target va bundle ID nomlari `Scanlet` bo'lib qoladi — foydalanuvchiga ko'rinmaydi; ekrandagi nom `Scanmuse`.)
2. *Signing & Capabilities* bo'limida o'z Team'ingizni tanlang. Kerak bo'lsa, Bundle ID'ni (`com.scanlet.app`) o'zgartiring.
3. **Run** tugmasini bosing. Scheme'ga `Products.storekit` ulangan, shuning uchun xaridlarni simulyatorda ham sinab ko'rish mumkin.
4. Testlar uchun **⌘U** ni bosing.

> Hujjat kamerasi faqat haqiqiy qurilmada ishlaydi. Simulyatorda "Import from Photos" dan foydalaning.

Loyiha faylini qayta yaratish uchun: `brew install xcodegen && xcodegen generate` (`project.yml` asosida).

## App Store'ga chiqarishdan oldin

1. App Store Connect'da `com.scanlet.app.pro.weekly` va `com.scanlet.app.pro.monthly` obunalarini **Scanmuse Pro** guruhida yarating. Haftalik tarifga 3 kunlik bepul sinov qo'shing.
2. `Scanlet/App/AppConfig.swift` faylida `appStoreID` va `supportEmail` qiymatlarini yangilang.
3. Repozitoriyada GitHub Pages'ni yoqing (Settings → Pages → `main` / `docs`). Maxfiylik siyosati `…/New-App/privacy.html` manzilida chiqadi.
4. Metama'lumotlar `fastlane/metadata/` papkasida tayyor (en-US, ru, es-MX).
5. App Privacy bo'limida **Data Not Collected** ni belgilang.

ASO va narxlar tahlili: [docs/ASO-va-Narxlar.md](docs/ASO-va-Narxlar.md)

## Tuzilma

```
Scanlet/
  App/         Kirish nuqtasi, RootView, konfiguratsiya
  Models/      SwiftData: ScanDocument, ScanPage, Folder
  Services/    OCR, rasmga ishlov berish, eksport, StoreKit, App Lock
  Views/       Library, Document, Export, Paywall, Settings, Signature, Onboarding
  Intents/     App Intents (Siri / Shortcuts)
  Resources/   Assets, String Catalog, StoreKit config, Privacy manifest
ScanletTests/  Swift Testing unit testlari
fastlane/      App Store metama'lumotlari
docs/          Maxfiylik siyosati, yordam sahifasi, ASO tahlili
tools/         Ikonka va tarjimalarni yaratuvchi skriptlar
```
