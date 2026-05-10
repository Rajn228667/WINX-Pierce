import SwiftUI

/// Live Captions — full-screen, AAA-contrast real-time speech transcription
/// for hard-of-hearing users. Massive text, auto-scroll, language picker,
/// and quick share / copy. Press the big button to start/stop.
struct ListenView: View {

    @StateObject private var recognizer = SpeechRecognizer()
    @EnvironmentObject private var settings: SettingsStore
    @EnvironmentObject private var loc: LocalizationManager
    @State private var sessionTranscript: String = ""
    @State private var fontScale: CGFloat = 1.0
    @State private var presentingShare: Bool = false
    @State private var pulse: Bool = false

    private var displayText: String {
        let live = recognizer.transcript
        if live.isEmpty && sessionTranscript.isEmpty {
            return loc.tr(.listen_intro)
        }
        return sessionTranscript + (sessionTranscript.isEmpty ? "" : "\n\n") + live
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // High-contrast background — dark base with subtle gradient
            LinearGradient(colors: [Color.black, Color(red: 0.03, green: 0.03, blue: 0.05)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            // Captions area — auto-scrolls
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(displayText)
                            .font(.system(size: 36 * fontScale * settings.textScale,
                                          weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .id("caption")
                            .padding(.horizontal, 22)
                            .padding(.top, 32)
                            .padding(.bottom, 220)
                            .accessibilityLabel(displayText)
                    }
                }
                .onChange(of: recognizer.transcript) { _, _ in
                    withAnimation { proxy.scrollTo("caption", anchor: .bottom) }
                }
            }

            // Bottom toolbar — listen button, font size, language, share
            VStack(spacing: 14) {
                HStack(spacing: 10) {
                    fontButton(icon: "textformat.size.smaller") {
                        fontScale = max(0.7, fontScale - 0.15)
                    }
                    fontButton(icon: "textformat.size") {
                        fontScale = 1.0
                    }
                    fontButton(icon: "textformat.size.larger") {
                        fontScale = min(2.4, fontScale + 0.15)
                    }
                    Spacer()
                    Menu {
                        ForEach(AppLanguage.allCases) { l in
                            Button {
                                recognizer.updateLocale(l.speechLocale)
                            } label: {
                                Text(l.displayName)
                            }
                        }
                    } label: {
                        Image(systemName: "globe")
                            .font(.system(size: 22, weight: .heavy))
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(.ultraThinMaterial))
                            .foregroundStyle(.white)
                    }
                    .accessibilityLabel(Text(loc.tr(.listen_language)))
                }

                Button {
                    if recognizer.isListening {
                        recognizer.stop()
                    } else {
                        if !recognizer.transcript.isEmpty {
                            sessionTranscript += (sessionTranscript.isEmpty ? "" : "\n") + recognizer.transcript
                        }
                        try? recognizer.start()
                    }
                    HapticManager.shared.tap()
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .stroke(.white.opacity(0.3), lineWidth: 6)
                                .frame(width: 40, height: 40)
                            Image(systemName: recognizer.isListening ? "stop.fill" : "ear.fill")
                                .font(.system(size: 22, weight: .black))
                                .foregroundStyle(.white)
                                .scaleEffect(pulse && recognizer.isListening ? 1.15 : 1.0)
                        }
                        Text(recognizer.isListening ? loc.tr(.listen_stop) : loc.tr(.listen_start))
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, minHeight: 84)
                    .background(
                        Capsule().fill(recognizer.isListening ? Theme.brandRed : Theme.accentEmerald)
                    )
                }
                .accessibilityLabel(Text(recognizer.isListening ? loc.tr(.listen_stop) : loc.tr(.listen_start)))

                HStack(spacing: 12) {
                    Button {
                        let full = sessionTranscript + (sessionTranscript.isEmpty ? "" : "\n") + recognizer.transcript
                        UIPasteboard.general.string = full
                        VoiceSynthesizer.shared.speak(loc.tr(.listen_copied))
                        HapticManager.shared.tap()
                    } label: {
                        Label(loc.tr(.listen_copy), systemImage: "doc.on.doc.fill")
                            .font(.system(size: 18, weight: .heavy))
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(.ultraThinMaterial, in: Capsule())
                            .foregroundStyle(.white)
                    }
                    Button {
                        sessionTranscript = ""
                        HapticManager.shared.tap()
                    } label: {
                        Label(loc.tr(.listen_clear), systemImage: "trash.fill")
                            .font(.system(size: 18, weight: .heavy))
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(.ultraThinMaterial, in: Capsule())
                            .foregroundStyle(.white)
                    }
                    Button {
                        presentingShare = true
                    } label: {
                        Label(loc.tr(.listen_share), systemImage: "square.and.arrow.up.fill")
                            .font(.system(size: 18, weight: .heavy))
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(.ultraThinMaterial, in: Capsule())
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .navigationTitle(Text(loc.tr(.tile_listen)))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            recognizer.updateLocale(loc.currentLanguage.speechLocale)
            withAnimation(.easeInOut(duration: 0.8).repeatForever()) { pulse = true }
        }
        .onDisappear { recognizer.stop() }
        .sheet(isPresented: $presentingShare) {
            let full = sessionTranscript + (sessionTranscript.isEmpty ? "" : "\n") + recognizer.transcript
            ActivityShareSheet(items: [full])
        }
    }

    private func fontButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .heavy))
                .frame(width: 56, height: 56)
                .background(Circle().fill(.ultraThinMaterial))
                .foregroundStyle(.white)
        }
        .accessibilityLabel(Text(loc.tr(.listen_font_size)))
    }
}
