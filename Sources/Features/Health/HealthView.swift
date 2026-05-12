import SwiftUI
import CoreMotion
import UserNotifications

/// A friendly health hub.
///
/// We deliberately avoid HealthKit (which requires the `com.apple.developer.healthkit`
/// entitlement that sideloaded apps can't grant) and instead use:
///   • CoreMotion's pedometer for step + walking distance
///   • UserNotifications for medication reminders
///   • A guided breathing exercise with a slow animated halo
///   • An LLM chat for general well-being questions
struct HealthMedication: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var dose: String
    var time: Date
    var enabled: Bool = true
    /// Stored notification identifier so we can cancel reliably.
    var notificationId: String?
}

@MainActor
final class HealthStore: ObservableObject {

    @Published var meds: [HealthMedication] = [] { didSet { persist() } }
    @Published var stepsToday: Int = 0
    @Published var distanceMeters: Double = 0
    @Published var flightsClimbed: Int = 0
    @Published var pedometerAvailable: Bool = CMPedometer.isStepCountingAvailable()

    private let pedometer = CMPedometer()

    private let url: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base.appendingPathComponent("meds.json")
    }()

    init() { load() }

    private func load() {
        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([HealthMedication].self, from: data) {
            meds = decoded
        }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(meds) { try? data.write(to: url) }
    }

    func startPedometer() {
        guard CMPedometer.isStepCountingAvailable() else { return }
        let from = Calendar.current.startOfDay(for: Date())
        pedometer.queryPedometerData(from: from, to: Date()) { [weak self] data, _ in
            guard let data else { return }
            Task { @MainActor in
                self?.stepsToday = data.numberOfSteps.intValue
                self?.distanceMeters = data.distance?.doubleValue ?? 0
                self?.flightsClimbed = data.floorsAscended?.intValue ?? 0
            }
        }
        pedometer.startUpdates(from: from) { [weak self] data, _ in
            guard let data else { return }
            Task { @MainActor in
                self?.stepsToday = data.numberOfSteps.intValue
                self?.distanceMeters = data.distance?.doubleValue ?? 0
                self?.flightsClimbed = data.floorsAscended?.intValue ?? 0
            }
        }
    }

    func stopPedometer() {
        pedometer.stopUpdates()
    }

    func add(_ med: HealthMedication) {
        var m = med
        m.notificationId = scheduleNotification(for: m)
        meds.append(m)
    }

    func remove(at offsets: IndexSet) {
        for idx in offsets {
            if let nid = meds[idx].notificationId {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [nid])
            }
        }
        meds.remove(atOffsets: offsets)
    }

    private func scheduleNotification(for med: HealthMedication) -> String? {
        let center = UNUserNotificationCenter.current()
        let id = UUID().uuidString
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        let content = UNMutableNotificationContent()
        content.title = "Время принять \(med.name)"
        content.body = med.dose.isEmpty ? "Не забудьте!" : med.dose
        content.sound = .default
        var dc = DateComponents()
        let comps = Calendar.current.dateComponents([.hour, .minute], from: med.time)
        dc.hour = comps.hour
        dc.minute = comps.minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
        let req = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(req, withCompletionHandler: nil)
        return id
    }
}

struct HealthView: View {

    @EnvironmentObject private var loc: LocalizationManager
    @StateObject private var store = HealthStore()
    @State private var newName: String = ""
    @State private var newDose: String = ""
    @State private var newTime: Date = .now
    @State private var breathing = false
    @State private var breathPhase: Double = 0.4

