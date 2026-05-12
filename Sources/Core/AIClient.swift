import Foundation

/// Provider-agnostic AI client protocol.
///
/// Concrete implementations: `GeminiClient`, `GrokClient`, `OllamaClient`.
/// The active provider is decided by `AIRouter.shared`, which proxies every
/// call to whichever client is currently configured.
protocol AIClient {
    /// Human-readable name used in Settings / Onboarding.
    var displayName: String { get }

    /// True if the client has everything it needs to make a call (key / URL).
    var isReady: Bool { get }

    /// Cheap health check — returns true if the provider answers.
    func ping() async -> Bool

    /// Single non-streaming chat. Returns the full assistant text.
    func chat(messages: [AIMessage], temperature: Double) async throws -> String

    /// Streaming chat. Yields token chunks as they arrive.
    func streamChat(messages: [AIMessage], temperature: Double) -> AsyncThrowingStream<String, Error>

    /// Multimodal — describe / answer about a JPEG (base64-encoded).
    func describeImage(base64JPEG: String, prompt: String) async throws -> String
}

/// Provider-agnostic chat message.
struct AIMessage: Codable, Equatable {
    enum Role: String, Codable { case system, user, assistant }
    let role: Role
    let content: String
    /// Optional inline JPEG (base64) attached to a `user` message.
    let imageBase64: String?

    init(role: Role, content: String, imageBase64: String? = nil) {
        self.role = role
        self.content = content
        self.imageBase64 = imageBase64
    }
}

/// Available AI providers shown in Settings.
enum AIProvider: String, Codable, CaseIterable, Identifiable {
    case gemini
    case grok
    case ollama

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gemini: return "Google Gemini"
        case .grok:   return "xAI Grok"
        case .ollama: return "Локальная Ollama"
        }
    }

    /// User-facing localised tagline shown under the picker.
    var tagline: String {
        switch self {
        case .gemini: return "Облако · быстро · бесплатные квоты"
        case .grok:   return "Облако · продвинутая модель"
        case .ollama: return "Своя нейросеть · туннель"
        }
    }
}

/// Single source of truth for the active provider + API keys. Keys live in the
/// Keychain so they survive reinstall + app-uninstall on most iOS versions.
@MainActor
final class AISettings: ObservableObject {
    static let shared = AISettings()

    @Published var provider: AIProvider {
        didSet {
            UserDefaults.standard.set(provider.rawValue, forKey: "ai.provider")
        }
    }

    private init() {
        let defaults = UserDefaults.standard
        if let raw = defaults.string(forKey: "ai.provider"),
           let p = AIProvider(rawValue: raw) {
            self.provider = p
        } else {
            self.provider = .gemini   // sane default: free tier + vision
            defaults.set(AIProvider.gemini.rawValue, forKey: "ai.provider")
        }
    }

    var geminiKey: String? {
        get { KeychainStore.get(.geminiKey) }
        set { KeychainStore.set(newValue, for: .geminiKey) }
    }

    var xaiKey: String? {
        get { KeychainStore.get(.xaiKey) }
        set { KeychainStore.set(newValue, for: .xaiKey) }
    }
}

/// Routes every AI call to the currently-selected provider. If the active
/// provider is missing its key/URL, the router silently falls back to the
/// first ready client in priority order (gemini → grok → ollama).
final class AIRouter: AIClient {

    static let shared = AIRouter()
    private init() {}

    private func activeClient() -> AIClient {
        // Read directly from UserDefaults to avoid main-actor hops — the
        // `provider` setter on `AISettings` mirrors the value here on every
        // change, so this is always up to date.
        let preferred: AIProvider = {
            if let raw = UserDefaults.standard.string(forKey: "ai.provider"),
               let p = AIProvider(rawValue: raw) {
                return p
            }
            return .gemini
        }()

        let clients: [AIClient] = {
            switch preferred {
            case .gemini: return [GeminiClient.shared, GrokClient.shared, OllamaClient.shared]
            case .grok:   return [GrokClient.shared, GeminiClient.shared, OllamaClient.shared]
            case .ollama: return [OllamaClient.shared, GeminiClient.shared, GrokClient.shared]
            }
        }()
        return clients.first(where: { $0.isReady }) ?? clients[0]
    }

    var displayName: String { activeClient().displayName }
    var isReady: Bool { activeClient().isReady }

    func ping() async -> Bool { await activeClient().ping() }

    func chat(messages: [AIMessage], temperature: Double = 0.6) async throws -> String {
        try await activeClient().chat(messages: messages, temperature: temperature)
    }

    func streamChat(messages: [AIMessage], temperature: Double = 0.6) -> AsyncThrowingStream<String, Error> {
        activeClient().streamChat(messages: messages, temperature: temperature)
    }

    func describeImage(base64JPEG: String, prompt: String) async throws -> String {
        try await activeClient().describeImage(base64JPEG: base64JPEG, prompt: prompt)
    }
}

/// Errors common to every provider.
enum AIError: LocalizedError {
    case notConfigured(provider: String)
    case badStatus(code: Int, body: String)
    case decode
    case transport(Error)
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .notConfigured(let p): return "\(p) не настроен. Откройте настройки и вставьте API-ключ."
        case .badStatus(let c, let body): return "AI вернул ошибку \(c): \(body.prefix(160))"
        case .decode: return "Не удалось разобрать ответ AI."
        case .transport(let e): return e.localizedDescription
        case .rateLimited: return "Слишком много запросов. Попробуйте через минуту."
        }
    }
}
