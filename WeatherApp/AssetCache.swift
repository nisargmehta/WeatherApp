//
//  AssetCache.swift
//  WeatherApp
//
//  Created by Nisarg Mehta on 3/12/23.
//

import Foundation
import UIKit

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
