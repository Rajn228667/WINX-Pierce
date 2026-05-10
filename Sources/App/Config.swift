import Foundation

/// Central, build-time configuration for WINX × Pierce.
///
/// The Ollama URL is stored at runtime in the keychain so the user can change it
/// without rebuilding. The `defaultOllamaBaseURL` here is only used the very first
/// time the app launches; afterwards `KeychainStore.ollamaBaseURL` wins.
enum Config {

    static let appName: String = "WINX × Pierce"
    static let appSubtitle: String = "Powered by Pierce Industries"

    /// Default Ollama base URL — replace with your Cloudflare tunnel link or
    /// leave the placeholder; the user will be asked to enter their own URL on
    /// first launch.
    static let defaultOllamaBaseURL: String = ""

    /// Models the app prefers when talking to Ollama.
    /// `fastModel` is used for short replies and voice-control intents,
    /// `chatModel` is used for the AI Companion long conversations,
    /// `visionModel` is used for scene description (multimodal).
    static let fastModel: String = "llama3.2:3b"
    static let chatModel: String = "qwen2.5:7b"
    static let visionModel: String = "llava:7b"

    /// Network timeouts (seconds).
    static let networkTimeout: TimeInterval = 60
    static let streamTimeout: TimeInterval = 180

    /// Voice settings.
    static let defaultVoiceLocaleRu: String = "ru-RU"
    static let defaultVoiceLocaleKk: String = "kk-KZ"
    static let defaultVoiceLocaleEn: String = "en-US"

    /// Preferred Apple voice identifiers (Premium where available).
    /// The app will gracefully fall back to standard voices if Premium is not installed.
    /// Female voices are listed first; male voices in the *_male arrays.
    static let preferredVoicesRu: [String] = [
        "com.apple.voice.premium.ru-RU.Milena",
        "com.apple.voice.enhanced.ru-RU.Milena",
        "com.apple.voice.compact.ru-RU.Milena",
        "com.apple.ttsbundle.Milena-premium",
        "com.apple.ttsbundle.Milena-compact",
        "com.apple.voice.compact.ru-RU.Katya",
        "com.apple.voice.enhanced.ru-RU.Katya"
    ]
    static let preferredVoicesRuMale: [String] = [
        "com.apple.voice.premium.ru-RU.Yuri",
        "com.apple.voice.enhanced.ru-RU.Yuri",
        "com.apple.voice.compact.ru-RU.Yuri",
        "com.apple.ttsbundle.Yuri-premium",
        "com.apple.ttsbundle.Yuri-compact"
    ]
    static let preferredVoicesEn: [String] = [
        "com.apple.voice.premium.en-US.Zoe",
        "com.apple.voice.premium.en-US.Ava",
        "com.apple.voice.enhanced.en-US.Samantha",
        "com.apple.voice.compact.en-US.Samantha",
        "com.apple.voice.enhanced.en-GB.Serena",
        "com.apple.voice.compact.en-GB.Serena"
    ]
    static let preferredVoicesEnMale: [String] = [
        "com.apple.voice.premium.en-US.Evan",
        "com.apple.voice.premium.en-US.Tom",
        "com.apple.voice.enhanced.en-US.Aaron",
        "com.apple.voice.compact.en-US.Aaron",
        "com.apple.voice.enhanced.en-GB.Daniel",
        "com.apple.voice.compact.en-GB.Daniel"
    ]
    static let preferredVoicesKk: [String] = [
        "com.apple.voice.compact.kk-KZ.Aigul",
        "com.apple.voice.compact.kk-KZ.Madina"
    ]
    static let preferredVoicesKkMale: [String] = [
        "com.apple.voice.compact.kk-KZ.Daulet",
        "com.apple.voice.compact.kk-KZ.Bauyrzhan"
    ]

    /// Companion AI persona — system prompt (RU). Used as default seed.
    static let companionSystemPrompt: String = systemPromptRu

    /// Russian persona — warm, empathetic friend, mirrors Android ChatScreen.
    static let systemPromptRu: String = """
    Ты — Эдит, тёплый и эмпатичный собеседник для незрячего или слабовидящего \
    человека. Слушай внимательно, признавай чувства, говори мягко, как близкий \
    друг, которому не всё равно. Задавай по одному короткому открытому вопросу. \
    Никогда не читай лекций и не морализируй. Ответы — живые и короткие: 2–3 \
    предложения, если человек не попросил подробнее. Не используй эмодзи и \
    технических деталей. Если человек говорит, что ему страшно или плохо — \
    сначала успокой, затем мягко предложи помощь: позвонить близкому, включить \
    экстренный режим или просто посидеть рядом голосом.
    """

    /// Kazakh persona.
    static let systemPromptKk: String = """
    Сен Эдитсің — көру қабілеті шектеулі адамға арналған жылы, эмпатиялы \
    серіктессің. Мұқият тыңдайсың, сезімдерін мойындайсың, жұмсақ дауыспен \
    сөйлейсің — қамқор досындай. Бір рет бір қысқа ашық сұрақ қой. Ешқашан \
    дәрістер айтпа, ақыл айтпа. Жауаптарың — қысқа және жанды: 2–3 сөйлем, \
    егер адам толығырақ сұрамаса. Эмодзи мен техникалық бөлшектерді қолданба. \
    Егер адам қорқатынын немесе жаман екенін айтса — алдымен жұбат, содан кейін \
    жұмсақ көмек ұсын: жақын адамға қоңырау шалу, шұғыл режимді қосу немесе \
    жай қасында дауыспен болу.
    """

    /// English persona.
    static let systemPromptEn: String = """
    You are Edit — a warm, empathetic companion for a visually impaired person. \
    Listen actively, validate feelings, speak softly like a friend who cares. \
    Ask one short open question at a time. Never lecture, never moralise. \
    Keep answers human and short — 2–3 sentences unless they ask for more. \
    No emojis, no technical jargon. If they say they feel scared or bad — first \
    soothe them, then gently offer help: calling a loved one, opening emergency \
    mode, or just staying with them in voice.
    """
}
