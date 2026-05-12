import SwiftUI
import AVFoundation

/// All accessibility settings in one place. Every change is reactive — no restart.
/// All copy is fully localised (ru/kk/en).
struct AccessibilityCenterView: View {

    @EnvironmentObject private var settings: SettingsStore
    @EnvironmentObject private var loc: LocalizationManager

    @State private var availableVoices: [AVSpeechSynthesisVoice] = []

    var body: some View {
        Form {
            // ── Quick presets ─────────────────────────────────────────────
            Section {
                Button { applyLowVisionPreset(); HapticManager.shared.tap()
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

                Button { applyHugeMode(); HapticManager.shared.tap()
                    VoiceSynthesizer.shared.speak(loc.tr(.big_mode_on))
                } label: {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(loc.tr(.big_mode_title))
                                .font(.system(size: 17, weight: .heavy))
                            Text(loc.tr(.big_mode_hint))
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "textformat.size.larger")
                            .foregroundStyle(Theme.brandRed)
                    }
                }
                .accessibilityHint(Text(loc.tr(.big_mode_hint)))
            }

            // ── Text ──────────────────────────────────────────────────────
            Section(loc.tr(.acc_text_section)) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(loc.tr(.acc_text_size))
                        Spacer()
                        Text("\(Int(settings.textScale * 100))%")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $settings.textScale, in: 0.8...3.0, step: 0.05) {
                        Text(loc.tr(.acc_text_size))
                    }
                    // Live preview — instantly reflects the slider position.
                    Text(loc.tr(.acc_text_preview_short))
                        .font(.system(size: 17 * settings.textScale,
                                      weight: settings.boldText ? .heavy : .semibold))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.elevatedBackground))
                }
                Toggle(loc.tr(.acc_bold), isOn: $settings.boldText)
                Toggle(loc.tr(.acc_high_contrast), isOn: $settings.highContrast)
            }

            // ── Vision ────────────────────────────────────────────────────
            Section(loc.tr(.acc_vision_section)) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(loc.tr(.acc_warm_filter))
                        Spacer()
                        Text(warmLabel)
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $settings.blueLightFilter, in: 0...0.6, step: 0.05)
                }
                Picker(loc.tr(.acc_color_scheme), selection: $settings.colorSchemeRaw) {
                    Text(loc.tr(.acc_scheme_system)).tag("system")
                    Text(loc.tr(.acc_scheme_light)).tag("light")
                    Text(loc.tr(.acc_scheme_dark)).tag("dark")
                }
                Picker(loc.tr(.acc_colorblind), selection: $settings.colorblindModeRaw) {
                    Text(loc.tr(.acc_colorblind_none)).tag(ColorblindMode.none.rawValue)
                    Text(loc.tr(.acc_colorblind_protanopia)).tag(ColorblindMode.protanopia.rawValue)
                    Text(loc.tr(.acc_colorblind_deuteranopia)).tag(ColorblindMode.deuteranopia.rawValue)
                    Text(loc.tr(.acc_colorblind_tritanopia)).tag(ColorblindMode.tritanopia.rawValue)
                    Text(loc.tr(.acc_colorblind_monochrome)).tag(ColorblindMode.monochrome.rawValue)
                }
            }

            // ── Voice ─────────────────────────────────────────────────────
            Section(loc.tr(.acc_voice_section)) {
                Picker(loc.tr(.acc_voice_gender), selection: $settings.voiceGenderRaw) {
                    Label(loc.tr(.acc_voice_female), systemImage: "person.crop.circle.fill")
                        .tag(VoiceGender.female.rawValue)
                    Label(loc.tr(.acc_voice_male), systemImage: "person.crop.circle.fill")
                        .tag(VoiceGender.male.rawValue)
                }
                .pickerStyle(.segmented)
                .onChange(of: settings.voiceGenderRaw) { _ in
                    settings.voiceIdentifier = ""   // reset pin
                }

                if !availableVoices.isEmpty {
                    Picker(loc.tr(.acc_voice_picker), selection: $settings.voiceIdentifier) {
                        Text(loc.tr(.acc_voice_auto)).tag("")
                        ForEach(availableVoices, id: \.identifier) { v in
                            Text(voiceLabel(v)).tag(v.identifier)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(loc.tr(.acc_voice_rate))
                    Slider(value: $settings.voiceRate, in: 0...1)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(loc.tr(.acc_voice_pitch))
                    Slider(value: $settings.voicePitch, in: 0.5...2.0)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(loc.tr(.acc_voice_volume))
                    Slider(value: $settings.voiceVolume, in: 0...1)
                }
                Button {
                    VoiceSynthesizer.shared.speak(loc.tr(.acc_voice_preview_text))
                } label: {
                    Label(loc.tr(.acc_voice_preview), systemImage: "speaker.wave.2.fill")
                }
            }

            // ── Control ───────────────────────────────────────────────────
            Section(loc.tr(.acc_control_section)) {
                Toggle(loc.tr(.acc_voice_control), isOn: $settings.voiceControlEnabled)
                Toggle(loc.tr(.acc_danger_haptics), isOn: $settings.dangerVibrations)
                Toggle(loc.tr(.acc_haptics), isOn: $settings.hapticsEnabled)
                VStack(alignment: .leading, spacing: 6) {
                    Toggle(loc.tr(.acc_voice_guide), isOn: $settings.voiceGuideEnabled)
                    Text(loc.tr(.acc_voice_guide_hint))
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
            }

            // ── Language ──────────────────────────────────────────────────
            Section(loc.tr(.acc_language_section)) {
                Picker(loc.tr(.acc_language_picker), selection: $settings.languageRaw) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang.raw)
                    }
                }
                .onChange(of: settings.languageRaw) { _ in
                    refreshVoices()
                    settings.voiceIdentifier = ""
                }
            }

            // ── AI ────────────────────────────────────────────────────────
            Section(loc.tr(.acc_ai_section)) {
                Picker(loc.tr(.acc_ai_model), selection: $settings.preferredCompanionModel) {
                    Text("llama3.2:3b").tag("llama3.2:3b")
                    Text("qwen2.5:7b").tag("qwen2.5:7b")
                    Text("qwen2.5-coder:7b").tag("qwen2.5-coder:7b")
                    Text("llava:7b").tag("llava:7b")
                }
                NavigationLink {
                    OllamaURLEditView()
                } label: {
                    Label(loc.tr(.acc_ai_url), systemImage: "network")
                }
            }
        }
        .navigationTitle(Text(loc.tr(.tile_accessibility)))
        .onAppear { refreshVoices() }
            .voiceGuide(.guide_accessibility)
    }

    // MARK: - Helpers

    private var warmLabel: String {
        switch settings.blueLightFilter {
        case ..<0.05: return loc.tr(.acc_warm_off)
        case ..<0.30: return loc.tr(.acc_warm_low)
        default:      return loc.tr(.acc_warm_high)
        }
    }

    private func voiceLabel(_ v: AVSpeechSynthesisVoice) -> String {
        let qual: String
        switch v.quality {
        case .premium: qual = loc.tr(.acc_quality_premium)
        case .enhanced: qual = loc.tr(.acc_quality_enhanced)
        default: qual = loc.tr(.acc_quality_compact)
        }
        return "\(v.name) · \(qual)"
    }

    private func refreshVoices() {
        availableVoices = VoiceSynthesizer.shared.availableVoices(for: loc.currentLanguage)
    }

    private func applyLowVisionPreset() {
        settings.textScale = 1.7
        settings.boldText = true
        settings.highContrast = true
    }

    private func applyHugeMode() {
        settings.textScale = 2.5
        settings.boldText = true
        settings.highContrast = true
        settings.hapticsEnabled = true
        settings.dangerVibrations = true
        settings.voiceControlEnabled = true
    }
}
