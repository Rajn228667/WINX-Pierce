import AVFoundation
import UIKit
import SwiftUI
import Combine
import CoreImage

/// Owns the camera AVCaptureSession and forwards CMSampleBuffers to subscribers.
/// Supports Front/Back camera, torch, ultra-wide for low light and 5x telephoto
/// when available, and auto-zoom.
@MainActor
final class CameraManager: NSObject, ObservableObject {

    @Published private(set) var isAuthorized: Bool = false
    @Published private(set) var isRunning: Bool = false
    @Published var torchOn: Bool = false { didSet { setTorch(torchOn) } }
    @Published var zoom: CGFloat = 1.0 { didSet { setZoom(zoom) } }

    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "winx.camera.queue")
    private var videoOutput: AVCaptureVideoDataOutput?
    private var device: AVCaptureDevice?
    private weak var sampleDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?

    private(set) var maxZoom: CGFloat = 5
    private(set) var minZoom: CGFloat = 1

    func configure(sampleDelegate: AVCaptureVideoDataOutputSampleBufferDelegate? = nil) {
        self.sampleDelegate = sampleDelegate
        sessionQueue.async {
            self.configureSession()
        }
    }

    func start() {
        sessionQueue.async {
            if !self.session.isRunning { self.session.startRunning() }
            DispatchQueue.main.async { self.isRunning = self.session.isRunning }
        }
    }

    func stop() {
        sessionQueue.async {
            if self.session.isRunning { self.session.stopRunning() }
            DispatchQueue.main.async { self.isRunning = false }
        }
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .high

        for input in session.inputs { session.removeInput(input) }
        for output in session.outputs { session.removeOutput(output) }

        let device: AVCaptureDevice?
        if #available(iOS 13.0, *) {
            device = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back)
                ?? AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
                ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        } else {
            device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        }

        guard let device,
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        self.device = device
        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(sampleDelegate, queue: DispatchQueue(label: "winx.camera.frames"))
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.connection(with: .video)?.videoOrientation = .portrait
        }
        videoOutput = output

        if let device = self.device {
            DispatchQueue.main.async {
                self.maxZoom = min(device.activeFormat.videoMaxZoomFactor, 6)
                self.minZoom = 1
            }
        }
        session.commitConfiguration()

        DispatchQueue.main.async {
            self.isAuthorized = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
        }
    }

    // MARK: - Controls

    private func setTorch(_ on: Bool) {
        guard let device, device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }

    private func setZoom(_ value: CGFloat) {
        guard let device else { return }
        try? device.lockForConfiguration()
        let clamped = max(1.0, min(device.activeFormat.videoMaxZoomFactor, value))
        device.videoZoomFactor = clamped
        device.unlockForConfiguration()
    }

    // MARK: - Snapshot

    /// Take a JPEG snapshot from the current frame produced by the data-output.
    /// Returns nil if no frame has been received yet.
    func snapshotJPEG(from sampleBuffer: CMSampleBuffer, quality: CGFloat = 0.85) -> Data? {
        guard let pixel = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ci = CIImage(cvPixelBuffer: pixel)
        let context = CIContext()
        guard let cg = context.createCGImage(ci, from: ci.extent) else { return nil }
        let ui = UIImage(cgImage: cg, scale: 1, orientation: .up)
        return ui.jpegData(compressionQuality: quality)
    }
}

/// SwiftUI bridge — embeds an AVCaptureVideoPreviewLayer.
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let v = PreviewUIView()
        v.previewLayer.session = session
        v.previewLayer.videoGravity = .resizeAspectFill
        return v
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {
        uiView.previewLayer.session = session
    }

    final class PreviewUIView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}
