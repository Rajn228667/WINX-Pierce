import SwiftUI
import Contacts
import UIKit

/// Telegram voice flow — same UX as WhatsApp but uses Telegram's URL scheme.
/// We support two routes:
///   • If the contact has a known phone, we open `tg://resolve?phone=<digits>`.
///   • Otherwise we fall back to share-sheet only and the user picks the chat
///     manually inside Telegram.
struct TelegramView: View {

    @State private var pickedContact: ContactsLoader.PickedContact?
    @State private var showContacts: Bool = false
    @State private var showShare: Bool = false
    @StateObject private var recorder = VoiceRecorder()
    @State private var ackText: String = ""

    var body: some View {
        VStack(spacing: 18) {
            Group {
                if let c = pickedContact {
                    HStack {
                        ZStack {
                            Circle().fill(Theme.accentBlue.opacity(0.18)).frame(width: 56, height: 56)
                            Text(c.initials).font(.title2.bold()).foregroundStyle(Theme.accentBlue)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(c.displayName).font(.title3.bold())
                            Text(c.phone).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("Заменить") { showContacts = true }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
                    .padding(.horizontal)
                } else {
                    Button {
                        showContacts = true
                    } label: {
                        Label("Выбрать контакт Telegram", systemImage: "paperplane.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accentBlue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .padding(.horizontal)
                    }
                }
            }

            VStack(spacing: 12) {
                Waveform(amplitude: recorder.amplitude, color: Theme.accentBlue)
                    .frame(height: 60)
                    .opacity(recorder.isRecording ? 1 : 0.35)

                Text(timeString(recorder.elapsed))
                    .font(.system(size: 36, weight: .black, design: .rounded))

                if !recorder.isRecording {
                    Button {
                        recorder.start()
                    } label: {
                        Label("Записать голосовое", systemImage: "mic.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accentBlue)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                } else {
                    HStack(spacing: 12) {
                        Button {
                            recorder.cancel()
                        } label: {
                            Label("Отменить", systemImage: "xmark")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Theme.elevatedBackground)
                                .foregroundStyle(Theme.primaryText)
                                .clipShape(Capsule())
                        }
                        Button {
                            _ = recorder.stop()
                            HapticManager.shared.success()
                        } label: {
                            Label("Готово", systemImage: "stop.fill")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Theme.brandRed)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 22).fill(Theme.card))
            .padding(.horizontal)

            if let _ = recorder.url, !recorder.isRecording {
                Button {
                    sendToTelegram()
                } label: {
                    Label("Отправить в Telegram", systemImage: "paperplane.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(colors: [Theme.accentBlue, Theme.accentSky], startPoint: .leading, endPoint: .trailing))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal)
                .disabled(pickedContact == nil)
                .opacity(pickedContact == nil ? 0.6 : 1)
            }

            if !ackText.isEmpty {
                Text(ackText).font(.callout).foregroundStyle(.secondary).padding(.horizontal)
            }

            Spacer()
        }
        .padding(.top)
        .sheet(isPresented: $showContacts) {
            NavigationStack {
                InlineContactsPickerView(accent: Theme.accentBlue) { picked in
                    pickedContact = picked
                    showContacts = false
                }
                .navigationTitle("Контакты Telegram")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .sheet(isPresented: $showShare) {
            if let url = recorder.url {
                ActivityShareSheet(items: [url])
            }
        }
    }

    private func timeString(_ t: TimeInterval) -> String {
        String(format: "%02d:%02d", Int(t) / 60, Int(t) % 60)
    }

    private func sendToTelegram() {
        guard let contact = pickedContact else { return }

        // 1) Try to open the Telegram chat with that phone (works only if the
        //    contact has registered with that number on Telegram).
        let digits = contact.phone.filter { $0.isNumber }
        let resolveURL = URL(string: "tg://resolve?phone=\(digits)")!

        if UIApplication.shared.canOpenURL(resolveURL) {
            UIApplication.shared.open(resolveURL) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showShare = true
                    ackText = "В Telegram откроется чат. В меню «Поделиться» выберите Telegram и подтвердите отправку."
                }
            }
        } else if UIApplication.shared.canOpenURL(URL(string: "tg://")!) {
            // Telegram is installed but the contact isn't reachable directly:
            // open Telegram and let the user pick the recipient via share-sheet.
            UIApplication.shared.open(URL(string: "tg://")!) { _ in
                showShare = true
                ackText = "Выберите чат в Telegram и подтвердите отправку голосового сообщения."
            }
        } else {
            ackText = "Telegram не установлен на этом устройстве."
        }
    }
}
