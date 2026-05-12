import Foundation

/// Google Gemini (generativelanguage.googleapis.com) implementation.
///
/// Uses the v1beta REST API. Models:
///  - `gemini-2.5-flash` for chat and vision (multimodal-ready).
final class GeminiClient: AIClient {

    static let shared = GeminiClient()
    private init() {}

    let displayName = "Google Gemini"

    private let chatModel   = "gemini-2.5-flash"
    private let visionModel = "gemini-2.5-flash"
    private let baseURL     = "https://generativelanguage.googleapis.com/v1beta/models"

    var isReady: Bool {
        guard let key = KeychainStore.get(.geminiKey) else { return false }
        return !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var apiKey: String? {
        KeychainStore.get(.geminiKey)?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Wire format

    private struct GenerateContentRequest: Encodable {
        let contents: [Content]
        let systemInstruction: Content?
        let generationConfig: GenerationConfig?

        struct Content: Encodable {
            let role: String?           // "user" | "model"
            let parts: [Part]
        }
        struct Part: Encodable {
            let text: String?
            let inlineData: InlineData?
            enum CodingKeys: String, CodingKey { case text, inlineData = "inline_data" }
        }
        struct InlineData: Encodable {
            let mimeType: String
            let data: String
            enum CodingKeys: String, CodingKey { case mimeType = "mime_type", data }
        }
        struct GenerationConfig: Encodable {
            let temperature: Double?
            let maxOutputTokens: Int?
        }
    }

    private struct GenerateContentResponse: Decodable {
        let candidates: [Candidate]?

        struct Candidate: Decodable {
            let content: Content?
            struct Content: Decodable {
                let parts: [Part]?
            }
            struct Part: Decodable {
                let text: String?
            }
        }
    }

    // MARK: - AIClient

    func ping() async -> Bool {
        guard let key = apiKey, let url = URL(string: "\(baseURL)?key=\(key)") else { return false }
        var req = URLRequest(url: url, timeoutInterval: 10)
        req.httpMethod = "GET"
        do {
            let (_, resp) = try await URLSession.shared.data(for: req)
            if let http = resp as? HTTPURLResponse { return (200..<300).contains(http.statusCode) }
        } catch {}
        return false
    }

    func chat(messages: [AIMessage], temperature: Double = 0.6) async throws -> String {
        try await invoke(model: chatModel, messages: messages, temperature: temperature)
    }

    func streamChat(messages: [AIMessage], temperature: Double = 0.6) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    // Gemini streams via SSE on `:streamGenerateContent?alt=sse`.
                    guard let key = apiKey else { throw AIError.notConfigured(provider: "Gemini") }
                    guard let url = URL(string: "\(baseURL)/\(chatModel):streamGenerateContent?alt=sse&key=\(key)") else {
                        throw AIError.notConfigured(provider: "Gemini")
                    }
                    let payload = Self.buildPayload(messages: messages, temperature: temperature)
                    var req = URLRequest(url: url, timeoutInterval: Config.streamTimeout)
                    req.httpMethod = "POST"
                    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    req.httpBody = try JSONEncoder().encode(payload)

                    let (bytes, resp) = try await URLSession.shared.bytes(for: req)
                    if let http = resp as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                        continuation.finish(throwing: AIError.badStatus(code: http.statusCode, body: ""))
                        return
                    }
                    for try await line in bytes.lines {
                        guard line.hasPrefix("data:") else { continue }
                        let json = line.dropFirst(5).trimmingCharacters(in: .whitespaces)
                        guard !json.isEmpty, json != "[DONE]",
                              let data = json.data(using: .utf8),
                              let chunk = try? JSONDecoder().decode(GenerateContentResponse.self, from: data),
                              let text = chunk.candidates?.first?.content?.parts?.compactMap(\.text).joined(),
                              !text.isEmpty
                        else { continue }
                        continuation.yield(text)
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
        guard let key = apiKey else { throw AIError.notConfigured(provider: "Gemini") }
        guard let url = URL(string: "\(baseURL)/\(model):generateContent?key=\(key)") else {
            throw AIError.notConfigured(provider: "Gemini")
        }
        let payload = Self.buildPayload(messages: messages, temperature: temperature)
        var req = URLRequest(url: url, timeoutInterval: Config.networkTimeout)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(payload)
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            if let http = resp as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                let body = String(data: data, encoding: .utf8) ?? ""
                if http.statusCode == 429 { throw AIError.rateLimited }
                throw AIError.badStatus(code: http.statusCode, body: body)
            }
            let decoded = try JSONDecoder().decode(GenerateContentResponse.self, from: data)
            let text = decoded.candidates?.first?.content?.parts?.compactMap(\.text).joined() ?? ""
            if text.isEmpty { throw AIError.decode }
            return text
        } catch let e as AIError { throw e } catch { throw AIError.transport(error) }
    }

    private static func buildPayload(messages: [AIMessage], temperature: Double) -> GenerateContentRequest {
        var system: GenerateContentRequest.Content?
        var contents: [GenerateContentRequest.Content] = []
        for msg in messages {
            switch msg.role {
            case .system:
                // Gemini exposes a dedicated `systemInstruction` slot.
                system = .init(role: nil, parts: [.init(text: msg.content, inlineData: nil)])
            case .user, .assistant:
                let geminiRole = (msg.role == .assistant) ? "model" : "user"
                var parts: [GenerateContentRequest.Part] = []
                if !msg.content.isEmpty {
                    parts.append(.init(text: msg.content, inlineData: nil))
                }
                if let b64 = msg.imageBase64 {
                    parts.append(.init(text: nil,
                                       inlineData: .init(mimeType: "image/jpeg", data: b64)))
                }
                contents.append(.init(role: geminiRole, parts: parts))
            }
        }
        return GenerateContentRequest(
            contents: contents,
            systemInstruction: system,
            generationConfig: .init(temperature: temperature, maxOutputTokens: 1024)
        )
    }
}
