//
//  WeatherService.swift
//  Weather
//
//  Created by Varsana Maharaj on 2025/06/22.
//

import Foundation
import CoreLocation

/// Protocol defining the weather fetching service interface.

protocol WeatherServiceProtocol {
    /**
     Fetches weather data for the specified latitude and longitude.
     
     - Parameters:
     - latitude: The latitude coordinate.
     - longitude: The longitude coordinate.
     - completion: A closure called with the result of the fetch operation,
     either a success with `WeatherResponseModel` or a failure with an `Error`.
     */
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (Result<WeatherResponseModel, Error>) -> Void)
}

/// Concrete implementation of `WeatherServiceProtocol` using OpenWeatherMap API.

class WeatherService: WeatherServiceProtocol {
    private let apiKey = "32dd395a6acffa18009d14e576917144"
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    /**
     Fetches weather data asynchronously from OpenWeatherMap API for the given coordinates.
     
     - Parameters:
     - latitude: Latitude of the location.
     - longitude: Longitude of the location.
     - completion: Completion handler returning a `Result` with either
     `WeatherResponseModel` on success or an `Error` on failure.
     */
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (Result<WeatherResponseModel, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0)))
                return
            }
            
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponseModel.self, from: data)
                completion(.success(weatherResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

