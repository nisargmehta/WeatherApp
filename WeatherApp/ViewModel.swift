//
//  ViewModel.swift
//  WeatherApp
//
//  Created by Nisarg Mehta on 3/11/23.
//

import Foundation
import CoreLocation

final class ViewModel {
    
    private enum Constants {
        static let minCount = 3
        static let delayInMs = 200
    }
    
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
}

extension ViewModel: LocationDataDelegate {
    func statusChanged(status: CLAuthorizationStatus) {
        // handle status change
    }
    
    func currentLocationChanged() {
        fetchWeatherForCurrentLocation()
    }
}
