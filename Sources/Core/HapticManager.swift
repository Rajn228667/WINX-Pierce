import UIKit
import CoreHaptics

/// Centralised haptic feedback. Falls back from CoreHaptics → UIFeedbackGenerator
/// when the device doesn't support patterns.
final class HapticManager {

    static let shared = HapticManager()

    private var engine: CHHapticEngine?
    private let supportsHaptics: Bool

    private init() {
        self.supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        prepareEngine()
    }

    private func prepareEngine() {
        guard supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            engine?.resetHandler = { [weak self] in self?.prepareEngine() }
            engine?.stoppedHandler = { _ in }
            try engine?.start()
        } catch {
            engine = nil
        }
    }

    // MARK: - Public API

    func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    /// Strong "danger ahead" pattern used by Vision/Walking modules.
    func dangerPattern() {
        guard supportsHaptics, let engine else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        do {
            let events: [CHHapticEvent] = [
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                ], relativeTime: 0.0),
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                ], relativeTime: 0.18),
                CHHapticEvent(eventType: .hapticContinuous, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                ], relativeTime: 0.32, duration: 0.5)
            ]
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }

    /// Soft "you have arrived / found it" cue.
    func successPattern() {
        guard supportsHaptics, let engine else {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            return
        }
        do {
            let events: [CHHapticEvent] = [
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
                ], relativeTime: 0.0),
                CHHapticEvent(eventType: .hapticTransient, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                ], relativeTime: 0.20)
            ]
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}
