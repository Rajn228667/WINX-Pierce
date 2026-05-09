import Foundation
import Speech
import AVFoundation

/// Wrapper around SFSpeechRecognizer + AVAudioEngine. Records the microphone, runs
/// real-time on-device recognition, and publishes partial transcripts.
@MainActor
final class SpeechRecognizer: ObservableObject {

    @Published private(set) var transcript: String = ""
    @Published private(set) var isListening: Bool = false
    @Published private(set) var lastError: String?

    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var recognizer: SFSpeechRecognizer?

    private var localeIdentifier: String

    init(locale: String? = nil) {
        let id = locale ?? LocalizationManager.shared.currentLanguage.speechLocale
        self.localeIdentifier = id
        self.recognizer = SFSpeechRecognizer(locale: Locale(identifier: id))
    }

    func updateLocale(_ id: String) {
        guard id != localeIdentifier else { return }
        localeIdentifier = id
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: id))
    }

    // MARK: - Permission

    static func requestAuthorization() async -> Bool {
        await withCheckedContinuation { cont in
            SFSpeechRecognizer.requestAuthorization { status in
                cont.resume(returning: status == .authorized)
            }
        }
    }

    // MARK: - Start / Stop

    func start() throws {
        guard !isListening else { return }
        guard let recognizer, recognizer.isAvailable else {
            lastError = "Распознавание речи недоступно для этого языка."
            return
        }

        AudioSessionManager.shared.activatePlayAndRecord()

        let engine = AVAudioEngine()
        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = true
        if #available(iOS 16.0, *) {
            req.addsPunctuation = true
            req.requiresOnDeviceRecognition = false
        }

        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak req] buffer, _ in
            req?.append(buffer)
        }

        engine.prepare()
        try engine.start()

        task = recognizer.recognitionTask(with: req) { [weak self] result, error in
            guard let self else { return }
            Task { @MainActor in
                if let result {
                    self.transcript = result.bestTranscription.formattedString
                }
                if error != nil || (result?.isFinal == true) {
                    self.stop()
                }
            }
        }

        self.audioEngine = engine
        self.request = req
        self.transcript = ""
        self.isListening = true
        self.lastError = nil
    }

    func stop() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        audioEngine = nil
        request = nil
        task = nil
        isListening = false
    }
}
