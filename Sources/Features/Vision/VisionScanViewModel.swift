import SwiftUI
import AVFoundation
import Combine

@MainActor
final class VisionScanViewModel: NSObject, ObservableObject {

    @Published var detections: [ObjectDetector.Detection] = []
    @Published var lastSpokenSummary: String = ""
    @Published var lastFrameSize: CGSize = .zero
    @Published var dangerLevel: Double = 0
    @Published var isAutoNarrating: Bool = false

    let camera = CameraManager()
    private let detector = ObjectDetector()
    private var lastInferenceTime: Date = .distantPast
    private var lastWarningTime: Date = .distantPast
    private var lastNarrationTime: Date = .distantPast
    private let voice = VoiceSynthesizer.shared
    private let cuePlayer = VoiceCuePlayer.shared
    nonisolated(unsafe) private var lastSampleBuffer: CMSampleBuffer?
    nonisolated private let bufferLock = NSLock()
    private var autoNarrationTask: Task<Void, Never>?

    override init() {
        super.init()
        camera.configure(sampleDelegate: self)
    }

    func start() {
        camera.start()
        // Auto-flash in low light is handled by the device when running ML; we
        // still expose a manual torch toggle.
    }

    func stop() {
        camera.stop()
        voice.stop()
        cuePlayer.stop()
        stopAutoNarration()
    }

    /// Manual one-shot description (button "Опиши сейчас").
    func describeNow() async {
        bufferLock.lock()
        let buffer = lastSampleBuffer
        bufferLock.unlock()
        guard let buffer, let jpeg = camera.snapshotJPEG(from: buffer) else {
            voice.speak("Кадр пока не готов.")
            return
        }
        await sendForDescription(jpeg: jpeg, prompt: descriptionPrompt())
    }

    // MARK: - Auto narration

    func toggleAutoNarration() {
        isAutoNarrating.toggle()
        if isAutoNarrating {
            startAutoNarration()
        } else {
            stopAutoNarration()
        }
    }

    private func startAutoNarration() {
        autoNarrationTask?.cancel()
        autoNarrationTask = Task { @MainActor [weak self] in
            while let self, !Task.isCancelled, self.isAutoNarrating {
                await self.narrateOnceIfReady()
                // Pause between narrations: 6 seconds keeps the ear free so
                // immediate obstacle warnings can break through.
                try? await Task.sleep(nanoseconds: 6_000_000_000)
            }
        }
    }

    private func stopAutoNarration() {
        autoNarrationTask?.cancel()
        autoNarrationTask = nil
        isAutoNarrating = false
    }

    private func narrateOnceIfReady() async {
        bufferLock.lock()
        let buffer = lastSampleBuffer
        bufferLock.unlock()
        guard let buffer, let jpeg = camera.snapshotJPEG(from: buffer, quality: 0.6) else { return }
        // Don't talk over urgent obstacle warnings.
        if Date().timeIntervalSince(lastWarningTime) < 4 { return }
        await sendForDescription(jpeg: jpeg, prompt: shortNarrationPrompt(), interrupt: false)
        lastNarrationTime = Date()
    }

    private func sendForDescription(jpeg: Data, prompt: String, interrupt: Bool = true) async {
        let base64 = jpeg.base64EncodedString()
        do {
            let reply = try await OllamaClient.shared.describeImage(base64JPEG: base64, prompt: prompt)
            let trimmed = reply.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            lastSpokenSummary = trimmed
            if interrupt { voice.stop() }
            voice.speak(trimmed)
        } catch {
            if interrupt {
                let msg = "Не удалось описать сцену. Проверьте туннель."
                lastSpokenSummary = msg
                voice.speak(msg)
            }
        }
    }

    private func descriptionPrompt() -> String {
        switch LocalizationManager.shared.currentLanguage {
        case .ru, .system: return "Опиши кратко, что я вижу на этой фотографии. Только важное. До 3 предложений."
        case .kk: return "Осы фотода не көрінетінін қысқаша сипатта. Тек маңызды. 3 сөйлемге дейін."
        case .en: return "Describe briefly what I see in this photo. Only important things. Up to 3 sentences."
        }
    }

    private func shortNarrationPrompt() -> String {
        switch LocalizationManager.shared.currentLanguage {
        case .ru, .system: return "Я иду и не вижу. Очень коротко скажи, что прямо передо мной — одной фразой до 12 слов. Без вступлений."
        case .kk: return "Мен жүріп бара жатырмын, көрмеймін. Тура алдымда не бар екенін бір сөйлеммен қысқа айт — 12 сөзге дейін."
        case .en: return "I am walking and cannot see. Very briefly tell me what's right in front of me — one sentence, up to 12 words. No preamble."
        }
    }

    // MARK: - Helpers

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
        let now = Date()
        bufferLock.lock()
        lastSampleBuffer = sampleBuffer
        bufferLock.unlock()
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
                self.dangerLevel = self.dangerScore(for: dets)
            } catch {
                // Vision sometimes fails on a busy frame — ignore.
            }
        }
    }

    /// Smart obstacle warning that uses bundled HUMAN voice cues for
    /// the three core scenarios: wall ahead, turn left, turn right.
    private func maybeWarn(about detections: [ObjectDetector.Detection]) {
        guard SettingsStore.shared.dangerVibrations else { return }
        let now = Date()
        guard now.timeIntervalSince(lastWarningTime) > 4 else { return }

        // Box in the centre 40 % of the frame.
        let centre = CGRect(x: 0.30, y: 0.30, width: 0.40, height: 0.40)
        let leftHalf = CGRect(x: 0, y: 0, width: 0.50, height: 1.0)
        let rightHalf = CGRect(x: 0.50, y: 0, width: 0.50, height: 1.0)

        let bigCentre = detections.first { $0.box.intersects(centre) && $0.box.area > 0.10 }
        let bigLeft = detections.first { $0.box.intersects(leftHalf) && $0.box.area > 0.10 }
        let bigRight = detections.first { $0.box.intersects(rightHalf) && $0.box.area > 0.10 }

        // 1) Wall / large obstacle right in front → "Остановитесь, впереди стена".
        if let _ = bigCentre, bigCentre?.box.area ?? 0 > 0.18 {
            cuePlayer.play(.stopWall)
            HapticManager.shared.dangerPattern()
            lastWarningTime = now
            return
        }

        // 2) Obstacle on the left → "Поверните правее".
        if bigLeft != nil && bigRight == nil {
            cuePlayer.play(.turnRight)
            HapticManager.shared.tap()
            lastWarningTime = now
            return
        }

        // 3) Obstacle on the right → "Поверните левее".
        if bigRight != nil && bigLeft == nil {
            cuePlayer.play(.turnLeft)
            HapticManager.shared.tap()
            lastWarningTime = now
            return
        }

        // 4) Anything else big & central but smaller than wall — narrate via TTS.
        if let big = bigCentre {
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

    private func dangerScore(for detections: [ObjectDetector.Detection]) -> Double {
        let centre = CGRect(x: 0.30, y: 0.30, width: 0.40, height: 0.40)
        let total = detections
            .filter { $0.box.intersects(centre) }
            .map { Double($0.box.area) }
            .reduce(0, +)
        return min(1.0, total * 4)
    }
}

private extension CGRect {
    var area: CGFloat { width * height }
}
