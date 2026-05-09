import Foundation
import AVFoundation
import Combine

@MainActor
final class AICompanionViewModel: ObservableObject {

    @Published var isUserListening: Bool = false
    @Published var isThinking: Bool = false
    @Published var isAISpeaking: Bool = false
    @Published var partialUserText: String = ""
    @Published var lastAssistantReply: String = ""
    @Published var amplitude: Double = 0.0
    @Published private(set) var messages: [OllamaClient.Message] = []

    private let recognizer = SpeechRecognizer()
    private let voice = VoiceSynthesizer.shared
    private var cancellables = Set<AnyCancellable>()
    private var streamingTask: Task<Void, Never>?
    private var amplitudeTask: Task<Void, Never>?

    init() {
        // Seed with the system prompt.
        messages.append(OllamaClient.Message(role: "system", content: Config.companionSystemPrompt))

        recognizer.$transcript
            .receive(on: DispatchQueue.main)
            .assign(to: &$partialUserText)
        recognizer.$isListening
            .receive(on: DispatchQueue.main)
            .assign(to: &$isUserListening)
        VoiceSynthesizer.shared.$isSpeaking
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAISpeaking)
    }

    func greet() {
        guard messages.count == 1 else { return }
        let intro: String
        switch LocalizationManager.shared.currentLanguage {
        case .ru, .system: intro = "Здравствуйте. Я Эдит. Расскажите, чем помочь."
        case .kk: intro = "Сәлеметсіз бе. Мен Эдитпін. Қалай көмектесейін?"
        case .en: intro = "Hello. I'm Edit. How can I help you today?"
        }
        lastAssistantReply = intro
        voice.speak(intro)
    }

    func togglePushToTalk() {
        if isUserListening {
            stopListening(submit: true)
        } else {
            startListening()
        }
    }

    private func startListening() {
        voice.stop()
        let id = LocalizationManager.shared.currentLanguage.speechLocale
        recognizer.updateLocale(id)
        do {
            try recognizer.start()
            HapticManager.shared.tap()
            startAmplitudeFakeStream()
        } catch {
            voice.speak("Не удалось включить микрофон.")
        }
    }

    private func stopListening(submit: Bool) {
        recognizer.stop()
        amplitudeTask?.cancel()
        amplitudeTask = nil
        amplitude = 0
        let final = partialUserText.trimmingCharacters(in: .whitespacesAndNewlines)
        if submit, !final.isEmpty {
            send(userText: final)
        }
    }

    func cancel() {
        streamingTask?.cancel()
        streamingTask = nil
        recognizer.stop()
        voice.stop()
        isThinking = false
        amplitudeTask?.cancel()
        amplitude = 0
    }

    func regenerate() async {
        // Resend the last user message.
        if let last = messages.last(where: { $0.role == "user" }) {
            // Remove the last assistant turn (if any) to keep the chat tidy.
            if messages.last?.role == "assistant" { messages.removeLast() }
            await streamReply(after: last)
        }
    }

    private func send(userText: String) {
        let msg = OllamaClient.Message(role: "user", content: userText)
        messages.append(msg)
        partialUserText = ""
        streamingTask = Task { await streamReply(after: msg) }
    }

    private func streamReply(after userMessage: OllamaClient.Message) async {
        isThinking = true
        lastAssistantReply = ""

        let model = SettingsStore.shared.preferredCompanionModel
        var buffer: String = ""
        var spokenChunkBoundary: Int = 0
        do {
            let stream = OllamaClient.shared.streamChat(
                model: model,
                messages: messages,
                temperature: 0.55
            )
            for try await token in stream {
                buffer += token
                lastAssistantReply = buffer
                isThinking = false

                // Speak in sentence-sized chunks so the voice feels natural.
                if let boundary = nextSentenceBoundary(in: buffer, after: spokenChunkBoundary) {
                    let chunk = String(buffer[buffer.index(buffer.startIndex, offsetBy: spokenChunkBoundary)..<buffer.index(buffer.startIndex, offsetBy: boundary)])
                    voice.speak(chunk)
                    spokenChunkBoundary = boundary
                }
            }
            // Speak any leftover tail.
            let tail = String(buffer.suffix(buffer.count - spokenChunkBoundary)).trimmingCharacters(in: .whitespacesAndNewlines)
            if !tail.isEmpty { voice.speak(tail) }

            messages.append(OllamaClient.Message(role: "assistant", content: buffer))
        } catch {
            isThinking = false
            let msg: String
            if let oerr = error as? OllamaClient.OllamaError {
                msg = oerr.errorDescription ?? "Ошибка нейросети"
            } else {
                msg = "Не удалось получить ответ. Проверьте туннель."
            }
            lastAssistantReply = msg
            voice.speak(msg)
        }
    }

    /// Finds the next sentence-ending punctuation (`.`, `?`, `!`, `;`, line-break)
    /// starting from `from`. Returns the offset *after* the punctuation, or nil if
    /// the buffer doesn't yet contain a complete sentence.
    private func nextSentenceBoundary(in text: String, after offset: Int) -> Int? {
        guard offset < text.count else { return nil }
        let starts = text.index(text.startIndex, offsetBy: offset)
        let slice = text[starts...]
        guard let firstEnd = slice.firstIndex(where: { ".?!\n;".contains($0) }) else { return nil }
        let after = text.index(after: firstEnd)
        return text.distance(from: text.startIndex, to: after)
    }

    // MARK: - Amplitude

    /// We don't tap the audio engine directly here (the SpeechRecognizer owns it),
    /// so we simulate amplitude via a deterministic pseudo-random stream that the
    /// sphere reacts to. It still feels alive and stays cheap.
    private func startAmplitudeFakeStream() {
        amplitudeTask?.cancel()
        amplitudeTask = Task { [weak self] in
            var t: Double = 0
            while let self, !Task.isCancelled, self.isUserListening {
                t += 0.1
                let value = (sin(t * 4) + sin(t * 7) * 0.6) * 0.25 + 0.55
                let clamped = max(0.05, min(1.0, value + Double.random(in: -0.05...0.10)))
                self.amplitude = clamped
                try? await Task.sleep(nanoseconds: 80_000_000)
            }
        }
    }
}
