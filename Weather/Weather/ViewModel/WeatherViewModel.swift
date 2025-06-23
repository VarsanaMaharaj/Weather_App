//
//  WeatherViewModel.swift
//  Weather
//
//  Created by Varsana Maharaj on 2025/06/20.
//

import Foundation
import CoreLocation
import SwiftUI

/// ViewModel responsible for fetching and formatting weather data for presentation in views.

class WeatherViewModel: ObservableObject {
    @Published var temperature: String = ""
    @Published var icon: String = ""
    @Published var sunrise: String = ""
    @Published var sunset: String = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    var iconURL: URL? {
        return getWeatherIconURL(for: icon)
    }
    
    private let weatherService: WeatherServiceProtocol
    
    /// Initializes the ViewModel with an optional weather service

    init(weatherService: WeatherServiceProtocol = WeatherService()) {
        self.weatherService = weatherService
    }
    
    /// Fetches weather data for the specified coordinates.
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        weatherService.fetchWeather(latitude: latitude, longitude: longitude) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weather):
                    self?.updateUI(with: weather)
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch weather data: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func refreshWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        fetchWeather(latitude: latitude , longitude: longitude)
    }
    
    /// Updates the published properties with weather data.
    
    private func updateUI(with weather: WeatherResponseModel) {
        self.temperature = "\(Int(weather.main.temp))°C"
        self.icon = weather.weather.first?.icon ?? "01d"
        self.sunrise = formatUnixTime(weather.sys.sunrise)
        self.sunset = formatUnixTime(weather.sys.sunset)
    }
    
    /// Generates a URL for the weather icon based on icon code and size.
    
    private func getWeatherIconURL(for iconCode: String, size: Int = 2) -> URL? {
            let baseURL = "https://openweathermap.org/img/wn/"
            let formattedURLString = "\(baseURL)\(iconCode)@\(size)x.png"
            return URL(string: formattedURLString)
    }
    
    /// Converts a Unix timestamp to a formatted local time string.
   
    func formatUnixTime(_ unixTime: Double) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter.string(from: date)
    }
}
