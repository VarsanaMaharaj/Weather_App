# WeatherApp

## Overview
A simple SwiftUI-based Weather application that fetches and displays current weather information for your location using the OpenWeatherMap API.

## Features
- Requests location access to determine the user's current position.
- Shows current temperature in Celsius.
- Displays weather icon corresponding to the current weather condition.
- Shows sunrise and sunset times.
- Allows users to refresh the data using a "Refresh" button.
- Displays loading state and error messages 
- MVVM architecture and follows best practices.
- Includes unit tests for key components.

## Requirements
- iOS 15.0+ / macOS 12.0+ (or adjust based on your deployment target)
- Xcode 14 or newer
- Swift 5.7 or newer
- An active internet connection (to fetch weather data)
- OpenWeatherMap API key (already embedded in the code, but recommended to replace with your own key)

## Setup Instructions
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd WeatherApp
