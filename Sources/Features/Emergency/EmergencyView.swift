import SwiftUI
import MessageUI
import CoreLocation

/// Big red SOS button. Press-and-hold for 1.4s, sends SMS with location to all
/// emergency contacts and dials the preferred one.
struct EmergencyView: View {

    @EnvironmentObject private var loc: LocalizationManager
    @EnvironmentObject private var contacts: EmergencyContactsStore
    @StateObject private var vm = EmergencyViewModel()
    @State private var pressProgress: Double = 0
    @State private var holding: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            Text(loc.tr(.sos_title))
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .padding(.top)

            Text(loc.tr(.sos_press_to_alert))
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            ZStack {
                Circle()
                    .stroke(Theme.accentRed.opacity(0.2), lineWidth: 14)
                    .frame(width: 260, height: 260)

                Circle()
                    .trim(from: 0, to: pressProgress)
                    .stroke(
                        LinearGradient(
                            colors: [Theme.accentRed, Color.orange],
                            startPoint: .top, endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 260, height: 260)
                    .animation(.linear(duration: 0.1), value: pressProgress)

                Circle()
                    .fill(holding ? Theme.accentRed : Theme.accentRed.opacity(0.85))
                    .frame(width: 200, height: 200)
                    .shadow(color: Theme.accentRed.opacity(0.6), radius: 30, x: 0, y: 0)
                    .scaleEffect(holding ? 0.95 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: holding)

                VStack(spacing: 8) {
                    Image(systemName: vm.sent ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 56, weight: .black))
                        .foregroundStyle(.white)
                    Text(vm.sent ? loc.tr(.sos_alert_sent) : "SOS")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
            .gesture(
                LongPressGesture(minimumDuration: 1.5)
                    .onChanged { _ in
                        startHold()
                    }
                    .onEnded { _ in
                        triggerSOS()
                    }
            )
            .onLongPressGesture(minimumDuration: 0, pressing: { p in
                if p { startHold() } else { cancelHold() }
            }, perform: {})

            HStack(spacing: 18) {
                Button(action: { vm.callPreferred(in: contacts) }) {
                    Label(loc.tr(.sos_call), systemImage: "phone.fill")
                        .padding(.vertical, 14)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity)
                        .background(Theme.accentEmerald)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                Button(action: { vm.shareLocation() }) {
                    Label(loc.tr(.sos_share_location), systemImage: "location.fill")
                        .padding(.vertical, 14)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity)
                        .background(Theme.accentBlue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal)

            ContactsManagerSection(contacts: contacts)
                .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 8)
        .sheet(isPresented: $vm.showShare) {
            if let url = vm.shareURL {
                ActivityShareSheet(items: [url])
            }
        }
    }

    private func startHold() {
        guard !holding else { return }
        holding = true
        HapticManager.shared.tap()
        Task {
            for i in 0...15 {
                try? await Task.sleep(nanoseconds: 100_000_000)
                guard holding else { return }
                pressProgress = Double(i) / 15.0
            }
        }
    }

    private func cancelHold() {
        if holding && pressProgress < 0.95 {
            holding = false
            withAnimation { pressProgress = 0 }
        }
    }

    private func triggerSOS() {
        holding = false
        pressProgress = 1.0
        Task {
            await vm.fireSOS(to: contacts)
        }
    }
}

private struct ContactsManagerSection: View {
    @ObservedObject var contacts: EmergencyContactsStore
    @EnvironmentObject private var loc: LocalizationManager
    @State private var newName: String = ""
    @State private var newPhone: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Контакты доверия").font(.headline)
            ForEach(contacts.contacts) { c in
                HStack {
                    Image(systemName: c.preferred ? "star.fill" : "person.crop.circle")
                        .foregroundStyle(c.preferred ? Theme.brandRed : Theme.secondaryText)
                    VStack(alignment: .leading) {
                        Text(c.displayName).bold()
                        Text(c.phone).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        contacts.makePreferred(c)
                    } label: {
                        Text(c.preferred ? "Главный" : "Сделать главным")
                    }
                    .buttonStyle(.bordered)
                    Button(role: .destructive) {
                        contacts.remove(c)
                    } label: {
                        Image(systemName: "trash")
                    }
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 14).fill(Theme.card))
            }

            HStack {
                TextField("Имя", text: $newName)
                    .textFieldStyle(.roundedBorder)
                TextField("Телефон", text: $newPhone)
                    .keyboardType(.phonePad)
                    .textFieldStyle(.roundedBorder)
                Button("Добавить") {
                    let c = EmergencyContact(displayName: newName.isEmpty ? newPhone : newName,
                                             phone: newPhone,
                                             preferred: contacts.contacts.isEmpty)
                    contacts.add(c)
                    newName = ""
                    newPhone = ""
                }
                .buttonStyle(.borderedProminent)
                .disabled(newPhone.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}
