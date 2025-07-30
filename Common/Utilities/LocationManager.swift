//
//  LocationManager.swift
//  Weather
//
//  Created by Romain Rabouan on 7/29/25.
//

import Foundation
import Combine
import CoreLocation

enum LocationManagerError: Error {
    case permissionDenied
    case locationNotFound
}

final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    private var locationCompletion: ((Result<CLLocationCoordinate2D, LocationManagerError>) -> Void)?

    var currentLocation: CLLocation?

    private(set) var hasGrantedPermission: Bool

    @Published var authorizationStatus: CLAuthorizationStatus?

    override init() {
        hasGrantedPermission = locationManager.authorizationStatus == .authorizedWhenInUse
        super.init()
        locationManager.delegate = self
    }


    func getPlacemark(from location: CLLocationCoordinate2D) async throws -> CLPlacemark {
        let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        guard let mainPlacemark = placemarks.first else {
            throw LocationManagerError.locationNotFound
        }

        return mainPlacemark
    }

    func requestLocation(completion: @escaping (Result<CLLocationCoordinate2D, LocationManagerError>) -> Void) {
        locationCompletion = completion

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorized:
            hasGrantedPermission = true
            locationManager.requestLocation()

        case .restricted, .denied:
            hasGrantedPermission = false
            completion(.failure(.permissionDenied))
            locationCompletion = nil

        case .authorizedAlways:
            assertionFailure("Unhandled case.")
        @unknown default:
            hasGrantedPermission = false
            completion(.failure(.permissionDenied))
            locationCompletion = nil
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let completion = locationCompletion else { return }
        defer { locationCompletion = nil }

        completion(.failure(.locationNotFound))
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.first
        guard let completion = locationCompletion else { return }

        defer { locationCompletion = nil }

        if let coordinate = locations.first?.coordinate {
            completion(.success(coordinate))
        } else {
            completion(.failure(.locationNotFound))
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorized:
            hasGrantedPermission = true
            // if a requestLocation is in flight, fire it now
            locationManager.requestLocation()

        case .restricted, .denied:
            hasGrantedPermission = false
            // if user just denied, inform the waiting completion
            locationCompletion?(.failure(.permissionDenied))
            locationCompletion = nil

        case .notDetermined:
            hasGrantedPermission = false

        case .authorizedAlways:
            assertionFailure("Handle authorizedAlways if you need it")

        @unknown default:
            assertionFailure("Handle new authorization status")
        }

    }
}
