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
    }
    
    let imageCache = ImageCache()
    let manager = LocationDataManager()
    let service: WeatherService
    private(set) var cities: [City] = []
    private(set) var weatherData: WeatherData?
    private var pendingRequestWorkItem: DispatchWorkItem?
    var currentInput: String?
    
    var selectedCity: City? {
        didSet {
            guard let city = selectedCity else {
                return
            }
            self.getWeatherData(lat: String(city.lat), lon: String(city.lon))
            // persist selection
        }
    }
    
    var citiesFetchedHandler: (() -> Void)?
    var weatherDataFetchedHandler: (() -> Void)?
    
    // inject the network service via initializer
    init(service: WeatherService) {
        self.service = service
        self.manager.dataDelegate = self
    }
    
    // MARK: - logic funcs
    func fetchWeatherForCurrentLocation() {
        let status = manager.locationManager.authorizationStatus
        guard status == .authorizedWhenInUse || status == .authorizedAlways, let coordinate = manager.getCurrentCoordinates() else {
            return
        }
        let lat = String(coordinate.latitude)
        let lon = String(coordinate.longitude)
        self.getWeatherData(lat: lat, lon: lon)
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
        currentInput = input
        pendingRequestWorkItem?.cancel()
        pendingRequestWorkItem = nil
        
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
            if self.currentInput != input {
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
        service.getCurrentWeather(
            lat: lat,
            long: lon
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.weatherData = data
                    self.weatherDataFetchedHandler?()
                case .failure(let error):
                    print(error.localizedDescription)
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
        fetchWeatherForCurrentLocation()
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
