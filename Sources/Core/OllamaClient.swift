import Foundation

/// Ollama HTTP client. Talks to the user's self-hosted Ollama server, exposed via
/// a Cloudflare tunnel. Supports plain chat, streaming chat (token-by-token), and
/// multimodal chat (image + prompt) for the Scene Description feature.
final class OllamaClient {

    static let shared = OllamaClient()

    private init() {}

    enum OllamaError: LocalizedError {
        case noBaseURL
        case badStatus(Int)
        case decode
        case transport(Error)

        var errorDescription: String? {
            switch self {
            case .noBaseURL: return "Ollama URL не указан. Откройте онбординг и вставьте ссылку туннеля."
            case .badStatus(let code): return "Ollama вернул ошибку (\(code))."
            case .decode: return "Не удалось разобрать ответ Ollama."
            case .transport(let err): return err.localizedDescription
            }
        }
    }

    // MARK: - Models

    struct Message: Codable, Equatable {
        let role: String   // "system" / "user" / "assistant"
        let content: String
        let images: [String]?

        init(role: String, content: String, images: [String]? = nil) {
            self.role = role
            self.content = content
            self.images = images
        }
    }

    private struct ChatRequest: Encodable {
        let model: String
        let messages: [Message]
        let stream: Bool
        let options: Options?
        let keep_alive: String?

        struct Options: Encodable {
            let temperature: Double?
            let num_ctx: Int?
            let num_predict: Int?
        }
    }

    private struct ChatResponse: Decodable {
        struct Msg: Decodable { let role: String; let content: String }
        let message: Msg?
        let done: Bool?
        let response: String?
    }

    private struct TagsResponse: Decodable {
        struct Model: Decodable { let name: String }
        let models: [Model]
    }

    // MARK: - Public API

    /// Returns true if the server responds to /api/tags.
    func ping() async -> Bool {
        guard let url = baseURL()?.appendingPathComponent("api/tags") else { return false }
        var req = URLRequest(url: url, timeoutInterval: 10)
        req.httpMethod = "GET"
        req.cachePolicy = .reloadIgnoringLocalCacheData
        do {
            let (_, resp) = try await URLSession.shared.data(for: req)
            if let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) {
                return true
            }
        } catch {}
        return false
    }

    /// List available models.
    func listModels() async throws -> [String] {
        guard let url = baseURL()?.appendingPathComponent("api/tags") else { throw OllamaError.noBaseURL }
        let (data, resp) = try await URLSession.shared.data(from: url)
        if let http = resp as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw OllamaError.badStatus(http.statusCode)
        }
        let tags = try JSONDecoder().decode(TagsResponse.self, from: data)
        return tags.models.map(\.name)
    }

    /// Single non-streaming chat completion.
    func chat(model: String, messages: [Message], temperature: Double = 0.6) async throws -> String {
        guard let url = baseURL()?.appendingPathComponent("api/chat") else { throw OllamaError.noBaseURL }
        let body = ChatRequest(
            model: model,
            messages: messages,
            stream: false,
            options: .init(temperature: temperature, num_ctx: 4096, num_predict: 512),
            keep_alive: "30m"
        )
        var req = URLRequest(url: url, timeoutInterval: Config.networkTimeout)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(body)
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            if let http = resp as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                throw OllamaError.badStatus(http.statusCode)
            }
            let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
            if let msg = decoded.message?.content { return msg }
            if let resp = decoded.response { return resp }
            throw OllamaError.decode
        } catch let e as OllamaError { throw e } catch { throw OllamaError.transport(error) }
    }

    /// Streaming chat completion. Yields tokens as they arrive.
    func streamChat(
        model: String,
        messages: [Message],
        temperature: Double = 0.6
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    guard let url = baseURL()?.appendingPathComponent("api/chat") else {
                        throw OllamaError.noBaseURL
                    }
                    let body = ChatRequest(
                        model: model,
                        messages: messages,
                        stream: true,
                        options: .init(temperature: temperature, num_ctx: 4096, num_predict: 512),
                        keep_alive: "30m"
                    )
                    var req = URLRequest(url: url, timeoutInterval: Config.streamTimeout)
                    req.httpMethod = "POST"
                    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    req.httpBody = try JSONEncoder().encode(body)

                    let (bytes, resp) = try await URLSession.shared.bytes(for: req)
                    if let http = resp as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                        continuation.finish(throwing: OllamaError.badStatus(http.statusCode))
                        return
                    }

                    for try await line in bytes.lines {
                        guard !line.isEmpty,
                              let data = line.data(using: .utf8),
                              let chunk = try? JSONDecoder().decode(ChatResponse.self, from: data)
                        else { continue }

                        if let token = chunk.message?.content, !token.isEmpty {
                            continuation.yield(token)
                        } else if let token = chunk.response, !token.isEmpty {
                            continuation.yield(token)
                        }

                        if chunk.done == true {
                            continuation.finish()
                            return
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    /// Multimodal: ask the vision model to describe an image (base64 JPEG).
    func describeImage(base64JPEG: String, prompt: String, model: String? = nil) async throws -> String {
        let visionModel = model ?? Config.visionModel
        let userMsg = Message(role: "user", content: prompt, images: [base64JPEG])
        return try await chat(model: visionModel, messages: [userMsg], temperature: 0.4)
    }

    // MARK: - Helpers

    private func baseURL() -> URL? {
        guard var raw = KeychainStore.ollamaBaseURL?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else {
            return nil
        }
        if !raw.lowercased().hasPrefix("http") {
            raw = "https://" + raw
        }
        if raw.hasSuffix("/") { raw.removeLast() }
        return URL(string: raw)
    }

    var hasURL: Bool { baseURL() != nil }
}
