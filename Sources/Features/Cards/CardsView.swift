import SwiftUI

/// Phrase cards — for non-verbal users. Tap a card and it speaks the phrase loudly
/// with a strong haptic. Cards are grouped by category and editable.
struct CardsView: View {

    private let groups: [(String, Color, [String])] = [
        ("Срочно", Theme.brandRed, ["Помогите, пожалуйста!", "Мне больно.", "Вызовите скорую.", "Мне страшно."]),
        ("Я хочу", Theme.accentBlue, ["Воды.", "Поесть.", "Выйти на улицу.", "Позвонить близкому."]),
        ("Мне нужно", Theme.accentEmerald, ["Туалет.", "Лекарство.", "Помощь врача.", "Помощь полиции."]),
        ("Чувства", Theme.accentPurple, ["Мне грустно.", "Мне холодно.", "Мне жарко.", "Спасибо!"])
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                ForEach(Array(groups.enumerated()), id: \.offset) { _, group in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(group.0)
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundStyle(group.1)
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                            ForEach(group.2, id: \.self) { phrase in
                                Button {
                                    HapticManager.shared.successPattern()
                                    VoiceSynthesizer.shared.speak(phrase)
                                } label: {
                                    Text(phrase)
                                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity, minHeight: 92)
                                        .padding(8)
                                        .background(group.1.opacity(0.18))
                                        .foregroundStyle(group.1)
                                        .clipShape(RoundedRectangle(cornerRadius: 18))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Карточки фраз")
            .voiceGuide(.guide_cards)
    }
}
