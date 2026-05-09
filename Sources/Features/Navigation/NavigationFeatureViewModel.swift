import Foundation
import MapKit
import CoreLocation
import SwiftUI

@MainActor
final class NavigationFeatureViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @Published var searchQuery: String = ""
    @Published var destinationCoordinate: CLLocationCoordinate2D?
    @Published var activeRoute: MKRoute?
    @Published var currentInstruction: String?

    private let locationManager = CLLocationManager()
    private var stepIndex: Int = 0
    private var spokenSteps: Set<Int> = []
    private var locationContinuation: CheckedContinuation<CLLocation?, Never>?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func searchAndRoute(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed
        if let userLoc = locationManager.location {
            request.region = MKCoordinateRegion(center: userLoc.coordinate,
                                                latitudinalMeters: 5000,
                                                longitudinalMeters: 5000)
        }

        do {
            let results = try await MKLocalSearch(request: request).start()
            guard let dest = results.mapItems.first else {
                VoiceSynthesizer.shared.speak("Ничего не найдено.")
                return
            }
            destinationCoordinate = dest.placemark.coordinate
            VoiceSynthesizer.shared.speak("Найдено: \(dest.name ?? "место"). Прокладываю маршрут.")
            await calculateRoute(to: dest.placemark.coordinate)
        } catch {
            VoiceSynthesizer.shared.speak("Не удалось выполнить поиск.")
        }
    }

    func calculateRoute(to dest: CLLocationCoordinate2D) async {
        guard let userLoc = locationManager.location else { return }
        let req = MKDirections.Request()
        req.source = MKMapItem(placemark: MKPlacemark(coordinate: userLoc.coordinate))
        req.destination = MKMapItem(placemark: MKPlacemark(coordinate: dest))
        req.transportType = .walking
        req.requestsAlternateRoutes = false

        do {
            let directions = MKDirections(request: req)
            let response = try await directions.calculate()
            if let route = response.routes.first {
                activeRoute = route
                stepIndex = 0
                spokenSteps.removeAll()
                if let first = route.steps.first(where: { !$0.instructions.isEmpty }) {
                    currentInstruction = first.instructions
                }
                let dist = Int(route.distance)
                VoiceSynthesizer.shared.speak("Маршрут готов. Расстояние \(dist) метров.")
            }
        } catch {
            VoiceSynthesizer.shared.speak("Не удалось проложить маршрут.")
        }
    }

    func start() {
        guard activeRoute != nil else { return }
        VoiceSynthesizer.shared.speak("Начинаю навигацию.")
        // Steps will be announced as user moves (locationManager:didUpdateLocations:).
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task { @MainActor in
            self.locationContinuation?.resume(returning: loc)
            self.locationContinuation = nil
            self.advanceIfNeeded(at: loc)
        }
    }

    private func advanceIfNeeded(at userLocation: CLLocation) {
        guard let route = activeRoute else { return }
        let steps = route.steps
        guard !steps.isEmpty else { return }
        for (idx, step) in steps.enumerated() where idx >= stepIndex {
            // Compute distance from user to the step's start point.
            let stepLoc = CLLocation(latitude: step.polyline.coordinate.latitude,
                                     longitude: step.polyline.coordinate.longitude)
            let dist = userLocation.distance(from: stepLoc)
            if dist < 25, !spokenSteps.contains(idx), !step.instructions.isEmpty {
                spokenSteps.insert(idx)
                currentInstruction = step.instructions
                VoiceSynthesizer.shared.speak(step.instructions)
                stepIndex = idx + 1
                if stepIndex >= steps.count {
                    VoiceSynthesizer.shared.speak("Вы прибыли.")
                    HapticManager.shared.successPattern()
                }
                break
            }
        }
    }
}
