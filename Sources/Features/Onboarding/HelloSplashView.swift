import SwiftUI

/// Apple-style first-boot splash. Logo blooms in, then a sequence of
/// "Hello / Привет / Сәлем" greetings glides through, each one written
/// the way Apple does the iPhone setup screen — light strokes, soft fade.
/// On the very first launch the device-language greeting is also spoken aloud.
struct HelloSplashView: View {

    @EnvironmentObject private var settings: SettingsStore
    @EnvironmentObject private var loc: LocalizationManager

    /// Total time on screen.
    var duration: Double = 3.6

    var onFinished: () -> Void

    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.65
    @State private var greetIndex: Int = 0
    @State private var greetVisible: Bool = false
    @State private var hasSpoken: Bool = false

    /// Greetings shown in order. First one is the user's apparent language;
    /// the others rotate through the supported set so every user sees something
    /// they recognise (matches Apple's hello.app boot behaviour).
    private var greetings: [(String, AppLanguage)] {
        let primary = LocalizationManager.shared.currentLanguage
        var seq: [(String, AppLanguage)] = []
        let primaryGreet: (String, AppLanguage) = {
            switch primary {
            case .ru: return ("Привет", .ru)
            case .kk: return ("Сәлем", .kk)
            case .en: return ("Hello", .en)
            case .system:
                let pref = Locale.preferredLanguages.first ?? "en"
                if pref.hasPrefix("ru") { return ("Привет", .ru) }
                if pref.hasPrefix("kk") { return ("Сәлем", .kk) }
                return ("Hello", .en)
            }
        }()
        seq.append(primaryGreet)
        for pair in [("Hello", AppLanguage.en), ("Привет", AppLanguage.ru), ("Сәлем", AppLanguage.kk)]
        where pair.1 != primaryGreet.1 {
            seq.append(pair)
        }
        return seq
    }

    var body: some View {
        ZStack {
            // Background — soft gradient that mirrors Apple's setup wallpaper.
            LinearGradient(
                colors: [
                    Theme.background,
                    Theme.brandRed.opacity(0.10),
                    Theme.brandPink.opacity(0.06),
                    Theme.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 36) {
                Spacer()

                // Logo — fades in and scales out softly
                Image("Logo")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 168, height: 168)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.primaryText, Theme.brandRed.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Theme.brandRed.opacity(0.30), radius: 28, y: 14)
                    .opacity(logoOpacity)
                    .scaleEffect(logoScale)

                // Greeting — Apple-style cursive feel via .rounded heavy
                if greetIndex < greetings.count {
                    Text(greetings[greetIndex].0)
                        .font(.system(size: 64, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.primaryText)
                        .opacity(greetVisible ? 1 : 0)
                        .scaleEffect(greetVisible ? 1.0 : 0.92)
                        .id("hello-\(greetIndex)")
                        .transition(.opacity.combined(with: .scale))
                }

                Spacer()

                Text("WINX × Pierce")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(Theme.secondaryText)
                    .opacity(logoOpacity * 0.8)
                    .padding(.bottom, 32)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("WINX × Pierce. Hello."))
        .task { await runSequence() }
    }

    private func runSequence() async {
        // Logo bloom
        withAnimation(.easeOut(duration: 0.8)) {
            logoOpacity = 1
            logoScale = 1.0
        }

        // Speak the device-language hello aloud once (only on the very first launch)
        try? await Task.sleep(nanoseconds: 500_000_000)
        if !hasSpoken && !settings.hasCompletedOnboarding,
           let g = greetings.first {
            hasSpoken = true
            VoiceSynthesizer.shared.speak(g.0, language: g.1)
            HapticManager.shared.tap()
        }

        // Greeting sequence — primary first, then rotate through the others
        let perGreet = max(0.7, (duration - 0.8) / Double(greetings.count))
        for index in 0..<greetings.count {
            await MainActor.run {
                greetIndex = index
                withAnimation(.easeInOut(duration: 0.45)) { greetVisible = true }
            }
            try? await Task.sleep(nanoseconds: UInt64((perGreet * 0.7) * 1_000_000_000))
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.35)) { greetVisible = false }
            }
            try? await Task.sleep(nanoseconds: UInt64((perGreet * 0.3) * 1_000_000_000))
        }

        // Fade logo out
        await MainActor.run {
            withAnimation(.easeIn(duration: 0.4)) {
                logoOpacity = 0
                logoScale = 0.94
            }
        }
        try? await Task.sleep(nanoseconds: 420_000_000)
        await MainActor.run { onFinished() }
    }
}
