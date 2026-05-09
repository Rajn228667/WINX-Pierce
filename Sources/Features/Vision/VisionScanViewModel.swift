import SwiftUI
import AVFoundation
import Combine

@MainActor
final class VisionScanViewModel: NSObject, ObservableObject {

    @Published var detections: [ObjectDetector.Detection] = []
    @Published var lastSpokenSummary: String = ""
    @Published var lastFrameSize: CGSize = .zero

    let camera = CameraManager()
    private let detector = ObjectDetector()
    private var lastInferenceTime: Date = .distantPast
    private var lastWarningTime: Date = .distantPast
    private let voice = VoiceSynthesizer.shared
    private var lastSampleBuffer: CMSampleBuffer?

    override init() {
        super.init()
        camera.configure(sampleDelegate: self)
    }

    func start() { camera.start() }
    func stop() { camera.stop(); voice.stop() }

    func describeNow() async {
        guard let buffer = lastSampleBuffer,
              let jpeg = camera.snapshotJPEG(from: buffer) else {
            voice.speak("Кадр пока не готов.")
            return
        }
        let base64 = jpeg.base64EncodedString()
        do {
            let prompt: String
            switch LocalizationManager.shared.currentLanguage {
            case .ru, .system: prompt = "Опиши кратко, что я вижу на этой фотографии. Только важное. До 3 предложений."
            case .kk: prompt = "Осы фотода не көрінетінін қысқаша сипатта. Тек маңызды. 3 сөйлемге дейін."
            case .en: prompt = "Describe briefly what I see in this photo. Only important things. Up to 3 sentences."
            }
            let reply = try await OllamaClient.shared.describeImage(base64JPEG: base64, prompt: prompt)
            lastSpokenSummary = reply
            voice.speak(reply)
        } catch {
            let msg = "Не удалось описать сцену. Проверьте туннель."
            lastSpokenSummary = msg
            voice.speak(msg)
        }
    }

    // MARK: - Helpers

    /// Convert a Vision coordinate (0…1, origin bottom-left) to a SwiftUI rect in points.
    func viewRect(for visionBox: CGRect, in size: CGSize) -> CGRect {
        let x = visionBox.minX * size.width
        let w = visionBox.width * size.width
        let h = visionBox.height * size.height
        let y = (1 - visionBox.maxY) * size.height
        return CGRect(x: x, y: y, width: w, height: h)
    }
}

extension VisionScanViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput,
                                   didOutput sampleBuffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {
        // Throttle to ~3 FPS detection.
        let now = Date()
        Task { @MainActor in self.lastSampleBuffer = sampleBuffer }
        Task { @MainActor [weak self] in
            guard let self else { return }
            if now.timeIntervalSince(self.lastInferenceTime) < 0.33 { return }
            self.lastInferenceTime = now

            guard let pixel = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let h = CGFloat(CVPixelBufferGetHeight(pixel))
            let w = CGFloat(CVPixelBufferGetWidth(pixel))
            self.lastFrameSize = CGSize(width: w, height: h)

            do {
                let dets = try await self.detector.detect(in: pixel)
                self.detections = dets
                self.maybeWarn(about: dets)
            } catch {
                // Ignored — Vision sometimes fails on a busy frame.
            }
        }
    }

    private func maybeWarn(about detections: [ObjectDetector.Detection]) {
        guard SettingsStore.shared.dangerVibrations else { return }
        let now = Date()
        guard now.timeIntervalSince(lastWarningTime) > 4 else { return }

        // Anything large and centered = "obstacle ahead".
        let center = CGRect(x: 0.30, y: 0.30, width: 0.40, height: 0.40)
        if let big = detections.first(where: { $0.box.intersects(center) && $0.box.width * $0.box.height > 0.10 }) {
            let dist = ObjectDetector().estimatedMetres(for: big, frameSize: lastFrameSize)
            let distText = dist.map { String(format: " на %.1f м", $0) } ?? ""
            let phrase: String
            switch LocalizationManager.shared.currentLanguage {
            case .ru, .system: phrase = "Внимание, \(big.label.lowercased()) впереди\(distText)."
            case .kk: phrase = "Назар, алдыңызда \(big.label.lowercased())\(distText)."
            case .en: phrase = "Attention, \(big.label.lowercased()) ahead\(distText)."
            }
            voice.speak(phrase)
            HapticManager.shared.dangerPattern()
            lastWarningTime = now
        }
    }
}
