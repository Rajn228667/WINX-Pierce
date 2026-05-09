import Foundation
import Combine
import SwiftUI

/// Centralised voice-command engine. Holds a SpeechRecognizer, intercepts the
/// transcript live, and routes recognised commands to the corresponding feature
/// via published `intent` events.
@MainActor
final class VoiceControlEngine: ObservableObject {

    static let shared = VoiceControlEngine()

    @Published private(set) var isListening: Bool = false
    @Published private(set) var partialTranscript: String = ""
    @Published private(set) var lastIntent: VoiceIntent? = nil

    let recognizer = SpeechRecognizer()
    private var cancellables = Set<AnyCancellable>()
    private let voice = VoiceSynthesizer.shared

    private init() {
        bind()
    }

    private func bind() {
        recognizer.$transcript
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self else { return }
                self.partialTranscript = text
                if let intent = CommandRouter.shared.route(text) {
                    self.handle(intent)
                }
            }
            .store(in: &cancellables)
        recognizer.$isListening
            .receive(on: DispatchQueue.main)
            .assign(to: &$isListening)
    }

    func toggle() {
        if isListening { stop() } else { start() }
    }

    func start() {
        guard SettingsStore.shared.voiceControlEnabled else { return }
        let id = LocalizationManager.shared.currentLanguage.speechLocale
        recognizer.updateLocale(id)
        do {
            try recognizer.start()
            HapticManager.shared.tap()
        } catch {
            voice.speak(LocalizationManager.shared.tr(.err_no_permission))
        }
    }

    func stop() {
        recognizer.stop()
    }

    private func handle(_ intent: VoiceIntent) {
        guard intent != lastIntent else { return }
        lastIntent = intent
        HapticManager.shared.success()
        // The actual navigation happens in HomeView via .onChange(lastIntent).
    }
}

// MARK: - Intent model

enum VoiceIntent: String, Equatable {
    case openCompanion
    case openVision
    case openOCR
    case openMagnifier
    case openNavigation
    case openLocator
    case openWalking
    case openSOS
    case openHealth
    case openLearning
    case openWhatsApp
    case openTelegram
    case openMusic
    case openDiary
    case openSmartHome
    case openEyeComfort
    case openScene
    case openAccessibility
    case openCards
    case openListen
    case openCurrency
    case stopAll
}
