import Foundation
import AVFoundation
import SoundAnalysis

/// Real-time sound classification using Apple's built-in MLSoundClassifier
/// (a SoundAnalysis classifier that ships with iOS 15+, identifier
/// `version1`, recognises 300+ everyday sounds: alarms, doorbells, dogs,
/// glass breaking, sirens, speech, water, etc).
@MainActor
final class SoundDetectorEngine: NSObject, ObservableObject {

    enum DetectedSound: String, CaseIterable {
        case alarm, doorbell, glass, dog, baby, siren, speech, water, unknown

        var localKey: LocalKey {
            switch self {
            case .alarm: return .sound_alarm
            case .doorbell: return .sound_doorbell
            case .glass: return .sound_glass
            case .dog: return .sound_dog
            case .baby: return .sound_baby
            case .siren: return .sound_siren
            case .speech: return .sound_speech
            case .water: return .sound_water
            case .unknown: return .sound_unknown
            }
        }
        var systemImage: String {
            switch self {
            case .alarm: return "bell.and.waves.left.and.right.fill"
            case .doorbell: return "door.left.hand.open"
            case .glass: return "exclamationmark.triangle.fill"
            case .dog: return "pawprint.fill"
            case .baby: return "figure.and.child.holdinghands"
            case .siren: return "light.beacon.max.fill"
            case .speech: return "mouth.fill"
            case .water: return "drop.fill"
            case .unknown: return "waveform"
            }
        }
        /// Mapping from Apple sound classifier label → coarse category.
        /// Labels come from the YAMNet-derived classifier in iOS.
        static func from(label: String) -> DetectedSound? {
            let l = label.lowercased()
            if l.contains("alarm") || l.contains("smoke_detector") || l.contains("buzzer") || l.contains("beep") { return .alarm }
            if l.contains("doorbell") || l.contains("door_bell") || l.contains("ringtone") { return .doorbell }
            if l.contains("glass") || l.contains("shatter") { return .glass }
            if l.contains("dog") || l.contains("bark") { return .dog }
            if l.contains("baby") || l.contains("cry") || l.contains("infant") { return .baby }
            if l.contains("siren") || l.contains("ambulance") || l.contains("police") || l.contains("fire_engine") { return .siren }
            if l.contains("speech") || l.contains("conversation") || l.contains("narration") { return .speech }
            if l.contains("water") || l.contains("faucet") || l.contains("shower") { return .water }
            return nil
        }
    }

    @Published private(set) var isListening: Bool = false
    @Published private(set) var lastDetected: DetectedSound?
    @Published private(set) var lastConfidence: Double = 0
    @Published private(set) var lastDetectionDate: Date?
    /// Rolling history (newest first, capped at 30 entries) — used by the UI list.
    @Published private(set) var history: [(sound: DetectedSound, date: Date)] = []

    private var audioEngine: AVAudioEngine?
    private var analyzer: SNAudioStreamAnalyzer?
    private let analysisQueue = DispatchQueue(label: "winx.sound.analysis")
    private let observerHolder = ObserverHolder()
    private var lastAlertDate: [DetectedSound: Date] = [:]
    private let alertCooldown: TimeInterval = 6

    func start() throws {
        guard !isListening else { return }
        AudioSessionManager.shared.activatePlayAndRecord()

        let engine = AVAudioEngine()
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        let analyzer = SNAudioStreamAnalyzer(format: format)

        let request: SNClassifySoundRequest
        if #available(iOS 15.0, *) {
            request = try SNClassifySoundRequest(classifierIdentifier: .version1)
        } else {
            return
        }
        request.windowDuration = CMTimeMakeWithSeconds(0.975, preferredTimescale: 48000)
        request.overlapFactor = 0.5

        observerHolder.engine = self
        try analyzer.add(request, withObserver: observerHolder)

        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 8192, format: format) { [weak analyzer] buffer, when in
            self.analysisQueue.async {
                analyzer?.analyze(buffer, atAudioFramePosition: when.sampleTime)
            }
        }

        engine.prepare()
        try engine.start()

        self.audioEngine = engine
        self.analyzer = analyzer
        self.isListening = true
    }

    func stop() {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        analyzer?.removeAllRequests()
        audioEngine = nil
        analyzer = nil
        isListening = false
    }

    fileprivate func ingest(label: String, confidence: Double) {
        guard let sound = DetectedSound.from(label: label), confidence > 0.55 else { return }
        let now = Date()
        if let last = lastAlertDate[sound], now.timeIntervalSince(last) < alertCooldown { return }
        lastAlertDate[sound] = now
        Task { @MainActor in
            self.lastDetected = sound
            self.lastConfidence = confidence
            self.lastDetectionDate = now
            self.history.insert((sound, now), at: 0)
            if self.history.count > 30 { self.history.removeLast() }
            // Spoken + haptic alert
            let phrase = LocalizationManager.shared.tr(sound.localKey)
            VoiceSynthesizer.shared.speak(phrase)
            HapticManager.shared.dangerPattern()
        }
    }
}

/// Bridge to the Objective-C SoundAnalysis observer protocol — kept off-actor
/// because SNResultsObserving callbacks happen on the analysis queue.
private final class ObserverHolder: NSObject, SNResultsObserving {
    weak var engine: SoundDetectorEngine?

    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult,
              let top = result.classifications.first else { return }
        Task { @MainActor [weak engine] in
            engine?.ingest(label: top.identifier, confidence: top.confidence)
        }
    }
}