    var body: some View {
        Form {
            // ── Today ────────────────────────────────────────────────────
            Section("Сегодня") {
                statRow(icon: "figure.walk",
                        title: "Шаги",
                        value: "\(store.stepsToday)",
                        color: Theme.accentEmerald)
                statRow(icon: "ruler.fill",
                        title: "Дистанция",
                        value: formattedDistance(store.distanceMeters),
                        color: Theme.accentBlue)
                statRow(icon: "arrow.up.to.line.compact",
                        title: "Этажей",
                        value: "\(store.flightsClimbed)",
                        color: Theme.accentOrange)
                if !store.pedometerAvailable {
                    Text("Шаг-датчик недоступен на этом устройстве.")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
            }

            // ── Medications ──────────────────────────────────────────────
            Section("Лекарства") {
                ForEach(store.meds) { m in
                    HStack {
                        Image(systemName: "pills.fill").foregroundStyle(Theme.brandRed)
                        VStack(alignment: .leading) {
                            Text(m.name).bold()
                            Text("\(m.dose) · \(m.time, style: .time)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button {
                            VoiceSynthesizer.shared.speak("Примите \(m.name), \(m.dose).")
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.title3)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .onDelete { idx in store.remove(at: idx) }

                VStack(spacing: 8) {
                    HStack {
                        TextField("Название", text: $newName)
                            .textFieldStyle(.roundedBorder)
                        TextField("Доза", text: $newDose)
                            .textFieldStyle(.roundedBorder)
                    }
                    HStack {
                        DatePicker("Время", selection: $newTime, displayedComponents: .hourAndMinute)
                        Button {
                            guard !newName.isEmpty else { return }
                            store.add(.init(name: newName, dose: newDose, time: newTime))
                            VoiceSynthesizer.shared.speak("Лекарство \(newName) добавлено.")
                            newName = ""; newDose = ""
                        } label: {
                            Label("Добавить", systemImage: "plus.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.vertical, 4)
            }

            // ── Wellbeing ────────────────────────────────────────────────
            Section("Самочувствие") {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Theme.accentBlue.opacity(0.18))
                            .frame(width: 76, height: 76)
                            .scaleEffect(breathing ? 1.4 : 1.0)
                            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: breathing)
                        Image(systemName: "wind")
                            .font(.title)
                            .foregroundStyle(Theme.accentBlue)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Дыхание 4-6")
                            .font(.system(size: 16, weight: .heavy))
                        Text("Вдох 4 секунды, выдох 6 — успокаивает за 1 минуту.")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        toggleBreathing()
                    } label: {
                        Image(systemName: breathing ? "stop.fill" : "play.fill")
                            .font(.title2)
                            .padding(10)
                            .background(Circle().fill(Theme.accentBlue.opacity(0.2)))
                    }
                }
                Button {
                    Task { await askAboutSymptoms() }
                } label: {
                    Label("Поговорить о самочувствии", systemImage: "heart.text.square.fill")
                }
            }
        }
        .navigationTitle(Text(loc.tr(.tile_health)))
        .onAppear { store.startPedometer() }
        .onDisappear { store.stopPedometer() }
            .voiceGuide(.guide_health)
    }

    // MARK: - Helpers

    private func statRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Circle().fill(color))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                Text(value).font(.system(size: 22, weight: .black, design: .rounded))
                    .monospacedDigit()
            }
            Spacer()
        }
    }

    private func formattedDistance(_ meters: Double) -> String {
        if meters >= 1000 {
            return String(format: "%.2f км", meters / 1000)
        }
        return "\(Int(meters)) м"
    }

    private func toggleBreathing() {
        breathing.toggle()
        if breathing {
            VoiceSynthesizer.shared.speak("Сделайте глубокий вдох на 4 секунды, затем выдох 6 секунд. Повторим минуту.")
        } else {
            VoiceSynthesizer.shared.stop()
        }
    }

    private func askAboutSymptoms() async {
        let prompt = "Я расскажу тебе про мои симптомы, а ты дай короткие, спокойные советы и напомни, когда нужно вызвать врача."
        do {
            let reply = try await OllamaClient.shared.chat(
                model: Config.fastModel,
                messages: [.init(role: "user", content: prompt)]
            )
            VoiceSynthesizer.shared.speak(reply)
        } catch {
            VoiceSynthesizer.shared.speak(loc.tr(.err_ollama_offline))
        }
    }
}
