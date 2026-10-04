# Scanmuse — App Store metadata (4-bosqich)

> Har bir qator `tools/aso/metadata.py` da saqlanadi va Apple limitlari bo'yicha avtomatik tekshiriladi (nom ≤ 30, subtitle ≤ 30, keywords ≤ 100 bayt, promo ≤ 170, bir lokalizatsiya ichida so'z takrorlanmaydi). "Asos" ustunidagi raqamlar `docs/ASO-Research.md` jadvallaridan: **Lx** = Apple autocomplete bu so'zni x-harfdan keyin taklif qiladi (kichik = ko'p qidiriladi), **Dx** = qiyinlik 1–100, **Px** = Apple popularity.

**Brend:** `Scanmuse` — 2-bosqichda 174 do'konning birortasida aynan bir xil yoki o'xshash ilova yo'q, USPTO'da yaqin faol belgi yo'q. `Scanlet` band (55 do'konda aynan shu nomli ilova bor).

## 1. Qaysi do'kon qaysi lokalizatsiyalarni indekslaydi (cross-localization)

Manba: [Apple — App Store localizations](https://developer.apple.com/help/app-store-connect/reference/app-store-localizations)

| Do'kon | Indekslanadigan lokalizatsiyalar | Jami kalit so'z joyi |
|---|---|---|
| US | **en-US**, **es-MX**, **pt-BR**, **fr-FR**, **ru**, **ko**, **ar-SA**, **zh-Hans**, **zh-Hant**, **vi** | 10 × (30+30+100) |
| GB | **en-GB** | 1 × (30+30+100) |
| CA | **en-CA**, **fr-CA** | 2 × (30+30+100) |
| AU | **en-AU**, **en-GB** | 2 × (30+30+100) |
| IN | **en-GB**, hi | 1 × (30+30+100) |
| DE | **de-DE**, **en-GB** | 2 × (30+30+100) |
| FR | **fr-FR**, **en-GB** | 2 × (30+30+100) |
| ES | **es-ES**, **ca**, **en-GB** | 3 × (30+30+100) |
| IT | **it**, **en-GB** | 2 × (30+30+100) |
| BR | **pt-BR**, **en-GB** | 2 × (30+30+100) |
| MX | **es-MX**, **en-GB** | 2 × (30+30+100) |
| JP | **ja**, **en-US** | 2 × (30+30+100) |
| KR | **ko**, **en-GB** | 2 × (30+30+100) |
| RU | **ru**, **en-GB**, **uk** | 3 × (30+30+100) |
| TR | **tr**, **en-GB** | 2 × (30+30+100) |
| NL | **nl-NL**, **en-GB** | 2 × (30+30+100) |
| PL | **pl**, **en-GB** | 2 × (30+30+100) |
| SE | **sv**, **en-GB** | 2 × (30+30+100) |

Qalin = bizda to'ldirilgan. en-GB bitta o'zi 13 ta asosiy bozorda qo'shimcha indekslanadi, shuning uchun unga inglizcha asosiy so'zlar qo'yildi (BR, MX, TR, KR, RU'da ham inglizcha "scanner", "pdf scanner" autocomplete'da birinchi 2 harfda chiqadi).

## 2. Metadata (App Store Connect'ga kiritiladigan qiymatlar)

| Lokalizatsiya | Bozor | App nomi (30) | Subtitle (30) | Keywords (100 bayt) | Uzunlik n/s/k |
|---|---|---|---|---|---|
| `en-US` | US (+JP) | Scanmuse: PDF Document Scanner | Scan App: OCR Text & Signature | `receipt,sign,signer,jpg,converter,photo,image,camera,cam,doc,id,card,paper,translate,copy,extract` | 30/30/97 |
| `en-GB` | GB, AU, IN + English searches in DE FR ES IT BR MX KR RU TR NL PL SE | Scanmuse: PDF Document Scanner | Scan App: OCR Text & Signature | `receipt,sign,signer,jpg,converter,photo,image,camera,maker,doc,id,card,paper,translate,copy,extract` | 30/30/99 |
| `en-AU` | AU (en-GB also indexed) | Scanmuse: PDF Document Scanner | Scan Documents & Image to Text | `receipts,app,ocr,photos,pictures,picture,files,handwriting,notes,lock,password,print,reader,maker` | 30/30/97 |
| `en-CA` | CA (fr-CA also indexed) | Scanmuse: PDF Document Scanner | Scan App: OCR Text & Signature | `receipt,sign,signer,jpg,converter,photo,image,camera,cam,doc,id,card,paper,translate,copy,extract` | 30/30/97 |
| `ar-SA` | US (extra slot) | Scanmuse: PDF Document Scanner | Scan Receipts, IDs & Contracts | `handwriting,notes,files,print,share,reader,phone,mobile,batch,multipage` | 30/30/71 |
| `vi` | US (extra slot) | Scanmuse: PDF Document Scanner | Pictures & Photos to Text | `picture,images,png,jpeg,convert,documents,pages,quick,crop,enhance,filter` | 30/25/73 |
| `zh-Hans` | US (extra slot) | Scanmuse: PDF Document Scanner | E-Sign & Password Lock | `esign,initials,agreement,draw,autograph,secure,private,faceid,protect,signed` | 30/22/76 |
| `zh-Hant` | US (extra slot) | Scanmuse: PDF Document Scanner | Searchable Docs & Text Capture | `recognition,recognize,extractor,words,letters,language,languages,offline,scanning,scanned` | 30/30/89 |
| `tr` | TR | Scanmuse: PDF Belge Tarayıcı | Tarama, OCR Metin Tanıma, İmza | `scanner,tara,evrak,fiş,kimlik,fotoğraf,fotoğraftan,metne,resim,yazı,jpg,çeviri,şifre` | 28/30/90 |
| `ru` | RU (+US) | Scanmuse: Сканер документов | PDF, скан текста и подпись | `сканирование,чек,фото,текст,jpg,конвертер,паспорт` | 27/26/89 |
| `uk` | UA (+RU) | Scanmuse: Сканер документів | PDF, текст із фото, підпис | `скан,сканування,чек,паспорт,jpg,конвертер,переклад` | 27/26/91 |
| `pt-BR` | BR (+US) | Scanmuse: Escanear Documentos | Digitalizar PDF, Assinar e OCR | `scanner,documento,texto,imagem,foto,assinatura,recibo,nota,fiscal,rg,cnh,jpg,converter` | 29/30/86 |
| `es-MX` | MX (+US) | Scanmuse: Escáner PDF y OCR | Escanear documentos y firmar | `escaner,scanner,fotos,texto,imagen,firma,recibo,factura,convertir,jpg,traducir,cámara,ine` | 27/28/90 |
| `de-DE` | DE (+AT, CH) | Scanmuse: Dokumente Scannen | PDF Scanner, OCR, Unterschrift | `kassenbon,beleg,unterschreiben,erstellen,app,foto,bild,jpg,umwandeln,texterkennung,ausweis,scan` | 27/30/95 |
| `fr-FR` | FR (+US, BE, CH) | Scanmuse: Scanner PDF Document | Scan, OCR, Signature & Texte | `numériser,image,photo,jpg,fichier,doc,reçu,facture,identité,carte,convertisseur,traduire,caméra` | 30/28/99 |
| `fr-CA` | CA (with en-CA) | Scanmuse: Numériser Documents | Scanneur PDF, OCR et signature | `texte,image,photo,reçu,facture,carte,jpg,convertisseur,traduire,caméra,fichier,scan,numérisation` | 29/30/99 |
| `sv` | SE | Scanmuse: Skanna dokument | PDF skanner, OCR och signatur | `skanning,bilder,bild,text,kvitto,id,kort,foto,kamera,jpg,konvertera,översätt,lösenord,fil` | 25/29/92 |
| `es-ES` | ES | Scanmuse: Escanear Documentos | Escáner PDF, OCR y firmar | `escaner,fotos,texto,imagen,firma,recibo,factura,dni,convertir,jpg,traducir,cámara,scanner` | 29/25/90 |
| `ca` | ES (extra slot) | Scanmuse: Escanejar Documents | Escàner PDF, OCR i signatura | `escaneig,imatge,foto,rebut,traduir,càmera,signar,escaneja,fitxer,targeta,arxiu,lector` | 29/28/86 |
| `it` | IT | Scanmuse: Scansione Documenti | Scanner PDF, OCR testo e firma | `scansiona,foto,immagine,ricevuta,scontrino,fattura,identità,carta,jpg,convertitore,traduci,scan,app` | 29/30/100 |
| `pl` | PL | Scanmuse: Skaner dokumentów | Skanuj PDF, tekst OCR, podpis | `skanowanie,dokumenty,dokument,zdjęcia,zdjęcie,paragon,dowód,jpg,konwerter,faktura,hasło,skan` | 27/29/96 |
| `nl-NL` | NL | Scanmuse: Documenten Scannen | PDF Scanner, OCR, Ondertekenen | `scan,document,foto,tekst,bon,kassabon,handtekening,afbeelding,jpg,vertalen,wachtwoord,id` | 28/30/88 |
| `ja` | JP | Scanmuse: 書類スキャン・PDFスキャナー | 写真から文字読み取り・OCR・署名 | `アプリ,カメラ,画像,変換,レシート,文書,テキスト,認識,翻訳,サイン,jpg` | 25/17/94 |
| `ko` | KR (+US) | Scanmuse: 문서 스캔·PDF 스캐너 | 사진 텍스트 추출, 문자 인식 OCR | `앱,서명,영수증,카메라,변환,이미지,jpg,번역,스캐너앱,스캔앱,전자서명` | 23/20/94 |

## 3. Promotional text (170)

| Lokalizatsiya | Matn | Uzunlik |
|---|---|---|
| `en-US` | Scan documents to PDF in seconds, recognize text with on-device OCR and sign anything. Private by design: no account, no cloud. | 127 |
| `en-GB` | Scan documents to PDF in seconds, recognise text with on-device OCR and sign anything. Private by design: no account, no cloud. | 127 |
| `en-AU` | Scan documents to PDF in seconds, recognise text with on-device OCR and sign anything. Private by design: no account, no cloud. | 127 |
| `en-CA` | Scan documents to PDF in seconds, recognize text with on-device OCR and sign anything. Private by design: no account, no cloud. | 127 |
| `ar-SA` | Scan documents to PDF in seconds, recognize text with on-device OCR and sign anything. Private by design: no account, no cloud. | 127 |
| `vi` | Scan documents to PDF in seconds, recognize text with on-device OCR and sign anything. Private by design: no account, no cloud. | 127 |
| `zh-Hans` | Scan documents to PDF in seconds, recognize text with on-device OCR and sign anything. Private by design: no account, no cloud. | 127 |
| `zh-Hant` | Scan documents to PDF in seconds, recognize text with on-device OCR and sign anything. Private by design: no account, no cloud. | 127 |
| `tr` | Belgeleri saniyeler içinde PDF olarak tarayın, cihaz üzerinde OCR ile metni tanıyın ve imzalayın. Hesap yok, bulut yok — tamamen gizli. | 135 |
| `ru` | Сканируйте документы в PDF за секунды, распознавайте текст на устройстве и подписывайте. Без аккаунта и облака — всё остаётся у вас. | 132 |
| `uk` | Скануйте документи в PDF за секунди, розпізнавайте текст на пристрої та підписуйте. Без акаунта й хмари — усе лишається у вас. | 126 |
| `pt-BR` | Digitalize documentos em PDF em segundos, reconheça texto com OCR no aparelho e assine. Sem conta e sem nuvem — tudo fica com você. | 131 |
| `es-MX` | Escanea documentos a PDF en segundos, reconoce texto con OCR en tu iPhone y firma. Sin cuenta y sin nube: todo se queda contigo. | 128 |
| `de-DE` | Scanne Dokumente in Sekunden als PDF, erkenne Text per OCR direkt auf dem iPhone und unterschreibe. Kein Konto, keine Cloud – alles bleibt bei dir. | 147 |
| `fr-FR` | Numérisez vos documents en PDF en quelques secondes, reconnaissez le texte par OCR sur l'iPhone et signez. Sans compte ni cloud. | 128 |
| `fr-CA` | Numérisez vos documents en PDF en quelques secondes, reconnaissez le texte par OCR sur l'iPhone et signez. Sans compte ni nuage. | 128 |
| `sv` | Skanna dokument till PDF på några sekunder, känn igen text med OCR direkt i iPhone och signera. Inget konto, inget moln. | 120 |
| `es-ES` | Escanea documentos a PDF en segundos, reconoce texto con OCR en tu iPhone y firma. Sin cuenta y sin nube: todo se queda contigo. | 128 |
| `ca` | Escaneja documents a PDF en segons, reconeix text amb OCR a l'iPhone i signa. Sense compte ni núvol. | 100 |
| `it` | Scansiona documenti in PDF in pochi secondi, riconosci il testo con l'OCR sull'iPhone e firma. Nessun account, nessun cloud. | 124 |
| `pl` | Skanuj dokumenty do PDF w kilka sekund, rozpoznawaj tekst przez OCR na iPhonie i podpisuj. Bez konta i chmury — wszystko zostaje u Ciebie. | 138 |
| `nl-NL` | Scan documenten in enkele seconden naar PDF, herken tekst met OCR op je iPhone en onderteken. Geen account, geen cloud — alles blijft bij jou. | 142 |
| `ja` | 書類を数秒でPDFにスキャン。端末内のOCRで文字を読み取り、署名もできます。アカウント不要、クラウド不要で安心。 | 57 |
| `ko` | 문서를 몇 초 만에 PDF로 스캔하고, 기기 내 OCR로 텍스트를 추출하고, 서명하세요. 계정도 클라우드도 필요 없습니다. | 68 |

## 4. Har bir tanlovning asosi

| Lokalizatsiya | Asos (ma'lumot) |
|---|---|
| `en-US` | US Apple popularity: scanner app free P66, scanner P62, pdf scanner P59, scan to pdf P59, scan P58, document scanner P55, scanner app P49, scan documents P48 — every word sits in name/subtitle. ocr/text/image to text/receipt/sign pdf are P5 (low volume, low difficulty: pdf signer D12, sign pdf free D17, ocr scan D29) → subtitle + keywords. 'free' is excluded: App Review Guideline 2.3.7 forbids pricing terms in metadata. |
| `en-GB` | GB autocomplete: pdf scanner L2, scanner app L2, scan documents L3, ocr text scanner L3, receipt scanner L4 (D34), document scanner L4, ocr copy L5 (D21), sign pdf free L6. IN: doc scanner L1 (D68), pdf scanner L2, document scanner L2, scan and pdf maker L6, scan pdf maker L6, scan receipt L6 (D21), scan signature L6 (D23). English 'scanner' / 'pdf scanner' are also top-3 autocomplete terms in BR, MX, TR, KR (see their tables) — en-GB is indexed there, so the English core stays in this name. |
| `en-AU` | AU autocomplete: pdf scanner L2, scanner app L2, scan documents L3, document scanner L3, receipt scanner L4, scan to text L6, image to text L7. en-GB (also indexed in AU) already holds receipt/sign/jpg/…, so en-AU adds plurals and different words instead of repeating them. |
| `en-CA` | CA autocomplete: pdf scanner L2, scanner app free L2, scanner L2, ocr scanner L3 (D46), scan document L3, document scanner L3, scan pdf L3, scan receipt L6, image to text L7. |
| `ar-SA` | US long-tail: receipt scanner L3, scan receipts L6, pdf mobile scanner L5. Words not used in en-US. |
| `vi` | US: jpg to pdf photos L5, pdf to jpg converter L5 (D22), scan documents P48 (plural form). |
| `zh-Hans` | US: pdf signature L5 (D24), pdf signer L5 (D12), sign pdf free L6 (D17), sign pdf documents L6 (D24). |
| `zh-Hant` | US: ocr text scanner L3 (D53), ocr scan L3 (D29), ocr pdf L3 (D31), ocr scanner L5 (D28). |
| `tr` | TR autocomplete: belge tarama L3 (D14), belge tarayıcı L3 (D7), ocr metin tarayıcı L3 (D4), tarayıcı L3, tarama L4, pdf tarayıcı L5 (D20), pdf imza L5 (D13), fotoğraftan metne (D1). English 'scanner' L2 / 'pdf scanner' L5 come from en-GB; 'scanner' kept here for 'scanner pdf' combos. |
| `ru` | RU autocomplete: сканер документов L1 (D71), pdf сканер L2, сканер L2, подпись документов L4 (D34), скан документов L4, сканирование документов L4, pdf подпись L5 (D32), чек скан L1, скан текста с фото L6, скан текста L6 (D30). 'PDF Сканер документов' does not fit 30 with the brand → PDF moved to the subtitle (Apple combines words across name+subtitle+keywords). |
| `uk` | RU storefront also indexes uk. No separate UA keyword study (not in the requested market list); words mirror the RU findings in Ukrainian. |
| `pt-BR` | BR autocomplete: scanner L2 (D79), pdf scanner L2, digitalizar documentos pdf L2 (D52), escanear documentos L3 (D33), digitalizar L3, escanear L4, escanear documentos gratis L4 (D21), pdf scanner de documentos L5 (D8), escanear pdf L5 (D16), assinar pdf L5 (D33), escanear para pdf L10. |
| `es-MX` | MX autocomplete: escaner pdf L2 (D52), scanner L2, pdf scanner L2, escanear documentos L2 (D57), escanear fotos L3 (D24), escanear L3 (D33), escáner documentos L4 (D31), ocr escaner de texto L5 (D30), escaner de documentos L5 (D20), escanear pdf L7 (D21), escanear fotos a pdf L7 (D21). Both spellings 'escáner' and 'escaner' appear as separate autocomplete terms, so both are indexed. |
| `de-DE` | DE autocomplete: pdf scanner L2 (D74), scanner app L2, ocr scanner L3 (D70), dokumente scannen L3 (D64), kassenbon scanner app L3 (D25), unterschrift erstellen L3 (D29), scan to pdf L4, pdf unterschreiben L5 (D30), pdf zu bild L5, pdf in jpg umwandeln L5 (D39), unterschrift pdf L6 (D41). |
| `fr-FR` | FR autocomplete: scanner pdf L2 (D74), scan L2, ocr scanner L3 (D68), signature pdf L3 (D36), scanner L3, scan document L4 (D69), scan pdf L4, pdf jpg L5, scan texte L6 (D52), scan fichier L6 (D29), scan signature L6 (D45), image en texte L8 (D42). 'gratuit' terms excluded (pricing, 2.3.7). |
| `fr-CA` | CA French autocomplete returns 'numériser' and 'scanneur' (seed terms) plus 'scanner gratuit', 'scan document gratuit', 'scanner document gratuit' (L5–L9). English core comes from en-CA. |
| `sv` | SE autocomplete: pdf scanner L2 (D55), scanner L2 (D67), ocr L3 (D43), skanna dokument L4 (D25), skanner L5 (D52), pdf signer L5 (D30), skanna bilder L5 (D38), ocr id L5 (D43), pdf fil L5. English core comes from en-GB. |
| `es-ES` | ES autocomplete: escanear documentos L2 (D59), pdf scanner L2, scanner L2, escaner L2 (D53), escanear L3, escanear fotos L3 (D47), escaner pdf L3 (D45), escáner documentos L4 (D52), firmar pdf L4 (D39), ocr escaner de texto L5 (D42), pdf to jpg convert L5 (D22). |
| `ca` | Spain indexes ca as well; ES results include Catalan titles such as 'OCR Escaneig de Text'. App UI is not in Catalan, so this slot is optional. |
| `it` | IT autocomplete: scanner L2 (D84), scanner pdf L2 (D70), ocr scanner L3 (D63), ocr scan L3, scansione documenti L3 (D46), firma pdf L4 (D23), pdf da foto L5, scansiona documenti pdf L5 (D42), da foto a testo L5 (D46), scanner documenti L5, scansione L5, scansiona documenti L5. |
| `pl` | PL autocomplete: pdf scanner L2 (D65), scanner L2, ocr scanner L3 (D48), skaner L3 (D43), darmowy skaner pdf L4 (D9), skanuj dokumenty L5 (D17), skanuj L5, skanuj dokument L5 (D20), skanowanie L5 (D44), skaner pdf L5 (D34), pdf to jpg convert L5 (D18). English core comes from en-GB. |
| `nl-NL` | NL autocomplete: pdf scanner L2 (D63), ocr scanner L3 (D38), document scanner L3, scanner L3, scan pdf L3, documenten scannen L4 (D57), document scannen L4, pdf to jpg L5 (D22), pdf sign L5, ocr text L5 (D28), foto naar pdf gratis L6 (D18), scan document L6. English core also comes from en-GB. |
| `ja` | JP autocomplete: 書類 スキャン 無料 L1 (D50), スキャン L2 (D64), pdf スキャン L2 (D53), スキャナー L2, ocr L2 (D50), 書類 スキャン pdf L2 (D28), スキャナー 無料 L4 (D31), 写真 スキャナー L4, スキャン アプリ L6, スキャン カメラ pdf L6, 文字 読み取り (D44). en-US is also indexed in JP ('pdf scanner' L5, D34). |
| `ko` | KR autocomplete: 문서 스캔 L1 (D31), 텍스트 추출 L1 (D49), 스캐너 L2, 스캔 L2, pdf 스캔 L2, pdf scanner L2 (D24), 문서 스캔 무료 L2 (D16), 스캔 앱 L4 (D18), 사진 텍스트 추출 L4 (D8), pdf 서명 L5 (D19), 문자 인식 (D31). |

## 5. Description

Apple description matnini qidiruvda indekslamaydi, shuning uchun u konversiya uchun yozilgan: `fastlane/metadata/<locale>/description.txt` (har bir tilda alohida). Yangi lokalizatsiyalar (en-AU, en-CA, ar-SA, vi, zh-Hans, zh-Hant, fr-CA) mos tildagi matndan nusxa oladi.

## 6. Tadqiq qilinmagan, lekin mavjud lokalizatsiyalar

Quyidagilar ilova tiliga mos ravishda saqlanib qoldi, faqat brend yangilandi; ular uchun alohida keyword tadqiqoti qilinmagan: `cs`, `da`, `el`, `fi`, `hr`, `hu`, `no`, `pt-PT`, `ro`, `sk`.

## 7. Ilova lokalizatsiyasi bo'yicha tavsiya

| Bozor | Do'kon tili | Ilova shu tilda | Tavsiya |
|---|---|---|---|
| JP | ja | ❌ | Ilova interfeysini ja ga tarjima qilish (metadata tayyor) |
| KR (+US) | ko | ❌ | Ilova interfeysini ko ga tarjima qilish (metadata tayyor) |
