import SwiftUI

/// Root coordinator. Decides between Onboarding (first launch / no Ollama URL set)
/// and the main TabView/Home.
struct RootView: View {

    @EnvironmentObject private var settings: SettingsStore
    @State private var showSplash: Bool = true

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            Group {
                if showSplash {
                    SplashView()
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
        .task {
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            withAnimation { showSplash = false }
        }
    }
}

// MARK: - Splash

struct SplashView: View {
    @State private var pulse: Bool = false
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Theme.brandRed.opacity(0.18),
                    Theme.brandPink.opacity(0.10),
                    Theme.background
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "sparkles")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 88)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.brandRed, Theme.brandPink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(pulse ? 1.08 : 0.92)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulse)

                Text("WINX × Pierce")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.primaryText)

                Text(Config.appSubtitle)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.secondaryText)
            }
        }
        .onAppear { pulse = true }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("WINX × Pierce. \(Config.appSubtitle)"))
    }
}
