import SwiftUI

/// Persistent "Голосовая команда" bar on the bottom of the home screen + a settings
/// gear button. Tapping the bar starts/stops voice control listening; the gear
/// opens the Accessibility Center.
struct BottomVoiceBar: View {

    @EnvironmentObject private var loc: LocalizationManager
    @EnvironmentObject private var voiceControl: VoiceControlEngine

    let onSettings: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: { voiceControl.toggle() }) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle().fill(Theme.accentBlue.opacity(0.18))
                            .frame(width: 44, height: 44)
                        Image(systemName: voiceControl.isListening ? "waveform" : "mic.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Theme.accentBlue)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(loc.tr(.voice_bar_title))
                            .font(.system(size: 17, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.primaryText)
                        Text(voiceControl.isListening
                             ? loc.tr(.action_listen)
                             : loc.tr(.voice_bar_subtitle))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.secondaryText)
                    }
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Theme.card)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            Button(action: onSettings) {
                ZStack {
                    Circle()
                        .stroke(Color.primary.opacity(0.10), lineWidth: 1)
                        .background(Circle().fill(Theme.card))
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Theme.primaryText)
                }
                .frame(width: 56, height: 56)
            }
            .accessibilityLabel(Text(loc.tr(.tile_accessibility)))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}
