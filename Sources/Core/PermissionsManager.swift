import Foundation
import AVFoundation
import Speech
import CoreLocation
import Contacts
import HomeKit
import Photos
import UIKit

@MainActor
final class PermissionsManager: NSObject, ObservableObject {

    static let shared = PermissionsManager()

    @Published private(set) var camera: PermissionState = .notDetermined
    @Published private(set) var microphone: PermissionState = .notDetermined
    @Published private(set) var speech: PermissionState = .notDetermined
    @Published private(set) var location: PermissionState = .notDetermined
    @Published private(set) var contacts: PermissionState = .notDetermined
    @Published private(set) var photos: PermissionState = .notDetermined

    private let locationManager = CLLocationManager()

    enum PermissionState: String {
        case notDetermined
        case granted
        case denied
        case limited
    }

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func refreshAll() {
        camera = mapAVAuth(AVCaptureDevice.authorizationStatus(for: .video))
        microphone = mapMicAuth(AVAudioSession.sharedInstance().recordPermission)
        speech = mapSpeechAuth(SFSpeechRecognizer.authorizationStatus())
        location = mapLocAuth(locationManager.authorizationStatus)
        contacts = mapContactsAuth(CNContactStore.authorizationStatus(for: .contacts))
        photos = mapPhotosAuth(PHPhotoLibrary.authorizationStatus(for: .readWrite))
    }

    // MARK: - Requests

    func requestCamera() async -> Bool {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        await MainActor.run { self.camera = granted ? .granted : .denied }
        return granted
    }

    func requestMicrophone() async -> Bool {
        let granted: Bool = await withCheckedContinuation { cont in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                cont.resume(returning: granted)
            }
        }
        await MainActor.run { self.microphone = granted ? .granted : .denied }
        return granted
    }

    func requestSpeech() async -> Bool {
        let ok = await SpeechRecognizer.requestAuthorization()
        await MainActor.run { self.speech = ok ? .granted : .denied }
        return ok
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestContacts() async -> Bool {
        do {
            let granted: Bool = try await withCheckedThrowingContinuation { cont in
                CNContactStore().requestAccess(for: .contacts) { granted, err in
                    if let err { cont.resume(throwing: err) } else { cont.resume(returning: granted) }
                }
            }
            await MainActor.run { self.contacts = granted ? .granted : .denied }
            return granted
        } catch {
            await MainActor.run { self.contacts = .denied }
            return false
        }
    }

    func requestPhotos() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        await MainActor.run { self.photos = mapPhotosAuth(status) }
        return status == .authorized || status == .limited
    }

    // MARK: - Mapping

    private func mapAVAuth(_ s: AVAuthorizationStatus) -> PermissionState {
        switch s {
        case .authorized: return .granted
        case .denied, .restricted: return .denied
        case .notDetermined: return .notDetermined
        @unknown default: return .notDetermined
        }
    }
    private func mapMicAuth(_ s: AVAudioSession.RecordPermission) -> PermissionState {
        switch s {
        case .granted: return .granted
        case .denied: return .denied
        case .undetermined: return .notDetermined
        @unknown default: return .notDetermined
        }
    }
    private func mapSpeechAuth(_ s: SFSpeechRecognizerAuthorizationStatus) -> PermissionState {
        switch s {
        case .authorized: return .granted
        case .denied, .restricted: return .denied
        case .notDetermined: return .notDetermined
        @unknown default: return .notDetermined
        }
    }
    private func mapLocAuth(_ s: CLAuthorizationStatus) -> PermissionState {
        switch s {
        case .authorizedAlways, .authorizedWhenInUse: return .granted
        case .denied, .restricted: return .denied
        case .notDetermined: return .notDetermined
        @unknown default: return .notDetermined
        }
    }
    private func mapContactsAuth(_ s: CNAuthorizationStatus) -> PermissionState {
        switch s {
        case .authorized: return .granted
        case .denied, .restricted: return .denied
        case .notDetermined: return .notDetermined
        case .limited: return .limited
        @unknown default: return .notDetermined
        }
    }
    private func mapPhotosAuth(_ s: PHAuthorizationStatus) -> PermissionState {
        switch s {
        case .authorized: return .granted
        case .denied, .restricted: return .denied
        case .notDetermined: return .notDetermined
        case .limited: return .limited
        @unknown default: return .notDetermined
        }
    }
}

extension PermissionsManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in self.refreshAll() }
    }
}
