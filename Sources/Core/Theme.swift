import SwiftUI

/// Centralised design tokens for WINX × Pierce.
/// All colours, gradients, corner radii and shadows live here so we can change the
/// look-and-feel in one place. Asset-catalog-backed colours are also exposed for
/// adaptive light/dark behaviour.
enum Theme {

    // MARK: - Brand colours

    static let brandRed: Color = Color(red: 0.92, green: 0.16, blue: 0.30)
    static let brandPink: Color = Color(red: 1.00, green: 0.49, blue: 0.62)

    // MARK: - Module accents (match Android tile top-bar colours)

    static let accentBlue: Color = Color(red: 0.20, green: 0.55, blue: 1.00)
    static let accentSky: Color = Color(red: 0.25, green: 0.78, blue: 1.00)
    static let accentOrange: Color = Color(red: 1.00, green: 0.62, blue: 0.20)
    static let accentPurple: Color = Color(red: 0.55, green: 0.40, blue: 1.00)
    static let accentGreen: Color = Color(red: 0.30, green: 0.80, blue: 0.45)
    static let accentEmerald: Color = Color(red: 0.10, green: 0.78, blue: 0.55)
    static let accentRed: Color = Color(red: 0.95, green: 0.30, blue: 0.30)
    static let accentYellow: Color = Color(red: 1.00, green: 0.78, blue: 0.20)

    // MARK: - Surfaces

    static var background: Color {
        Color(uiColor: .systemBackground)
    }
    static var elevatedBackground: Color {
        Color(uiColor: .secondarySystemBackground)
    }
    static var card: Color {
        Color(uiColor: .secondarySystemGroupedBackground)
    }

    // MARK: - Text

    static var primaryText: Color { Color(uiColor: .label) }
    static var secondaryText: Color { Color(uiColor: .secondaryLabel) }
    static var tertiaryText: Color { Color(uiColor: .tertiaryLabel) }

    // MARK: - Glassmorphism helpers

    static func glassFill(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color.white.opacity(0.06)
            : Color.white.opacity(0.55)
    }
    static func glassStroke(_ scheme: ColorScheme) -> Color {
        scheme == .dark
            ? Color.white.opacity(0.10)
            : Color.black.opacity(0.06)
    }

    // MARK: - Radii / spacing

    static let radiusSmall: CGFloat = 14
    static let radiusMedium: CGFloat = 22
    static let radiusLarge: CGFloat = 30
    static let radiusXLarge: CGFloat = 40

    static let paddingSmall: CGFloat = 10
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 24

    // MARK: - Shadows

    static func softShadow(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.black.opacity(0.5) : Color.black.opacity(0.10)
    }

    // MARK: - Hero gradient (matches the red AI Companion card)

    static let heroGradient = LinearGradient(
        colors: [
            Color(red: 0.96, green: 0.18, blue: 0.34),
            Color(red: 1.00, green: 0.40, blue: 0.55)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - AI Sphere gradient

    static let sphereGradient = RadialGradient(
        colors: [
            Color(red: 1.00, green: 0.80, blue: 0.85),
            Color(red: 0.95, green: 0.30, blue: 0.50),
            Color(red: 0.55, green: 0.10, blue: 0.30)
        ],
        center: .center,
        startRadius: 4,
        endRadius: 200
    )
}

// MARK: - View helpers

extension View {

    /// Glassmorphism background — subtle blur + thin border + soft shadow.
    func glassCard(
        cornerRadius: CGFloat = Theme.radiusLarge,
        intensity: CGFloat = 1.0
    ) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, intensity: intensity))
    }

    /// Apply a min-height accessibility-friendly hit target (Apple recommends ≥ 44pt;
    /// this app uses 64pt as a default for low-vision usability).
    func accessibleHitTarget(_ height: CGFloat = 64) -> some View {
        frame(minHeight: height)
    }
}

private struct GlassCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let intensity: CGFloat
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Theme.glassFill(scheme).opacity(Double(intensity)))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Theme.glassStroke(scheme), lineWidth: 1)
            )
            .shadow(color: Theme.softShadow(scheme), radius: 14, x: 0, y: 6)
    }
}
