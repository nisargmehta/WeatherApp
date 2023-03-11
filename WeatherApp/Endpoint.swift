//
//  Endpoint.swift
//  WeatherApp
//
//  Created by Nisarg Mehta on 3/10/23.
//

import Foundation

enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol Endpoint {
    var scheme: String { get }
    var baseUrl: String { get }
    var path: String { get }
    var method: RequestMethod { get }
    var paramaters: [URLQueryItem] { get }
    var headers: [String: String]? { get }
}

struct WeatherEndpoint: Endpoint {
    var scheme: String = "https"
    
    var baseUrl: String
    
    var path: String
    
    var method: RequestMethod
    
    var paramaters: [URLQueryItem]
    
    var headers: [String : String]?
}

extension WeatherEndpoint {
    private static let apiKey = "1e6ffd8120367c7e4cf94c5df1409830"
    
    static func lookupCity(_ name: String) -> WeatherEndpoint {
        WeatherEndpoint(
            baseUrl: "api.openweathermap.org",
            path: "/geo/1.0/direct",
            method: .get,
            paramaters: [URLQueryItem(name: "q", value: name),
                         URLQueryItem(name: "limit", value: "5"),
                         URLQueryItem(name: "appid", value: WeatherEndpoint.apiKey)]
        )
    }
    
    // https://openweathermap.org/img/wn/10d@2x.png
    static func downloadIcon(_ name: String) -> WeatherEndpoint {
        WeatherEndpoint(
            baseUrl: "openweathermap.org",
            path: "/img/wn/\(name)@2x.png",
            method: .get,
            paramaters: []
        )
    }
    
    static func getCurrentWeather(lat: String, long: String) -> WeatherEndpoint {
        WeatherEndpoint(
            baseUrl: "api.openweathermap.org",
            path: "/data/2.5/weather",
            method: .get,
            paramaters: [URLQueryItem(name: "lat", value: lat),
                         URLQueryItem(name: "lon", value: long),
                         URLQueryItem(name: "appid", value: WeatherEndpoint.apiKey)]
        )
    }
}
