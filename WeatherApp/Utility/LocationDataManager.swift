//
//  LocationDataManager.swift
//  WeatherApp
//
//  Created by Nisarg Mehta on 3/12/23.
//

import Foundation
import CoreLocation

protocol LocationDataDelegate: AnyObject {
    func statusChanged(status: CLAuthorizationStatus)
    func currentLocationChanged()
}

class LocationDataManager: NSObject, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    weak var dataDelegate: LocationDataDelegate?
    private var currentLocation: CLLocation?
    
    override init() {
        super.init()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
        }
    }
    
    // Location-related properties and delegate methods.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            print("when in use")
            manager.requestLocation()
            break
        case .denied, .restricted:
            print("denied")
            break
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            break
        }
        dataDelegate?.statusChanged(status: manager.authorizationStatus)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, manager.authorizationStatus == .authorizedWhenInUse else { return }
        print(location)
        dataDelegate?.currentLocationChanged()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func getCurrentCoordinates() -> CLLocationCoordinate2D? {
        locationManager.location?.coordinate
    }
}
