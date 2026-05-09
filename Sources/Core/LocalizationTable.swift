import Foundation

/// Strongly-typed list of every translatable string in the app.
/// Adding a new screen string? Add a case here, then a value in each of the three
/// `LocalizationTable` dictionaries below. The compiler enforces that you don't
/// forget any language.
enum LocalKey: String, CaseIterable {
    // Brand
    case brand_subtitle
    case status_ready

    // Onboarding
    case onb_welcome_title
    case onb_welcome_body
    case onb_lang_title
    case onb_lang_body
    case onb_perm_title
    case onb_perm_body
    case onb_perm_camera
    case onb_perm_mic
    case onb_perm_speech
    case onb_perm_location
    case onb_perm_contacts
    case onb_ollama_title
    case onb_ollama_body
    case onb_ollama_placeholder
    case onb_ollama_test
    case onb_ollama_skip
    case onb_continue
    case onb_finish

    // Home tile titles
    case tile_ai_companion
    case tile_ai_companion_subtitle
    case tile_scan
    case tile_scan_subtitle
    case tile_magnifier
    case tile_magnifier_subtitle
    case tile_currency
    case tile_currency_subtitle
    case tile_listen
    case tile_listen_subtitle
    case tile_cards
    case tile_cards_subtitle
    case tile_ask
    case tile_ask_subtitle
    case tile_locator
    case tile_locator_subtitle
    case tile_walking
    case tile_walking_subtitle
    case tile_navigation
    case tile_navigation_subtitle
    case tile_sos
    case tile_sos_subtitle
    case tile_health
    case tile_health_subtitle
    case tile_learning
    case tile_learning_subtitle
    case tile_whatsapp
    case tile_whatsapp_subtitle
    case tile_telegram
    case tile_telegram_subtitle
    case tile_music
    case tile_music_subtitle
    case tile_diary
    case tile_diary_subtitle
    case tile_smart_home
    case tile_smart_home_subtitle
    case tile_eye_comfort
    case tile_eye_comfort_subtitle
    case tile_scene
    case tile_scene_subtitle
    case tile_accessibility
    case tile_accessibility_subtitle

    // Section headers
    case section_eyes
    case section_voice
    case section_movement
    case section_life
    case section_safety
    case section_smart

    // Home bottom voice bar
    case voice_bar_title
    case voice_bar_subtitle

    // Common
    case action_close
    case action_cancel
    case action_save
    case action_done
    case action_speak
    case action_stop
    case action_listen
    case action_send
    case action_record
    case action_replay
    case action_retry
    case action_open
    case action_choose

    // AI Companion
    case ai_speak_to_me
    case ai_listening
    case ai_thinking
    case ai_say_hello
    case ai_no_url
    case ai_set_url

    // Vision / Scan
    case vision_describe_scene
    case vision_describe_now
    case vision_obstacle_ahead
    case vision_no_obstacle
    case vision_night_mode
    case vision_zoom

    // OCR
    case ocr_scanning
    case ocr_recognized
    case ocr_translate
    case ocr_summary
    case ocr_no_text

    // Navigation
    case nav_destination
    case nav_search_pharmacy
    case nav_search_hospital
    case nav_search_store
    case nav_start_route

    // Emergency
    case sos_title
    case sos_press_to_alert
    case sos_alert_sent
    case sos_share_location
    case sos_call

    // Errors
    case err_no_permission
    case err_network
    case err_ollama_offline
}

/// Embedded localisations. Translators only need to edit this one Swift file.
/// We keep it in code (not .strings) so the per-language switch happens without
/// re-launching the app — `Bundle.main.localizedString` requires a restart.
struct LocalizationTable {

    static let shared = LocalizationTable()

    private init() {}

    func lookup(_ key: LocalKey, language: AppLanguage) -> String {
        switch language {
        case .ru, .system: return Self.ru[key] ?? key.rawValue
        case .kk: return Self.kk[key] ?? Self.ru[key] ?? key.rawValue
        case .en: return Self.en[key] ?? Self.ru[key] ?? key.rawValue
        }
    }
}

extension LocalizationTable {

