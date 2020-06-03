//
//  URLSession+Extension.swift
//  MapirServices
//
//  Created by Alireza Asadi on 11/3/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import Foundation

extension URLSession {
    @discardableResult
    func dataTask<Response>(
        with urlRequest: URLRequest,
        decoderBlock: @escaping (Data) -> Response?,
        completionHandler: @escaping (Result<Response, Error>) -> Void
    ) -> URLSessionDataTask? {
        let dataTask = self.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                if let nsError = error as NSError?, nsError.code == NSURLErrorCancelled {
                    completionHandler(.failure(ServiceError.canceled))
                } else {
                    completionHandler(.failure(ServiceError.network))
                }
                return
            }

            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200, 201:
                    if let data = data, let decoded = decoderBlock(data) {
                        completionHandler(.success(decoded))
                    } else {
                        completionHandler(.failure(ServiceError.noResult))
                    }
                case 401:
                    NotificationCenter.default.post(name: Utilities.unauthorizedNotification, object: nil)
                    completionHandler(.failure(ServiceError.unauthorized(reason: .wrong)))
                case 400, 402..<500:
                    completionHandler(.failure(ServiceError.noResult))
                case 300..<400:
                    completionHandler(.failure(ServiceError.network))
                case 500..<600:
                    completionHandler(.failure(ServiceError.serverError(httpStatusCode: response.statusCode)))
                default:
                    fatalError("Unknown response status code.")
                }
            } else {
                completionHandler(.failure(ServiceError.network))
            }
        }

        return dataTask
    }
}
