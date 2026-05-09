import Foundation
import CoreLocation
import UIKit
import Combine

@MainActor
final class EmergencyViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var sent: Bool = false
    @Published var lastError: String?
    @Published var showShare: Bool = false
    @Published var shareURL: URL?

    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation?, Never>?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }

    func fireSOS(to store: EmergencyContactsStore) async {
        let location = await currentLocation()
        let mapsURL: String = {
            if let l = location {
                return "https://maps.apple.com/?ll=\(l.coordinate.latitude),\(l.coordinate.longitude)"
            }
            return "Местоположение недоступно"
        }()

        let template = """
        Это сообщение SOS от пользователя WINX × Pierce. Мне нужна помощь.
        Геолокация: \(mapsURL)
        Время: \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium))
        """

        // Speak it out loud first.
        VoiceSynthesizer.shared.speak(LocalizationManager.shared.tr(.sos_alert_sent))
        HapticManager.shared.dangerPattern()

        // Open SMS pre-filled with the message and the preferred contact.
        if let contact = store.preferred {
            let cleaned = contact.phone.filter { $0.isNumber || $0 == "+" }
            if let url = URL(string: "sms:\(cleaned)&body=\(template.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
                await UIApplication.shared.open(url)
            }
        }
        sent = true
    }

    func callPreferred(in store: EmergencyContactsStore) {
        guard let contact = store.preferred else { return }
        let cleaned = contact.phone.filter { $0.isNumber || $0 == "+" }
        if let url = URL(string: "tel://\(cleaned)") {
            UIApplication.shared.open(url)
        }
    }

    func shareLocation() {
        Task {
            let location = await currentLocation()
            guard let l = location else { return }
            let urlString = "https://maps.apple.com/?ll=\(l.coordinate.latitude),\(l.coordinate.longitude)"
            if let url = URL(string: urlString) {
                shareURL = url
                showShare = true
            }
        }
    }

    private func currentLocation() async -> CLLocation? {
        await withCheckedContinuation { (cont: CheckedContinuation<CLLocation?, Never>) in
            locationContinuation = cont
            locationManager.requestLocation()
            // Hard timeout fallback in 4s.
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                self?.locationContinuation?.resume(returning: nil)
                self?.locationContinuation = nil
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let last = locations.last
        Task { @MainActor in
            self.locationContinuation?.resume(returning: last)
            self.locationContinuation = nil
        }
    }
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.locationContinuation?.resume(returning: nil)
            self.locationContinuation = nil
        }
    }
}
