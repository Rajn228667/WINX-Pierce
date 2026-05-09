import SwiftUI

/// The brand header used at the top of every screen — matches the Android version:
/// small "WiNX × pierce" mark on the left, "WINX × pierce" wordmark, the
/// "При поддержке Pierce Industries" subtitle, and a rounded "Готов" status pill on
/// the right.
struct HeaderView: View {

    @EnvironmentObject private var loc: LocalizationManager
    var statusReady: Bool = true

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Brand mark
            VStack(spacing: 2) {
                Text("WiNX")
                    .font(.system(size: 12, weight: .black, design: .default))
                    .tracking(1.2)
                Text("pierce")
                    .font(.system(size: 9, weight: .medium, design: .default))
                    .tracking(1.0)
            }
            .frame(width: 40, height: 40)
            .foregroundStyle(Theme.primaryText)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Theme.elevatedBackground)
            )

            VStack(alignment: .leading, spacing: 2) {
                Text("WINX × pierce")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.primaryText)

                Text(loc.tr(.brand_subtitle))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer(minLength: 8)

            // Status pill
            HStack(spacing: 8) {
                Circle()
                    .fill(statusReady ? Theme.accentBlue : Theme.accentRed)
                    .frame(width: 8, height: 8)
                Text(loc.tr(.status_ready))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .stroke(Theme.glassStroke(.dark), lineWidth: 1)
                    .background(
                        Capsule().fill(.ultraThinMaterial)
                    )
            )
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("WINX × Pierce, " + loc.tr(.brand_subtitle))
    }
}

#Preview {
    VStack {
        HeaderView()
            .environmentObject(LocalizationManager.shared)
        Spacer()
    }
}
