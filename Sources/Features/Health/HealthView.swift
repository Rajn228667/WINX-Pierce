import SwiftUI

struct HealthMedication: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var dose: String
    var time: Date
    var enabled: Bool = true
}

@MainActor
final class HealthStore: ObservableObject {
    @Published var meds: [HealthMedication] = [] { didSet { persist() } }
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
}

struct HealthView: View {
    @StateObject private var store = HealthStore()
    @State private var newName: String = ""
    @State private var newDose: String = ""
    @State private var newTime: Date = .now

    var body: some View {
        Form {
            Section("Лекарства") {
                ForEach(store.meds) { m in
                    HStack {
                        Image(systemName: "pills.fill").foregroundStyle(Theme.brandRed)
                        VStack(alignment: .leading) {
                            Text(m.name).bold()
                            Text("\(m.dose) · \(m.time, style: .time)").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button {
                            VoiceSynthesizer.shared.speak("Принять \(m.name), \(m.dose).")
                        } label: { Image(systemName: "speaker.wave.2.fill") }
                    }
                }
                .onDelete { idx in store.meds.remove(atOffsets: idx) }

                HStack {
                    TextField("Название", text: $newName)
                    TextField("Доза", text: $newDose)
                    DatePicker("", selection: $newTime, displayedComponents: .hourAndMinute).labelsHidden()
                    Button {
                        guard !newName.isEmpty else { return }
                        store.meds.append(.init(name: newName, dose: newDose, time: newTime))
                        newName = ""; newDose = ""
                    } label: { Image(systemName: "plus.circle.fill") }
                }
            }

            Section("Состояние") {
                Button {
                    VoiceSynthesizer.shared.speak("Сделайте 4 секунды глубокого вдоха, затем 6 секунд выдоха. Повторим 5 раз.")
                } label: {
                    Label("Дыхательная техника 4-6", systemImage: "wind")
                }
                Button {
                    Task {
                        let prompt = "Я расскажу тебе про мои симптомы, а ты дай короткие, спокойные советы и напомни, когда нужно вызвать врача."
                        let reply = (try? await OllamaClient.shared.chat(model: Config.fastModel, messages: [.init(role: "user", content: prompt)])) ?? "Я не могу сейчас связаться с AI."
                        VoiceSynthesizer.shared.speak(reply)
                    }
                } label: {
                    Label("Поговорить о самочувствии", systemImage: "heart.text.square.fill")
                }
            }
        }
        .navigationTitle("Здоровье")
    }
}
