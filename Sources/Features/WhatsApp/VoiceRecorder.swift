import AVFoundation
import Combine

/// Records a voice message into a `.m4a` (AAC) file. We choose AAC because:
///  • it's the same container WhatsApp's iOS client expects when receiving an
///    audio file via Share Sheet,
///  • Telegram accepts it as a regular audio attachment,
///  • it's tiny on disk.
@MainActor
final class VoiceRecorder: NSObject, ObservableObject {

    @Published private(set) var isRecording: Bool = false
    @Published private(set) var elapsed: TimeInterval = 0
    @Published private(set) var url: URL?
    @Published private(set) var amplitude: Double = 0

    private var recorder: AVAudioRecorder?
    private var meterTimer: Timer?

    func start() {
        AudioSessionManager.shared.activatePlayAndRecord()
        let filename = FileManager.default.temporaryDirectory.appendingPathComponent("winx-voice-\(Int(Date().timeIntervalSince1970)).m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 22050.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            let r = try AVAudioRecorder(url: filename, settings: settings)
            r.isMeteringEnabled = true
            r.delegate = self
            if r.record() {
                recorder = r
                isRecording = true
                elapsed = 0
                url = filename
                meterTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                    Task { @MainActor in
                        guard let self, let rec = self.recorder else { return }
                        rec.updateMeters()
                        let dB = rec.averagePower(forChannel: 0)
                        let normalised = max(0, min(1, (Double(dB) + 60) / 60))
                        self.amplitude = normalised
                        self.elapsed = rec.currentTime
                    }
                }
                HapticManager.shared.tap()
            }
        } catch {
            VoiceSynthesizer.shared.speak("Не удалось начать запись.")
        }
    }

    func stop() -> URL? {
        recorder?.stop()
        meterTimer?.invalidate()
        meterTimer = nil
        isRecording = false
        let result = url
        recorder = nil
        return result
    }

    func cancel() {
        recorder?.stop()
        meterTimer?.invalidate()
        meterTimer = nil
        isRecording = false
        if let u = url { try? FileManager.default.removeItem(at: u) }
        url = nil
        recorder = nil
    }
}

extension VoiceRecorder: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in self.isRecording = false }
    }
}