    static let ru: [LocalKey: String] = [
        .brand_subtitle: "При поддержке Pierce Industries",
        .status_ready: "Готов",

        .onb_welcome_title: "Здравствуйте",
        .onb_welcome_body: "WINX × Pierce помогает вам видеть, слышать и ориентироваться в мире вокруг.",
        .onb_lang_title: "Язык приложения",
        .onb_lang_body: "Можно сменить в любой момент. Голос помощника тоже сменится.",
        .onb_perm_title: "Разрешения",
        .onb_perm_body: "Чтобы помочь по-настоящему, нам нужны: камера, микрофон, распознавание речи, геолокация и контакты.",
        .onb_perm_camera: "Камера — описывать мир и читать текст",
        .onb_perm_mic: "Микрофон — слышать вас",
        .onb_perm_speech: "Распознавание речи — понимать команды",
        .onb_perm_location: "Геолокация — голосовая навигация и SOS",
        .onb_perm_contacts: "Контакты — отправлять SOS близкому",
        .onb_ollama_title: "Подключение к нейросети",
        .onb_ollama_body: "Вставьте ссылку на ваш Cloudflare-туннель Ollama. Без неё AI Companion и описание сцены работать не будут — остальные функции работают и без сети.",
        .onb_ollama_placeholder: "https://....trycloudflare.com",
        .onb_ollama_test: "Проверить связь",
        .onb_ollama_skip: "Пропустить",
        .onb_continue: "Продолжить",
        .onb_finish: "Готово",

        .tile_ai_companion: "ЭДИТ",
        .tile_ai_companion_subtitle: "Поговори со мной. Расскажу о погоде, найду адрес, отвечу на любой вопрос — тёплым голосом.",
        .tile_scan: "Сканировать",
        .tile_scan_subtitle: "Описать, что вокруг",
        .tile_magnifier: "Лупа",
        .tile_magnifier_subtitle: "Увеличить × фонарик",
        .tile_currency: "Купюры",
        .tile_currency_subtitle: "KZT",
        .tile_listen: "Слух",
        .tile_listen_subtitle: "Речь → текст",
        .tile_cards: "Карточки",
        .tile_cards_subtitle: "Фразы для немых",
        .tile_ask: "Спросить",
        .tile_ask_subtitle: "Голосовой помощник",
        .tile_locator: "Локатор",
        .tile_locator_subtitle: "Веду голосом по комнате",
        .tile_walking: "Ходьба",
        .tile_walking_subtitle: "Препятствия впереди",
        .tile_navigation: "Маршрут",
        .tile_navigation_subtitle: "Карты вслух",
        .tile_sos: "SOS",
        .tile_sos_subtitle: "SMS близкому контакту",
        .tile_health: "Здоровье",
        .tile_health_subtitle: "Лекарства · пульс",
        .tile_learning: "Учёба",
        .tile_learning_subtitle: "Уроки голосом",
        .tile_whatsapp: "WhatsApp",
        .tile_whatsapp_subtitle: "Голосовое контакту",
        .tile_telegram: "Telegram",
        .tile_telegram_subtitle: "Голосовое контакту",
        .tile_music: "Музыка",
        .tile_music_subtitle: "Любимые треки",
        .tile_diary: "Дневник",
        .tile_diary_subtitle: "Запись голосом",
        .tile_smart_home: "Умный дом",
        .tile_smart_home_subtitle: "Свет · сцены",
        .tile_eye_comfort: "Зрение",
        .tile_eye_comfort_subtitle: "Комфорт глаз",
        .tile_scene: "Сцена",
        .tile_scene_subtitle: "Описание окружения",
        .tile_accessibility: "Доступность",
        .tile_accessibility_subtitle: "Размер · контраст · голос",

        .section_eyes: "Глаза",
        .section_voice: "Слух и голос",
        .section_movement: "Движение",
        .section_life: "Жизнь",
        .section_safety: "Безопасность",
        .section_smart: "Дом и удобство",

        .voice_bar_title: "Голосовая команда",
        .voice_bar_subtitle: "Нажмите и говорите",

        .action_close: "Закрыть",
        .action_cancel: "Отмена",
        .action_save: "Сохранить",
        .action_done: "Готово",
        .action_speak: "Говорить",
        .action_stop: "Стоп",
        .action_listen: "Слушаю",
        .action_send: "Отправить",
        .action_record: "Записать",
        .action_replay: "Прослушать",
        .action_retry: "Повторить",
        .action_open: "Открыть",
        .action_choose: "Выбрать",

        .ai_speak_to_me: "Поговорите со мной",
        .ai_listening: "Слушаю...",
        .ai_thinking: "Думаю...",
        .ai_say_hello: "Скажите «Привет, Эдит»",
        .ai_no_url: "Нейросеть не подключена",
        .ai_set_url: "Указать ссылку",

        .vision_describe_scene: "Что вокруг меня?",
        .vision_describe_now: "Опиши сейчас",
        .vision_obstacle_ahead: "Впереди препятствие",
        .vision_no_obstacle: "Путь свободен",
        .vision_night_mode: "Ночной режим",
        .vision_zoom: "Приблизить",

        .ocr_scanning: "Сканирую текст...",
        .ocr_recognized: "Распознано",
        .ocr_translate: "Перевести",
        .ocr_summary: "Кратко",
        .ocr_no_text: "Текст не найден",

        .nav_destination: "Куда идём?",
        .nav_search_pharmacy: "Аптека рядом",
        .nav_search_hospital: "Больница рядом",
        .nav_search_store: "Магазин рядом",
        .nav_start_route: "Начать маршрут",

        .sos_title: "Экстренный режим",
        .sos_press_to_alert: "Нажмите и удерживайте, чтобы оповестить",
        .sos_alert_sent: "SOS отправлен",
        .sos_share_location: "Поделиться местоположением",
        .sos_call: "Позвонить",

        .err_no_permission: "Нет разрешения",
        .err_network: "Нет соединения",
        .err_ollama_offline: "Нейросеть не отвечает. Проверьте туннель."
    ]

