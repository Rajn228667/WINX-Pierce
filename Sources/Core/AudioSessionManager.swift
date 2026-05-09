import AVFoundation

/// Owns the global AVAudioSession. The app routinely combines TTS playback with
/// speech recognition / voice recording, so we configure `.playAndRecord` with
/// `.duckOthers` and `.defaultToSpeaker` to match user expectations.
final class AudioSessionManager {

    static let shared = AudioSessionManager()

    private init() {}

    private let session = AVAudioSession.sharedInstance()

    func activatePlayAndRecord() {
        do {
            try session.setCategory(
                .playAndRecord,
                mode: .spokenAudio,
                options: [.defaultToSpeaker, .allowBluetooth, .duckOthers, .allowBluetoothA2DP]
            )
            try session.setActive(true, options: [])
        } catch {
            // Falls back silently — the system will use the default category.
        }
    }

    func activatePlayback() {
        do {
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true, options: [])
        } catch {}
    }

    func deactivate() {
        try? session.setActive(false, options: [.notifyOthersOnDeactivation])
    }
}
