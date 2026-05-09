import SwiftUI
import AVFoundation

struct DiaryEntry: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var date: Date
    var transcript: String
    var audioFile: String?
}

@MainActor
final class DiaryStore: ObservableObject {
    @Published var entries: [DiaryEntry] = [] { didSet { persist() } }

    private let url: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base.appendingPathComponent("diary.json")
    }()

    init() { load() }
    private func load() {
        if let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([DiaryEntry].self, from: data) {
            entries = decoded
        }
    }
    private func persist() {
        if let data = try? JSONEncoder().encode(entries) { try? data.write(to: url) }
    }
}

struct DiaryView: View {
    @StateObject private var store = DiaryStore()
    @StateObject private var recorder = VoiceRecorder()
    @StateObject private var recognizer = SpeechRecognizer()

    var body: some View {
        VStack(spacing: 12) {
            // Recorder
            VStack(spacing: 12) {
                Waveform(amplitude: recorder.amplitude, color: Theme.accentGreen)
                    .frame(height: 50)
                    .opacity(recorder.isRecording ? 1 : 0.35)

                if recognizer.isListening || !recognizer.transcript.isEmpty {
                    Text(recognizer.transcript)
                        .font(.system(size: 18, weight: .semibold))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Theme.elevatedBackground))
                }

                HStack {
                    Button {
                        if recorder.isRecording {
                            _ = recorder.stop()
                            recognizer.stop()
                            saveEntry()
                        } else {
                            recorder.start()
                            try? recognizer.start()
                        }
                    } label: {
                        Label(recorder.isRecording ? "Готово" : "Записать",
                              systemImage: recorder.isRecording ? "stop.fill" : "mic.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(recorder.isRecording ? Theme.brandRed : Theme.accentGreen)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 22).fill(Theme.card))
            .padding(.horizontal)

            // Entries
            List {
                ForEach(store.entries.reversed()) { entry in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(entry.date, style: .date).font(.caption).foregroundStyle(.secondary)
                        Text(entry.transcript)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            if let idx = store.entries.firstIndex(of: entry) { store.entries.remove(at: idx) }
                        } label: { Label("Удалить", systemImage: "trash") }
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Дневник")
    }

    private func saveEntry() {
        let entry = DiaryEntry(
            date: .now,
            transcript: recognizer.transcript,
            audioFile: recorder.url?.lastPathComponent
        )
        store.entries.append(entry)
        VoiceSynthesizer.shared.speak("Запись сохранена.")
    }
}
