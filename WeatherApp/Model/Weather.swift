//
//  Weather.swift
//  WeatherApp
//
//  Created by Nisarg Mehta on 3/10/23.
//

import Foundation

struct WeatherData: Codable {
    let coord: Coordinate
    let weather: [Weather]
    let main: Main
    let visibility: Double
    let wind: Wind
    let dt: Double
    let sys: System
    let timezone: Double
    let name: String
    
    var dateString: String {
        let offset = dt + timezone
        let date = Date(timeIntervalSince1970: offset)
        return DateFormatter.dayWithDateAndTime.string(from: date)
    }
}

struct Coordinate: Codable {
    let lat: Double
    let lon: Double
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Double
    let humidity: Int
    
    var tempInF: String {
        let f = (temp - 273.15) * 9/5 + 32
        return String(format: "%.1f °F", f)
    }
    
    var humidityString: String {
        String("\(humidity) %")
    }
}

struct Wind: Codable {
    let speed: Double
    var windString: String {
        String("\(speed) m/s")
    }
}

struct System: Codable {
    let country: String
}
