//
//  LocationManager.swift
//  Weather
//
//  Created by Varsana Maharaj on 2025/06/20.
//

import Foundation
import CoreLocation

/**
 Protocol defining the interface for location services.
 This protocol allows for dependency injection and easier testing by abstracting `CLLocationManager`.
 */
protocol LocationManagerProtocol: AnyObject {
    var delegate: CLLocationManagerDelegate? { get set }     /// The delegate to receive location updates and authorization changes.
    func requestWhenInUseAuthorization()     /// Requests permission to use location services when the app is in use.
    func requestLocation()     /// Requests the current location of the device.
}

extension CLLocationManager: LocationManagerProtocol {}

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager: LocationManagerProtocol
    
    @Published var latitude: CLLocationDegrees?
    @Published var longitude: CLLocationDegrees?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    /**
     Initializes the `LocationManager` with an optional `LocationManagerProtocol`.
     - Parameter locationManager: The location manager instance to use. Defaults to `CLLocationManager()`.
     */
    init(locationManager: LocationManagerProtocol = CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    /**
     Requests the current location from the location manager and sets loading state.
     */
    func requestLocation() {
        isLoading = true
        locationManager.requestLocation()
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    /**
     Called when new location data is available.
     - Parameters:
     - manager: The location manager object reporting the location update.
     - locations: An array of location data, ordered with the most recent last.
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            self.errorMessage = nil
            self.isLoading = false
        }
    }
    
    /**
     Called when the location manager fails with an error.
     - Parameters:
     - manager: The location manager object reporting the error.
     - error: The error object containing details of the failure.
     */
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
    
    /**
     Called when the authorization status changes.
     - Parameter manager: The location manager object reporting the authorization change.
     Handles authorization statuses and updates error messages accordingly.
     */
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.errorMessage = "Location permission denied. Please enable it in settings."
            }
        default:
            break
        }
    }
}
