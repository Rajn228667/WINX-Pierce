import SwiftUI

struct OnboardingView: View {

    @EnvironmentObject private var loc: LocalizationManager
    @EnvironmentObject private var settings: SettingsStore
    @State private var page: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            // Step indicator
            HStack(spacing: 6) {
                ForEach(0..<4) { i in
                    Capsule()
                        .fill(i <= page ? Theme.brandRed : Color.primary.opacity(0.15))
                        .frame(width: i == page ? 28 : 16, height: 6)
                        .animation(.spring(response: 0.4), value: page)
                }
            }
            .padding(.top, 10)

            TabView(selection: $page) {
                WelcomePage(onNext: next).tag(0)
                LanguagePage(onNext: next).tag(1)
                PermissionsPage(onNext: next).tag(2)
                OllamaSetupPage(onFinish: finish).tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxHeight: .infinity)

            HStack {
                if page > 0 {
                    Button(loc.tr(.action_close)) { withAnimation { page -= 1 } }
                        .padding()
                }
                Spacer()
                if page < 3 {
                    Button(loc.tr(.onb_continue)) { withAnimation { page += 1 } }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .padding()
                } else {
                    Button(loc.tr(.onb_finish)) { finish() }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .padding()
                }
            }
        }
        .padding(.horizontal, 4)
    }

    private func next() {
        withAnimation { page = min(3, page + 1) }
    }

    private func finish() {
        withAnimation {
            settings.hasCompletedOnboarding = true
        }
    }
}

// MARK: - Pages

private struct WelcomePage: View {
    let onNext: () -> Void
    @EnvironmentObject private var loc: LocalizationManager
    @State private var pulse = false
    var body: some View {
        VStack(spacing: 22) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Theme.brandRed.opacity(0.18))
                    .frame(width: 220, height: 220)
                    .blur(radius: 40)
                    .scaleEffect(pulse ? 1.1 : 0.9)
                Image("Logo")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundStyle(Theme.primaryText)
            }
            Text(loc.tr(.onb_welcome_title))
                .font(.system(size: 36, weight: .black, design: .rounded))
            Text(loc.tr(.onb_welcome_body))
                .font(.system(size: 18, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.secondaryText)
                .padding(.horizontal, 28)
            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { pulse = true }
            VoiceSynthesizer.shared.speak(loc.tr(.onb_welcome_body))
        }
    }
}

private struct LanguagePage: View {
    let onNext: () -> Void
    @EnvironmentObject private var loc: LocalizationManager
    @EnvironmentObject private var settings: SettingsStore
    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "globe")
                .resizable().scaledToFit().frame(width: 70, height: 70)
                .foregroundStyle(Theme.accentBlue)
            Text(loc.tr(.onb_lang_title))
                .font(.system(size: 28, weight: .heavy, design: .rounded))
            Text(loc.tr(.onb_lang_body))
                .font(.system(size: 16))
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: 12) {
                ForEach(AppLanguage.allCases) { lang in
                    Button {
                        settings.languageRaw = lang.raw
                        VoiceSynthesizer.shared.speak(lang.displayName, language: lang)
                    } label: {
                        HStack {
                            Text(lang.displayName)
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                            Spacer()
                            if settings.languageRaw == lang.raw {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.brandRed)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            Spacer()
        }
        .padding(.top)
    }
}

private struct PermissionsPage: View {
    let onNext: () -> Void
    @EnvironmentObject private var loc: LocalizationManager
    @StateObject private var perms = PermissionsManager.shared
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(loc.tr(.onb_perm_title))
                .font(.system(size: 28, weight: .heavy, design: .rounded))
            Text(loc.tr(.onb_perm_body))
                .foregroundStyle(Theme.secondaryText)

            row("camera.fill", loc.tr(.onb_perm_camera), perms.camera) {
                _ = await perms.requestCamera()
            }
            row("mic.fill", loc.tr(.onb_perm_mic), perms.microphone) {
                _ = await perms.requestMicrophone()
            }
            row("waveform", loc.tr(.onb_perm_speech), perms.speech) {
                _ = await perms.requestSpeech()
            }
            row("location.fill", loc.tr(.onb_perm_location), perms.location) {
                perms.requestLocation()
            }
            row("person.2.fill", loc.tr(.onb_perm_contacts), perms.contacts) {
                _ = await perms.requestContacts()
            }

            Spacer()
        }
        .padding()
    }

    @ViewBuilder
    private func row(_ icon: String, _ label: String, _ state: PermissionsManager.PermissionState, action: @escaping () async -> Void) -> some View {
        Button {
            Task { await action(); perms.refreshAll() }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .frame(width: 36, height: 36)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Theme.elevatedBackground))
                Text(label).font(.system(size: 16, weight: .semibold))
                Spacer()
                Image(systemName: state == .granted ? "checkmark.circle.fill" : "chevron.right")
                    .foregroundStyle(state == .granted ? Theme.accentEmerald : Theme.secondaryText)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
        }
        .buttonStyle(.plain)
    }
}

private struct OllamaSetupPage: View {
    let onFinish: () -> Void
    @EnvironmentObject private var loc: LocalizationManager
    @State private var url: String = KeychainStore.ollamaBaseURL ?? ""
    @State private var status: TestStatus = .idle

    enum TestStatus: Equatable {
        case idle, testing, ok, fail(String)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(loc.tr(.onb_ollama_title))
                .font(.system(size: 28, weight: .heavy, design: .rounded))
            Text(loc.tr(.onb_ollama_body))
                .foregroundStyle(Theme.secondaryText)

            TextField(loc.tr(.onb_ollama_placeholder), text: $url)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)

            HStack {
                Button(loc.tr(.onb_ollama_test)) {
                    Task { await test() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(url.trimmingCharacters(in: .whitespaces).isEmpty || status == .testing)
                Spacer()
                statusBadge
            }

            Button(loc.tr(.onb_ollama_skip)) { onFinish() }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 6)

            Spacer()
        }
        .padding()
        .onChange(of: url) { _ in status = .idle }
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch status {
        case .idle: EmptyView()
        case .testing: ProgressView()
        case .ok:
            HStack(spacing: 6) { Image(systemName: "checkmark.circle.fill"); Text("OK") }
                .foregroundStyle(Theme.accentEmerald)
        case .fail(let msg):
            Label(msg, systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(Theme.accentRed)
                .font(.caption)
        }
    }

    private func test() async {
        status = .testing
        KeychainStore.ollamaBaseURL = url.trimmingCharacters(in: .whitespaces)
        let ok = await OllamaClient.shared.ping()
        status = ok ? .ok : .fail("Ollama не отвечает")
        if ok {
            VoiceSynthesizer.shared.speak("Связь с нейросетью установлена.")
        }
    }
}
