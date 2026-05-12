import SwiftUI
import CoreMotion

/// "Locator" — voice-guides the user inside a room using the device's compass and
/// heading, narrating their orientation (front, left, right) and step count.
struct LocatorView: View {

    @StateObject private var motion = MotionAnnouncer()
    @EnvironmentObject private var loc: LocalizationManager

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Theme.accentPurple.opacity(0.15))
                    .frame(width: 240, height: 240)
                Image(systemName: "location.north.line.fill")
                    .font(.system(size: 100, weight: .black))
                    .foregroundStyle(Theme.accentPurple)
                    .rotationEffect(.degrees(motion.heading))
                    .animation(.easeOut(duration: 0.3), value: motion.heading)
            }
            VStack(alignment: .leading, spacing: 8) {
                Label("Шагов: \(motion.steps)", systemImage: "figure.walk")
                Label("Высота: \(motion.altitudeText)", systemImage: "arrow.up.and.down")
                Label("Курс: \(Int(motion.heading))°", systemImage: "safari")
            }
            .font(.title3.bold())
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
            .padding(.horizontal)

            HStack {
                Button {
                    motion.toggle()
                } label: {
                    Label(motion.running ? loc.tr(.action_stop) : loc.tr(.action_speak),
                          systemImage: motion.running ? "stop.fill" : "play.fill")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(motion.running ? Theme.accentRed : Theme.accentPurple)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal)
            Spacer()
        }
        .onDisappear { motion.stop() }
            .voiceGuide(.guide_locator)
    }
}

@MainActor
final class MotionAnnouncer: ObservableObject {
    @Published var heading: Double = 0
    @Published var steps: Int = 0
    @Published var altitude: Double = 0
    @Published var running: Bool = false

    private let pedometer = CMPedometer()
    private let manager = CMMotionManager()
    private let altimeter = CMAltimeter()
    private var announceTimer: Timer?
    private let voice = VoiceSynthesizer.shared

    var altitudeText: String { String(format: "%.1f м", altitude) }

    func toggle() { running ? stop() : start() }

    func start() {
        manager.deviceMotionUpdateInterval = 0.1
        manager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { [weak self] motion, _ in
            guard let m = motion else { return }
            self?.heading = m.heading
        }
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: Date()) { [weak self] data, _ in
                Task { @MainActor in
                    self?.steps = data?.numberOfSteps.intValue ?? 0
                }
            }
        }
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, _ in
                self?.altitude = data?.relativeAltitude.doubleValue ?? 0
            }
        }
        running = true
        announceTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.announce() }
        }
        voice.speak("Локатор включён. Я буду подсказывать направление каждые несколько секунд.")
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
        pedometer.stopUpdates()
        altimeter.stopRelativeAltitudeUpdates()
        announceTimer?.invalidate()
        announceTimer = nil
        running = false
    }

    private func announce() {
        let direction: String
        switch heading {
        case 337.5...360, 0..<22.5: direction = "север"
        case 22.5..<67.5: direction = "северо-восток"
        case 67.5..<112.5: direction = "восток"
        case 112.5..<157.5: direction = "юго-восток"
        case 157.5..<202.5: direction = "юг"
        case 202.5..<247.5: direction = "юго-запад"
        case 247.5..<292.5: direction = "запад"
        default: direction = "северо-запад"
        }
        voice.speak("Вы смотрите на \(direction). Шагов: \(steps).")
    }
}
