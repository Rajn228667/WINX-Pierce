import SwiftUI

@main
struct WINXPierceApp: App {

    @StateObject private var settings = SettingsStore.shared
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var voice = VoiceSynthesizer.shared
    @StateObject private var voiceControl = VoiceControlEngine.shared
    @StateObject private var eyeComfort = EyeComfortEngine.shared
    @StateObject private var emergencyContacts = EmergencyContactsStore.shared

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
                .task { AppBootstrap.configureOnLaunch() }
        }
    }
}

enum AppBootstrap {
    /// Light-weight start-up tasks. Anything that can fail or block is wrapped
    /// in a `try?` / deferred so the app always reaches first paint.
    @MainActor
    static func configureOnLaunch() {
        // Activate audio session lazily — voice synth will re-activate when needed.
        // Done on a background queue so launch is not blocked.
        Task.detached(priority: .utility) {
            await MainActor.run {
                AudioSessionManager.shared.activatePlayAndRecord()
            }
        }
        // Pre-warm permissions snapshot — cheap, fully synchronous, no prompts.
        PermissionsManager.shared.refreshAll()
        // Apply saved eye-comfort preferences (brightness / warm filter).
        EyeComfortEngine.shared.applySaved()
    }
}
