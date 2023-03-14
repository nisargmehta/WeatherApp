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
    
    var fullName: String {
        var title = "\(name), \(country)"
        if let st = state {
            title = "\(name), \(st), \(country)"
        }
        return title
    }
}
