import SwiftUI
import AVFoundation
import UIKit

/// Drives the [LocatorView] — owns the camera + obstacle analyser, plays the
/// pre-recorded voice cues, and exposes a stream of published state for the
/// view to bind to.
///
/// Same priorities as the Android port:
///   1. **Obstacle cues** (highest) — pre-recorded MP3 with 3 s same-cue
///      cooldown. CENTER + close = "wall ahead" — interrupts anything.
///   2. **Idle nudge** — when 15 s have passed without any voice activity we
///      play the warmer "и че мы замолчали" easter-egg cue.
///   3. **Heartbeat** — every 10 s of completely clear path we say
///      "путь свободен" via TTS so the user knows the analyser is alive.
@MainActor
final class LocatorViewModel: NSObject, ObservableObject {

    // MARK: - Published state

    enum State: Equatable { case clear, warning, danger, dark }

    @Published var snapshot: ObstacleSnapshot = .clear
    @Published var state: State = .clear
    @Published var message: String = ""
    @Published var isRunning: Bool = false

    // MARK: - Dependencies

    let camera = CameraManager()
    private let cues = VoiceCuePlayer.shared
    private let speech = VoiceSynthesizer.shared
    private let haptics = HapticManager.shared

    /// `nonisolated` so the capture-output delegate (which runs on a private
    /// dispatch queue) can call `analyze(pixelBuffer:)` without hopping to the
    /// main actor first.
    private nonisolated(unsafe) var analyzer: ObstacleAnalyzer!

    // MARK: - Cadence state

    private var heartbeatTask: Task<Void, Never>?
    private var idleTask: Task<Void, Never>?
    private var lastVoiceActivityAt: Date = .distantPast
    private var lastDangerAt: Date = .distantPast
    private var lastCue: VoiceCuePlayer.Cue?

    private let heartbeatInterval: TimeInterval = 10
    private let idleInterval: TimeInterval = 15

    // MARK: - Lifecycle

    override init() {
        super.init()
        self.analyzer = ObstacleAnalyzer(proximityThreshold: 0.10) { [weak self] snap in
            Task { @MainActor in self?.handleSnapshot(snap) }
        }
        camera.configure(sampleDelegate: self)
        message = LocalizationManager.shared.tr(.locator_status_clear)
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        AudioSessionManager.shared.activatePlayAndRecord()
        camera.start()
        speech.speak(LocalizationManager.shared.tr(.locator_intro))
        markVoiceActivity()
        startHeartbeat()
        startIdleNudge()
    }

    func stop() {
        camera.stop()
        heartbeatTask?.cancel(); heartbeatTask = nil
        idleTask?.cancel(); idleTask = nil
        isRunning = false
        speech.stop()
        cues.stop()
    }

    func togglePause() {
        if isRunning { stop() } else { start() }
    }

    func repeatLastCue() {
        if let lastCue {
            cues.play(lastCue, force: true)
        } else {
            speech.speak(message)
        }
    }

    func triggerSOS() {
        // Forward to the existing SOS flow. We just open `tel:` so the user
        // gets the dialer with their preferred emergency contact pre-filled if
        // configured. Falls back to 112 (the EU/KZ emergency number).
        let number = EmergencyContactsStore.shared.preferred?.phone ?? "112"
        let digits = number.filter { $0.isNumber || $0 == "+" }
        let url = URL(string: "tel://\(digits)")
        speech.speak(LocalizationManager.shared.tr(.tile_sos))
        if let url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        haptics.error()
    }

    // MARK: - Snapshot handling

    private func handleSnapshot(_ snap: ObstacleSnapshot) {
        self.snapshot = snap
        let loc = LocalizationManager.shared

        if snap.tooDark {
            state = .dark
            message = loc.tr(.locator_status_dark)
            return
        }

        switch snap.zone {
        case .none:
            state = .clear
            message = loc.tr(.locator_status_clear)
        case .left:
            state = .warning
            message = loc.tr(.locator_status_turn_right)
            playCue(.turnRight)
        case .right:
            state = .warning
            message = loc.tr(.locator_status_turn_left)
            playCue(.turnLeft)
        case .center:
            if snap.proximity > 0.55 {
                state = .danger
                message = loc.tr(.locator_status_stop_wall)
                playCue(.stopWall, interrupt: true)
                lastDangerAt = Date()
                haptics.error()
            } else {
                state = .warning
                let side: VoiceCuePlayer.Cue = snap.centroidX < 0.5 ? .turnRight : .turnLeft
                message = side == .turnRight
                    ? loc.tr(.locator_status_turn_right)
                    : loc.tr(.locator_status_turn_left)
                playCue(side)
            }
        }
    }

    private func playCue(_ cue: VoiceCuePlayer.Cue, interrupt: Bool = false) {
        if interrupt { cues.stop() }
        if cues.play(cue) {
            lastCue = cue
            markVoiceActivity()
            haptics.warning()
        }
    }

    // MARK: - Heartbeat / idle

    private func startHeartbeat() {
        heartbeatTask?.cancel()
        heartbeatTask = Task { [weak self] in
            while let self, !Task.isCancelled, self.isRunning {
                try? await Task.sleep(nanoseconds: UInt64(self.heartbeatInterval * 1_000_000_000))
                await MainActor.run {
                    guard self.isRunning else { return }
                    if self.state == .clear,
                       Date().timeIntervalSince(self.lastDangerAt) > 8,
                       !self.cues.isPlaying,
                       !self.speech.isSpeaking {
                        self.speech.speak(LocalizationManager.shared.tr(.locator_heartbeat))
                    }
                }
            }
        }
    }

    private func startIdleNudge() {
        idleTask?.cancel()
        idleTask = Task { [weak self] in
            while let self, !Task.isCancelled, self.isRunning {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    guard self.isRunning else { return }
                    if Date().timeIntervalSince(self.lastVoiceActivityAt) > self.idleInterval,
                       !self.cues.isPlaying,
                       !self.speech.isSpeaking {
                        if self.cues.play(.idle) {
                            self.markVoiceActivity()
                        }
                    }
                }
            }
        }
    }

    private func markVoiceActivity() {
        lastVoiceActivityAt = Date()
    }
}

// MARK: - Camera delegate

extension LocatorViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput,
                                   didOutput sampleBuffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {
        guard let pixel = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        analyzer.analyze(pixelBuffer: pixel)
    }
}
