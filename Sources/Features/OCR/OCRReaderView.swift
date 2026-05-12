import SwiftUI
import Vision
import AVFoundation

struct OCRReaderView: View {

    @StateObject private var vm = OCRReaderViewModel()
    @EnvironmentObject private var loc: LocalizationManager

    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .topTrailing) {
                CameraPreview(session: vm.camera.session)
                    .frame(height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Theme.brandRed.opacity(vm.scanning ? 1 : 0.3), lineWidth: 3)
                    )

                if vm.scanning {
                    ProgressView()
                        .padding()
                        .background(.ultraThinMaterial, in: Circle())
                        .padding()
                }
            }
            .padding(.horizontal)
            .onAppear { vm.start() }
            .onDisappear { vm.stop() }

            HStack(spacing: 12) {
                Button {
                    Task { await vm.scanFrame() }
                } label: {
                    Label(loc.tr(.action_speak), systemImage: "doc.text.viewfinder")
                        .padding(.horizontal, 14).padding(.vertical, 12)
                        .background(Theme.accentBlue.opacity(0.15))
                        .foregroundStyle(Theme.accentBlue)
                        .clipShape(Capsule())
                }
                Button {
                    vm.summarize()
                } label: {
                    Label(loc.tr(.ocr_summary), systemImage: "text.append")
                        .padding(.horizontal, 14).padding(.vertical, 12)
                        .background(Theme.accentPurple.opacity(0.15))
                        .foregroundStyle(Theme.accentPurple)
                        .clipShape(Capsule())
                }
                Button {
                    vm.translate()
                } label: {
                    Label(loc.tr(.ocr_translate), systemImage: "translate")
                        .padding(.horizontal, 14).padding(.vertical, 12)
                        .background(Theme.accentEmerald.opacity(0.15))
                        .foregroundStyle(Theme.accentEmerald)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal)

            ScrollView {
                Text(vm.recognizedText.isEmpty ? loc.tr(.ocr_no_text) : vm.recognizedText)
                    .font(.system(size: 22 * SettingsStore.shared.textScale, weight: .medium, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
                    .padding(.horizontal)
            }

            HStack {
                Button {
                    VoiceSynthesizer.shared.speak(vm.recognizedText)
                } label: {
                    Label(loc.tr(.action_replay), systemImage: "speaker.wave.3.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.brandRed)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                Button {
                    VoiceSynthesizer.shared.stop()
                } label: {
                    Label(loc.tr(.action_stop), systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.elevatedBackground)
                        .foregroundStyle(Theme.primaryText)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal).padding(.bottom)
        }
            .voiceGuide(.guide_ocr)
    }
}
