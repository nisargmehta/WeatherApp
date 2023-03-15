//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Nisarg Mehta on 3/10/23.
//

import XCTest
@testable import WeatherApp

class WeatherAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    private func dummyWeatherData() -> WeatherData {
        WeatherData(coord: Coordinate(lat: 3, lon: 4), weather: [], main: Main(temp: 4, humidity: 4), visibility: 5, wind: Wind(speed: 3), dt: 342, sys: System(country: "US"), timezone: 35, name: "abc")
    }
    
    private func dummyCityData() -> [City] {
        [City(name: "SF", lat: 23, lon: 44, country: "US", state: nil), City(name: "NY", lat: 87, lon: 98, country: "US", state: nil)]
    }
    
    func testValidInputShowsCityResults() {
        let data = dummyCityData()
        let mock = MockService(cities: data)
        let sut = ViewModel(service: mock)
        let testExpectation = expectation(description: "valid input")
        sut.citiesFetchedHandler = {
            testExpectation.fulfill()
        }
        sut.checkCriteriaAndSearch("abc")
        waitForExpectations(timeout: 2.0, handler: nil)
        XCTAssertEqual(sut.cities.count, 2)
    }
    
    func testNoWeatherDataWhenNetworkUnavailable() {
        let data = dummyCityData()
        let weather = dummyWeatherData()
        let mock = MockService(nwAvailable: false, cities: data, weather: weather)
        let sut = ViewModel(service: mock)
        let testExpectation = expectation(description: "no network weather data")
        testExpectation.isInverted = true
        sut.weatherDataFetchedHandler = { data, err in
            XCTAssert(data == nil)
            guard data != nil, err == nil else { return }
            testExpectation.fulfill()
        }
        sut.selectedCity = data.first
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}

struct MockService: WeatherServiceable {
    let nwAvailable: Bool
    let citiesData: [City]?
    let weatherData: WeatherData?
    let dummyError = NSError(domain: "", code: 401, userInfo: [ NSLocalizedDescriptionKey: "Invalid data"])
    
    init(nwAvailable: Bool = true,
         cities: [City]? = nil,
         weather: WeatherData? = nil) {
        self.nwAvailable = nwAvailable
        self.citiesData = cities
        self.weatherData = weather
    }
    
    func isNetworkAvailable() -> Bool {
        nwAvailable
    }
    
    func lookupCity(name: String, completion: @escaping (Result<[City], Error>) -> ()) {
        if let cities = citiesData {
            completion(.success(cities))
        } else {
            completion(.failure(dummyError))
        }
    }
    
    func getCurrentWeather(lat: String, long: String, completion: @escaping (Result<WeatherData, Error>) -> ()) {
        if let data = weatherData {
            completion(.success(data))
        } else {
            completion(.failure(dummyError))
        }
    }
    
    func downloadImage(name: String, completion: @escaping (Result<UIImage, Error>) -> ()) {
        // no op
    }
}
