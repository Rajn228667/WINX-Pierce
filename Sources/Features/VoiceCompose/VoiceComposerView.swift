import SwiftUI

/// Voice Composer — for users who can't speak (or can't be heard) but
/// can type. They write a phrase, the app speaks it out loud in a natural
/// voice, and they can share the text or quickly fire common phrases.
struct VoiceComposerView: View {

    @EnvironmentObject private var loc: LocalizationManager
    @EnvironmentObject private var settings: SettingsStore
    @State private var text: String = ""
    @State private var presentingShare: Bool = false
    @State private var savedPhrases: [String] = ["Здравствуйте", "Спасибо", "Помогите, пожалуйста.", "Я слабослышащий, говорите громче."]

    private var quickPhrases: [String] {
        switch loc.currentLanguage {
        case .kk: return ["Сәлеметсіз бе", "Рахмет", "Маған көмек керек.", "Мен нашар естимін, қаттырақ сөйлеңіз."]
        case .en: return ["Hello", "Thank you", "I need help, please.", "I am hard of hearing — please speak louder."]
        default: return ["Здравствуйте", "Спасибо", "Помогите, пожалуйста.", "Я слабослышащий, говорите громче."]
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {

                // Editor — huge font, dark text on white card for accessibility
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(loc.tr(.compose_placeholder))
                            .font(.system(size: 22 * settings.textScale, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.secondaryText)
                            .padding(20)
                    }
                    TextEditor(text: $text)
                        .font(.system(size: 22 * settings.textScale, weight: .heavy, design: .rounded))
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 220)
                        .padding(14)
                }
                .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Theme.card))
                .padding(.horizontal, 16)

                // Big speak button
                Button {
                    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmed.isEmpty { return }
                    VoiceSynthesizer.shared.speak(trimmed)
                    HapticManager.shared.tap()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 26, weight: .black))
                        Text(loc.tr(.compose_speak))
                            .font(.system(size: 24, weight: .black, design: .rounded))
                    }
                    .frame(maxWidth: .infinity, minHeight: 84)
                    .foregroundStyle(.white)
                    .background(Capsule().fill(Theme.brandRed))
                }
                .padding(.horizontal, 16)
                .accessibilityLabel(Text(loc.tr(.compose_speak)))

                HStack(spacing: 12) {
                    Button {
                        presentingShare = true
                    } label: {
                        Label(loc.tr(.compose_share), systemImage: "square.and.arrow.up.fill")
                            .font(.system(size: 18, weight: .heavy))
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(.ultraThinMaterial, in: Capsule())
                            .foregroundStyle(Theme.primaryText)
                    }
                    Button {
                        if !text.isEmpty && !savedPhrases.contains(text) {
                            savedPhrases.insert(text, at: 0)
                            if savedPhrases.count > 10 { savedPhrases.removeLast() }
                            VoiceSynthesizer.shared.speak(loc.tr(.compose_save))
                        }
                    } label: {
                        Label(loc.tr(.compose_save), systemImage: "star.fill")
                            .font(.system(size: 18, weight: .heavy))
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(.ultraThinMaterial, in: Capsule())
                            .foregroundStyle(Theme.primaryText)
                    }
                    Button {
                        text = ""
                        HapticManager.shared.tap()
                    } label: {
                        Label(loc.tr(.compose_clear), systemImage: "xmark.circle.fill")
                            .font(.system(size: 18, weight: .heavy))
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(.ultraThinMaterial, in: Capsule())
                            .foregroundStyle(Theme.primaryText)
                    }
                }
                .padding(.horizontal, 16)

                // Quick phrases
                VStack(alignment: .leading, spacing: 10) {
                    Text("Быстрые фразы")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(Theme.secondaryText)
                        .padding(.horizontal, 18)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(quickPhrases, id: \.self) { phrase in
                            Button {
                                text = phrase
                                VoiceSynthesizer.shared.speak(phrase)
                                HapticManager.shared.tap()
                            } label: {
                                Text(phrase)
                                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                                    .foregroundStyle(Theme.primaryText)
                                    .multilineTextAlignment(.leading)
                                    .padding(14)
                                    .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
                                    .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
                                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.brandRed.opacity(0.4), lineWidth: 1.5))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Saved
                if !savedPhrases.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Избранное")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(Theme.secondaryText)
                            .padding(.horizontal, 18)
                        VStack(spacing: 8) {
                            ForEach(savedPhrases.prefix(5), id: \.self) { phrase in
                                Button {
                                    text = phrase
                                    VoiceSynthesizer.shared.speak(phrase)
                                } label: {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(Theme.accentOrange)
                                        Text(phrase)
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundStyle(Theme.primaryText)
                                            .lineLimit(2)
                                        Spacer()
                                        Image(systemName: "speaker.wave.2.fill")
                                            .foregroundStyle(Theme.brandRed)
                                    }
                                    .padding(14)
                                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 18)
        }
        .navigationTitle(Text(loc.tr(.tile_voice_compose)))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $presentingShare) {
            ActivityShareSheet(items: [text])
        }
            .voiceGuide(.guide_voice_compose)
    }
}
