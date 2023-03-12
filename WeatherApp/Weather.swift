//
//  Weather.swift
//  WeatherApp
//
//  Created by Nisarg Mehta on 3/10/23.
//

import Foundation

struct WeatherData: Codable {
    let weather: [Weather]
    let main: Main
    let visibility: Double
    let wind: Wind
    let dt: Double
    let sys: System
    let timezone: Double
    let name: String
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
}

struct Wind: Codable {
    let speed: Double
}

struct System: Codable {
    let country: String
}