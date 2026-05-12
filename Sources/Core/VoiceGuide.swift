import SwiftUI
import Combine

/// Centralized voice guidance for every screen.
///
/// Each screen calls `VoiceGuide.shared.announce(.someScreen)` in its
/// `.onAppear` — the service:
///  • respects `SettingsStore.voiceGuideEnabled`,
///  • picks the current localized string from `LocalizationTable`,
///  • routes the playback through `VoiceSynthesizer` (which already honours
///    voice gender / pinned voice / rate / pitch / volume settings).
///
/// We also de-duplicate announcements: if the user navigates back-and-forth
/// inside a small window, we don't repeat the same hint — that would be
/// annoying. The `cooldown` is per-screen.
@MainActor
final class VoiceGuide: ObservableObject {

    static let shared = VoiceGuide()

    private var lastSpoken: [LocalKey: Date] = [:]
    private let cooldown: TimeInterval = 12

    private init() {}

    /// Speak the per-screen guide string.
    /// - Parameters:
    ///   - key: a `guide_*` localization key.
    ///   - force: ignore the per-screen cooldown.
    func announce(_ key: LocalKey, force: Bool = false) {
        guard SettingsStore.shared.voiceGuideEnabled else { return }
        if !force, let last = lastSpoken[key], Date().timeIntervalSince(last) < cooldown {
            return
        }
        lastSpoken[key] = Date()
        let text = LocalizationManager.shared.tr(key)
        VoiceSynthesizer.shared.speak(text)
    }

    /// Speak an arbitrary string — convenience for screens that build their
    /// announcement dynamically (e.g. "you're at 1500 steps").
    func speak(_ text: String) {
        guard SettingsStore.shared.voiceGuideEnabled, !text.isEmpty else { return }
        VoiceSynthesizer.shared.speak(text)
    }

    /// Stop any current announcement.
    func stop() {
        VoiceSynthesizer.shared.stop()
    }

    /// Reset cooldowns — used when language changes so the next visit is fresh.
    func resetCooldowns() {
        lastSpoken.removeAll()
    }
}

// MARK: - SwiftUI sugar

/// `.voiceGuide(.guide_home)` — drop this on any view and it will speak the
/// hint when the view appears, only if the user has the voice guide enabled.
extension View {
    func voiceGuide(_ key: LocalKey, force: Bool = false) -> some View {
        modifier(VoiceGuideModifier(key: key, force: force))
    }
}

private struct VoiceGuideModifier: ViewModifier {
    let key: LocalKey
    let force: Bool

    func body(content: Content) -> some View {
        content.task {
            // Tiny delay so the screen transition isn't talked over.
            try? await Task.sleep(nanoseconds: 350_000_000)
            VoiceGuide.shared.announce(key, force: force)
        }
        .onDisappear {
            // If the user swipes back mid-utterance, stop talking immediately.
            VoiceGuide.shared.stop()
        }
    }
}
