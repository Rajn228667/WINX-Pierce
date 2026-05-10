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
    case tile_tools
    case tile_tools_subtitle
    case tile_banks
    case tile_banks_subtitle

    // Greetings
    case greeting_morning
    case greeting_day
    case greeting_evening
    case greeting_night

    // Tools (mirror Android ToolsScreen)
    case tools_intro
    case tools_scene
    case tools_scene_hint
    case tools_color
    case tools_color_hint
    case tools_money
    case tools_money_hint
    case tools_light
    case tools_light_hint
    case tools_face
    case tools_face_hint
    case tools_time
    case tools_battery
    case tools_capturing
    case tools_processing
    case tools_no_snapshot

    // Banks
    case banks_intro
    case banks_hint
    case banks_opening

    // Walking
    case walking_intro
    case walking_auto_on
    case walking_auto_off
    case walking_status_safe
    case walking_status_attention
    case walking_status_stop
    case walking_torch_on
    case walking_torch_off

    // Vision auto-narrate
    case vision_auto_on
    case vision_auto_off

    // Low-vision settings
    case settings_lowvision_title
    case settings_lowvision_hint
    case settings_aaa_contrast
    case settings_xl_text

    // Live Captions (Listen module)
    case listen_intro
    case listen_start
    case listen_stop
    case listen_copy
    case listen_clear
    case listen_share
    case listen_copied
    case listen_language
    case listen_font_size

    // Sound Detection
    case tile_sound_detect
    case tile_sound_detect_subtitle
    case sound_intro
    case sound_listening
    case sound_paused
    case sound_alarm
    case sound_doorbell
    case sound_glass
    case sound_dog
    case sound_baby
    case sound_siren
    case sound_speech
    case sound_water
    case sound_unknown

    // Voice Composer (type → speak → share)
    case tile_voice_compose
    case tile_voice_compose_subtitle
    case compose_placeholder
    case compose_speak
    case compose_share
    case compose_save
    case compose_clear

    // Big Mode (one-tap accessibility)
    case big_mode_title
    case big_mode_hint
    case big_mode_on
    case big_mode_off

    // v1.4 Accessibility deep dive
    case acc_text_section
    case acc_text_size
    case acc_text_preview_short
    case acc_bold
    case acc_high_contrast
    case acc_vision_section
    case acc_warm_filter
    case acc_warm_off
    case acc_warm_low
    case acc_warm_high
    case acc_color_scheme
    case acc_scheme_system
    case acc_scheme_light
    case acc_scheme_dark
    case acc_colorblind
    case acc_colorblind_none
    case acc_colorblind_protanopia
    case acc_colorblind_deuteranopia
    case acc_colorblind_tritanopia
    case acc_colorblind_monochrome
    case acc_voice_section
    case acc_voice_gender
    case acc_voice_female
    case acc_voice_male
    case acc_voice_picker
    case acc_voice_auto
    case acc_voice_rate
    case acc_voice_pitch
    case acc_voice_volume
    case acc_voice_preview
    case acc_voice_preview_text
    case acc_control_section
    case acc_voice_control
    case acc_haptics
    case acc_danger_haptics
    case acc_language_section
    case acc_language_picker
    case acc_ai_section
    case acc_ai_model
    case acc_ai_url
    case acc_quality_premium
    case acc_quality_enhanced
    case acc_quality_compact

    // First-launch language selector
    case lang_choose_title
    case lang_choose_subtitle
    case lang_continue

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
        .err_ollama_offline: "Нейросеть не отвечает. Проверьте туннель.",

        .tile_tools: "Инструменты",
        .tile_tools_subtitle: "Цвет · свет · купюра · время",
        .tile_banks: "Банки",
        .tile_banks_subtitle: "Kaspi · Halyk",

        .greeting_morning: "Доброе утро",
        .greeting_day: "Добрый день",
        .greeting_evening: "Добрый вечер",
        .greeting_night: "Доброй ночи",

        .tools_intro: "Выберите инструмент. Я помогу разобраться.",
        .tools_scene: "Что передо мной",
        .tools_scene_hint: "Опишу предметы и людей в кадре",
        .tools_color: "Цвет",
        .tools_color_hint: "Назову основные цвета объекта",
        .tools_money: "Купюра",
        .tools_money_hint: "Распознаю валюту и номинал",
        .tools_light: "Свет",
        .tools_light_hint: "Подскажу, светло или темно",
        .tools_face: "Лицо",
        .tools_face_hint: "Опишу человека напротив",
        .tools_time: "Время",
        .tools_battery: "Батарея",
        .tools_capturing: "Делаю снимок...",
        .tools_processing: "Анализирую...",
        .tools_no_snapshot: "Не удалось сделать снимок",

        .banks_intro: "Откройте свой банк одним касанием.",
        .banks_hint: "Если приложение установлено — откроется сразу. Иначе откроется сайт.",
        .banks_opening: "Открываю",

        .walking_intro: "Сканер помещения включён. Я буду подсказывать про препятствия и направление.",
        .walking_auto_on: "Постоянное описание включено.",
        .walking_auto_off: "Постоянное описание выключено.",
        .walking_status_safe: "Идём, путь свободен.",
        .walking_status_attention: "Внимание, рядом препятствие.",
        .walking_status_stop: "Стоп, прямо перед вами препятствие.",
        .walking_torch_on: "Фонарик включён.",
        .walking_torch_off: "Фонарик выключен.",

        .vision_auto_on: "Описание сцены включено.",
        .vision_auto_off: "Описание сцены выключено.",

        .settings_lowvision_title: "Слабовидящим",
        .settings_lowvision_hint: "Усиленный контраст и крупный шрифт во всём приложении.",
        .settings_aaa_contrast: "Максимальный контраст",
        .settings_xl_text: "Очень крупный текст",

        .listen_intro: "Нажмите «Слушать». Я переведу речь собеседника в крупный текст.",
        .listen_start: "Слушать",
        .listen_stop: "Стоп",
        .listen_copy: "Копировать",
        .listen_clear: "Очистить",
        .listen_share: "Поделиться",
        .listen_copied: "Скопировано в буфер.",
        .listen_language: "Язык распознавания",
        .listen_font_size: "Размер шрифта",

        .tile_sound_detect: "Звуки",
        .tile_sound_detect_subtitle: "Тревога · звонок · плач",
        .sound_intro: "Нажмите «Слушать звуки», и приложение предупредит вас о важных звуках вокруг.",
        .sound_listening: "Слушаю окружение…",
        .sound_paused: "На паузе",
        .sound_alarm: "Сработала тревога — будильник или сигнализация.",
        .sound_doorbell: "Звонок в дверь.",
        .sound_glass: "Звук разбитого стекла.",
        .sound_dog: "Лает собака.",
        .sound_baby: "Плачет ребёнок.",
        .sound_siren: "Сирена скорой или полиции.",
        .sound_speech: "Кто-то говорит рядом.",
        .sound_water: "Шум воды — кран или душ.",
        .sound_unknown: "Необычный звук.",

        .tile_voice_compose: "Мой голос",
        .tile_voice_compose_subtitle: "Текст → речь → отправка",
        .compose_placeholder: "Напишите, что нужно сказать…",
        .compose_speak: "Озвучить",
        .compose_share: "Отправить аудио",
        .compose_save: "Сохранить",
        .compose_clear: "Очистить",

        .big_mode_title: "Огромный режим",
        .big_mode_hint: "Очень крупные кнопки и подписи. Минимум деталей.",
        .big_mode_on: "Огромный режим включён.",
        .big_mode_off: "Огромный режим выключен.",

        .acc_text_section: "Текст",
        .acc_text_size: "Размер текста",
        .acc_text_preview_short: "Так выглядят меню и кнопки",
        .acc_bold: "Жирный шрифт",
        .acc_high_contrast: "Высокий контраст",
        .acc_vision_section: "Зрение",
        .acc_warm_filter: "Тёплый фильтр (бережёт глаза)",
        .acc_warm_off: "Выкл",
        .acc_warm_low: "Слабый",
        .acc_warm_high: "Сильный",
        .acc_color_scheme: "Цветовая схема",
        .acc_scheme_system: "Системная",
        .acc_scheme_light: "Светлая",
        .acc_scheme_dark: "Тёмная",
        .acc_colorblind: "Дальтонизм",
        .acc_colorblind_none: "Без коррекции",
        .acc_colorblind_protanopia: "Протанопия (красно-зелёный)",
        .acc_colorblind_deuteranopia: "Дейтеранопия (зелёный)",
        .acc_colorblind_tritanopia: "Тританопия (сине-жёлтый)",
        .acc_colorblind_monochrome: "Монохром",
        .acc_voice_section: "Голос",
        .acc_voice_gender: "Голос помощника",
        .acc_voice_female: "Женский",
        .acc_voice_male: "Мужской",
        .acc_voice_picker: "Выбор голоса",
        .acc_voice_auto: "Авто (лучший доступный)",
        .acc_voice_rate: "Скорость",
        .acc_voice_pitch: "Тон",
        .acc_voice_volume: "Громкость",
        .acc_voice_preview: "Прослушать пример",
        .acc_voice_preview_text: "Это пример того, как я звучу. Я говорю с тобой ровно так, как ты слышишь сейчас.",
        .acc_control_section: "Управление",
        .acc_voice_control: "Голосовое управление",
        .acc_haptics: "Тактильный отклик",
        .acc_danger_haptics: "Вибрация при опасности",
        .acc_language_section: "Язык",
        .acc_language_picker: "Язык интерфейса",
        .acc_ai_section: "ИИ",
        .acc_ai_model: "Модель Ollama",
        .acc_ai_url: "URL туннеля Ollama",
        .acc_quality_premium: "Премиум",
        .acc_quality_enhanced: "Улучшенный",
        .acc_quality_compact: "Стандартный",

        .lang_choose_title: "Выберите язык",
        .lang_choose_subtitle: "Эту настройку можно изменить позже",
        .lang_continue: "Продолжить"
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
        .err_ollama_offline: "Нейрожүйе жауап бермейді.",

        .tile_tools: "Құралдар",
        .tile_tools_subtitle: "Түс · жарық · купюра · уақыт",
        .tile_banks: "Банктер",
        .tile_banks_subtitle: "Kaspi · Halyk",

        .greeting_morning: "Қайырлы таң",
        .greeting_day: "Қайырлы күн",
        .greeting_evening: "Қайырлы кеш",
        .greeting_night: "Қайырлы түн",

        .tools_intro: "Құрал таңдаңыз. Көмектесемін.",
        .tools_scene: "Алдымда не бар",
        .tools_scene_hint: "Кадрдағы заттарды сипаттаймын",
        .tools_color: "Түс",
        .tools_color_hint: "Заттың негізгі түстерін айтам",
        .tools_money: "Купюра",
        .tools_money_hint: "Валюта мен номиналын танимын",
        .tools_light: "Жарық",
        .tools_light_hint: "Жарық па, қараңғы ма — айтам",
        .tools_face: "Бет",
        .tools_face_hint: "Қарсы алдыңыздағы адамды сипаттаймын",
        .tools_time: "Уақыт",
        .tools_battery: "Батарея",
        .tools_capturing: "Сурет түсіріп жатырмын...",
        .tools_processing: "Талдап жатырмын...",
        .tools_no_snapshot: "Сурет түсіру мүмкін болмады",

        .banks_intro: "Банкіңізді бір рет басып ашыңыз.",
        .banks_hint: "Қолданба орнатылса — бірден ашылады. Жоқ болса — сайт ашылады.",
        .banks_opening: "Ашылып жатыр",

        .walking_intro: "Бөлме сканері қосылды. Кедергілер мен бағыт туралы айтып отырамын.",
        .walking_auto_on: "Үздіксіз сипаттау қосулы.",
        .walking_auto_off: "Үздіксіз сипаттау өшірулі.",
        .walking_status_safe: "Жол ашық, жүре беріңіз.",
        .walking_status_attention: "Назар, жанында кедергі бар.",
        .walking_status_stop: "Тоқтаңыз, тура алдыңызда кедергі бар.",
        .walking_torch_on: "Шамшырақ қосылды.",
        .walking_torch_off: "Шамшырақ өшірілді.",

        .vision_auto_on: "Сурет сипаттамасы қосылды.",
        .vision_auto_off: "Сурет сипаттамасы өшірілді.",

        .settings_lowvision_title: "Көру қабілеті төмен үшін",
        .settings_lowvision_hint: "Бүкіл қолданбада күшейтілген контраст пен ірі қаріп.",
        .settings_aaa_contrast: "Максималды контраст",
        .settings_xl_text: "Өте ірі қаріп",

        .listen_intro: "«Тыңдау» батырмасын басыңыз. Сөзді ірі мәтінге айналдырамын.",
        .listen_start: "Тыңдау",
        .listen_stop: "Тоқтату",
        .listen_copy: "Көшіру",
        .listen_clear: "Тазарту",
        .listen_share: "Бөлісу",
        .listen_copied: "Алмасу буферіне көшірілді.",
        .listen_language: "Тану тілі",
        .listen_font_size: "Қаріп өлшемі",

        .tile_sound_detect: "Дыбыстар",
        .tile_sound_detect_subtitle: "Дабыл · қоңырау · жылау",
        .sound_intro: "«Дыбыстарды тыңдау» батырмасын басыңыз — маңызды дыбыстар туралы хабарлаймын.",
        .sound_listening: "Айналаны тыңдап тұрмын…",
        .sound_paused: "Тоқтаулы",
        .sound_alarm: "Дабыл — оятқыш немесе дабыл жүйесі.",
        .sound_doorbell: "Есік қоңырауы.",
        .sound_glass: "Шыны сынды.",
        .sound_dog: "Ит үреді.",
        .sound_baby: "Бала жылайды.",
        .sound_siren: "Жедел жәрдем немесе полиция дабылы.",
        .sound_speech: "Біреу сөйлейді.",
        .sound_water: "Су ағыны — кран немесе душ.",
        .sound_unknown: "Әдеттен тыс дыбыс.",

        .tile_voice_compose: "Менің даусым",
        .tile_voice_compose_subtitle: "Мәтін → дауыс → жіберу",
        .compose_placeholder: "Не айту керек, жазыңыз…",
        .compose_speak: "Дауыстау",
        .compose_share: "Аудионы жіберу",
        .compose_save: "Сақтау",
        .compose_clear: "Тазарту",

        .big_mode_title: "Алып режим",
        .big_mode_hint: "Өте ірі батырмалар мен жазулар. Аз бөлшек.",
        .big_mode_on: "Алып режим қосылды.",
        .big_mode_off: "Алып режим өшірілді.",

        .acc_text_section: "Мәтін",
        .acc_text_size: "Мәтін өлшемі",
        .acc_text_preview_short: "Мәзірлер мен батырмалар осылай көрінеді",
        .acc_bold: "Қалың қаріп",
        .acc_high_contrast: "Жоғары контраст",
        .acc_vision_section: "Көру",
        .acc_warm_filter: "Жылы сүзгі (көзге жайлы)",
        .acc_warm_off: "Өшірілді",
        .acc_warm_low: "Әлсіз",
        .acc_warm_high: "Күшті",
        .acc_color_scheme: "Түс схемасы",
        .acc_scheme_system: "Жүйелік",
        .acc_scheme_light: "Жарық",
        .acc_scheme_dark: "Қараңғы",
        .acc_colorblind: "Дальтонизм",
        .acc_colorblind_none: "Түзетусіз",
        .acc_colorblind_protanopia: "Протанопия (қызыл-жасыл)",
        .acc_colorblind_deuteranopia: "Дейтеранопия (жасыл)",
        .acc_colorblind_tritanopia: "Тританопия (көк-сары)",
        .acc_colorblind_monochrome: "Монохром",
        .acc_voice_section: "Дауыс",
        .acc_voice_gender: "Көмекшінің дауысы",
        .acc_voice_female: "Әйел",
        .acc_voice_male: "Ер",
        .acc_voice_picker: "Дауысты таңдау",
        .acc_voice_auto: "Авто (ең жақсы)",
        .acc_voice_rate: "Жылдамдық",
        .acc_voice_pitch: "Тон",
        .acc_voice_volume: "Дауыс",
        .acc_voice_preview: "Үлгіні тыңдау",
        .acc_voice_preview_text: "Менің қалай естілетінімнің үлгісі. Мен сенімен дәл осылай сөйлесемін.",
        .acc_control_section: "Басқару",
        .acc_voice_control: "Дауыстық басқару",
        .acc_haptics: "Тактильді жауап",
        .acc_danger_haptics: "Қауіп кезінде діріл",
        .acc_language_section: "Тіл",
        .acc_language_picker: "Интерфейс тілі",
        .acc_ai_section: "ИИ",
        .acc_ai_model: "Ollama моделі",
        .acc_ai_url: "Ollama туннель URL",
        .acc_quality_premium: "Премиум",
        .acc_quality_enhanced: "Жақсартылған",
        .acc_quality_compact: "Стандарт",

        .lang_choose_title: "Тілді таңдаңыз",
        .lang_choose_subtitle: "Бұл параметрді кейін өзгертуге болады",
        .lang_continue: "Жалғастыру"
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
        .err_ollama_offline: "AI is not responding. Check the tunnel.",

        .tile_tools: "Tools",
        .tile_tools_subtitle: "Colour · light · banknote · time",
        .tile_banks: "Banks",
        .tile_banks_subtitle: "Kaspi · Halyk",

        .greeting_morning: "Good morning",
        .greeting_day: "Good afternoon",
        .greeting_evening: "Good evening",
        .greeting_night: "Good night",

        .tools_intro: "Pick a tool. I'll help you figure it out.",
        .tools_scene: "What's in front of me",
        .tools_scene_hint: "I describe objects and people in view",
        .tools_color: "Colour",
        .tools_color_hint: "I name the main colours of the object",
        .tools_money: "Banknote",
        .tools_money_hint: "I recognise currency and value",
        .tools_light: "Light",
        .tools_light_hint: "I tell you if it's bright or dark",
        .tools_face: "Face",
        .tools_face_hint: "I describe the person in front of you",
        .tools_time: "Time",
        .tools_battery: "Battery",
        .tools_capturing: "Taking a snapshot...",
        .tools_processing: "Analysing...",
        .tools_no_snapshot: "Couldn't take a snapshot",

        .banks_intro: "Open your bank with one tap.",
        .banks_hint: "If the app is installed it opens instantly. Otherwise the website opens.",
        .banks_opening: "Opening",

        .walking_intro: "Room scanner is on. I'll guide you around obstacles and direction.",
        .walking_auto_on: "Continuous narration is on.",
        .walking_auto_off: "Continuous narration is off.",
        .walking_status_safe: "Path is clear, keep going.",
        .walking_status_attention: "Attention, an obstacle is nearby.",
        .walking_status_stop: "Stop, an obstacle is right in front of you.",
        .walking_torch_on: "Torch is on.",
        .walking_torch_off: "Torch is off.",

        .vision_auto_on: "Scene narration is on.",
        .vision_auto_off: "Scene narration is off.",

        .settings_lowvision_title: "Low vision",
        .settings_lowvision_hint: "Stronger contrast and a much larger text size everywhere.",
        .settings_aaa_contrast: "Maximum contrast",
        .settings_xl_text: "Extra-large text",

        .listen_intro: "Tap Listen — I'll turn whatever is said into large clear text.",
        .listen_start: "Listen",
        .listen_stop: "Stop",
        .listen_copy: "Copy",
        .listen_clear: "Clear",
        .listen_share: "Share",
        .listen_copied: "Copied to clipboard.",
        .listen_language: "Recognition language",
        .listen_font_size: "Font size",

        .tile_sound_detect: "Sounds",
        .tile_sound_detect_subtitle: "Alarm · doorbell · cry",
        .sound_intro: "Tap Listen — I'll alert you when an important sound happens around you.",
        .sound_listening: "Listening to surroundings…",
        .sound_paused: "Paused",
        .sound_alarm: "Alarm or smoke detector going off.",
        .sound_doorbell: "Doorbell rang.",
        .sound_glass: "Glass breaking.",
        .sound_dog: "A dog is barking.",
        .sound_baby: "A baby is crying.",
        .sound_siren: "Ambulance or police siren.",
        .sound_speech: "Someone is speaking nearby.",
        .sound_water: "Running water — tap or shower.",
        .sound_unknown: "Unusual sound.",

        .tile_voice_compose: "My voice",
        .tile_voice_compose_subtitle: "Text → speech → share",
        .compose_placeholder: "Type what you want to say…",
        .compose_speak: "Speak",
        .compose_share: "Send audio",
        .compose_save: "Save",
        .compose_clear: "Clear",

        .big_mode_title: "Huge mode",
        .big_mode_hint: "Extra-large buttons and labels. Minimum detail.",
        .big_mode_on: "Huge mode enabled.",
        .big_mode_off: "Huge mode disabled.",

        .acc_text_section: "Text",
        .acc_text_size: "Text size",
        .acc_text_preview_short: "Menus and buttons look like this",
        .acc_bold: "Bold text",
        .acc_high_contrast: "High contrast",
        .acc_vision_section: "Vision",
        .acc_warm_filter: "Warm filter (eye comfort)",
        .acc_warm_off: "Off",
        .acc_warm_low: "Low",
        .acc_warm_high: "High",
        .acc_color_scheme: "Color scheme",
        .acc_scheme_system: "System",
        .acc_scheme_light: "Light",
        .acc_scheme_dark: "Dark",
        .acc_colorblind: "Color blindness",
        .acc_colorblind_none: "No correction",
        .acc_colorblind_protanopia: "Protanopia (red-green)",
        .acc_colorblind_deuteranopia: "Deuteranopia (green)",
        .acc_colorblind_tritanopia: "Tritanopia (blue-yellow)",
        .acc_colorblind_monochrome: "Monochrome",
        .acc_voice_section: "Voice",
        .acc_voice_gender: "Assistant voice",
        .acc_voice_female: "Female",
        .acc_voice_male: "Male",
        .acc_voice_picker: "Choose a voice",
        .acc_voice_auto: "Auto (best available)",
        .acc_voice_rate: "Speed",
        .acc_voice_pitch: "Pitch",
        .acc_voice_volume: "Volume",
        .acc_voice_preview: "Hear a sample",
        .acc_voice_preview_text: "This is what I sound like. I will speak to you exactly as you hear me now.",
        .acc_control_section: "Control",
        .acc_voice_control: "Voice control",
        .acc_haptics: "Haptic feedback",
        .acc_danger_haptics: "Vibrate on danger",
        .acc_language_section: "Language",
        .acc_language_picker: "Interface language",
        .acc_ai_section: "AI",
        .acc_ai_model: "Ollama model",
        .acc_ai_url: "Ollama tunnel URL",
        .acc_quality_premium: "Premium",
        .acc_quality_enhanced: "Enhanced",
        .acc_quality_compact: "Standard",

        .lang_choose_title: "Choose your language",
        .lang_choose_subtitle: "You can change this later in Settings",
        .lang_continue: "Continue"
    ]
}
