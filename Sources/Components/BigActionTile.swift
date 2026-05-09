import SwiftUI

/// Large, accessibility-friendly home tile with a top accent bar, an SF Symbol on
/// a tinted square, a title and a subtitle — a direct iOS analogue of the Android
/// app's grid items, but using SF Symbols (no emoji) and glassmorphism.
struct BigActionTile<Destination: View>: View {

    let titleKey: LocalKey
    let subtitleKey: LocalKey
    let systemImage: String
    let accent: Color
    let destination: () -> Destination

    @EnvironmentObject private var loc: LocalizationManager
    @EnvironmentObject private var settings: SettingsStore
    @State private var pressed: Bool = false

    var body: some View {
        NavigationLink {
            destination()
                .navigationTitle(Text(loc.tr(titleKey)))
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            tileContent
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(loc.tr(titleKey)))
        .accessibilityHint(Text(loc.tr(subtitleKey)))
    }

    private var tileContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Top accent bar (matches Android colored tile-cap)
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(accent)
                .frame(maxWidth: .infinity)
                .frame(height: 6)

            // Icon block
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(accent.opacity(0.15))
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .padding(14)
                    .foregroundStyle(accent)
            }
            .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 4) {
                Text(loc.tr(titleKey))
                    .font(.system(size: 22, weight: settings.boldText ? .heavy : .bold, design: .rounded))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                Text(loc.tr(subtitleKey))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 200, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: Theme.radiusLarge, style: .continuous)
                .fill(Theme.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusLarge, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
        .scaleEffect(pressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: pressed)
        .onLongPressGesture(minimumDuration: 0, pressing: { p in
            pressed = p
            if p { HapticManager.shared.tap() }
        }, perform: {})
    }
}