    static let kk: [LocalKey: String] = [
        .brand_subtitle: "Pierce Industries қолдауымен",
        .status_ready: "Дайын",

        .onb_welcome_title: "Сәлеметсіз бе",
        .onb_welcome_body: "WINX × Pierce сізге айналаңызды көруге, естуге және бағдарлауға көмектеседі.",
        .onb_lang_title: "Қолданба тілі",
        .onb_lang_body: "Кез келген уақытта өзгертуге болады.",
        .onb_perm_title: "Рұқсаттар",
        .onb_perm_body: "Толық көмек үшін бізге камера, микрофон, сөйлеуді тану, геолокация және контактілер қажет.",
        .onb_perm_camera: "Камера — әлемді сипаттау, мәтін оқу",
        .onb_perm_mic: "Микрофон — сізді есту",
        .onb_perm_speech: "Сөйлеу тану — командаларды түсіну",
        .onb_perm_location: "Геолокация — дауыстық бағдар, SOS",
        .onb_perm_contacts: "Контактілер — SOS-ты жақын адамға жіберу",
        .onb_ollama_title: "Нейрожүйеге қосылу",
        .onb_ollama_body: "Cloudflare-туннель сілтемесін енгізіңіз. Онсыз AI серіктесі мен сахна сипаттамасы жұмыс істемейді.",
        .onb_ollama_placeholder: "https://....trycloudflare.com",
        .onb_ollama_test: "Байланысты тексеру",
        .onb_ollama_skip: "Өткізіп жіберу",
        .onb_continue: "Жалғастыру",
        .onb_finish: "Дайын",

        .tile_ai_companion: "ЭДИТ",
        .tile_ai_companion_subtitle: "Менімен сөйлесіңіз. Жылы дауыспен барлық сұраққа жауап беремін.",
        .tile_scan: "Сканерлеу",
        .tile_scan_subtitle: "Айналаны сипаттау",
        .tile_magnifier: "Лупа",
        .tile_magnifier_subtitle: "Үлкейту · шам",
        .tile_currency: "Купюралар",
        .tile_currency_subtitle: "KZT",
        .tile_listen: "Есту",
        .tile_listen_subtitle: "Сөз → мәтін",
        .tile_cards: "Карточкалар",
        .tile_cards_subtitle: "Үнсіз сөйлемдер",
        .tile_ask: "Сұрау",
        .tile_ask_subtitle: "Дауыс көмекшісі",
        .tile_locator: "Локатор",
        .tile_locator_subtitle: "Бөлмеде дауыспен бағыттаймын",
        .tile_walking: "Жүру",
        .tile_walking_subtitle: "Кедергілер алда",
        .tile_navigation: "Бағыт",
        .tile_navigation_subtitle: "Карта дауыспен",
        .tile_sos: "SOS",
        .tile_sos_subtitle: "Жақынға SMS",
        .tile_health: "Денсаулық",
        .tile_health_subtitle: "Дәрілер · пульс",
        .tile_learning: "Оқу",
        .tile_learning_subtitle: "Дауыстық сабақтар",
        .tile_whatsapp: "WhatsApp",
        .tile_whatsapp_subtitle: "Контактіге дауыс",
        .tile_telegram: "Telegram",
        .tile_telegram_subtitle: "Контактіге дауыс",
        .tile_music: "Музыка",
        .tile_music_subtitle: "Сүйікті трек",
        .tile_diary: "Күнделік",
        .tile_diary_subtitle: "Дауыстық жазба",
        .tile_smart_home: "Ақылды үй",
        .tile_smart_home_subtitle: "Жарық · сахналар",
        .tile_eye_comfort: "Көру",
        .tile_eye_comfort_subtitle: "Көзге жайлы",
        .tile_scene: "Сахна",
        .tile_scene_subtitle: "Қоршаған ортаны сипаттау",
        .tile_accessibility: "Қолжетімділік",
        .tile_accessibility_subtitle: "Көлем · контраст · дауыс",

        .section_eyes: "Көру",
        .section_voice: "Есту мен дауыс",
        .section_movement: "Қозғалыс",
        .section_life: "Өмір",
        .section_safety: "Қауіпсіздік",
        .section_smart: "Үй мен ыңғайлық",

        .voice_bar_title: "Дауыстық команда",
        .voice_bar_subtitle: "Басып сөйлеңіз",

        .action_close: "Жабу",
        .action_cancel: "Болдырмау",
        .action_save: "Сақтау",
        .action_done: "Дайын",
        .action_speak: "Сөйлеу",
        .action_stop: "Тоқтату",
        .action_listen: "Тыңдап тұрмын",
        .action_send: "Жіберу",
        .action_record: "Жазу",
        .action_replay: "Қайта тыңдау",
        .action_retry: "Қайталау",
        .action_open: "Ашу",
        .action_choose: "Таңдау",

        .ai_speak_to_me: "Менімен сөйлесіңіз",
        .ai_listening: "Тыңдап тұрмын...",
        .ai_thinking: "Ойланып жатырмын...",
        .ai_say_hello: "«Сәлем, Эдит» деп айтыңыз",
        .ai_no_url: "Нейрожүйе қосылмаған",
        .ai_set_url: "Сілтеме енгізу",

        .vision_describe_scene: "Айналамда не бар?",
        .vision_describe_now: "Қазір сипатта",
        .vision_obstacle_ahead: "Алда кедергі бар",
        .vision_no_obstacle: "Жол ашық",
        .vision_night_mode: "Түнгі режим",
        .vision_zoom: "Жақындату",

        .ocr_scanning: "Мәтінді сканерлеп жатырмын...",
        .ocr_recognized: "Танылды",
        .ocr_translate: "Аудару",
        .ocr_summary: "Қысқаша",
        .ocr_no_text: "Мәтін табылмады",

        .nav_destination: "Қайда барамыз?",
        .nav_search_pharmacy: "Жақын дәріхана",
        .nav_search_hospital: "Жақын аурухана",
        .nav_search_store: "Жақын дүкен",
        .nav_start_route: "Бағытты бастау",

        .sos_title: "Шұғыл режим",
        .sos_press_to_alert: "Хабарлау үшін басып ұстап тұрыңыз",
        .sos_alert_sent: "SOS жіберілді",
        .sos_share_location: "Орналасуды бөлісу",
        .sos_call: "Қоңырау шалу",

        .err_no_permission: "Рұқсат жоқ",
        .err_network: "Желі жоқ",
        .err_ollama_offline: "Нейрожүйе жауап бермейді."
    ]

