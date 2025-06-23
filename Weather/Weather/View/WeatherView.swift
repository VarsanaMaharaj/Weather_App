//
//  WeatherView.swift
//  Weather
//
//  Created by Varsana Maharaj on 2025/06/20.
//

import Foundation
import SwiftUI
import CoreLocationUI

/// A SwiftUI view that displays current weather information and user location.

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            VStack {
                LocationButton(.shareCurrentLocation) {
                    locationManager.requestLocation()
                    ProgressView("Loading...")
                }
                .cornerRadius(30)
                .symbolVariant(.fill)
                .foregroundColor(.white)
                .padding(40)

                Text("Temperature: \(viewModel.temperature)")
                    .font(.title)
                    .padding()
                
                if let iconURL = viewModel.iconURL {
                    AsyncImage(url: iconURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    } placeholder: {
                        ProgressView()
                    }
                }
                Text("🌅 Sunrise: \(viewModel.sunrise)")
                    .font(.subheadline)
                
                Text("🌄 Sunset: \(viewModel.sunset)")
                    .font(.subheadline)
                
                Button("Refresh") {
                    viewModel.fetchWeather(latitude: locationManager.latitude ?? 4.0, longitude: locationManager.longitude ?? 4.0)
                }
                    .padding()
                
                if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .onAppear() {
            locationManager.requestLocation()
            viewModel.fetchWeather(latitude: locationManager.latitude ?? 4.0, longitude: locationManager.longitude ?? 4.0)
        }
    }
}

#Preview {
    NavigationView() {
        WeatherView()
    }
}
