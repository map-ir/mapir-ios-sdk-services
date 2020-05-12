//
//  URLRequest+Extension.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 8/9/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

extension URLRequest {

    enum HTTPMethod: String {
        case get
        case post
        case delete
    }

    init(url urlComponents: URLComponents,
         httpMethod: URLRequest.HTTPMethod = .get,
         cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
         timeoutInterval: TimeInterval = 60.0) {

        guard let url = urlComponents.url else {
            fatalError("Something went wrong in converting URLComponent to URL.")
        }

        self.init(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        self.httpMethod = httpMethod.rawValue
    }
}
