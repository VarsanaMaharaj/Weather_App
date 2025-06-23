//
//  LocationManagerTests.swift
//  WeatherTests
//
//  Created by Varsana Maharaj on 2025/06/22.
//

import CoreLocation
import XCTest
import Combine
@testable import Weather

// MARK: - Mock CLLocationManager for Testing
class MockCLLocationManager: LocationManagerProtocol {
    var delegate: CLLocationManagerDelegate?
    var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest

    var simulateError: Error?
    var simulateLocations: [CLLocation] = []

    func requestWhenInUseAuthorization() {
        delegate?.locationManagerDidChangeAuthorization?(CLLocationManager())
    }

    func requestLocation() {
        if let error = simulateError {
            delegate?.locationManager?(CLLocationManager(), didFailWithError: error)
        } else if !simulateLocations.isEmpty {
            delegate?.locationManager?(CLLocationManager(), didUpdateLocations: simulateLocations)
        }
    }
}

// MARK: - LocationManager Unit Tests
class LocationManagerTests: XCTestCase {
    private var locationManager: LocationManager!
    private var mockCLLocationManager: MockCLLocationManager!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockCLLocationManager = MockCLLocationManager()
        locationManager = LocationManager(locationManager: mockCLLocationManager)
        cancellables = []
    }

    override func tearDown() {
        locationManager = nil
        mockCLLocationManager = nil
        cancellables.removeAll()
        super.tearDown()
    }

    func testLocationUpdate() {
        let expectation = self.expectation(description: "Location updated successfully")

        locationManager.$latitude
            .dropFirst()
            .sink { latitude in
                XCTAssertEqual(latitude, 37.7749, "Latitude should match the simulated location")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        mockCLLocationManager.simulateLocations = [
            CLLocation(latitude: 37.7749, longitude: -122.4194)
        ]
        locationManager.requestLocation()

        wait(for: [expectation], timeout: 1.0)
    }

    func testLocationFailure() {
        let expectation = self.expectation(description: "Location failure reported")

        locationManager.$errorMessage
            .dropFirst()
            .sink { errorMessage in
                XCTAssertEqual(errorMessage, "Simulated error", "Error message should match the simulated error")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        mockCLLocationManager.simulateError = NSError(
            domain: "",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Simulated error"]
        )
        locationManager.requestLocation()

        wait(for: [expectation], timeout: 1.0)
    }
}
