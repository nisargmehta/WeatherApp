//
//  AssetCache.swift
//  WeatherApp
//
//  Created by Nisarg Mehta on 3/12/23.
//

import Foundation
import UIKit
import CoreLocation

protocol DataCaching {
    associatedtype T
    associatedtype K
    func saveData(data: T, key: K)
    func getData(key: K) -> T?
}

struct ImageCache: DataCaching {
    typealias T = UIImage
    typealias K = NSString
    
    private let cache = NSCache<NSString, UIImage>()
    
    func saveData(data: UIImage, key: NSString) {
        cache.setObject(data, forKey: key)
    }
    
    func getData(key: NSString) -> UIImage? {
        cache.object(forKey: key)
    }
}

struct PersistentStore<C: Codable>: DataCaching {
    private let userDefaults = UserDefaults.standard
    typealias T = C
    typealias K = String
    
    func saveData(data: C, key: String) {
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults.set(encoded, forKey: key)
        }
    }
    
    func getData(key: String) -> C? {
        if let data = userDefaults.object(forKey: key) as? Data,
           let value = try? JSONDecoder().decode(C.self, from: data) {
            return value
        }
        return nil
    }
}
