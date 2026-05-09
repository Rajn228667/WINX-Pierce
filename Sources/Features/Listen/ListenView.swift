import SwiftUI

/// Real-time speech-to-text — useful for hard-of-hearing users to "see" what
/// the person opposite them is saying. Big text, high contrast, and a copy/share button.
struct ListenView: View {

    @StateObject private var recognizer = SpeechRecognizer()

    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                Text(recognizer.transcript.isEmpty ? "Нажмите «Слушать» и попросите собеседника говорить ясно." : recognizer.transcript)
                    .font(.system(size: 28 * SettingsStore.shared.textScale, weight: .heavy, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
                    .padding(.horizontal)
            }

            HStack(spacing: 12) {
                Button {
                    if recognizer.isListening { recognizer.stop() }
                    else { try? recognizer.start() }
                } label: {
                    Label(recognizer.isListening ? "Стоп" : "Слушать",
                          systemImage: recognizer.isListening ? "stop.fill" : "ear")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(recognizer.isListening ? Theme.brandRed : Theme.accentOrange)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }

                Button {
                    UIPasteboard.general.string = recognizer.transcript
                    VoiceSynthesizer.shared.speak("Скопировано.")
                } label: {
                    Label("Копировать", systemImage: "doc.on.doc")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Theme.elevatedBackground)
                        .foregroundStyle(Theme.primaryText)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal)
        }
    }
}
