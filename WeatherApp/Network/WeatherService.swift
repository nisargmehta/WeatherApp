//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Nisarg Mehta on 3/10/23.
//

import Foundation
import UIKit
import Network

protocol WeatherServiceable {
    func isNetworkAvailable() -> Bool
    func lookupCity(name: String, completion: @escaping(Result<[City], Error>) -> ())
    func getCurrentWeather(lat: String, long: String, completion: @escaping(Result<WeatherData, Error>) -> ())
    func downloadImage(name: String, completion: @escaping(Result<UIImage, Error>) -> ())
}

class WeatherService: WeatherServiceable, NetworkClient {
    var pathMonitor: NWPathMonitor!
    var path: NWPath?
    lazy var pathUpdateHandler: ((NWPath) -> Void) = { [weak self] value in
        guard let self = self else { return }
        self.path = value
        if self.path?.status == NWPath.Status.satisfied {
            print("Connected")
        } else if self.path?.status == NWPath.Status.unsatisfied {
            print("unsatisfied")
        } else if self.path?.status == NWPath.Status.requiresConnection {
            print("requiresConnection")
        }
    }
    
    let backgroudQueue = DispatchQueue.global(qos: .background)
    
    init() {
        pathMonitor = NWPathMonitor()
        pathMonitor.pathUpdateHandler = self.pathUpdateHandler
        pathMonitor.start(queue: backgroudQueue)
    }
    
    func downloadImage(name: String, completion: @escaping (Result<UIImage, Error>) -> ()) {
        request(endpoint: WeatherEndpoint.downloadIcon(name)) { imageResult in
            switch imageResult {
            case .success(let data):
                if let image = UIImage(data: data) {
                    completion(.success(image))
                } else {
                    // error
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func isNetworkAvailable() -> Bool {
        if let path = self.path {
            if path.status == NWPath.Status.satisfied {
                return true
            }
        }
        return false
    }
    
    func lookupCity(name: String, completion: @escaping (Result<[City], Error>) -> ()) {
        request(endpoint: WeatherEndpoint.lookupCity(name)) { result in
            switch result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode([City].self, from: data)
                    completion(.success(decoded))
                } catch let err {
                    completion(.failure(err))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getCurrentWeather(lat: String, long: String, completion: @escaping (Result<WeatherData, Error>) -> ()) {
        request(endpoint: WeatherEndpoint.getCurrentWeather(lat: lat, long: long)) { result in
            switch result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(WeatherData.self, from: data)
                    completion(.success(decoded))
                } catch let err {
                    completion(.failure(err))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    // TODO: refactor json decoding code to avoid duplication
}
