import SwiftUI

struct AICompanionView: View {

    @EnvironmentObject private var loc: LocalizationManager
    @StateObject private var vm = AICompanionViewModel()
    @State private var showHistory = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Theme.brandRed.opacity(0.18),
                    Theme.brandPink.opacity(0.10),
                    Theme.background
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer(minLength: 4)

                VoiceReactiveSphere(
                    amplitude: vm.amplitude,
                    isThinking: vm.isThinking,
                    isUserSpeaking: vm.isUserListening,
                    isAISpeaking: vm.isAISpeaking
                )
                .padding(.top, 24)

                // Status / partial text
                Group {
                    if vm.isUserListening {
                        Text(loc.tr(.ai_listening) + " " + vm.partialUserText)
                            .multilineTextAlignment(.center)
                    } else if vm.isThinking {
                        Text(loc.tr(.ai_thinking))
                    } else if vm.isAISpeaking {
                        Text(vm.lastAssistantReply)
                            .multilineTextAlignment(.center)
                    } else if !vm.lastAssistantReply.isEmpty {
                        Text(vm.lastAssistantReply)
                            .multilineTextAlignment(.center)
                    } else {
                        Text(loc.tr(.ai_say_hello))
                            .foregroundStyle(Theme.secondaryText)
                    }
                }
                .font(.system(size: 19, weight: .semibold, design: .rounded))
                .padding(.horizontal, 24)
                .frame(minHeight: 70)

                Spacer()

                // Big mic button
                Button(action: vm.togglePushToTalk) {
                    ZStack {
                        Circle()
                            .fill(vm.isUserListening ? Theme.accentRed : Theme.brandRed)
                            .frame(width: 132, height: 132)
                            .shadow(color: Theme.brandRed.opacity(0.6), radius: 24, x: 0, y: 0)
                        Image(systemName: vm.isUserListening ? "stop.fill" : "mic.fill")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .accessibilityLabel(Text(vm.isUserListening ? loc.tr(.action_stop) : loc.tr(.action_speak)))
                .padding(.bottom, 8)

                // Tertiary actions
                HStack(spacing: 14) {
                    actionPill(systemImage: "text.bubble", label: "История") {
                        showHistory.toggle()
                    }
                    actionPill(systemImage: "stop.circle", label: loc.tr(.action_stop)) {
                        vm.cancel()
                    }
                    actionPill(systemImage: "arrow.clockwise", label: loc.tr(.action_retry)) {
                        Task { await vm.regenerate() }
                    }
                }
                .padding(.bottom, 24)

                if !OllamaClient.shared.hasURL {
                    NoOllamaBanner()
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showHistory) {
            ConversationHistoryView(messages: vm.messages)
                .presentationDetents([.medium, .large])
        }
        .onAppear { vm.greet() }
        .onDisappear { vm.cancel() }
            .voiceGuide(.guide_ai_companion)
    }

    private func actionPill(systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(label)
            }
            .font(.system(size: 15, weight: .heavy, design: .rounded))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Capsule().fill(Theme.card))
            .overlay(Capsule().stroke(Color.primary.opacity(0.08)))
        }
        .buttonStyle(.plain)
    }
}

private struct NoOllamaBanner: View {
    @EnvironmentObject private var loc: LocalizationManager
    @State private var showSheet = false
    var body: some View {
        Button {
            showSheet = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "cloud.slash.fill")
                    .foregroundStyle(.white)
                VStack(alignment: .leading, spacing: 2) {
                    Text(loc.tr(.ai_no_url)).font(.system(size: 15, weight: .heavy))
                    Text(loc.tr(.err_ollama_offline)).font(.system(size: 12))
                }
                .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.white.opacity(0.7))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(colors: [Color.orange, Theme.accentRed], startPoint: .leading, endPoint: .trailing))
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showSheet) {
            NavigationStack { OllamaURLEditView() }
        }
    }
}

struct OllamaURLEditView: View {
    @State private var url: String = KeychainStore.ollamaBaseURL ?? ""
    @State private var status: String = ""
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Form {
            Section("Cloudflare-tunnel URL") {
                TextField("https://....trycloudflare.com", text: $url)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .keyboardType(.URL)
            }
            Section {
                Button("Сохранить и проверить") {
                    KeychainStore.ollamaBaseURL = url.trimmingCharacters(in: .whitespaces)
                    Task {
                        let ok = await OllamaClient.shared.ping()
                        status = ok ? "Связь установлена" : "Ollama не отвечает"
                        if ok { dismiss() }
                    }
                }
                if !status.isEmpty { Text(status).foregroundStyle(.secondary) }
            }
        }
        .navigationTitle("Ollama")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Закрыть") { dismiss() }
            }
        }
    }
}

private struct ConversationHistoryView: View {
    let messages: [OllamaClient.Message]
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(messages.enumerated()), id: \.offset) { _, msg in
                        VStack(alignment: msg.role == "user" ? .trailing : .leading, spacing: 4) {
                            Text(msg.role == "user" ? "Вы" : "Эдит").font(.caption).foregroundStyle(.secondary)
                            Text(msg.content)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 18).fill(msg.role == "user" ? Theme.accentBlue.opacity(0.18) : Theme.card))
                        }
                        .frame(maxWidth: .infinity, alignment: msg.role == "user" ? .trailing : .leading)
                    }
                }
                .padding()
            }
            .navigationTitle("Диалог")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
