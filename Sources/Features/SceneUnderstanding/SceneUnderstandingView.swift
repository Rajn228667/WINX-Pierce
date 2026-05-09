import SwiftUI
import AVFoundation

/// Continuously samples the camera, sends a frame to the multimodal model every
/// 6 seconds, and narrates the answer. Designed to be a hands-free "tell me what
/// you see" mode.
struct SceneUnderstandingView: View {
    @StateObject private var vm = SceneUnderstandingViewModel()

    var body: some View {
        ZStack {
            CameraPreview(session: vm.camera.session)
                .ignoresSafeArea()
                .onAppear { vm.start() }
                .onDisappear { vm.stop() }

            VStack {
                Spacer()
                if !vm.lastDescription.isEmpty {
                    Text(vm.lastDescription)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                        .padding()
                }
                HStack {
                    Toggle("Авто", isOn: $vm.autoDescribe)
                        .toggleStyle(.switch)
                        .tint(Theme.brandRed)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: Capsule())
                    Spacer()
                    Button {
                        Task { await vm.describeOnce() }
                    } label: {
                        Label("Опиши сейчас", systemImage: "sparkles")
                            .padding(.horizontal, 18).padding(.vertical, 12)
                            .background(Theme.brandRed)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                .padding()
            }
        }
    }
}

@MainActor
final class SceneUnderstandingViewModel: NSObject, ObservableObject {

    @Published var lastDescription: String = ""
    @Published var autoDescribe: Bool = true
    let camera = CameraManager()

    private var lastBuffer: CMSampleBuffer?
    private var timer: Timer?
    private var inFlight: Bool = false

    override init() {
        super.init()
        camera.configure(sampleDelegate: self)
    }

    func start() {
        camera.start()
        timer = Timer.scheduledTimer(withTimeInterval: 7.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.autoDescribe, !self.inFlight else { return }
                await self.describeOnce()
            }
        }
    }

    func stop() {
        camera.stop()
        timer?.invalidate()
        timer = nil
        VoiceSynthesizer.shared.stop()
    }

    func describeOnce() async {
        guard !inFlight, let buffer = lastBuffer else { return }
        inFlight = true
        defer { inFlight = false }
        guard let jpeg = camera.snapshotJPEG(from: buffer) else { return }
        let prompt: String
        switch LocalizationManager.shared.currentLanguage {
        case .ru, .system: prompt = "Опиши, что я вижу, как другу. Коротко, тёплым тоном, до 3 предложений. Только важное."
        case .kk: prompt = "Менің не көріп тұрғанымды досқа айтып бергендей сипатта. Қысқа, жылы дауыспен, 3 сөйлемге дейін."
        case .en: prompt = "Describe what I see as if to a friend. Short, warm tone, up to 3 sentences."
        }
        do {
            let reply = try await OllamaClient.shared.describeImage(base64JPEG: jpeg.base64EncodedString(), prompt: prompt)
            lastDescription = reply
            VoiceSynthesizer.shared.speak(reply)
        } catch {
            // silent — try again next tick
        }
    }
}

extension SceneUnderstandingViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput,
                                   didOutput sampleBuffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {
        Task { @MainActor in self.lastBuffer = sampleBuffer }
    }
}
