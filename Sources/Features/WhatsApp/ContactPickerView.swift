import SwiftUI
import Contacts
import ContactsUI

/// Native CNContactPickerViewController bridge. Returns the picked contact or nil.
struct ContactPickerView: UIViewControllerRepresentable {
    let onPick: (CNContact?) -> Void

    func makeCoordinator() -> Coord { Coord(parent: self) }

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let vc = CNContactPickerViewController()
        vc.delegate = context.coordinator
        vc.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        return vc
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    final class Coord: NSObject, CNContactPickerDelegate {
        let parent: ContactPickerView
        init(parent: ContactPickerView) { self.parent = parent }
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            parent.onPick(contact)
        }
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            parent.onPick(nil)
        }
    }
}

/// In-app contacts list (when we want to skip the picker UI).
@MainActor
final class ContactsLoader: ObservableObject {
    @Published var contacts: [PickedContact] = []
    @Published var loading: Bool = false

    struct PickedContact: Identifiable, Hashable {
        let id: String
        let displayName: String
        let phone: String
        let initials: String
    }

    func load() async {
        loading = true
        defer { loading = false }
        let store = CNContactStore()
        let granted: Bool = await withCheckedContinuation { cont in
            store.requestAccess(for: .contacts) { ok, _ in cont.resume(returning: ok) }
        }
        guard granted else { return }
        let keys: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactImageDataAvailableKey as CNKeyDescriptor
        ]
        let req = CNContactFetchRequest(keysToFetch: keys)
        req.sortOrder = .givenName

        var collected: [PickedContact] = []
        try? store.enumerateContacts(with: req) { contact, _ in
            for phoneEntry in contact.phoneNumbers {
                let phone = phoneEntry.value.stringValue
                let name = [contact.givenName, contact.familyName].filter { !$0.isEmpty }.joined(separator: " ")
                let display = name.isEmpty ? phone : name
                let initials: String = {
                    let parts = display.split(separator: " ").compactMap { $0.first }
                    return String(parts.prefix(2)).uppercased()
                }()
                collected.append(.init(id: "\(contact.identifier)|\(phone)",
                                       displayName: display,
                                       phone: phone,
                                       initials: initials.isEmpty ? "?" : initials))
            }
        }
        contacts = collected
    }
}

/// Visual contact picker with avatars + search.
struct InlineContactsPickerView: View {
    @StateObject var loader = ContactsLoader()
    @State private var search: String = ""
    let accent: Color
    let onPick: (ContactsLoader.PickedContact) -> Void

    var filtered: [ContactsLoader.PickedContact] {
        let q = search.lowercased()
        return q.isEmpty ? loader.contacts : loader.contacts.filter {
            $0.displayName.lowercased().contains(q) || $0.phone.contains(q)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Поиск контакта", text: $search)
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 14).fill(Theme.elevatedBackground))
            .padding()

            if loader.loading {
                ProgressView().padding()
            }

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filtered) { c in
                        Button {
                            onPick(c)
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle().fill(accent.opacity(0.18)).frame(width: 44, height: 44)
                                    Text(c.initials).font(.system(size: 14, weight: .heavy)).foregroundStyle(accent)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(c.displayName).font(.system(size: 16, weight: .semibold))
                                    Text(c.phone).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Theme.card))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .task { await loader.load() }
    }
}
