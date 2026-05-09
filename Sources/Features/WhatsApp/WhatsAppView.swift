import SwiftUI
import Contacts
import UIKit

/// WhatsApp voice flow:
///   1. user picks a contact (from his contacts book — proper iOS picker),
///   2. records a voice message,
///   3. taps Send — we open WhatsApp pre-filled with the contact's phone number
///      AND share-sheet the recorded m4a so they can attach it in 1 tap.
///
/// iOS forbids 3rd-party apps from posting voice messages directly to WhatsApp's
/// chat history. We therefore use the official "Share with WhatsApp" pipeline.
struct WhatsAppView: View {

    @State private var pickedContact: ContactsLoader.PickedContact?
    @State private var showContacts: Bool = false
    @State private var showShare: Bool = false
    @StateObject private var recorder = VoiceRecorder()
    @State private var ackText: String = ""

    var body: some View {
        VStack(spacing: 18) {
            // Picked contact card
            Group {
                if let c = pickedContact {
                    HStack {
                        ZStack {
                            Circle().fill(Theme.accentEmerald.opacity(0.18)).frame(width: 56, height: 56)
                            Text(c.initials).font(.title2.bold()).foregroundStyle(Theme.accentEmerald)
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
                        Label("Выбрать контакт WhatsApp", systemImage: "person.crop.circle.badge.plus")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accentEmerald)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .padding(.horizontal)
                    }
                }
            }

            // Recorder
            VStack(spacing: 12) {
                Waveform(amplitude: recorder.amplitude, color: Theme.accentEmerald)
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
                            .background(Theme.accentEmerald)
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

            if let url = recorder.url, !recorder.isRecording {
                Button {
                    sendToWhatsApp()
                } label: {
                    Label("Отправить в WhatsApp", systemImage: "paperplane.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(colors: [Theme.accentEmerald, Color.green], startPoint: .leading, endPoint: .trailing))
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
                InlineContactsPickerView(accent: Theme.accentEmerald) { picked in
                    pickedContact = picked
                    showContacts = false
                }
                .navigationTitle("Контакты WhatsApp")
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

    private func sendToWhatsApp() {
        guard let contact = pickedContact, let _ = recorder.url else { return }

        // 1) Open the WhatsApp chat with that contact's phone number.
        let cleaned = contact.phone.filter { $0.isNumber || $0 == "+" }
        let chatURL = URL(string: "whatsapp://send?phone=\(cleaned)")!
        let canOpen = UIApplication.shared.canOpenURL(chatURL)

        // 2) Open share-sheet with the audio file. WhatsApp will appear as a target.
        // We do this *after* opening the chat — share-sheet wins focus, and tapping
        // WhatsApp inside it will attach the audio to the open conversation.
        if canOpen {
            UIApplication.shared.open(chatURL) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showShare = true
                    ackText = "Откройте WhatsApp, выберите его в меню «Поделиться» и нажмите «Отправить»."
                }
            }
        } else {
            ackText = "WhatsApp не установлен на этом устройстве."
        }
    }
}
