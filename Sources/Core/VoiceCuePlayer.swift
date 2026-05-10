import Foundation
import AVFoundation

/// Plays bundled human-recorded MP3 obstacle cues for the walking / scanner.
/// These are the user-provided voice phrases — they are MUCH warmer than TTS,
/// so we use them whenever we hit a known scenario:
///
///   - `.stopWall`   = "Остановитесь, впереди стена."
///   - `.turnLeft`   = "Впереди препятствия, поверните левее."
///   - `.turnRight`  = "Впереди препятствия, поверните правее."
///
/// The player owns its own `AVAudioPlayer` so it can run alongside TTS without
/// blocking. It also debounces: the same cue won't fire more than once every
/// `minRepeatInterval` seconds.
@MainActor
final class VoiceCuePlayer: NSObject, ObservableObject {

    static let shared = VoiceCuePlayer()

    enum Cue: String, CaseIterable {
        case stopWall   = "voice_stop_wall"
        case turnLeft   = "voice_turn_left"
        case turnRight  = "voice_turn_right"
    }

    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var lastCue: Cue?

    private var player: AVAudioPlayer?
    private var lastPlayed: [Cue: Date] = [:]
    private let minRepeatInterval: TimeInterval = 3.0

    /// Plays the cue if it hasn't been played in the last `minRepeatInterval`
    /// seconds. Returns true if it actually started playback.
    @discardableResult
    func play(_ cue: Cue, force: Bool = false) -> Bool {
        if !force, let last = lastPlayed[cue],
           Date().timeIntervalSince(last) < minRepeatInterval {
            return false
        }
        guard let url = Bundle.main.url(forResource: cue.rawValue, withExtension: "mp3") else {
            return false
        }
        AudioSessionManager.shared.activatePlayAndRecord()
        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.delegate = self
            p.volume = 1.0
            p.prepareToPlay()
            p.play()
            self.player = p
            self.isPlaying = true
            self.lastCue = cue
            self.lastPlayed[cue] = Date()
            return true
        } catch {
            return false
        }
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
    }
}

extension VoiceCuePlayer: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isPlaying = false
            self.player = nil
        }
    }
}
