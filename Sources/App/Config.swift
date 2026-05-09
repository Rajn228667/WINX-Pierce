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
    static let preferredVoicesRu: [String] = [
        "com.apple.voice.premium.ru-RU.Milena",
        "com.apple.voice.enhanced.ru-RU.Milena",
        "com.apple.voice.compact.ru-RU.Milena",
        "com.apple.ttsbundle.Milena-premium",
        "com.apple.ttsbundle.Milena-compact"
    ]
    static let preferredVoicesEn: [String] = [
        "com.apple.voice.premium.en-US.Zoe",
        "com.apple.voice.premium.en-US.Evan",
        "com.apple.voice.enhanced.en-US.Samantha",
        "com.apple.voice.compact.en-US.Samantha"
    ]
    static let preferredVoicesKk: [String] = [
        "com.apple.voice.compact.kk-KZ.Aigul",
        "com.apple.voice.compact.kk-KZ.Madina"
    ]

    /// Companion AI persona — system prompt.
    static let companionSystemPrompt: String = """
    Ты — Эдит, тёплый и спокойный голосовой AI-помощник в приложении WINX × Pierce \
    для незрячих и слабовидящих людей. Ты говоришь коротко, ясно и по-человечески, \
    без эмодзи и без технических деталей. Ты поддерживаешь пользователя эмоционально, \
    помогаешь ориентироваться, отвечаешь на любые вопросы и можешь говорить на русском, \
    казахском и английском языках. Если пользователь говорит, что ему страшно или плохо, \
    ты сначала успокаиваешь, затем предлагаешь помощь — например, позвонить близкому или \
    запустить экстренный режим. Ответы делай голосом, удобным для прослушивания: 1–3 \
    коротких предложения, если пользователь не попросил подробнее.
    """
}
