import SwiftUI
import Vision
import AVFoundation

/// Currency recogniser. Takes a photo of a banknote and asks the multimodal model
/// to identify the denomination. Optimised for KZT but the model can recognise USD,
/// EUR, RUB and others by content.
struct CurrencyView: View {
    @StateObject private var vm = CurrencyViewModel()

    var body: some View {
        ZStack {
            CameraPreview(session: vm.camera.session)
                .ignoresSafeArea()
                .onAppear { vm.start() }
                .onDisappear { vm.stop() }

            VStack {
                Spacer()
                if !vm.lastResult.isEmpty {
                    Text(vm.lastResult)
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                        .padding()
                }
                Button {
                    Task { await vm.recognise() }
                } label: {
                    Label("Распознать купюру", systemImage: "banknote.fill")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Theme.accentOrange)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .padding()
            }
        }
    }
}

@MainActor
final class CurrencyViewModel: NSObject, ObservableObject {
    @Published var lastResult: String = ""
    let camera = CameraManager()
    private var lastBuffer: CMSampleBuffer?

    override init() {
        super.init()
        camera.configure(sampleDelegate: self)
    }
    func start() { camera.start() }
    func stop() { camera.stop() }

    func recognise() async {
        guard let buffer = lastBuffer, let jpeg = camera.snapshotJPEG(from: buffer) else { return }
        let prompt = "Это фотография банкноты. Определи валюту и номинал коротко, например: «1000 тенге» или «20 евро». Если не уверен — скажи «не вижу банкноту»."
        do {
            let reply = try await OllamaClient.shared.describeImage(base64JPEG: jpeg.base64EncodedString(), prompt: prompt)
            lastResult = reply
            VoiceSynthesizer.shared.speak(reply)
            HapticManager.shared.success()
        } catch {
            lastResult = "Не удалось распознать."
            VoiceSynthesizer.shared.speak(lastResult)
        }
    }
}

extension CurrencyViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput,
                                   didOutput sampleBuffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {
        Task { @MainActor in self.lastBuffer = sampleBuffer }
    }
}
