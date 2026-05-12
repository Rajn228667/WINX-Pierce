import SwiftUI
import HomeKit

/// HomeKit dashboard: lists the user's homes, rooms, and accessories. Lets them
/// turn lights on/off and trigger scenes by voice or tap.
struct SmartHomeView: View {
    @StateObject private var hk = HomeKitController()

    var body: some View {
        List {
            if hk.homes.isEmpty {
                Section("Apple Home") {
                    Text("Чтобы управлять светом голосом, добавьте дом и аксессуары в приложении «Дом» от Apple. Затем вернитесь сюда — устройства появятся автоматически.")
                        .foregroundStyle(.secondary)
                }
            }

            ForEach(hk.homes, id: \.uniqueIdentifier) { home in
                Section(home.name) {
                    ForEach(home.accessories, id: \.uniqueIdentifier) { acc in
                        AccessoryRow(accessory: acc, hk: hk)
                    }
                }
                if !home.actionSets.isEmpty {
                    Section("\(home.name) — сцены") {
                        ForEach(home.actionSets, id: \.uniqueIdentifier) { scene in
                            Button {
                                hk.run(scene: scene, in: home)
                            } label: {
                                Label(scene.name, systemImage: "wand.and.stars")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Умный дом")
        .onAppear { hk.start() }
            .voiceGuide(.guide_smart_home)
    }
}

private struct AccessoryRow: View {
    let accessory: HMAccessory
    @ObservedObject var hk: HomeKitController
    @State private var isOn: Bool = false

    var body: some View {
        HStack {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(isOn ? Theme.accentYellow : Theme.secondaryText)
            Text(accessory.name)
            Spacer()
            Toggle("", isOn: Binding(
                get: { isOn },
                set: { v in
                    isOn = v
                    hk.setPower(v, on: accessory)
                }
            ))
            .labelsHidden()
        }
        .onAppear {
            isOn = hk.currentPower(of: accessory) ?? false
        }
    }
}

@MainActor
final class HomeKitController: NSObject, ObservableObject, HMHomeManagerDelegate {

    @Published var homes: [HMHome] = []

    private let manager = HMHomeManager()

    override init() {
        super.init()
        manager.delegate = self
    }

    func start() { /* delegate fires automatically */ }

    nonisolated func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        Task { @MainActor in self.homes = manager.homes }
    }

    func currentPower(of accessory: HMAccessory) -> Bool? {
        guard let service = accessory.services.first(where: { $0.serviceType == HMServiceTypeLightbulb }) else { return nil }
        guard let char = service.characteristics.first(where: { $0.characteristicType == HMCharacteristicTypePowerState }) else { return nil }
        return (char.value as? Bool) ?? false
    }

    func setPower(_ on: Bool, on accessory: HMAccessory) {
        guard let service = accessory.services.first(where: { $0.serviceType == HMServiceTypeLightbulb }) else { return }
        guard let char = service.characteristics.first(where: { $0.characteristicType == HMCharacteristicTypePowerState }) else { return }
        char.writeValue(on) { _ in }
    }

    func run(scene: HMActionSet, in home: HMHome) {
        home.executeActionSet(scene) { _ in }
    }
}
