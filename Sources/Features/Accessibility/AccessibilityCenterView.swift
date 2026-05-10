import SwiftUI

/// All accessibility settings in one place. Every change is reactive — no restart.
struct AccessibilityCenterView: View {

    @EnvironmentObject private var settings: SettingsStore
    @EnvironmentObject private var loc: LocalizationManager

    var body: some View {
        Form {
            Section {
                Button {
                    applyLowVisionPreset()
                    HapticManager.shared.tap()
                    VoiceSynthesizer.shared.speak(loc.tr(.settings_lowvision_hint))
                } label: {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(loc.tr(.settings_lowvision_title))
                                .font(.system(size: 17, weight: .heavy))
                            Text(loc.tr(.settings_lowvision_hint))
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "eye.trianglebadge.exclamationmark.fill")
                            .foregroundStyle(Theme.brandRed)
                    }
                }
                .accessibilityHint(Text(loc.tr(.settings_lowvision_hint)))
            }

            Section("Текст") {
                VStack(alignment: .leading) {
                    Text("Размер: \(Int(settings.textScale * 100))%")
                    Slider(value: $settings.textScale, in: 0.8...3.0, step: 0.05) {
                        Text("Размер текста")
                    }
                }
                Toggle("Жирный шрифт", isOn: $settings.boldText)
                Toggle("Высокий контраст", isOn: $settings.highContrast)
            }

            Section("Зрение") {
                VStack(alignment: .leading) {
                    Text("Тёплый фильтр (синий свет)")
                    Slider(value: $settings.blueLightFilter, in: 0...0.6, step: 0.05)
                }
                Picker("Цветовая схема", selection: $settings.colorSchemeRaw) {
                    Text("Системная").tag("system")
                    Text("Светлая").tag("light")
                    Text("Тёмная").tag("dark")
                }
                Picker("Дальтонизм", selection: $settings.colorblindModeRaw) {
                    ForEach(ColorblindMode.allCases) { mode in
                        Text(mode.displayName).tag(mode.rawValue)
                    }
                }
            }

            Section("Голос") {
                VStack(alignment: .leading) {
                    Text("Скорость")
                    Slider(value: $settings.voiceRate, in: 0...1)
                }
                VStack(alignment: .leading) {
                    Text("Тон")
                    Slider(value: $settings.voicePitch, in: 0.5...2.0)
                }
                VStack(alignment: .leading) {
                    Text("Громкость")
                    Slider(value: $settings.voiceVolume, in: 0...1)
                }
                Button {
                    VoiceSynthesizer.shared.speak("Это пример того, как я звучу с этими настройками.")
                } label: {
                    Label("Прослушать пример", systemImage: "speaker.wave.2.fill")
                }
            }

            Section("Управление") {
                Toggle("Голосовое управление", isOn: $settings.voiceControlEnabled)
                Toggle("Вибрация при опасности", isOn: $settings.dangerVibrations)
                Toggle("Тактильный отклик", isOn: $settings.hapticsEnabled)
            }

            Section("Язык") {
                Picker("Язык интерфейса", selection: $settings.languageRaw) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang.raw)
                    }
                }
            }

            Section("AI") {
                Picker("Модель Ollama", selection: $settings.preferredCompanionModel) {
                    Text("llama3.2:3b (быстро)").tag("llama3.2:3b")
                    Text("qwen2.5:7b (умно)").tag("qwen2.5:7b")
                    Text("qwen2.5-coder:7b (код)").tag("qwen2.5-coder:7b")
                    Text("llava:7b (зрение)").tag("llava:7b")
                }
                NavigationLink {
                    OllamaURLEditView()
                } label: {
                    Label("URL туннеля Ollama", systemImage: "network")
                }
            }
        }
        .navigationTitle("Доступность")
    }

    private func applyLowVisionPreset() {
        // Boost font, bold, and contrast in one tap. Values match Apple's
        // "Larger Accessibility Sizes" + Bold Text + Increase Contrast.
        settings.textScale = 1.7
        settings.boldText = true
        settings.highContrast = true
    }
}
