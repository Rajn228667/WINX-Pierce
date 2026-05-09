import SwiftUI

@main
struct WINXPierceApp: App {

    @StateObject private var settings = SettingsStore.shared
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var voice = VoiceSynthesizer.shared
    @StateObject private var voiceControl = VoiceControlEngine.shared
    @StateObject private var eyeComfort = EyeComfortEngine.shared
    @StateObject private var emergencyContacts = EmergencyContactsStore.shared

    init() {
        MainActor.assumeIsolated {
            AppBootstrap.configureOnLaunch()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(settings)
                .environmentObject(localization)
                .environmentObject(voice)
                .environmentObject(voiceControl)
                .environmentObject(eyeComfort)
                .environmentObject(emergencyContacts)
                .environment(\.locale, localization.currentLocale)
                .preferredColorScheme(settings.colorSchemePreference)
                .dynamicTypeSize(settings.dynamicTypeSize)
                .tint(Theme.brandRed)
        }
    }
}

enum AppBootstrap {
    @MainActor
    static func configureOnLaunch() {
        // Activate audio session in playback+record mode for TTS + STT coexistence.
        AudioSessionManager.shared.activatePlayAndRecord()
        // Pre-warm permissions checker so we know what to request on first screen.
        PermissionsManager.shared.refreshAll()
        // Apply saved eye-comfort preferences immediately.
        EyeComfortEngine.shared.applySaved()
    }
}
