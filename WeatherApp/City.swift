//
//  City.swift
//  WeatherApp
//
//  Created by Nisarg Mehta on 3/10/23.
//

import Foundation

struct City: Codable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
}
