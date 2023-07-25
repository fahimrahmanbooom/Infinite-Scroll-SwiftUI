//
//  NetworkManager.swift
//  Infinate-Scroll-SwiftUI
//
//  Created by Fahim Rahman on 2023-07-25.
//

import Foundation
import Alamofire

class NetworkManager {
    
    static let shared = NetworkManager()
    
    func makeGenericAPIRequest(url: String, method: HTTPMethod, parameters: Parameters? = nil, headers: HTTPHeaders? = nil, completion: @escaping (Result<Any, Error>) -> Void) {
        AF.request(url, method: method, parameters: parameters, headers: headers).response { response in
            switch response.result {
            case .success(let data):
                do {
                    if let jsonData = data {
                        let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
                        completion(.success(json))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
