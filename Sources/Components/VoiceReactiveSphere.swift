import SwiftUI

/// 3D-feeling voice-reactive sphere used by the AI Companion screen.
///
/// We render a layered radial gradient with multiple offset blobs to fake depth,
/// plus orbiting particles and an audio-amplitude-driven scale. This avoids
/// shipping a heavy SceneKit/Metal scene while still feeling premium and futuristic.
struct VoiceReactiveSphere: View {

    /// 0…1 audio amplitude provided by the parent view.
    var amplitude: Double = 0.0
    /// True while AI is "thinking" — adds shimmering rings.
    var isThinking: Bool = false
    /// True while user is speaking — adds outward shockwaves.
    var isUserSpeaking: Bool = false
    /// True while AI is speaking — sphere pulsates faster.
    var isAISpeaking: Bool = false

    @State private var rotate: Double = 0
    @State private var morph: Double = 0

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let pulse = 1.0 + 0.06 * sin(t * (isAISpeaking ? 6.5 : 1.4))
            let amp = max(0.0, min(1.0, amplitude))
            let scale = pulse + amp * 0.18

            ZStack {
                // Outer glow
                Circle()
                    .fill(Theme.brandRed.opacity(0.25 + amp * 0.30))
                    .blur(radius: 50)
                    .scaleEffect(scale * 1.30)

                // Mid glow
                Circle()
                    .fill(Theme.brandPink.opacity(0.50))
                    .blur(radius: 24)
                    .scaleEffect(scale * 1.10)

                // Core sphere
                ZStack {
                    Circle()
                        .fill(Theme.sphereGradient)
                    Circle()
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                    // Highlight reflection
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.65), .clear],
                                center: .topLeading,
                                startRadius: 1, endRadius: 80
                            )
                        )
                        .blendMode(.plusLighter)
                        .opacity(0.9)
                }
                .scaleEffect(scale)

                // Orbital ring 1
                ringOverlay(rotation: t * 25, amp: amp, color: .white, opacity: 0.25)
                // Orbital ring 2 (perpendicular)
                ringOverlay(rotation: -t * 35 + 60, amp: amp, color: Theme.brandPink, opacity: 0.40)
                    .rotation3DEffect(.degrees(75), axis: (x: 1, y: 0, z: 0))
                // Orbital ring 3
                ringOverlay(rotation: t * 18 + 30, amp: amp, color: .white, opacity: 0.18)
                    .rotation3DEffect(.degrees(45), axis: (x: 0.6, y: 1, z: 0))

                if isThinking {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                            .scaleEffect(scale * (1.0 + Double(i) * 0.18 + 0.05 * sin(t * 2 + Double(i))))
                            .opacity(0.5 - Double(i) * 0.12)
                    }
                }

                if isUserSpeaking {
                    ForEach(0..<4, id: \.self) { i in
                        let phase = t * 1.2 - Double(i) * 0.4
                        let s = scale * (1.0 + 0.5 * (phase.truncatingRemainder(dividingBy: 1)))
                        Circle()
                            .stroke(Theme.brandRed.opacity(0.5 - 0.5 * (phase.truncatingRemainder(dividingBy: 1))), lineWidth: 2)
                            .scaleEffect(s)
                    }
                }
            }
        }
        .frame(width: 220, height: 220)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func ringOverlay(rotation: Double, amp: Double, color: Color, opacity: Double) -> some View {
        Capsule()
            .stroke(
                LinearGradient(
                    colors: [color.opacity(opacity), .clear],
                    startPoint: .leading, endPoint: .trailing
                ),
                lineWidth: 2
            )
            .frame(width: 280, height: 60)
            .rotationEffect(.degrees(rotation + amp * 30))
            .opacity(0.85)
            .blendMode(.screen)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VoiceReactiveSphere(amplitude: 0.3, isAISpeaking: true)
    }
}
