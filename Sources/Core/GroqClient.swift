import Foundation

/// Groq (api.groq.com) implementation. Uses the OpenAI-compatible chat
/// completions endpoint:
///  - chat:   `llama-3.3-70b-versatile`
///  - vision: `meta-llama/llama-4-scout-17b-16e-instruct` (multimodal)
///
/// Note: this is **Groq**, not xAI's **Grok**. Groq is an LPU inference
/// provider that hosts open-weights models at ~500 tok/s.
final class GroqClient: AIClient {

    static let shared = GroqClient()
    private init() {}

    let displayName = "Groq"

    private let chatModel   = "llama-3.3-70b-versatile"
    private let visionModel = "meta-llama/llama-4-scout-17b-16e-instruct"
    private let endpoint    = URL(string: "https://api.groq.com/openai/v1/chat/completions")!

    var isReady: Bool {
        guard let key = KeychainStore.get(.xaiKey) else { return false }
        return !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var apiKey: String? {
        KeychainStore.get(.xaiKey)?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Wire format (OpenAI-compatible)

    private struct ChatRequest: Encodable {
        let model: String
        let messages: [WireMessage]
        let temperature: Double
        let maxTokens: Int?
        let stream: Bool

        enum CodingKeys: String, CodingKey {
            case model, messages, temperature
            case maxTokens = "max_tokens"
            case stream
        }
    }

    private struct WireMessage: Encodable {
        let role: String
        let content: AnyContent
    }

    /// OpenAI-style content can be a plain string OR a multimodal array of parts.
    private enum AnyContent: Encodable {
        case string(String)
        case parts([Part])

        struct Part: Encodable {
            let type: String                // "text" | "image_url"
            let text: String?
            let imageURL: ImageURL?

            enum CodingKeys: String, CodingKey { case type, text, imageURL = "image_url" }
        }
        struct ImageURL: Encodable { let url: String }

        func encode(to encoder: Encoder) throws {
            var c = encoder.singleValueContainer()
            switch self {
            case .string(let s): try c.encode(s)
            case .parts(let p):  try c.encode(p)
            }
        }
    }

    private struct ChatResponse: Decodable {
        let choices: [Choice]
        struct Choice: Decodable {
            let message: Msg?
            let delta: Msg?
            struct Msg: Decodable {
                let content: String?
            }
        }
    }

    // MARK: - AIClient

    func ping() async -> Bool {
        guard let key = apiKey else { return false }
        var req = URLRequest(url: URL(string: "https://api.groq.com/openai/v1/models")!,
                             timeoutInterval: 10)
        req.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        do {
            let (_, resp) = try await URLSession.shared.data(for: req)
            if let http = resp as? HTTPURLResponse { return (200..<300).contains(http.statusCode) }
        } catch {}
        return false
    }

    func chat(messages: [AIMessage], temperature: Double = 0.6) async throws -> String {
        let usesVision = messages.contains { $0.imageBase64 != nil }
        return try await invoke(model: usesVision ? visionModel : chatModel,
                                messages: messages,
                                temperature: temperature)
    }

    func streamChat(messages: [AIMessage], temperature: Double = 0.6) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    guard let key = apiKey else { throw AIError.notConfigured(provider: "Groq") }
                    let payload = Self.buildPayload(model: chatModel,
                                                    messages: messages,
                                                    temperature: temperature,
                                                    stream: true)
                    var req = URLRequest(url: endpoint, timeoutInterval: Config.streamTimeout)
                    req.httpMethod = "POST"
                    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    req.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
                    req.httpBody = try JSONEncoder().encode(payload)

                    let (bytes, resp) = try await URLSession.shared.bytes(for: req)
                    if let http = resp as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                        continuation.finish(throwing: AIError.badStatus(code: http.statusCode, body: ""))
                        return
                    }
                    for try await line in bytes.lines {
                        guard line.hasPrefix("data:") else { continue }
                        let payload = line.dropFirst(5).trimmingCharacters(in: .whitespaces)
                        if payload.isEmpty || payload == "[DONE]" {
                            if payload == "[DONE]" {
                                continuation.finish()
                                return
                            }
                            continue
                        }
                        guard let data = payload.data(using: .utf8),
                              let chunk = try? JSONDecoder().decode(ChatResponse.self, from: data),
                              let delta = chunk.choices.first?.delta?.content,
                              !delta.isEmpty
                        else { continue }
                        continuation.yield(delta)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    func describeImage(base64JPEG: String, prompt: String) async throws -> String {
        let userMsg = AIMessage(role: .user, content: prompt, imageBase64: base64JPEG)
        return try await invoke(model: visionModel, messages: [userMsg], temperature: 0.4)
    }

    // MARK: - Internals

    private func invoke(model: String, messages: [AIMessage], temperature: Double) async throws -> String {
        guard let key = apiKey else { throw AIError.notConfigured(provider: "Groq") }
        let payload = Self.buildPayload(model: model, messages: messages,
                                        temperature: temperature, stream: false)
        var req = URLRequest(url: endpoint, timeoutInterval: Config.networkTimeout)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        req.httpBody = try JSONEncoder().encode(payload)
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            if let http = resp as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                let body = String(data: data, encoding: .utf8) ?? ""
                if http.statusCode == 429 { throw AIError.rateLimited }
                throw AIError.badStatus(code: http.statusCode, body: body)
            }
            let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
            let text = decoded.choices.first?.message?.content ?? ""
            if text.isEmpty { throw AIError.decode }
            return text
        } catch let e as AIError { throw e } catch { throw AIError.transport(error) }
    }

    private static func buildPayload(
        model: String,
        messages: [AIMessage],
        temperature: Double,
        stream: Bool
    ) -> ChatRequest {
        let wire: [WireMessage] = messages.map { msg in
            let role: String = {
                switch msg.role {
                case .system: return "system"
                case .user: return "user"
                case .assistant: return "assistant"
                }
            }()
            if let b64 = msg.imageBase64 {
                let parts: [AnyContent.Part] = [
                    .init(type: "text", text: msg.content, imageURL: nil),
                    .init(type: "image_url",
                          text: nil,
                          imageURL: .init(url: "data:image/jpeg;base64,\(b64)"))
                ]
                return WireMessage(role: role, content: .parts(parts))
            }
            return WireMessage(role: role, content: .string(msg.content))
        }
        return ChatRequest(model: model,
                           messages: wire,
                           temperature: temperature,
                           maxTokens: 1024,
                           stream: stream)
    }
}