    static let en: [LocalKey: String] = [
        .brand_subtitle: "Powered by Pierce Industries",
        .status_ready: "Ready",

        .onb_welcome_title: "Welcome",
        .onb_welcome_body: "WINX × Pierce helps you see, hear, and navigate the world around you.",
        .onb_lang_title: "App language",
        .onb_lang_body: "You can change it any time. The companion's voice will follow.",
        .onb_perm_title: "Permissions",
        .onb_perm_body: "To help you fully we need camera, microphone, speech recognition, location and contacts.",
        .onb_perm_camera: "Camera — describe the world, read text",
        .onb_perm_mic: "Microphone — hear you",
        .onb_perm_speech: "Speech recognition — understand commands",
        .onb_perm_location: "Location — voice navigation and SOS",
        .onb_perm_contacts: "Contacts — send SOS to a loved one",
        .onb_ollama_title: "Connect to your AI",
        .onb_ollama_body: "Paste your Cloudflare-tunnel URL for Ollama. Without it the AI Companion and Scene Description will be disabled — all other features still work offline.",
        .onb_ollama_placeholder: "https://....trycloudflare.com",
        .onb_ollama_test: "Test connection",
        .onb_ollama_skip: "Skip",
        .onb_continue: "Continue",
        .onb_finish: "Done",

        .tile_ai_companion: "EDIT",
        .tile_ai_companion_subtitle: "Talk to me. I'll tell you the weather, find an address, answer anything — in a warm voice.",
        .tile_scan: "Scan",
        .tile_scan_subtitle: "Describe what's around",
        .tile_magnifier: "Magnifier",
        .tile_magnifier_subtitle: "Zoom · flashlight",
        .tile_currency: "Banknotes",
        .tile_currency_subtitle: "KZT",
        .tile_listen: "Listen",
        .tile_listen_subtitle: "Speech → text",
        .tile_cards: "Cards",
        .tile_cards_subtitle: "Phrases for non-speaking",
        .tile_ask: "Ask",
        .tile_ask_subtitle: "Voice assistant",
        .tile_locator: "Locator",
        .tile_locator_subtitle: "Voice-guide me in the room",
        .tile_walking: "Walking",
        .tile_walking_subtitle: "Obstacles ahead",
        .tile_navigation: "Route",
        .tile_navigation_subtitle: "Spoken maps",
        .tile_sos: "SOS",
        .tile_sos_subtitle: "SMS to a contact",
        .tile_health: "Health",
        .tile_health_subtitle: "Meds · pulse",
        .tile_learning: "Learning",
        .tile_learning_subtitle: "Voice lessons",
        .tile_whatsapp: "WhatsApp",
        .tile_whatsapp_subtitle: "Voice to a contact",
        .tile_telegram: "Telegram",
        .tile_telegram_subtitle: "Voice to a contact",
        .tile_music: "Music",
        .tile_music_subtitle: "Favourite tracks",
        .tile_diary: "Diary",
        .tile_diary_subtitle: "Voice journal",
        .tile_smart_home: "Smart home",
        .tile_smart_home_subtitle: "Lights · scenes",
        .tile_eye_comfort: "Vision",
        .tile_eye_comfort_subtitle: "Eye comfort",
        .tile_scene: "Scene",
        .tile_scene_subtitle: "Describe surroundings",
        .tile_accessibility: "Accessibility",
        .tile_accessibility_subtitle: "Size · contrast · voice",

        .section_eyes: "Eyes",
        .section_voice: "Hearing & voice",
        .section_movement: "Movement",
        .section_life: "Life",
        .section_safety: "Safety",
        .section_smart: "Home & comfort",

        .voice_bar_title: "Voice command",
        .voice_bar_subtitle: "Press and speak",

        .action_close: "Close",
        .action_cancel: "Cancel",
        .action_save: "Save",
        .action_done: "Done",
        .action_speak: "Speak",
        .action_stop: "Stop",
        .action_listen: "Listening",
        .action_send: "Send",
        .action_record: "Record",
        .action_replay: "Replay",
        .action_retry: "Retry",
        .action_open: "Open",
        .action_choose: "Choose",

        .ai_speak_to_me: "Talk to me",
        .ai_listening: "Listening...",
        .ai_thinking: "Thinking...",
        .ai_say_hello: "Say \"Hello, Edit\"",
        .ai_no_url: "AI is not connected",
        .ai_set_url: "Set URL",

        .vision_describe_scene: "What is around me?",
        .vision_describe_now: "Describe now",
        .vision_obstacle_ahead: "Obstacle ahead",
        .vision_no_obstacle: "Path is clear",
        .vision_night_mode: "Night mode",
        .vision_zoom: "Zoom in",

        .ocr_scanning: "Scanning text...",
        .ocr_recognized: "Recognized",
        .ocr_translate: "Translate",
        .ocr_summary: "Summary",
        .ocr_no_text: "No text found",

        .nav_destination: "Where to?",
        .nav_search_pharmacy: "Pharmacy nearby",
        .nav_search_hospital: "Hospital nearby",
        .nav_search_store: "Store nearby",
        .nav_start_route: "Start route",

        .sos_title: "Emergency mode",
        .sos_press_to_alert: "Press and hold to alert",
        .sos_alert_sent: "SOS sent",
        .sos_share_location: "Share location",
        .sos_call: "Call",

        .err_no_permission: "No permission",
        .err_network: "No connection",
        .err_ollama_offline: "AI is not responding. Check the tunnel."
    ]
}
