import SwiftUI

/// Voice-only "lessons" — the user picks a topic, the LLM explains it like a tutor
/// step-by-step, narrated by the speech synthesizer. Each lesson keeps a short
/// memory so follow-up questions work.
struct LearningView: View {
    private let topics: [(String, String, Color)] = [
        ("Английский с нуля", "graduationcap.fill", Theme.accentBlue),
        ("Казахский язык", "globe.asia.australia.fill", Theme.accentEmerald),
        ("Безопасность дома", "shield.fill", Theme.brandRed),
        ("Финансы и кредиты", "creditcard.fill", Theme.accentOrange),
        ("Кулинария", "fork.knife", Theme.accentPurple),
        ("Здоровый сон", "moon.stars.fill", Theme.accentSky)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(Array(topics.enumerated()), id: \.offset) { _, topic in
                    NavigationLink(destination: LessonView(topic: topic.0, accent: topic.2)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: topic.1)
                                .font(.title)
                                .foregroundStyle(topic.2)
                            Text(topic.0)
                                .font(.system(size: 18, weight: .heavy, design: .rounded))
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(Theme.primaryText)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 140, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Theme.card))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle("Уроки голосом")
    }
}

struct LessonView: View {
    let topic: String
    let accent: Color
    @State private var transcript: String = ""
    @State private var loading: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(topic)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(accent)
                if loading { ProgressView() }
                Text(transcript)
                    .font(.system(size: 19 * SettingsStore.shared.textScale, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
            .padding()
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    Task { await startLesson() }
                } label: { Label("Начать", systemImage: "play.fill") }
                Button { VoiceSynthesizer.shared.speak(transcript) } label: { Label("Озвучить", systemImage: "speaker.wave.2.fill") }
                Button { VoiceSynthesizer.shared.stop() } label: { Label("Стоп", systemImage: "stop.fill") }
            }
        }
        .task { await startLesson() }
    }

    private func startLesson() async {
        loading = true
        defer { loading = false }
        let prompt = "Объясни простым языком, тёплым голосом, тему «\(topic)» как урок для незрячего человека. Дай 3 коротких пункта по 1-2 предложения."
        do {
            let reply = try await OllamaClient.shared.chat(
                model: Config.chatModel,
                messages: [
                    .init(role: "system", content: Config.companionSystemPrompt),
                    .init(role: "user", content: prompt)
                ],
                temperature: 0.5
            )
            transcript = reply
            VoiceSynthesizer.shared.speak(reply)
        } catch {
            transcript = "Не удалось получить урок. Проверьте подключение к нейросети."
            VoiceSynthesizer.shared.speak(transcript)
        }
    }
}
