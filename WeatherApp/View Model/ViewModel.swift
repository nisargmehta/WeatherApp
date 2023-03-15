//
//  ViewModel.swift
//  WeatherApp
//
//  Created by Nisarg Mehta on 3/11/23.
//

import Foundation
import CoreLocation
import UIKit

final class ViewModel {
    
    private enum Constants {
        static let minCount = 3
        static let delayInMs = 200
        static let coordinateKey = "locationCoordinateKey"
    }
    
    let imageCache = ImageCache()
    let dataStore = PersistentStore<Coordinate>()
    let manager = LocationDataManager()
    let service: WeatherServiceable
    private(set) var cities: [City] = []
    private(set) var weatherData: WeatherData?
    private var pendingRequestWorkItem: DispatchWorkItem?
    // current city search input
    var currentSearchInput: String?
    
    var selectedCity: City? {
        didSet {
            guard let city = selectedCity else {
                return
            }
            self.getWeatherData(lat: String(city.lat), lon: String(city.lon))
        }
    }
    
    var citiesFetchedHandler: (() -> Void)?
    var weatherDataFetchedHandler: ((WeatherData?, Error?) -> Void)?
    
    // inject the network service via initializer
    init(service: WeatherServiceable) {
        self.service = service
        self.manager.dataDelegate = self
    }
    
    // MARK: - logic funcs
    func fetchWeatherIfPossible() {
        // weather for current location
        let status = manager.locationManager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways, let coordinate = manager.getCurrentCoordinates() {
            let lat = String(coordinate.latitude)
            let lon = String(coordinate.longitude)
            self.getWeatherData(lat: lat, lon: lon)
            return
        }
        // weather for saved location
        else if let coordinate = dataStore.getData(key: Constants.coordinateKey) {
            let lat = String(coordinate.lat)
            let lon = String(coordinate.lon)
            self.getWeatherData(lat: lat, lon: lon)
            return 
        }
        else {
            // TODO: inform the view
        }
    }
        
    func checkCriteriaAndSearch(_ text: String) {
        let input = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if input.count < Constants.minCount {
            if input.count == 0 {
                cities = []
                citiesFetchedHandler?()
            }
            print("min count")
            return
        }
        if !service.isNetworkAvailable() {
            return
        }
        currentSearchInput = input
        pendingRequestWorkItem?.cancel()
        pendingRequestWorkItem = nil
        
        // using dispatch work item to throttle user input
        let requestWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.fetchCities(input)
        }
        pendingRequestWorkItem = requestWorkItem
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(Constants.delayInMs),
                                          execute: requestWorkItem)
    }
    
    private func fetchCities(_ input: String) {
        service.lookupCity(name: input) { [weak self] result in
            guard let self = self else { return }
            // in case we get an older network call result
            if self.currentSearchInput != input {
                return
            }
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    print(items)
                    self.cities = items
                    // notify via the handler
                    self.citiesFetchedHandler?()
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
        }
    }
    
    private func getWeatherData(lat: String, lon: String) {
        if !service.isNetworkAvailable() {
            self.weatherDataFetchedHandler?(nil, nil)
            return
        }
        service.getCurrentWeather(
            lat: lat,
            long: lon
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.weatherData = data
                    // persist coordinates
                    let c = data.coord
                    self.dataStore.saveData(data: c, key: Constants.coordinateKey)
                    self.weatherDataFetchedHandler?(data, nil)
                case .failure(let error):
                    print(error.localizedDescription)
                    self.weatherDataFetchedHandler?(nil, error)
                }
            }
        }
    }
    
    func getIconImage(name: String, completion: @escaping ((UIImage?) -> Void)) {
        // find in cache
        if let img = imageCache.getData(key: name as NSString) {
            completion(img)
            return
        }
        if !service.isNetworkAvailable() {
            return
        }
        service.downloadImage(name: name) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    // cache image
                    self?.imageCache.saveData(data: data, key: name as NSString)
                    completion(data)
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }
}

extension ViewModel: LocationDataDelegate {
    func statusChanged(status: CLAuthorizationStatus) {
        // handle status change
    }
    
    func currentLocationChanged() {
        fetchWeatherIfPossible()
    }
}

// MARK: - weather data fetchers
extension ViewModel {
    func getCityName() -> String {
        self.weatherData?.name ?? ""
    }
    
    func getDateString() -> String {
        self.weatherData?.dateString ?? ""
    }
    
    func getTempString() -> String {
        self.weatherData?.main.tempInF ?? ""
    }
    
    func getDescription() -> String {
        self.weatherData?.weather.first?.description ?? ""
    }
    
    func getHumidity() -> String {
        self.weatherData?.main.humidityString ?? ""
    }
    
    func getWindSpeed() -> String {
        self.weatherData?.wind.windString ?? ""
    }
    
    func getIconName() -> String? {
        self.weatherData?.weather.first?.icon
    }
}
