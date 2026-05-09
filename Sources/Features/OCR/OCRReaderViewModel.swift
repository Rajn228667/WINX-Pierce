import SwiftUI
import Vision
import AVFoundation

@MainActor
final class OCRReaderViewModel: NSObject, ObservableObject {

    @Published var recognizedText: String = ""
    @Published var scanning: Bool = false

    let camera = CameraManager()
    private var lastBuffer: CMSampleBuffer?

    override init() {
        super.init()
        camera.configure(sampleDelegate: self)
    }

    func start() { camera.start() }
    func stop() { camera.stop() }

    func scanFrame() async {
        guard let buffer = lastBuffer,
              let pixel = CMSampleBufferGetImageBuffer(buffer) else { return }
        scanning = true
        defer { scanning = false }
        let req = VNRecognizeTextRequest()
        req.recognitionLevel = .accurate
        req.usesLanguageCorrection = true
        req.recognitionLanguages = ["ru-RU", "kk-KZ", "en-US"]

        do {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixel, orientation: .up)
            try handler.perform([req])
            let lines = (req.results ?? [])
                .compactMap { $0.topCandidates(1).first?.string }
            let joined = lines.joined(separator: "\n")
            recognizedText = joined
            if !joined.isEmpty {
                VoiceSynthesizer.shared.speak(joined)
                HapticManager.shared.success()
            }
        } catch {
            VoiceSynthesizer.shared.speak("Не удалось прочитать текст.")
        }
    }

    func summarize() {
        guard !recognizedText.isEmpty else { return }
        let lang = LocalizationManager.shared.currentLanguage
        let prompt: String
        switch lang {
        case .ru, .system: prompt = "Сделай очень короткое резюме в 1-2 предложения. Только суть.\nТекст:\n\(recognizedText)"
        case .kk: prompt = "1-2 сөйлеммен қысқаша қорытынды жаса. Тек мәні.\nМәтін:\n\(recognizedText)"
        case .en: prompt = "Summarize in 1-2 sentences. Only the essence.\nText:\n\(recognizedText)"
        }
        Task {
            do {
                let reply = try await OllamaClient.shared.chat(
                    model: Config.fastModel,
                    messages: [.init(role: "user", content: prompt)],
                    temperature: 0.4
                )
                VoiceSynthesizer.shared.speak(reply)
                recognizedText += "\n\n— Кратко: " + reply
            } catch {
                VoiceSynthesizer.shared.speak("Не удалось сделать резюме.")
            }
        }
    }

    func translate() {
        guard !recognizedText.isEmpty else { return }
        let target: String
        switch LocalizationManager.shared.currentLanguage {
        case .ru, .system: target = "русский"
        case .kk: target = "қазақ тілі"
        case .en: target = "English"
        }
        let prompt = "Переведи следующий текст на \(target). Дай только перевод, ничего больше.\n\(recognizedText)"
        Task {
            do {
                let reply = try await OllamaClient.shared.chat(
                    model: Config.fastModel,
                    messages: [.init(role: "user", content: prompt)],
                    temperature: 0.2
                )
                VoiceSynthesizer.shared.speak(reply)
                recognizedText = reply
            } catch {
                VoiceSynthesizer.shared.speak("Не удалось перевести.")
            }
        }
    }
}

extension OCRReaderViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput,
                                   didOutput sampleBuffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {
        Task { @MainActor in self.lastBuffer = sampleBuffer }
    }
}
