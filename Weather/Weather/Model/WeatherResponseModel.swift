//
//  WeatherResponseModel.swift
//  Weather
//
//  Created by Varsana Maharaj on 2025/06/20.
//

import Foundation

/// Represents the complete weather response returned by the API.

struct WeatherResponseModel: Decodable {
    let main: Main
    let sys: SystemResponse
    let weather: [WeatherInfo]
    
    struct Main: Decodable {
        let temp: Double
    }
    
    struct WeatherInfo: Decodable {
        let icon: String
    }
    
    struct SystemResponse: Decodable {
        let sunrise: Double
        let sunset: Double
    }
}
