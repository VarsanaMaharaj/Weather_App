//
//  WeatherViewModelTests.swift
//  WeatherTests
//
//  Created by Varsana Maharaj on 2025/06/22.
//

import Foundation
import CoreLocation
import XCTest
import Combine
import SwiftUI
@testable import Weather

// MARK: - MockWeatherService for Testing
struct MockWeatherService: WeatherServiceProtocol {
    var shouldReturnError = false
    var mockResponse: WeatherResponseModel?
    
    func fetchWeather(
        latitude: CLLocationDegrees,
        longitude: CLLocationDegrees,
        completion: @escaping (Result<WeatherResponseModel, Error>) -> Void
    ) {
        if shouldReturnError {
            completion(.failure(NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Simulated error"])))
        } else if let mockResponse = mockResponse {
            completion(.success(mockResponse))
        }
    }
    
    static func responseFromJSONString(_ jsonString: String) -> WeatherResponseModel? {
        guard let data = jsonString.data(using: .utf8) else {
            XCTFail("Failed to convert JSON string to Data")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(WeatherResponseModel.self, from: data)
        } catch {
            XCTFail("Failed to decode WeatherResponseModel: \(error.localizedDescription)")
            return nil
        }
    }
}

// MARK: - WeatherViewModel Unit Tests
final class WeatherViewModelTests: XCTestCase {
    private var viewModel: WeatherViewModel!
    private var mockService: MockWeatherService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockWeatherService()
        viewModel = WeatherViewModel(weatherService: mockService)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // Test decoding JSON response
    func testDecoding() {
        let jsonString = """
        {
          "main": { "temp": 22.5 },
          "weather": [{ "icon": "01d" }],
          "sys": { "sunrise": 1687430400, "sunset": 1687473600 }
        }
        """
        
        guard let mockResponse = MockWeatherService.responseFromJSONString(jsonString) else {
            XCTFail("Failed to decode mock response")
            return
        }
        
        XCTAssertEqual(mockResponse.main.temp, 22.5)
        XCTAssertEqual(mockResponse.weather.first?.icon, "01d")
        XCTAssertEqual(mockResponse.sys.sunrise, 1687430400)
        XCTAssertEqual(mockResponse.sys.sunset, 1687473600)
    }
    
    // Test icon URL formatting
    func testIconURLFormatting() {
        let iconCode = "10d"
        let expectedURL = URL(string: "https://openweathermap.org/img/wn/10d@2x.png")
        
        viewModel.icon = iconCode
        XCTAssertEqual(viewModel.iconURL, expectedURL)
    }
    
    // Test Unix time formatting indirectly
    func testFormatUnixTime() {
        let viewModel = WeatherViewModel()
        let unixTime: Double = 1687430400 // Fixed Unix timestamp
        let expectedFormattedTime: String = {
            let date = Date(timeIntervalSince1970: unixTime)
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.timeZone = .current
            return formatter.string(from: date)
        }()
        
        let formattedTime = viewModel.testableFormatUnixTime(unixTime)
        
        XCTAssertEqual(formattedTime, expectedFormattedTime, "Formatted time should match the expected value.")
    }
}

extension WeatherViewModel {
    func testableFormatUnixTime(_ unixTime: Double) -> String {
        return formatUnixTime(unixTime)
    }
}
