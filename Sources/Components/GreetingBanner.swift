import SwiftUI

/// Time-of-day greeting banner — mirrors the Android HomeScreen header.
/// Shows "Good morning / afternoon / evening / night" + a one-line subtitle in
/// the user's selected language. Uses SF Symbols (no emoji).
struct GreetingBanner: View {

    @EnvironmentObject private var loc: LocalizationManager

    var body: some View {
        let phase = currentPhase()
        HStack(spacing: 14) {
            Image(systemName: phase.icon)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(
                    Circle().fill(phase.color.opacity(0.92))
                )
            VStack(alignment: .leading, spacing: 3) {
                Text(loc.tr(phase.titleKey))
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.primaryText)
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusMedium, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusMedium, style: .continuous)
                .stroke(phase.color.opacity(0.35), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(loc.tr(phase.titleKey)). \(subtitle)"))
    }

    // MARK: - Phase

    private struct Phase {
        let titleKey: LocalKey
        let icon: String
        let color: Color
    }

    private func currentPhase() -> Phase {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12:
            return Phase(titleKey: .greeting_morning, icon: "sunrise.fill", color: Theme.accentOrange)
        case 12..<17:
            return Phase(titleKey: .greeting_day, icon: "sun.max.fill", color: Theme.accentYellow)
        case 17..<22:
            return Phase(titleKey: .greeting_evening, icon: "sunset.fill", color: Theme.accentPurple)
        default:
            return Phase(titleKey: .greeting_night, icon: "moon.stars.fill", color: Theme.accentBlue)
        }
    }

    private var subtitle: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: loc.currentLanguage.speechLocale)
        f.dateStyle = .full
        f.timeStyle = .short
        return f.string(from: Date())
    }
}
