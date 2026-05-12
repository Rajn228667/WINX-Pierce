import AVFoundation
import Vision
import CoreImage
import UIKit

/// Frame analyser that mirrors the Android `ObstacleAnalyzer`.
///
/// We use Apple's Vision framework. Specifically `VNGenerateObjectnessBasedSaliencyImageRequest`
/// — a model trained to highlight "object-like" regions in a photo. It runs
/// entirely on-device, in real time, with no entitlements or downloads
/// required. The output is a small set of bounding boxes; we pick the one with
/// the greatest area and decide where it lives (left / center / right) and
/// whether it's close enough to count as an obstacle.
///
/// The analyser also samples luminance to decide when the camera is effectively
/// blind (lights off, lens covered) and emits a `tooDark` snapshot.
final class ObstacleAnalyzer: NSObject, @unchecked Sendable {

    private let processQueue = DispatchQueue(label: "winx.locator.analyzer", qos: .userInitiated)
    private let inFlightLock = NSLock()
    private var inFlight: Bool = false
    private let onSnapshot: (ObstacleSnapshot) -> Void

    /// Minimum normalised area of the salient region to be considered an obstacle.
    private let proximityThreshold: Double

    /// Smallest sample mean luminance (0–255) we'll still trust.
    private let darknessThreshold: Double = 18.0

    init(proximityThreshold: Double = 0.10,
         onSnapshot: @escaping (ObstacleSnapshot) -> Void) {
        self.proximityThreshold = proximityThreshold
        self.onSnapshot = onSnapshot
    }

    /// Public hook for the camera delegate. Drops frames if a previous analysis
    /// is still in flight so the queue never backs up.
    func analyze(pixelBuffer: CVPixelBuffer) {
        // One-in-flight policy.
        inFlightLock.lock()
        if inFlight {
            inFlightLock.unlock()
            return
        }
        inFlight = true
        inFlightLock.unlock()

        processQueue.async {
            defer {
                self.inFlightLock.lock()
                self.inFlight = false
                self.inFlightLock.unlock()
            }

            // Brightness probe first — cheap, lets us short-circuit before paying
            // for the Vision request.
            if self.isTooDark(pixelBuffer: pixelBuffer) {
                self.deliver(ObstacleSnapshot(zone: .none, proximity: 0, centroidX: 0.5, tooDark: true))
                return
            }

            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])

            let request = VNGenerateObjectnessBasedSaliencyImageRequest { [weak self] req, error in
                guard let self else { return }
                guard error == nil, let result = req.results?.first as? VNSaliencyImageObservation else {
                    self.deliver(.clear)
                    return
                }
                self.handle(observation: result)
            }
            // Limit detections so we don't waste time on tiny noise.
            request.revision = VNGenerateObjectnessBasedSaliencyImageRequestRevision1

            do {
                try handler.perform([request])
            } catch {
                self.deliver(.clear)
            }
        }
    }

    /// Async overload — same logic, returns the snapshot directly. Useful for
    /// tests and for the `Walking` HUD which polls on its own schedule.
    func analyzeOnce(pixelBuffer: CVPixelBuffer) async -> ObstacleSnapshot {
        await withCheckedContinuation { continuation in
            if isTooDark(pixelBuffer: pixelBuffer) {
                continuation.resume(returning: ObstacleSnapshot(zone: .none, proximity: 0, centroidX: 0.5, tooDark: true))
                return
            }
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
            let request = VNGenerateObjectnessBasedSaliencyImageRequest { req, _ in
                guard let result = req.results?.first as? VNSaliencyImageObservation else {
                    continuation.resume(returning: .clear)
                    return
                }
                let snap = Self.snapshot(from: result, proximityThreshold: self.proximityThreshold)
                continuation.resume(returning: snap)
            }
            request.revision = VNGenerateObjectnessBasedSaliencyImageRequestRevision1
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: .clear)
            }
        }
    }

    // MARK: - Internals

    private func handle(observation: VNSaliencyImageObservation) {
        let snap = Self.snapshot(from: observation, proximityThreshold: proximityThreshold)
        deliver(snap)
    }

    private func deliver(_ snap: ObstacleSnapshot) {
        DispatchQueue.main.async { self.onSnapshot(snap) }
    }

    /// Translate a Vision saliency observation into our `ObstacleSnapshot`
    /// using the same 3-zone, area-priority logic as the Android port.
    private static func snapshot(from observation: VNSaliencyImageObservation,
                                 proximityThreshold: Double) -> ObstacleSnapshot {
        // `salientObjects` returns rectangles in normalised image coordinates
        // (0…1, origin bottom-left in Vision's convention).
        guard let objects = observation.salientObjects, !objects.isEmpty else {
            return .clear
        }

        // Find the largest rectangle.
        var bestArea: Double = 0
        var bestRect: CGRect = .zero
        for obj in objects {
            let r = obj.boundingBox
            let area = Double(r.width * r.height)
            if area > bestArea {
                bestArea = area
                bestRect = r
            }
        }

        guard bestArea >= proximityThreshold else {
            return ObstacleSnapshot(zone: .none, proximity: bestArea, centroidX: 0.5, tooDark: false)
        }

        let centerX = Double(bestRect.midX) // 0…1, 0 = left edge
        // Three vertical thirds — same scheme as the Android analyser.
        let zone: ObstacleSnapshot.Zone
        switch centerX {
        case ..<0.33: zone = .left
        case ..<0.67: zone = .center
        default:      zone = .right
        }

        return ObstacleSnapshot(zone: zone,
                                proximity: min(max(bestArea, 0), 1),
                                centroidX: min(max(centerX, 0), 1),
                                tooDark: false)
    }

    /// Sample N evenly spaced pixels from the Y (luma) plane of the buffer and
    /// return true if their mean falls below the darkness threshold. Works for
    /// both YpCbCr and BGRA buffers — for BGRA we approximate luma from green.
    private func isTooDark(pixelBuffer: CVPixelBuffer) -> Bool {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
        let format = CVPixelBufferGetPixelFormatType(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let sampleCount = 200
        switch format {
        case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
             kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
            guard let base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0) else { return false }
            let bpr = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0)
            let total = bpr * height
            if total < sampleCount { return false }
            let step = total / sampleCount
            var sum = 0
            var n = 0
            var pos = 0
            let ptr = base.assumingMemoryBound(to: UInt8.self)
            while n < sampleCount && pos < total {
                sum += Int(ptr[pos])
                pos += step
                n += 1
            }
            let mean = Double(sum) / Double(max(n, 1))
            return mean < darknessThreshold
        case kCVPixelFormatType_32BGRA:
            guard let base = CVPixelBufferGetBaseAddress(pixelBuffer) else { return false }
            let bpr = CVPixelBufferGetBytesPerRow(pixelBuffer)
            let total = bpr * height
            if total < sampleCount * 4 { return false }
            let step = (total / sampleCount) & ~0x3  // align to 4-byte pixel
            var sum = 0
            var n = 0
            var pos = 0
            let ptr = base.assumingMemoryBound(to: UInt8.self)
            // BGRA: byte order = B, G, R, A → green is at +1.
            while n < sampleCount && pos + 2 < total {
                let b = Int(ptr[pos])
                let g = Int(ptr[pos + 1])
                let r = Int(ptr[pos + 2])
                // Rec.601 luma approximation.
                sum += (299 * r + 587 * g + 114 * b) / 1000
                pos += step
                n += 1
            }
            _ = width // silence unused warning
            let mean = Double(sum) / Double(max(n, 1))
            return mean < darknessThreshold
        default:
            return false
        }
    }
}
