#!/usr/bin/env python3
"""Generates Scanlet/Resources/Localizable.xcstrings and InfoPlist.xcstrings.

Keys follow Xcode's extraction format (Int -> %lld, String/Text -> %@).
Edit the tables below, then run:  python3 tools/make_strings.py
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / "Scanlet/Resources"

# key: (Russian, Uzbek)
STRINGS = {
    # Library
    "Documents": ("Документы", "Hujjatlar"),
    "All Documents": ("Все документы", "Barcha hujjatlar"),
    "Favorites": ("Избранное", "Sevimlilar"),
    "Favorite": ("В избранном", "Sevimli"),
    "Unfavorite": ("Убрать", "Olib tashlash"),
    "Folders": ("Папки", "Jildlar"),
    "Search titles and text": ("Поиск по названию и тексту", "Nom va matn bo‘yicha qidirish"),
    "No Documents Yet": ("Документов пока нет", "Hali hujjatlar yo‘q"),
    "Scan paper documents, receipts and notes into sharp, searchable PDFs.": (
        "Сканируйте документы, чеки и заметки в чёткие PDF с поиском по тексту.",
        "Qog‘oz hujjatlar, cheklar va qaydlarni aniq, qidiriladigan PDF’ga aylantiring."),
    "Scan Your First Document": ("Отсканировать первый документ", "Birinchi hujjatni skanerlash"),
    "No Favorites": ("Нет избранного", "Sevimlilar yo‘q"),
    "Empty Folder": ("Папка пуста", "Jild bo‘sh"),
    "Mark documents as favorites to find them here.": (
        "Добавляйте документы в избранное, чтобы находить их здесь.",
        "Hujjatlarni shu yerda topish uchun ularni sevimlilarga qo‘shing."),
    "Scan or move documents into this folder.": (
        "Отсканируйте или переместите документы в эту папку.",
        "Hujjatlarni ushbu jildga skanerlang yoki ko‘chiring."),
    "Scan": ("Сканировать", "Skanerlash"),
    "Opens the camera to scan a document": ("Открывает камеру для сканирования документа", "Hujjatni skanerlash uchun kamerani ochadi"),
    "Import": ("Импорт", "Import"),
    "Import from Photos": ("Импорт из Фото", "Rasmlardan import"),
    "Import from Files": ("Импорт из Файлов", "Fayllardan import"),
    "Import Photos": ("Импортировать фото", "Rasmlarni import qilish"),
    "Settings": ("Настройки", "Sozlamalar"),
    "Go Pro": ("Pro", "Pro"),
    "Upgrade to Scanlet Pro": ("Перейти на Scanlet Pro", "Scanlet Pro’ga o‘tish"),
    "More": ("Ещё", "Yana"),
    "Select": ("Выбрать", "Tanlash"),
    "Select All": ("Выбрать все", "Barchasini tanlash"),
    "Deselect All": ("Снять выбор", "Tanlovni bekor qilish"),
    "Done": ("Готово", "Tayyor"),
    "Icons": ("Значки", "Belgilar"),
    "List": ("Список", "Ro‘yxat"),
    "View": ("Вид", "Ko‘rinish"),
    "Sort By": ("Сортировка", "Saralash"),
    "Date Modified": ("Дата изменения", "O‘zgartirilgan sana"),
    "Date Created": ("Дата создания", "Yaratilgan sana"),
    "Name": ("Название", "Nomi"),
    "New Folder": ("Новая папка", "Yangi jild"),
    "New Folder…": ("Новая папка…", "Yangi jild…"),
    "Rename Folder": ("Переименовать папку", "Jild nomini o‘zgartirish"),
    "Rename Folder…": ("Переименовать папку…", "Jild nomini o‘zgartirish…"),
    "Delete Folder": ("Удалить папку", "Jildni o‘chirish"),
    "Delete Folder?": ("Удалить папку?", "Jild o‘chirilsinmi?"),
    "Documents in this folder will be moved to All Documents.": (
        "Документы из этой папки будут перемещены во «Все документы».",
        "Ushbu jilddagi hujjatlar «Barcha hujjatlar»ga ko‘chiriladi."),
    "Enter a name for this folder.": ("Введите название папки.", "Jild nomini kiriting."),
    "Create": ("Создать", "Yaratish"),
    "Rename Document": ("Переименовать документ", "Hujjat nomini o‘zgartirish"),
    "Rename": ("Переименовать", "Nomini o‘zgartirish"),
    "Save": ("Сохранить", "Saqlash"),
    "Cancel": ("Отменить", "Bekor qilish"),
    "Delete": ("Удалить", "O‘chirish"),
    "Share": ("Поделиться", "Ulashish"),
    "Merge": ("Объединить", "Birlashtirish"),
    "Move": ("Переместить", "Ko‘chirish"),
    "Move to Folder": ("Переместить в папку", "Jildga ko‘chirish"),
    "Duplicate": ("Дублировать", "Nusxa yaratish"),
    "Add to Favorites": ("Добавить в избранное", "Sevimlilarga qo‘shish"),
    "Remove from Favorites": ("Убрать из избранного", "Sevimlilardan olib tashlash"),
    "Delete Document?": ("Удалить документ?", "Hujjat o‘chirilsinmi?"),
    "Delete Document": ("Удалить документ", "Hujjatni o‘chirish"),
    "This can’t be undone.": ("Это действие нельзя отменить.", "Bu amalni qaytarib bo‘lmaydi."),
    "Camera Unavailable": ("Камера недоступна", "Kamera mavjud emas"),
    "Document scanning isn’t supported on this device. You can import photos instead.": (
        "Сканирование документов не поддерживается на этом устройстве. Вместо этого можно импортировать фото.",
        "Bu qurilmada hujjat skanerlash qo‘llab-quvvatlanmaydi. Buning o‘rniga rasmlarni import qilishingiz mumkin."),
    "Something Went Wrong": ("Что-то пошло не так", "Nimadir xato ketdi"),
    "OK": ("ОК", "OK"),
    "Processing pages…": ("Обработка страниц…", "Sahifalar qayta ishlanmoqda…"),
    "The selected photos couldn’t be loaded.": ("Не удалось загрузить выбранные фото.", "Tanlangan rasmlarni yuklab bo‘lmadi."),
    "The selected files couldn’t be opened.": ("Не удалось открыть выбранные файлы.", "Tanlangan fayllarni ochib bo‘lmadi."),

    # Document
    "Scan %@": ("Скан %@", "Skan %@"),
    "%@ Copy": ("%@ (копия)", "%@ (nusxa)"),
    "No Pages": ("Нет страниц", "Sahifalar yo‘q"),
    "Add pages by scanning or importing.": ("Добавьте страницы сканированием или импортом.", "Sahifalarni skanerlash yoki import qilish orqali qo‘shing."),
    "Scan Pages": ("Сканировать страницы", "Sahifalarni skanerlash"),
    "Add Pages": ("Добавить страницы", "Sahifa qo‘shish"),
    "Extract Text": ("Извлечь текст", "Matnni ajratish"),
    "Sign": ("Подписать", "Imzolash"),
    "Organize Pages": ("Упорядочить страницы", "Sahifalarni tartiblash"),
    "Edit Page": ("Редактировать страницу", "Sahifani tahrirlash"),
    "Rotate Left": ("Повернуть влево", "Chapga burish"),
    "Rotate Right": ("Повернуть вправо", "O‘ngga burish"),
    "Share Page": ("Поделиться страницей", "Sahifani ulashish"),
    "Delete Page": ("Удалить страницу", "Sahifani o‘chirish"),
    "Delete Page?": ("Удалить страницу?", "Sahifa o‘chirilsinmi?"),
    "Page %lld": ("Страница %lld", "%lld-sahifa"),
    "%lld of %lld": ("%1$lld из %2$lld", "%1$lld / %2$lld"),
    "Page %lld of %lld": ("Страница %1$lld из %2$lld", "%1$lld-sahifa, jami %2$lld"),
    "Double-tap to edit this page.": ("Дважды коснитесь, чтобы изменить страницу.", "Sahifani tahrirlash uchun ikki marta bosing."),
    "Crop": ("Обрезать", "Kesish"),
    "Apply": ("Применить", "Qo‘llash"),
    "Full Page": ("Вся страница", "To‘liq sahifa"),
    "Auto Detect": ("Автоопределение", "Avto aniqlash"),
    "Applying crop…": ("Обрезка…", "Kesilmoqda…"),
    "Top-left corner": ("Верхний левый угол", "Yuqori chap burchak"),
    "Top-right corner": ("Верхний правый угол", "Yuqori o‘ng burchak"),
    "Bottom-right corner": ("Нижний правый угол", "Pastki o‘ng burchak"),
    "Bottom-left corner": ("Нижний левый угол", "Pastki chap burchak"),

    # Filters & export options
    "Original": ("Оригинал", "Asl"),
    "Auto": ("Авто", "Avto"),
    "Vivid": ("Ярко", "Yorqin"),
    "Grayscale": ("Оттенки серого", "Kulrang"),
    "B&W": ("Ч/Б", "Oq-qora"),
    "Original colors": ("Исходные цвета", "Asl ranglar"),
    "Automatic enhancement": ("Автоулучшение", "Avtomatik yaxshilash"),
    "Vivid colors": ("Яркие цвета", "Yorqin ranglar"),
    "Black and white": ("Чёрно-белый", "Oq-qora"),
    "Fit to Image": ("По размеру изображения", "Rasm o‘lchamida"),
    "A4": ("A4", "A4"),
    "US Letter": ("US Letter", "US Letter"),
    "US Legal": ("US Legal", "US Legal"),
    "Small File": ("Маленький файл", "Kichik fayl"),
    "Balanced": ("Сбалансировано", "Muvozanatli"),
    "Best Quality": ("Лучшее качество", "Eng yaxshi sifat"),
    "PDF": ("PDF", "PDF"),
    "JPG": ("JPG", "JPG"),
    "Text": ("Текст", "Matn"),

    # Text recognition
    "Recognizing text…": ("Распознавание текста…", "Matn aniqlanmoqda…"),
    "No Text Found": ("Текст не найден", "Matn topilmadi"),
    "Try a sharper scan with good lighting, or pick recognition languages in Settings.": (
        "Попробуйте более чёткий скан при хорошем освещении или выберите языки распознавания в настройках.",
        "Yaxshi yorug‘likda aniqroq skanerlang yoki Sozlamalarda aniqlash tillarini tanlang."),
    "Free Text Recognitions Used": ("Бесплатные распознавания закончились", "Bepul matn aniqlashlar tugadi"),
    "Upgrade to Scanlet Pro for unlimited text recognition, searchable PDFs and more.": (
        "Перейдите на Scanlet Pro для безлимитного распознавания текста, PDF с поиском и многого другого.",
        "Cheksiz matn aniqlash, qidiriladigan PDF va boshqa imkoniyatlar uchun Scanlet Pro’ga o‘ting."),
    "Unlock Scanlet Pro": ("Открыть Scanlet Pro", "Scanlet Pro’ni ochish"),
    "Copy All": ("Скопировать всё", "Hammasini nusxalash"),
    "Translate": ("Перевести", "Tarjima qilish"),

    # Export
    "Export": ("Экспорт", "Eksport"),
    "Export %@": ("Экспорт в %@", "%@ sifatida eksport"),
    "Export Failed": ("Ошибка экспорта", "Eksport amalga oshmadi"),
    "Format": ("Формат", "Format"),
    "Layout": ("Макет", "Joylashuv"),
    "Page Size": ("Размер страницы", "Sahifa o‘lchami"),
    "Quality": ("Качество", "Sifat"),
    "Options": ("Параметры", "Parametrlar"),
    "Searchable Text (OCR)": ("Текст с поиском (OCR)", "Qidiriladigan matn (OCR)"),
    "Password Protection": ("Защита паролем", "Parol bilan himoya"),
    "Password": ("Пароль", "Parol"),
    "Searchable PDFs let you find and copy text in any PDF app. Text is recognized on your iPhone.": (
        "В PDF с поиском можно находить и копировать текст в любом приложении. Текст распознаётся на вашем iPhone.",
        "Qidiriladigan PDF’da matnni istalgan ilovada topish va nusxalash mumkin. Matn iPhone’ingizda aniqlanadi."),
    "Each page is exported as a separate JPG image.": ("Каждая страница экспортируется отдельным JPG.", "Har bir sahifa alohida JPG rasm sifatida eksport qilinadi."),
    "Exports the recognized text of every page as a plain text file.": (
        "Экспортирует распознанный текст всех страниц в текстовый файл.",
        "Barcha sahifalarning aniqlangan matnini matnli fayl sifatida eksport qiladi."),
    "Remove “Scanned with Scanlet”": ("Убрать «Scanned with Scanlet»", "«Scanned with Scanlet» yozuvini olib tashlash"),
    "Free exports include a small footer.": ("В бесплатных экспортах есть небольшая подпись.", "Bepul eksportlarda kichik yozuv bo‘ladi."),
    "This document has no pages to export.": ("В документе нет страниц для экспорта.", "Hujjatda eksport uchun sahifalar yo‘q."),
    "The file couldn’t be created. Please try again.": ("Не удалось создать файл. Попробуйте ещё раз.", "Fayl yaratilmadi. Qayta urinib ko‘ring."),

    # Signatures
    "Signature": ("Подпись", "Imzo"),
    "Saved signature": ("Сохранённая подпись", "Saqlangan imzo"),
    "New Signature": ("Новая подпись", "Yangi imzo"),
    "Choose a page below, then pick a signature.": ("Выберите страницу ниже, затем подпись.", "Quyidan sahifani, so‘ng imzoni tanlang."),
    "Signatures are stored only on this device.": ("Подписи хранятся только на этом устройстве.", "Imzolar faqat shu qurilmada saqlanadi."),
    "Page": ("Страница", "Sahifa"),
    "Drag to move. Pinch to resize.": ("Перетащите для перемещения. Сведите пальцы для изменения размера.", "Siljitish uchun torting. O‘lchamni o‘zgartirish uchun chimchilang."),
    "Signature Size": ("Размер подписи", "Imzo o‘lchami"),
    "Place Signature": ("Поставить подпись", "Imzoni qo‘yish"),
    "Signing…": ("Подписание…", "Imzolanmoqda…"),
    "Sign here": ("Подпишите здесь", "Shu yerga imzo qo‘ying"),
    "Ink Color": ("Цвет чернил", "Siyoh rangi"),
    "Black": ("Чёрный", "Qora"),
    "Blue": ("Синий", "Ko‘k"),
    "Red": ("Красный", "Qizil"),
    "Clear": ("Очистить", "Tozalash"),

    # Lock
    "Scanlet Is Locked": ("Scanlet заблокирован", "Scanlet qulflangan"),
    "Your documents are protected.": ("Ваши документы защищены.", "Hujjatlaringiz himoyalangan."),
    "Unlock with %@": ("Разблокировать с %@", "%@ bilan ochish"),
    "Passcode": ("Код-пароль", "Parol kodi"),
    "Unlock your documents": ("Разблокируйте документы", "Hujjatlaringizni oching"),
    "Turn on app lock": ("Включить блокировку", "Ilova qulfini yoqish"),
    "Turn off app lock": ("Выключить блокировку", "Ilova qulfini o‘chirish"),

    # Paywall
    "Export Without Watermark": ("Экспорт без водяного знака", "Suv belgisiz eksport"),
    "Unlimited Text Recognition": ("Безлимитное распознавание текста", "Cheksiz matn aniqlash"),
    "Sign Documents Instantly": ("Подписывайте документы мгновенно", "Hujjatlarni bir zumda imzolang"),
    "Protect PDFs with a Password": ("Защитите PDF паролем", "PDF’ni parol bilan himoyalang"),
    "Lock Scanlet with Face ID": ("Блокировка Scanlet через Face ID", "Scanlet’ni Face ID bilan qulflang"),
    "Create Searchable PDFs": ("Создавайте PDF с поиском", "Qidiriladigan PDF yarating"),
    "Everything you need to scan, sign and share documents.": (
        "Всё, чтобы сканировать, подписывать и отправлять документы.",
        "Hujjatlarni skanerlash, imzolash va ulashish uchun hamma narsa."),
    "Copy, translate and share text from any page.": ("Копируйте, переводите и отправляйте текст с любой страницы.", "Istalgan sahifadagi matnni nusxalang, tarjima qiling va ulashing."),
    "Searchable PDFs": ("PDF с поиском", "Qidiriladigan PDF"),
    "Find words inside your scans in any PDF app.": ("Находите слова в сканах в любом PDF-приложении.", "Skanlaringiz ichidagi so‘zlarni istalgan PDF ilovada toping."),
    "Sign Documents": ("Подпись документов", "Hujjatlarni imzolash"),
    "Draw once, place your signature in seconds.": ("Нарисуйте один раз — ставьте подпись за секунды.", "Bir marta chizing — imzoni soniyalarda qo‘ying."),
    "Password-Protected PDFs": ("PDF с паролем", "Parolli PDF"),
    "Share sensitive files safely.": ("Безопасно делитесь важными файлами.", "Maxfiy fayllarni xavfsiz ulashing."),
    "Face ID App Lock": ("Блокировка через Face ID", "Face ID bilan qulf"),
    "Keep your documents private.": ("Ваши документы — только ваши.", "Hujjatlaringiz maxfiy qoladi."),
    "No Watermark": ("Без водяного знака", "Suv belgisiz"),
    "Clean, professional exports.": ("Чистый профессиональный экспорт.", "Toza, professional eksport."),
    "Plans are unavailable right now.": ("Тарифы сейчас недоступны.", "Tariflar hozircha mavjud emas."),
    "Plans are unavailable right now. Check your connection and try again.": (
        "Тарифы сейчас недоступны. Проверьте подключение и попробуйте снова.",
        "Tariflar hozircha mavjud emas. Internetni tekshirib, qayta urinib ko‘ring."),
    "Try Again": ("Повторить", "Qayta urinish"),
    "SAVE %lld%%": ("ЭКОНОМИЯ %lld%%", "%lld%% TEJANG"),
    "%@ free": ("%@ бесплатно", "%@ bepul"),
    "%@ free, then %@/%@": ("%1$@ бесплатно, затем %2$@/%3$@", "%1$@ bepul, keyin %2$@/%3$@"),
    "%@/%@, cancel anytime": ("%1$@/%2$@, отмена в любой момент", "%1$@/%2$@, istalgan vaqtda bekor qilish mumkin"),
    "Free for %@, then %@. Renews automatically until canceled. Cancel anytime in Settings at least 24 hours before the trial ends.": (
        "Бесплатно %1$@, затем %2$@. Подписка продлевается автоматически, пока вы её не отмените. Отмените в Настройках минимум за 24 часа до конца пробного периода.",
        "%1$@ bepul, keyin %2$@. Bekor qilinmaguncha avtomatik yangilanadi. Sinov muddati tugashidan kamida 24 soat oldin Sozlamalarda bekor qiling."),
    "%@. Renews automatically until canceled. Cancel anytime in Settings at least 24 hours before the period ends.": (
        "%@. Подписка продлевается автоматически, пока вы её не отмените. Отмените в Настройках минимум за 24 часа до конца периода.",
        "%@. Bekor qilinmaguncha avtomatik yangilanadi. Davr tugashidan kamida 24 soat oldin Sozlamalarda bekor qiling."),
    "Start Free Trial": ("Начать бесплатно", "Bepul sinovni boshlash"),
    "Continue": ("Продолжить", "Davom etish"),
    "Restore Purchases": ("Восстановить покупки", "Xaridlarni tiklash"),
    "Restoring…": ("Восстановление…", "Tiklanmoqda…"),
    "Terms of Use": ("Условия использования", "Foydalanish shartlari"),
    "Privacy Policy": ("Политика конфиденциальности", "Maxfiylik siyosati"),
    "Close": ("Закрыть", "Yopish"),
    "Purchase Pending": ("Покупка ожидает подтверждения", "Xarid tasdiqlanishi kutilmoqda"),
    "Your purchase is waiting for approval. Scanlet Pro unlocks automatically once it’s approved.": (
        "Покупка ожидает одобрения. Scanlet Pro откроется автоматически после подтверждения.",
        "Xaridingiz tasdiqlanishini kutmoqda. Tasdiqlangach Scanlet Pro avtomatik ochiladi."),
    "Purchase Failed": ("Не удалось совершить покупку", "Xarid amalga oshmadi"),
    "Nothing to Restore": ("Нечего восстанавливать", "Tiklanadigan xarid yo‘q"),
    "No active Scanlet Pro subscription was found for this Apple Account.": (
        "Для этого Аккаунта Apple не найдено активной подписки Scanlet Pro.",
        "Ushbu Apple hisobi uchun faol Scanlet Pro obunasi topilmadi."),
    "Restore Failed": ("Не удалось восстановить", "Tiklab bo‘lmadi"),
    "The purchase couldn’t be verified. Please try again.": ("Не удалось проверить покупку. Попробуйте ещё раз.", "Xaridni tekshirib bo‘lmadi. Qayta urinib ko‘ring."),
    "PRO": ("PRO", "PRO"),
    "Pro feature": ("Функция Pro", "Pro funksiyasi"),
    "day": ("день", "kun"),
    "days": ("дн.", "kun"),
    "week": ("неделю", "hafta"),
    "weeks": ("нед.", "hafta"),
    "month": ("месяц", "oy"),
    "months": ("мес.", "oy"),
    "year": ("год", "yil"),
    "years": ("г.", "yil"),

    # Onboarding
    "Scan Anything in Seconds": ("Сканируйте что угодно за секунды", "Istalgan narsani soniyalarda skanerlang"),
    "Edges are detected and straightened automatically. Documents, receipts, IDs and notes come out crisp and clean.": (
        "Края определяются и выравниваются автоматически. Документы, чеки, удостоверения и заметки получаются чёткими.",
        "Chegaralar avtomatik aniqlanadi va tekislanadi. Hujjatlar, cheklar, ID kartalar va qaydlar tiniq chiqadi."),
    "Turn Images into Text": ("Превращайте изображения в текст", "Rasmlarni matnga aylantiring"),
    "Scanlet reads text right on your iPhone. Search every scan, copy, translate and create searchable PDFs.": (
        "Scanlet распознаёт текст прямо на iPhone. Ищите по сканам, копируйте, переводите и создавайте PDF с поиском.",
        "Scanlet matnni to‘g‘ridan-to‘g‘ri iPhone’da o‘qiydi. Skanlar ichidan qidiring, nusxalang, tarjima qiling va qidiriladigan PDF yarating."),
    "Sign, Protect and Share": ("Подписывайте, защищайте, делитесь", "Imzolang, himoyalang va ulashing"),
    "Add your signature, lock PDFs with a password and share anywhere. Your documents never leave your device.": (
        "Ставьте подпись, защищайте PDF паролем и делитесь где угодно. Документы не покидают ваше устройство.",
        "Imzo qo‘ying, PDF’ni parol bilan himoyalang va istalgan joyga ulashing. Hujjatlaringiz qurilmangizdan chiqmaydi."),
    "Get Started": ("Начать", "Boshlash"),
    "Skip": ("Пропустить", "O‘tkazib yuborish"),

    # Settings
    "Default Filter": ("Фильтр по умолчанию", "Standart filtr"),
    "Auto-Crop Imported Photos": ("Автообрезка импортированных фото", "Import qilingan rasmlarni avto kesish"),
    "Scanning": ("Сканирование", "Skanerlash"),
    "Recognize Text Automatically": ("Распознавать текст автоматически", "Matnni avtomatik aniqlash"),
    "Recognition Languages": ("Языки распознавания", "Aniqlash tillari"),
    "Text Recognition": ("Распознавание текста", "Matnni aniqlash"),
    "Text is recognized on your iPhone, so you can search inside your scans. Nothing is uploaded.": (
        "Текст распознаётся на iPhone, поэтому можно искать внутри сканов. Ничего не загружается в сеть.",
        "Matn iPhone’ingizda aniqlanadi, shuning uchun skanlar ichidan qidirish mumkin. Hech narsa yuklanmaydi."),
    "Require %@": ("Требовать %@", "%@ talab qilinsin"),
    "Privacy": ("Конфиденциальность", "Maxfiylik"),
    "Scanlet stores your documents only on this iPhone.": ("Scanlet хранит документы только на этом iPhone.", "Scanlet hujjatlaringizni faqat shu iPhone’da saqlaydi."),
    "Support": ("Поддержка", "Yordam"),
    "Rate Scanlet": ("Оценить Scanlet", "Scanlet’ni baholash"),
    "I scan documents with Scanlet.": ("Я сканирую документы в Scanlet.", "Men hujjatlarni Scanlet bilan skanerlayman."),
    "Share Scanlet": ("Поделиться Scanlet", "Scanlet’ni ulashish"),
    "Contact Support": ("Связаться с поддержкой", "Yordam xizmatiga yozish"),
    "Version": ("Версия", "Versiya"),
    "About": ("О приложении", "Ilova haqida"),
    "Scanlet Pro": ("Scanlet Pro", "Scanlet Pro"),
    "All features unlocked. Thank you!": ("Все функции открыты. Спасибо!", "Barcha funksiyalar ochiq. Rahmat!"),
    "Manage Subscription": ("Управлять подпиской", "Obunani boshqarish"),
    "Unlimited OCR, signatures, no watermark": ("Безлимитный OCR, подписи, без водяного знака", "Cheksiz OCR, imzolar, suv belgisiz"),
    "Automatic": ("Автоматически", "Avtomatik"),
    "Automatic works for most documents. Choose specific languages to improve accuracy for mixed or uncommon text.": (
        "Автоматический режим подходит для большинства документов. Выберите языки, чтобы повысить точность для смешанного или редкого текста.",
        "Avtomatik rejim ko‘p hujjatlar uchun mos. Aralash yoki kam uchraydigan matnlarda aniqlikni oshirish uchun tillarni tanlang."),
    "Languages": ("Языки", "Tillar"),

    # Watermark (drawn into exported files)
    "Scanned with Scanlet": ("Отсканировано в Scanlet", "Scanlet bilan skanerlangan"),
}

# Plural keys: key: {lang: (one, other)}; English included.
PLURALS = {
    "%lld pages": {"en": ("%lld page", "%lld pages"), "ru": None, "uz": ("%lld sahifa", "%lld sahifa")},
    "%lld documents": {"en": ("%lld document", "%lld documents"), "ru": None, "uz": ("%lld hujjat", "%lld hujjat")},
    "Delete %lld Documents?": {"en": ("Delete %lld Document?", "Delete %lld Documents?"), "ru": None,
                               "uz": ("%lld hujjat o‘chirilsinmi?", "%lld hujjat o‘chirilsinmi?")},
}
RU_PLURALS = {
    "%lld pages": {"one": "%lld страница", "few": "%lld страницы", "many": "%lld страниц", "other": "%lld страницы"},
    "%lld documents": {"one": "%lld документ", "few": "%lld документа", "many": "%lld документов", "other": "%lld документа"},
    "Delete %lld Documents?": {"one": "Удалить %lld документ?", "few": "Удалить %lld документа?",
                               "many": "Удалить %lld документов?", "other": "Удалить %lld документа?"},
}

INFO_PLIST = {
    "NSCameraUsageDescription": (
        "Scanlet uses the camera to scan your documents.",
        "Scanlet использует камеру для сканирования документов.",
        "Scanlet hujjatlaringizni skanerlash uchun kameradan foydalanadi."),
    "NSFaceIDUsageDescription": (
        "Scanlet uses Face ID to keep your documents private.",
        "Scanlet использует Face ID для защиты ваших документов.",
        "Scanlet hujjatlaringizni himoyalash uchun Face ID’dan foydalanadi."),
    "CFBundleDisplayName": ("Scanlet", "Scanlet", "Scanlet"),
}


def unit(value):
    return {"stringUnit": {"state": "translated", "value": value}}


def plural(forms):
    return {"variations": {"plural": {k: unit(v) for k, v in forms.items()}}}


def build():
    strings = {}
    for key, (ru, uz) in sorted(STRINGS.items(), key=lambda item: item[0].lower()):
        strings[key] = {"localizations": {"ru": unit(ru), "uz": unit(uz)}}
    for key, langs in PLURALS.items():
        en_one, en_other = langs["en"]
        uz_one, uz_other = langs["uz"]
        strings[key] = {
            "localizations": {
                "en": plural({"one": en_one, "other": en_other}),
                "ru": plural(RU_PLURALS[key]),
                "uz": plural({"one": uz_one, "other": uz_other}),
            }
        }
    catalog = {"sourceLanguage": "en", "strings": dict(sorted(strings.items(), key=lambda i: i[0].lower())), "version": "1.0"}
    (ROOT / "Localizable.xcstrings").write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + "\n")

    info = {}
    for key, (en, ru, uz) in INFO_PLIST.items():
        info[key] = {
            "extractionState": "manual",
            "localizations": {"en": unit(en), "ru": unit(ru), "uz": unit(uz)},
        }
    (ROOT / "InfoPlist.xcstrings").write_text(
        json.dumps({"sourceLanguage": "en", "strings": info, "version": "1.0"}, ensure_ascii=False, indent=2) + "\n")
    print(f"{len(strings)} strings written")


if __name__ == "__main__":
    build()
