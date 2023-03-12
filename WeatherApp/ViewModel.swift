//
//  ViewModel.swift
//  WeatherApp
//
//  Created by Nisarg Mehta on 3/11/23.
//

import Foundation

final class ViewModel {
    
    private enum Constants {
        static let minCount = 3
        static let delayInMs = 200
    }
    
    let service: WeatherService
    private(set) var cities: [City] = []
    private(set) var weatherData: WeatherData?
    private var pendingRequestWorkItem: DispatchWorkItem?
    var currentInput: String?
    
    var selectedCity: City? {
        didSet {
            self.getWeatherData(for: selectedCity)
        }
    }
    
    var citiesFetchedHandler: (() -> Void)?
    var weatherDataFetchedHandler: (() -> Void)?
    
    // inject the network service via initializer
    init(service: WeatherService) {
        self.service = service
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
    
    private func getWeatherData(for city: City?) {
        guard let city = city else { return }
        let latString = String(city.lat)
        let lonString = String(city.lon)
        service.getCurrentWeather(
            lat: latString,
            long: lonString
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
