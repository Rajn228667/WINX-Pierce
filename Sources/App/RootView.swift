import SwiftUI

/// Root coordinator. Decides between Onboarding (first launch / no Ollama URL set)
/// and the main TabView/Home. Applies all global accessibility filters
/// (color-blind correction + blue-light/warm filter) at the very top of the
/// view tree so every screen inherits them.
struct RootView: View {

    @EnvironmentObject private var settings: SettingsStore
    @State private var showSplash: Bool = true

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            Group {
                if showSplash {
                    HelloSplashView { withAnimation { showSplash = false } }
                        .transition(.opacity)
                } else if !settings.hasCompletedOnboarding {
                    OnboardingView()
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    HomeView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.55), value: showSplash)
            .animation(.easeInOut(duration: 0.45), value: settings.hasCompletedOnboarding)
        }
        // Accessibility — these stack at the very top of the view tree so every
        // descendent (sheets, full-screen covers, modal dialogs) inherits them.
        .modifier(ColorblindFilter(mode: settings.colorblindMode))
        .modifier(WarmTintOverlay(intensity: settings.blueLightFilter))
    }
}

// MARK: - Accessibility filters

/// Approximates color-blindness corrections and the monochrome mode using
/// SwiftUI primitives that work on iOS 15+. Values are tuned so users
/// can clearly tell the modes apart while preserving the brand palette.
struct ColorblindFilter: ViewModifier {
    let mode: ColorblindMode

    func body(content: Content) -> some View {
        switch mode {
        case .none:
            content
        case .monochrome:
            content.saturation(0)
        case .protanopia:
            // Reduce red sensitivity → shift hue, drop saturation slightly
            content
                .hueRotation(.degrees(-12))
                .saturation(0.78)
        case .deuteranopia:
            // Reduce green sensitivity → shift hue toward blue, mute green
            content
                .hueRotation(.degrees(8))
                .saturation(0.74)
        case .tritanopia:
            // Reduce blue sensitivity → shift away from blue, slight desaturation
            content
                .hueRotation(.degrees(22))
                .saturation(0.82)
        }
    }
}

/// Warm-tint overlay (Night-Shift style). Intensity 0…0.6 — at 0 there is no
/// effect; at 0.6 the screen has a strong amber wash. Renders above all UI but
/// below presented sheets so user can always see what they tap.
struct WarmTintOverlay: ViewModifier {
    let intensity: Double
    func body(content: Content) -> some View {
        content
            .overlay(
                Color(red: 1.0, green: 0.66, blue: 0.30)
                    .opacity(min(0.6, max(0, intensity)))
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
            )
    }
}
