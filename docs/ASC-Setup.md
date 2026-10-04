# Scanmuse — App Store Connect sozlash

Apple App Store Connect API ilovaning **o'zini** (app record) yaratishga ruxsat bermaydi — `apps` resursida
`POST` yo'q. Shuning uchun 1-qadam brauzerda (qo'lda yoki Claude in Chrome bilan) bir marta bajariladi.
Qolgan hammasi API orqali: `tools/asc/asc_setup.py` va `fastlane deliver`.

| # | Qadam | Qanday | Holat |
|---|---|---|---|
| 0 | API kaliti → GitHub secrets: `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8` | GitHub → Settings → Secrets and variables → Actions | — |
| 1 | Bundle ID `com.scanlet.app` ro'yxatdan o'tkazish | API: Actions → *App Store Connect* → `bundle` | — |
| 2 | **Ilova yozuvini yaratish** | Brauzer (pastdagi jadval) | — |
| 3 | Obunalar: guruh, haftalik/oylik, narxlar, 3 kunlik bepul sinov | API: `subscriptions` | — |
| 4 | 34 lokalizatsiya metadata | API: `metadata-check`, keyin `metadata-upload` | — |
| 5 | Ilova ma'lumotlari, narx, maxfiylik, yosh reytingi | Brauzer (pastda) | — |
| 6 | Obuna review skrinshotlari, build, review'ga yuborish | Brauzer + Xcode | — |

`status` vazifasi (faqat o'qiydi) har qadamdan keyin nima bor, nima yo'qligini ko'rsatadi.

## 2. New App formasi (App Store Connect → Apps → ＋ → New App)

| Maydon | Qiymat |
|---|---|
| Platforms | **iOS** |
| Name | **Scanmuse: PDF Document Scanner** |
| Primary Language | **English (U.S.)** |
| Bundle ID | **com.scanlet.app** (1-qadamdan keyin ro'yxatda chiqadi) |
| SKU | **scanmuse-ios-001** |
| User Access | **Full Access** |

## 5. Brauzerda to'ldiriladigan qolgan maydonlar

| Bo'lim | Maydon | Qiymat |
|---|---|---|
| App Information | Category | Primary: **Productivity**, Secondary: **Business** |
| App Information | Content Rights | **Does not contain, show, or access third-party content** |
| App Information | Age Rating | Barcha savollarga **None / No** → **4+** |
| App Privacy | Privacy Policy URL | https://akbaralikhasanov-2000.github.io/New-App/privacy.html |
| App Privacy | Data collection | **Data Not Collected** (hisob, analitika va bulut yo'q; xaridlarni Apple boshqaradi) |
| Pricing and Availability | Price | **Free** (ichida obunalar) |
| Pricing and Availability | Availability | Barcha mamlakatlar. Xitoy materigi uchun ICP ro'yxatdan o'tkazish talab qilinadi — tayyor bo'lmaguncha **China mainland**ni olib tashlang |
| Subscriptions → har bir obuna | Review Information | Paywall skrinshoti (CI artefaktida `04-paywall.png`) + izoh: "Unlocks unlimited OCR, searchable PDFs, signatures, password-protected PDFs, Face ID lock, watermark-free export." |
| App Review Information | Notes | `fastlane/metadata/review_information/notes.txt` (deliver yuklaydi) |

## Claude in Chrome uchun tayyor topshiriq

Mac'dagi Claude (Chrome kengaytmasi bilan) ga quyidagini bering:

> App Store Connect'da (appstoreconnect.apple.com) Apps → ＋ → New App ni bos va formani to'ldir:
> Platform iOS; Name "Scanmuse: PDF Document Scanner"; Primary Language English (U.S.);
> Bundle ID com.scanlet.app; SKU scanmuse-ios-001; User Access Full Access. Create ni bos.
> Agar nom band desa, to'xta va menga ayt. Keyin App Information'da Category: Productivity / Business,
> Content Rights: "does not contain third-party content" qilib saqla. Parol yoki 2FA kodi so'ralsa, menga qoldir.

## Mac terminalidan (GitHub Actions o'rniga)

```sh
pip3 install pyjwt cryptography requests && brew install fastlane
export ASC_KEY_ID=… ASC_ISSUER_ID=… ASC_KEY_PATH=~/keys/AuthKey_XXXX.p8
python3 tools/asc/asc_setup.py status
python3 tools/asc/asc_setup.py bundle
python3 tools/asc/asc_setup.py subscriptions     # app record yaratilgandan keyin
fastlane deliver --api_key_path asc_api_key.json # {"key_id","issuer_id","key"} JSON
```
