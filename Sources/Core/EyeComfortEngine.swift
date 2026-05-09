import SwiftUI
import UIKit

/// Live-updating engine that tweaks UI brightness, blue-light filter and contrast
/// based on the user's preferences and the ambient brightness.
/// Exposes published values that views can apply via `.colorMultiply` /
/// `.brightness` / overlays.
@MainActor
final class EyeComfortEngine: ObservableObject {

    static let shared = EyeComfortEngine()

    @Published var blueLightStrength: Double = 0.0      // 0…0.6
    @Published var contrastBoost: Double = 0.0          // 0…0.5
    @Published var dimming: Double = 0.0                // 0…0.4
    @Published var adaptiveAuto: Bool = true

    private var ambientTimer: Timer?

    private init() {}

    func applySaved() {
        blueLightStrength = SettingsStore.shared.blueLightFilter
        if SettingsStore.shared.highContrast { contrastBoost = 0.30 } else { contrastBoost = 0 }
        if adaptiveAuto { startAmbientPolling() }
    }

    func startAmbientPolling() {
        ambientTimer?.invalidate()
        ambientTimer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tickAmbient() }
        }
        tickAmbient()
    }

    func stopAmbientPolling() {
        ambientTimer?.invalidate()
        ambientTimer = nil
    }

    /// Use the system's screen brightness as a proxy for ambient light.
    /// Lower screen brightness → user is in a dark environment → reduce dimming, ease contrast.
    private func tickAmbient() {
        let screenBrightness = Double(UIScreen.main.brightness) // 0…1
        if adaptiveAuto {
            // Bright environment: more contrast, less blue light.
            // Dark environment: less contrast (so it's easier on eyes), keep blue light.
            let target: Double = screenBrightness < 0.3 ? 0.10 : 0.25
            withAnimation(.easeInOut(duration: 0.6)) {
                contrastBoost = max(SettingsStore.shared.highContrast ? 0.30 : 0, target)
            }
        }
    }
}

// MARK: - Modifier

struct EyeComfortOverlay: ViewModifier {
    @ObservedObject var engine: EyeComfortEngine = .shared

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .center) {
                if engine.blueLightStrength > 0.01 {
                    Color.orange
                        .opacity(engine.blueLightStrength * 0.35)
                        .blendMode(.multiply)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .saturation(1.0 + engine.contrastBoost * 0.5)
            .contrast(1.0 + engine.contrastBoost)
    }
}

extension View {
    func eyeComfortOverlay() -> some View { modifier(EyeComfortOverlay()) }
}
