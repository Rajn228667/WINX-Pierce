import SwiftUI

/// Settings sheet where the user picks an AI provider and pastes the matching
/// API key (or Ollama tunnel URL). Used both inside Onboarding and as a
/// stand-alone sheet from the Accessibility Center.
struct AIProviderSettingsView: View {

    var showCloseButton: Bool = true

    @StateObject private var ai = AISettings.shared
    @EnvironmentObject private var loc: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    @State private var geminiKey: String = ""
    @State private var groqKey: String = ""
    @State private var ollamaURL: String = ""

    @State private var statusByProvider: [AIProvider: TestStatus] = [:]

    enum TestStatus: Equatable {
        case idle, testing, ok, fail(String)
    }

    var body: some View {
        let content = VStack(alignment: .leading, spacing: 18) {

            // Active-provider picker
            VStack(alignment: .leading, spacing: 8) {
                Text(loc.tr(.ai_settings_picker))
                    .font(.system(size: 16, weight: .heavy))
                providerPicker
            }

            // Per-provider key fields
            ForEach(AIProvider.allCases) { provider in
                providerCard(provider)
            }

            // Footnote
            Text(loc.tr(.ai_settings_footnote))
                .font(.footnote)
                .foregroundStyle(Theme.secondaryText)
                .padding(.top, 4)
        }
        .padding(.horizontal, 4)

        let scroll = ScrollView { content.padding(.vertical, 12) }

        if showCloseButton {
            NavigationStack {
                scroll
                    .navigationTitle(loc.tr(.ai_settings_title))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(loc.tr(.action_close)) { dismiss() }
                        }
                    }
            }
            .onAppear(perform: load)
            .onDisappear(perform: flush)
        } else {
            scroll
                .onAppear(perform: load)
                .onDisappear(perform: flush)
        }
    }

    /// Persist whatever the user typed so they don't lose the key if they
    /// leave the screen without pressing "Save & test".
    private func flush() {
        AISettings.shared.geminiKey = geminiKey.trimmingCharacters(in: .whitespaces)
        AISettings.shared.xaiKey    = groqKey.trimmingCharacters(in: .whitespaces)
        KeychainStore.ollamaBaseURL = ollamaURL.trimmingCharacters(in: .whitespaces)
    }

    // MARK: - Components

    private var providerPicker: some View {
        Picker(loc.tr(.ai_settings_picker), selection: $ai.provider) {
            ForEach(AIProvider.allCases) { p in
                Text(p.displayName).tag(p)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel(loc.tr(.ai_settings_picker))
    }

    private func providerCard(_ provider: AIProvider) -> some View {
        let status = statusByProvider[provider] ?? .idle
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: providerIcon(provider))
                    .font(.system(size: 22, weight: .bold))
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(providerColor(provider).opacity(0.18)))
                    .foregroundStyle(providerColor(provider))
                VStack(alignment: .leading, spacing: 2) {
                    Text(provider.displayName)
                        .font(.system(size: 17, weight: .heavy))
                    Text(provider.tagline)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.secondaryText)
                }
                Spacer()
                if ai.provider == provider {
                    Text(loc.tr(.ai_settings_active))
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Theme.accentEmerald.opacity(0.18)))
                        .foregroundStyle(Theme.accentEmerald)
                }
            }

            // Field per provider
            Group {
                switch provider {
                case .gemini:
                    keyField(binding: $geminiKey,
                             placeholder: "AIzaSy…",
                             keyboard: .asciiCapable)
                    helpLink(label: loc.tr(.ai_settings_get_gemini),
                             url: "https://aistudio.google.com/apikey")
                case .grok:
                    keyField(binding: $groqKey,
                             placeholder: "gsk_…",
                             keyboard: .asciiCapable)
                    helpLink(label: loc.tr(.ai_settings_get_groq),
                             url: "https://console.groq.com/keys")
                case .ollama:
                    keyField(binding: $ollamaURL,
                             placeholder: "https://….trycloudflare.com",
                             keyboard: .URL)
                    helpLink(label: loc.tr(.ai_settings_get_ollama),
                             url: "https://ollama.com/download")
                }
            }

            HStack(spacing: 10) {
                Button {
                    save(provider)
                    Task { await test(provider) }
                } label: {
                    Label(loc.tr(.ai_settings_save_test), systemImage: "checkmark.shield.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)

                if !fieldValue(for: provider).trimmingCharacters(in: .whitespaces).isEmpty {
                    Button(role: .destructive) {
                        clear(provider)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.bordered)
                }
            }

            statusBadge(status)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(ai.provider == provider ? Theme.accentEmerald.opacity(0.5) : .clear, lineWidth: 2)
        )
    }

    @ViewBuilder
    private func statusBadge(_ status: TestStatus) -> some View {
        switch status {
        case .idle: EmptyView()
        case .testing:
            HStack(spacing: 6) { ProgressView(); Text(loc.tr(.ai_settings_testing)) }
                .font(.caption)
                .foregroundStyle(Theme.secondaryText)
        case .ok:
            Label(loc.tr(.ai_settings_ok), systemImage: "checkmark.circle.fill")
                .font(.caption.bold())
                .foregroundStyle(Theme.accentEmerald)
        case .fail(let msg):
            Label(msg, systemImage: "exclamationmark.triangle.fill")
                .font(.caption)
                .foregroundStyle(Theme.accentRed)
        }
    }

    private func keyField(binding: Binding<String>,
                          placeholder: String,
                          keyboard: UIKeyboardType) -> some View {
        TextField(placeholder, text: binding)
            .textFieldStyle(.roundedBorder)
            .keyboardType(keyboard)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .font(.system(size: 15, weight: .medium, design: .monospaced))
    }

    private func helpLink(label: String, url: String) -> some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.right.square")
                Text(label).font(.footnote)
            }
            .foregroundStyle(Theme.accentBlue)
        }
    }

    // MARK: - Helpers

    private func load() {
        geminiKey = AISettings.shared.geminiKey ?? ""
        groqKey = AISettings.shared.xaiKey ?? ""
        ollamaURL = KeychainStore.ollamaBaseURL ?? ""
    }

    private func fieldValue(for provider: AIProvider) -> String {
        switch provider {
        case .gemini: return geminiKey
        case .grok:   return groqKey
        case .ollama: return ollamaURL
        }
    }

    private func save(_ provider: AIProvider) {
        let trimmed = fieldValue(for: provider).trimmingCharacters(in: .whitespaces)
        switch provider {
        case .gemini: AISettings.shared.geminiKey = trimmed
        case .grok:   AISettings.shared.xaiKey = trimmed
        case .ollama: KeychainStore.ollamaBaseURL = trimmed
        }
        ai.provider = provider
    }

    private func clear(_ provider: AIProvider) {
        switch provider {
        case .gemini:
            geminiKey = ""
            AISettings.shared.geminiKey = nil
        case .grok:
            groqKey = ""
            AISettings.shared.xaiKey = nil
        case .ollama:
            ollamaURL = ""
            KeychainStore.ollamaBaseURL = nil
        }
        statusByProvider[provider] = .idle
    }

    private func test(_ provider: AIProvider) async {
        statusByProvider[provider] = .testing
        let client: AIClient = {
            switch provider {
            case .gemini: return GeminiClient.shared
            case .grok:   return GroqClient.shared
            case .ollama: return OllamaClient.shared
            }
        }()
        let ok = await client.ping()
        statusByProvider[provider] = ok ? .ok : .fail(loc.tr(.ai_settings_no_response))
        if ok {
            VoiceSynthesizer.shared.speak(loc.tr(.ai_settings_connected))
            HapticManager.shared.success()
        } else {
            HapticManager.shared.warning()
        }
    }

    private func providerIcon(_ p: AIProvider) -> String {
        switch p {
        case .gemini: return "sparkles"
        case .grok:   return "bolt.fill"
        case .ollama: return "server.rack"
        }
    }

    private func providerColor(_ p: AIProvider) -> Color {
        switch p {
        case .gemini: return Theme.accentBlue
        case .grok:   return Theme.accentOrange
        case .ollama: return Theme.accentPurple
        }
    }
}
