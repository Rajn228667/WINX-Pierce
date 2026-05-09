import SwiftUI
import Combine

/// User-facing settings that persist across launches and propagate live.
/// All values are exposed as `@Published`, so any view observing the store updates
/// instantly — settings are applied without restart, as required.
final class SettingsStore: ObservableObject {

    static let shared = SettingsStore()

    private enum Keys {
        static let onboarded = "winx.onboarded"
        static let textScale = "winx.textScale"
        static let boldText = "winx.boldText"
        static let highContrast = "winx.highContrast"
        static let colorScheme = "winx.colorScheme"
        static let colorblindMode = "winx.colorblindMode"
        static let blueLightFilter = "winx.blueLightFilter"
        static let language = "winx.language"
        static let voiceRate = "winx.voiceRate"
        static let voicePitch = "winx.voicePitch"
        static let voiceVolume = "winx.voiceVolume"
        static let hapticsEnabled = "winx.hapticsEnabled"
        static let voiceControlEnabled = "winx.voiceControlEnabled"
        static let dangerVibrations = "winx.dangerVibrations"
        static let preferredCompanionModel = "winx.preferredCompanionModel"
    }

    private let defaults = UserDefaults.standard
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - State

    @Published var hasCompletedOnboarding: Bool {
        didSet { defaults.set(hasCompletedOnboarding, forKey: Keys.onboarded) }
    }

    @Published var textScale: Double {
        didSet { defaults.set(textScale, forKey: Keys.textScale) }
    }

    @Published var boldText: Bool {
        didSet { defaults.set(boldText, forKey: Keys.boldText) }
    }

    @Published var highContrast: Bool {
        didSet { defaults.set(highContrast, forKey: Keys.highContrast) }
    }

    @Published var colorSchemeRaw: String {
        didSet { defaults.set(colorSchemeRaw, forKey: Keys.colorScheme) }
    }

    @Published var colorblindModeRaw: String {
        didSet { defaults.set(colorblindModeRaw, forKey: Keys.colorblindMode) }
    }

    @Published var blueLightFilter: Double {
        didSet { defaults.set(blueLightFilter, forKey: Keys.blueLightFilter) }
    }

    @Published var languageRaw: String {
        didSet {
            defaults.set(languageRaw, forKey: Keys.language)
            LocalizationManager.shared.setLanguage(AppLanguage(raw: languageRaw))
        }
    }

    @Published var voiceRate: Double {
        didSet { defaults.set(voiceRate, forKey: Keys.voiceRate) }
    }

    @Published var voicePitch: Double {
        didSet { defaults.set(voicePitch, forKey: Keys.voicePitch) }
    }

    @Published var voiceVolume: Double {
        didSet { defaults.set(voiceVolume, forKey: Keys.voiceVolume) }
    }

    @Published var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: Keys.hapticsEnabled) }
    }

    @Published var voiceControlEnabled: Bool {
        didSet { defaults.set(voiceControlEnabled, forKey: Keys.voiceControlEnabled) }
    }

    @Published var dangerVibrations: Bool {
        didSet { defaults.set(dangerVibrations, forKey: Keys.dangerVibrations) }
    }

    @Published var preferredCompanionModel: String {
        didSet { defaults.set(preferredCompanionModel, forKey: Keys.preferredCompanionModel) }
    }

    // MARK: - Init

    private init() {
        self.hasCompletedOnboarding = defaults.bool(forKey: Keys.onboarded)
        self.textScale = defaults.double(forKey: Keys.textScale).nonZero(or: 1.0)
        self.boldText = defaults.object(forKey: Keys.boldText) as? Bool ?? true
        self.highContrast = defaults.bool(forKey: Keys.highContrast)
        self.colorSchemeRaw = defaults.string(forKey: Keys.colorScheme) ?? "system"
        self.colorblindModeRaw = defaults.string(forKey: Keys.colorblindMode) ?? "none"
        self.blueLightFilter = defaults.double(forKey: Keys.blueLightFilter)
        self.languageRaw = defaults.string(forKey: Keys.language) ?? AppLanguage.system.raw
        self.voiceRate = defaults.double(forKey: Keys.voiceRate).nonZero(or: 0.50)
        self.voicePitch = defaults.double(forKey: Keys.voicePitch).nonZero(or: 1.0)
        self.voiceVolume = defaults.double(forKey: Keys.voiceVolume).nonZero(or: 1.0)
        self.hapticsEnabled = defaults.object(forKey: Keys.hapticsEnabled) as? Bool ?? true
        self.voiceControlEnabled = defaults.object(forKey: Keys.voiceControlEnabled) as? Bool ?? true
        self.dangerVibrations = defaults.object(forKey: Keys.dangerVibrations) as? Bool ?? true
        self.preferredCompanionModel = defaults.string(forKey: Keys.preferredCompanionModel) ?? Config.chatModel
    }

    // MARK: - Derived

    var colorSchemePreference: ColorScheme? {
        switch colorSchemeRaw {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var dynamicTypeSize: DynamicTypeSize {
        switch textScale {
        case ..<0.85: return .small
        case ..<0.95: return .medium
        case ..<1.05: return .large
        case ..<1.20: return .xLarge
        case ..<1.40: return .xxLarge
        case ..<1.60: return .xxxLarge
        case ..<1.80: return .accessibility1
        case ..<2.00: return .accessibility2
        case ..<2.30: return .accessibility3
        case ..<2.60: return .accessibility4
        default: return .accessibility5
        }
    }

    var colorblindMode: ColorblindMode {
        ColorblindMode(rawValue: colorblindModeRaw) ?? .none
    }

    func reset() {
        for key in [
            Keys.onboarded, Keys.textScale, Keys.boldText, Keys.highContrast,
            Keys.colorScheme, Keys.colorblindMode, Keys.blueLightFilter, Keys.language,
            Keys.voiceRate, Keys.voicePitch, Keys.voiceVolume, Keys.hapticsEnabled,
            Keys.voiceControlEnabled, Keys.dangerVibrations, Keys.preferredCompanionModel
        ] {
            defaults.removeObject(forKey: key)
        }
    }
}

private extension Double {
    func nonZero(or fallback: Double) -> Double { self == 0 ? fallback : self }
}

enum ColorblindMode: String, CaseIterable, Identifiable {
    case none, deuteranopia, protanopia, tritanopia, monochrome
    var id: String { rawValue }

    var displayName: LocalizedStringKey {
        switch self {
        case .none: return "Без коррекции"
        case .deuteranopia: return "Дейтеранопия"
        case .protanopia: return "Протанопия"
        case .tritanopia: return "Тританопия"
        case .monochrome: return "Монохром"
        }
    }
}
