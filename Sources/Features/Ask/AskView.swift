import SwiftUI

/// Quick "ask anything" card — single-shot Q&A without conversation history.
/// Useful when the user just wants the time, the weather, or a fact.
struct AskView: View {

    @StateObject private var recognizer = SpeechRecognizer()
    @State private var prompt: String = ""
    @State private var answer: String = ""
    @State private var loading: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Спросите что угодно")
                .font(.system(size: 26, weight: .heavy, design: .rounded))

            HStack {
                TextField("Например: какая сейчас погода?", text: $prompt, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)
                Button {
                    if recognizer.isListening {
                        recognizer.stop()
                        prompt = recognizer.transcript
                    } else {
                        try? recognizer.start()
                    }
                } label: {
                    Image(systemName: recognizer.isListening ? "stop.fill" : "mic.fill")
                        .font(.title2)
                        .padding(10)
                        .background(recognizer.isListening ? Theme.brandRed : Theme.accentPurple)
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)

            Button {
                Task { await ask() }
            } label: {
                if loading {
                    ProgressView().padding()
                } else {
                    Label("Ответить", systemImage: "sparkles")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Theme.brandRed)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal)
            .disabled(loading || prompt.trimmingCharacters(in: .whitespaces).isEmpty)

            if !answer.isEmpty {
                ScrollView {
                    Text(answer)
                        .font(.system(size: 19 * SettingsStore.shared.textScale, weight: .medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
                        .padding(.horizontal)
                }
                Button {
                    VoiceSynthesizer.shared.speak(answer)
                } label: {
                    Label("Озвучить", systemImage: "speaker.wave.2.fill")
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(Theme.accentBlue.opacity(0.18))
                        .foregroundStyle(Theme.accentBlue)
                        .clipShape(Capsule())
                }
            }
            Spacer()
        }
        .padding(.top)
        .onChange(of: recognizer.transcript) { newValue in
            prompt = newValue
        }
    }

    private func ask() async {
        loading = true
        defer { loading = false }
        do {
            let reply = try await OllamaClient.shared.chat(
                model: Config.fastModel,
                messages: [
                    .init(role: "system", content: "Отвечай коротко, по делу, тёплым голосом, на том же языке, что и вопрос."),
                    .init(role: "user", content: prompt)
                ],
                temperature: 0.5
            )
            answer = reply
            VoiceSynthesizer.shared.speak(reply)
        } catch {
            answer = "Не удалось получить ответ. Проверьте туннель Ollama."
            VoiceSynthesizer.shared.speak(answer)
        }
    }
}
