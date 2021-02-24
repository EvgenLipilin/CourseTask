//
//  APIManager.swift
//  Course2FinalTask
//
//  Created by Евгений on 19.02.2021.
//  Copyright © 2021 e-Legion. All rights reserved.
//

import Foundation
import UIKit

typealias JSONTask = URLSessionDataTask
typealias JSONCompletionHandler = (Data?, HTTPURLResponse?, Error?) -> Void

enum APIResult<T> {
    case success(T)
    case failure(Error)
}

protocol APIManager {
    var sessionConfiguration: URLSessionConfiguration { get }
    var session: URLSession { get }
    
    func fetch<T: Codable>(request: URLRequest, completionHandler: @escaping (APIResult<T>) -> Void)
}

extension APIManager {
    
    private func JSONTask(request: URLRequest, completionHandler: @escaping JSONCompletionHandler) -> JSONTask {
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            
            guard let HTTPResponse = response as? HTTPURLResponse else {

                let error = NSError()
                completionHandler(nil, nil ,error)
                return
            }
            
            if data != nil {
                print("response = \(HTTPResponse.statusCode)")
                completionHandler(data, HTTPResponse, nil)
            } else {
                let error: ErrorManager
                
                switch HTTPResponse.statusCode {
                case 400: error = .badRequest
                case 401: error = .unauthorized
                case 404: error = .notFound
                case 406: error = .notAcceptable
                case 422: error = .unprocessable
                default: error = .transferError
                }

                completionHandler(nil, HTTPResponse, error)
            }
        }
        return dataTask
    }
    
    func fetch<T: Codable>(request: URLRequest, completionHandler: @escaping (APIResult<T>) -> Void) {
        
        let dataTask = JSONTask(request: request) { (data, _, error) in
            
            DispatchQueue.main.async {
                guard let data = data else {
                    if let error = error {
                        completionHandler(.failure(error))
                    }
                    return
                }
                
                if data.isEmpty {
//                    Для logout, так как там нет JSON
                    let error = NSError()
                    completionHandler(.failure(error))
                }
                
                if let value = decodeJSON(type: T.self, from: data) {
                    completionHandler(.success(value))
                } else {
                    let error = NSError()
                    completionHandler(.failure(error))
                }
            }
        }
        dataTask.resume()
    }
    
    private func decodeJSON<T: Codable>(type: T.Type, from: Data?) -> T? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        guard let data = from else { return nil }
        do {
            let objects = try decoder.decode(type.self, from: data)
            return objects
        } catch let jsonError {
            print("Failed to decode JSON", jsonError.localizedDescription)
            return nil
        }
    }
}
