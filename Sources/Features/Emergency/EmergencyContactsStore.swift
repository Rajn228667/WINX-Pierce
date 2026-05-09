import Foundation
import Combine

struct EmergencyContact: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var displayName: String
    var phone: String
    var relationship: String?
    var preferred: Bool = false
}

@MainActor
final class EmergencyContactsStore: ObservableObject {

    static let shared = EmergencyContactsStore()

    @Published var contacts: [EmergencyContact] = [] {
        didSet { persist() }
    }

    private let url: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base.appendingPathComponent("emergency_contacts.json")
    }()

    init() {
        load()
    }

    var preferred: EmergencyContact? {
        contacts.first(where: \.preferred) ?? contacts.first
    }

    func add(_ contact: EmergencyContact) {
        contacts.append(contact)
    }

    func remove(_ contact: EmergencyContact) {
        contacts.removeAll { $0.id == contact.id }
    }

    func makePreferred(_ contact: EmergencyContact) {
        contacts = contacts.map { c in
            var copy = c
            copy.preferred = (c.id == contact.id)
            return copy
        }
    }

    // MARK: - Persistence

    private func load() {
        guard let data = try? Data(contentsOf: url) else { return }
        if let decoded = try? JSONDecoder().decode([EmergencyContact].self, from: data) {
            contacts = decoded
        }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(contacts) else { return }
        try? data.write(to: url, options: [.atomic])
    }
}
