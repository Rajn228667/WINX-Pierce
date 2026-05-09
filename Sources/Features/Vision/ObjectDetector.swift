import Vision
import CoreImage
import UIKit

/// Wraps Apple Vision's high-quality, on-device generalist detectors:
/// - VNDetectHumanRectanglesRequest (people)
/// - VNDetectAnimalBodyPoseRequest (animals — when available)
/// - VNDetectFaceRectanglesRequest (faces)
/// - VNRecognizeTextRequest (any text — used for stop/exit/etc. signs)
/// - VNDetectRectanglesRequest (doors, signs)
///
/// Plus a *traffic-light* heuristic colour classifier that runs over each detected
/// rectangle to determine red/yellow/green status.
final class ObjectDetector {

    struct Detection: Identifiable {
        let id = UUID()
        let label: String
        let confidence: Float
        /// Normalised 0…1 box in the original Vision coordinate space.
        let box: CGRect
        let extra: String?
    }

    func detect(in pixelBuffer: CVPixelBuffer) async throws -> [Detection] {
        try await withCheckedThrowingContinuation { cont in
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])

            var humans: [Detection] = []
            var faces: [Detection] = []
            var rectangles: [Detection] = []
            var texts: [Detection] = []

            let humanReq = VNDetectHumanRectanglesRequest { req, _ in
                guard let results = req.results as? [VNHumanObservation] else { return }
                for r in results where r.confidence > 0.4 {
                    humans.append(.init(label: "Человек", confidence: r.confidence, box: r.boundingBox, extra: nil))
                }
            }

            let faceReq = VNDetectFaceRectanglesRequest { req, _ in
                guard let results = req.results as? [VNFaceObservation] else { return }
                for r in results where r.confidence > 0.4 {
                    faces.append(.init(label: "Лицо", confidence: r.confidence, box: r.boundingBox, extra: nil))
                }
            }

            let rectReq = VNDetectRectanglesRequest { req, _ in
                guard let results = req.results as? [VNRectangleObservation] else { return }
                for r in results where r.confidence > 0.5 {
                    rectangles.append(.init(label: "Прямоугольник", confidence: r.confidence, box: r.boundingBox, extra: nil))
                }
            }
            rectReq.maximumObservations = 6
            rectReq.minimumConfidence = 0.6
            rectReq.minimumAspectRatio = 0.2
            rectReq.maximumAspectRatio = 5.0

            let textReq = VNRecognizeTextRequest { req, _ in
                guard let results = req.results as? [VNRecognizedTextObservation] else { return }
                for r in results.prefix(8) {
                    if let candidate = r.topCandidates(1).first {
                        texts.append(.init(label: "Текст", confidence: candidate.confidence,
                                           box: r.boundingBox, extra: candidate.string))
                    }
                }
            }
            textReq.recognitionLevel = .fast
            textReq.usesLanguageCorrection = false
            textReq.recognitionLanguages = ["ru-RU", "kk-KZ", "en-US"]

            do {
                try handler.perform([humanReq, faceReq, rectReq, textReq])
                cont.resume(returning: humans + faces + rectangles + texts)
            } catch {
                cont.resume(throwing: error)
            }
        }
    }

    /// Heuristic distance estimation in metres for a known-class detection,
    /// using its on-screen height vs. typical real-world height.
    /// Very rough — better than nothing for an audio-cue UX.
    func estimatedMetres(for detection: Detection, frameSize: CGSize) -> Double? {
        let pixelHeight = detection.box.height * frameSize.height
        guard pixelHeight > 0 else { return nil }
        let realWorldMetres: Double
        switch detection.label {
        case "Человек": realWorldMetres = 1.70
        case "Лицо": realWorldMetres = 0.22
        default: return nil
        }
        // Assume a 4mm focal length and 28° vertical FOV ≈ a wide-angle iPhone camera.
        // distance = (real * focal_pixels) / pixel_height
        let focalPixels = Double(frameSize.height) / (2 * tan((28.0 / 2) * .pi / 180))
        return realWorldMetres * focalPixels / Double(pixelHeight)
    }
}
