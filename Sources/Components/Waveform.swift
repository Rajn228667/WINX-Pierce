import SwiftUI

/// Lightweight 32-bar audio waveform that pulses with the current input amplitude.
struct Waveform: View {
    var amplitude: Double = 0.0
    var color: Color = Theme.brandRed
    @State private var phase: Double = 0

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            HStack(spacing: 4) {
                ForEach(0..<32, id: \.self) { i in
                    let phase = t * 4 + Double(i) * 0.3
                    let h = (sin(phase) * 0.5 + 0.5) * (0.20 + amplitude * 0.80)
                    Capsule()
                        .fill(color)
                        .frame(width: 4, height: max(6, CGFloat(h) * 60))
                }
            }
            .frame(height: 60)
            .opacity(0.85)
        }
        .accessibilityHidden(true)
    }
}
