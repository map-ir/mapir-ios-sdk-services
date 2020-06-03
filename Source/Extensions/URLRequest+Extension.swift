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

    init(
        url urlComponents: URLComponents,
        httpMethod: URLRequest.HTTPMethod = .get,
        body: Data? = nil
    ) {

        guard let url = urlComponents.url else {
            fatalError("Couldn't create url from URLComponents due to invalid components.")
        }

        self.init(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60.0)
        self.httpMethod = httpMethod.rawValue

        if httpMethod == .post {
            httpBody = body
        }

        if let accessToken = AccountManager.apiKey {
            addValue(accessToken, forHTTPHeaderField: "x-api-key")
        }

        addValue(Utilities.userAgent, forHTTPHeaderField: "User-Agent")
        addValue(Utilities.sdkIDForHeader, forHTTPHeaderField: "MapIr-SDK")
    }
}
