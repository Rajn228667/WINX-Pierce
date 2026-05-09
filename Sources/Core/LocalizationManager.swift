import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case ru
    case kk
    case en

    var id: String { raw }
    var raw: String { rawValue }

    init(raw: String) {
        self = AppLanguage(rawValue: raw) ?? .system
    }

    var locale: Locale {
        switch self {
        case .system:
            return Locale.autoupdatingCurrent
        case .ru:
            return Locale(identifier: "ru_RU")
        case .kk:
            return Locale(identifier: "kk_KZ")
        case .en:
            return Locale(identifier: "en_US")
        }
    }

    /// Locale used for AVSpeechSynthesisVoice — must match `BCP-47`.
    var speechLocale: String {
        switch self {
        case .system:
            let preferred = Locale.preferredLanguages.first ?? "ru-RU"
            return preferred
        case .ru: return Config.defaultVoiceLocaleRu
        case .kk: return Config.defaultVoiceLocaleKk
        case .en: return Config.defaultVoiceLocaleEn
        }
    }

    var displayName: String {
        switch self {
        case .system: return "Система"
        case .ru: return "Русский"
        case .kk: return "Қазақша"
        case .en: return "English"
        }
    }
}

/// Switches the app language live without restart.
final class LocalizationManager: ObservableObject {

    static let shared = LocalizationManager()

    @Published private(set) var currentLanguage: AppLanguage
    @Published private(set) var currentLocale: Locale

    private init() {
        let raw = UserDefaults.standard.string(forKey: "winx.language") ?? AppLanguage.system.raw
        let lang = AppLanguage(raw: raw)
        self.currentLanguage = lang
        self.currentLocale = lang.locale
        applyLanguageBundleOverride(lang)
    }

    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        currentLocale = language.locale
        applyLanguageBundleOverride(language)
        objectWillChange.send()
    }

    private func applyLanguageBundleOverride(_ language: AppLanguage) {
        // For per-locale .strings overrides we set AppleLanguages in defaults,
        // but only switch the in-app text via SwiftUI's Locale environment to
        // avoid restart. The string lookup goes through `tr()` which respects
        // `currentLanguage`.
        if language != .system {
            UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        }
    }
}

// MARK: - Lookup

extension LocalizationManager {
    /// Localized string for the active in-app language — works without restart.
    func tr(_ key: LocalKey) -> String {
        let table = LocalizationTable.shared
        switch currentLanguage {
        case .system:
            return table.lookup(key, language: systemLanguageFallback())
        default:
            return table.lookup(key, language: currentLanguage)
        }
    }

    private func systemLanguageFallback() -> AppLanguage {
        let id = Locale.preferredLanguages.first ?? "ru"
        if id.hasPrefix("ru") { return .ru }
        if id.hasPrefix("kk") { return .kk }
        if id.hasPrefix("en") { return .en }
        return .ru
    }
}

/// Convenience view-modifier: `Text(L.home_title.tr)`
struct LocalKeyText: View {
    let key: LocalKey
    @EnvironmentObject private var loc: LocalizationManager
    var body: some View { Text(loc.tr(key)) }
}

extension LocalKey {
    /// Use only inside a SwiftUI view that has `LocalizationManager` in env.
    var localized: String { LocalizationManager.shared.tr(self) }
}
