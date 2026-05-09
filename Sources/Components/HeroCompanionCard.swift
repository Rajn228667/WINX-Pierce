import SwiftUI

/// The big red AI-Companion hero card on the home screen.
struct HeroCompanionCard: View {

    @EnvironmentObject private var loc: LocalizationManager
    @State private var animate: Bool = false

    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background gradient
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Theme.heroGradient)

                // Decorative bubbles (subtle "design language" detail)
                Circle()
                    .fill(Color.white.opacity(0.10))
                    .frame(width: 220, height: 220)
                    .offset(x: 130, y: -90)
                Circle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 320, height: 320)
                    .offset(x: 170, y: 160)

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white.opacity(0.18))
                            Image(systemName: "sparkles")
                                .resizable()
                                .scaledToFit()
                                .padding(11)
                                .foregroundStyle(Color.white)
                        }
                        .frame(width: 52, height: 52)
                        .scaleEffect(animate ? 1.04 : 0.96)

                        Spacer()

                        Text("AI · OLLAMA")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .tracking(2.0)
                            .foregroundStyle(Color.white.opacity(0.85))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule().fill(Color.white.opacity(0.18))
                            )
                    }

                    Text(loc.tr(.tile_ai_companion))
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundStyle(Color.white)
                        .padding(.top, 6)

                    Text(loc.tr(.tile_ai_companion_subtitle))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.95))
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)

                    HStack {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text(loc.tr(.ai_speak_to_me))
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                    }
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        Capsule().fill(Color.white.opacity(0.20))
                    )
                    .padding(.top, 6)
                }
                .padding(20)
            }
            .frame(maxWidth: .infinity, minHeight: 280, alignment: .topLeading)
            .shadow(color: Theme.brandRed.opacity(0.35), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(loc.tr(.tile_ai_companion))
        .accessibilityHint(loc.tr(.tile_ai_companion_subtitle))
    }
}
