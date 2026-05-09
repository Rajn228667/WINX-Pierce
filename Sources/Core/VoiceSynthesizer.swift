import AVFoundation
import Combine

/// Owns AVSpeechSynthesizer and chooses the best available voice for the user's
/// language (Premium → Enhanced → Compact).
@MainActor
final class VoiceSynthesizer: NSObject, ObservableObject {

    static let shared = VoiceSynthesizer()

    @Published private(set) var isSpeaking: Bool = false
    @Published private(set) var currentText: String = ""

    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
        // Trigger a tiny silent utterance so iOS warms up the audio stack — this
        // dramatically reduces the lag on the very first real `speak()`.
        let warmup = AVSpeechUtterance(string: " ")
        warmup.volume = 0
        warmup.rate = AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(warmup)
    }

    // MARK: - Public

    /// Speaks `text` in the most natural available voice for the given language.
    /// Cancels any previous utterance.
    func speak(_ text: String, language: AppLanguage? = nil) {
        guard !text.isEmpty else { return }
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        AudioSessionManager.shared.activatePlayAndRecord()

        let utterance = AVSpeechUtterance(string: text)
        let lang = language ?? LocalizationManager.shared.currentLanguage
        utterance.voice = bestVoice(for: lang)
        let settings = SettingsStore.shared
        utterance.rate = mapRate(settings.voiceRate)
        utterance.pitchMultiplier = Float(max(0.5, min(2.0, settings.voicePitch)))
        utterance.volume = Float(max(0, min(1, settings.voiceVolume)))
        utterance.preUtteranceDelay = 0.05
        utterance.postUtteranceDelay = 0.05
        currentText = text
        synthesizer.speak(utterance)
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    // MARK: - Voice selection

    func bestVoice(for language: AppLanguage) -> AVSpeechSynthesisVoice? {
        let preferredIDs: [String]
        let bcp47: String
        switch language {
        case .ru:
            preferredIDs = Config.preferredVoicesRu
            bcp47 = Config.defaultVoiceLocaleRu
        case .kk:
            preferredIDs = Config.preferredVoicesKk
            bcp47 = Config.defaultVoiceLocaleKk
        case .en:
            preferredIDs = Config.preferredVoicesEn
            bcp47 = Config.defaultVoiceLocaleEn
        case .system:
            let preferred = Locale.preferredLanguages.first ?? "ru-RU"
            if preferred.hasPrefix("ru") { return bestVoice(for: .ru) }
            if preferred.hasPrefix("kk") { return bestVoice(for: .kk) }
            if preferred.hasPrefix("en") { return bestVoice(for: .en) }
            preferredIDs = []
            bcp47 = preferred
        }

        let allVoices = AVSpeechSynthesisVoice.speechVoices()

        // 1) Try the user's preferred Premium / Enhanced identifiers in order.
        for id in preferredIDs {
            if let v = allVoices.first(where: { $0.identifier == id }) { return v }
        }

        // 2) Pick the highest-quality voice for the BCP-47 prefix.
        let langPrefix = String(bcp47.prefix(2)).lowercased()
        let candidates = allVoices.filter { $0.language.lowercased().hasPrefix(langPrefix) }

        if let premium = candidates.first(where: { $0.quality == .premium }) { return premium }
        if let enhanced = candidates.first(where: { $0.quality == .enhanced }) { return enhanced }
        if let any = candidates.first { return any }

        return AVSpeechSynthesisVoice(language: bcp47)
    }

    /// Map our 0…1 slider to AVSpeech's narrow useful range.
    /// AVSpeech's default rate is 0.5 and the useful range is roughly 0.40…0.60.
    private func mapRate(_ slider: Double) -> Float {
        let clamped = max(0.0, min(1.0, slider))
        let minR: Double = 0.40
        let maxR: Double = 0.62
        return Float(minR + (maxR - minR) * clamped)
    }
}

extension VoiceSynthesizer: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = true }
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = false }
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in self.isSpeaking = false }
    }
}
