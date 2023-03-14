//
//  NetworkClient.swift
//  WeatherApp
//
//  Created by Nisarg Mehta on 3/10/23.
//

import Foundation
import UIKit

protocol NetworkClient {
    func request(endpoint: Endpoint,
                 completion: @escaping(Result<Data, Error>) -> ())
}

extension NetworkClient {
    
    private func requestBuilder(endpoint: Endpoint) -> URLRequest? {
        var comp = URLComponents()
        comp.scheme = endpoint.scheme
        comp.host = endpoint.baseUrl
        comp.path = endpoint.path
        comp.queryItems = endpoint.paramaters
        guard let url = comp.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        return request
    }
    
    func request(endpoint: Endpoint, completion: @escaping(Result<Data, Error>) -> ()) {
        guard let request = requestBuilder(endpoint: endpoint) else {
            // completion with failure
            return
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            guard response != nil, let data = data else { return }
            completion(.success(data))
        }
        task.resume()
    }
}
