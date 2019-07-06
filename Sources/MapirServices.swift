//
//  MapirServices.swift
//  MapirServices
//
//  Created by Alireza Asadi on 31 Ordibehesht, 1398 AP.
//  Copyright © 1398 Map. All rights reserved.
//

// Include Foundation
@_exported import Foundation

public class MPSMapirServices {

    private struct Endpoint {
        static let reverseGeocode = "/reverse"
        static let fastReverseGeocode = "/fast-reverse"
        static let distanceMatrix = "/distancematrix"

    }

    static let shared = MPSMapirServices()
    
    let baseURL: URL! = URL(string: "https://map.ir")
    
    private let token: String

    private let session: URLSession = .shared

    private let decoder = JSONDecoder()
    
    private init() {
        let token = Bundle.main.object(forInfoDictionaryKey: "MAPIRServicesAccessToken") as? String
        self.token = token!
    }

    private func essentialRequest(withEndpoint endpoint: String, query: String, httpMethod: String) -> URLRequest? {
        let url = URL(string: baseURL.absoluteString + endpoint + query)
        var request = URLRequest(url: url!)
        request.timeoutInterval = 10
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        return request
    }

    public func getReverseGeocode(for point: MPSLocationCoordinate,
                                  completionHandler: @escaping (Result<MPSReverseGeocode, Error>) -> Void) {

        let query: String = "?lat=\(point.latitude)&lng=\(point.longitude)"
        let request = essentialRequest(withEndpoint: Endpoint.reverseGeocode, query: query, httpMethod: HTTPMethod.get)

        if let request = request {
            let dataTask = session.dataTask(with: request) { (data, urlResponse, error) in
                if let error = error {
                    DispatchQueue.main.async { completionHandler(.failure(error)) }
                    return
                }
                if let urlResponse = urlResponse as? HTTPURLResponse {
                    let statusCode = urlResponse.statusCode

                    if statusCode == 200 {
                        if let data = data {
                            do {
                                let decodedData = try self.decoder.decode(MPSReverseGeocode.self, from: data)
                                DispatchQueue.main.async { completionHandler(.success(decodedData)) }
                                return
                            } catch let parseError {
                                DispatchQueue.main.async { completionHandler(.failure(parseError)) }
                                return
                            }
                        }
                    } else if statusCode == 400 {
                        DispatchQueue.main.async { completionHandler(.failure(MPSError.RequestError.badRequest(code: 400))) }
                    } else if statusCode == 404 {
                        DispatchQueue.main.async { completionHandler(.failure(MPSError.RequestError.notFound)) }
                    }
                }
            }

            dataTask.resume()
        }

    }

    public func getFastReverseGeocode(for point: MPSLocationCoordinate,
                                      completionHandler: @escaping (Result<MPSFastReverseGeocode, Error>) -> Void) {

        let query: String = "?lat=\(point.latitude)&lng=\(point.longitude)"
        let request = essentialRequest(withEndpoint: Endpoint.reverseGeocode, query: query, httpMethod: HTTPMethod.get)

        if let request = request {
            let dataTask = session.dataTask(with: request) { (data, urlResponse, error) in
                if let error = error {
                    DispatchQueue.main.async { completionHandler(.failure(error)) }
                    return
                }
                if let urlResponse = urlResponse as? HTTPURLResponse {
                    let statusCode = urlResponse.statusCode

                    if statusCode == 200 {
                        if let data = data {
                            do {
                                let decodedData = try self.decoder.decode(MPSFastReverseGeocode.self, from: data)
                                DispatchQueue.main.async { completionHandler(.success(decodedData)) }
                                return
                            } catch let parseError {
                                DispatchQueue.main.async { completionHandler(.failure(parseError)) }
                                return
                            }
                        }
                    } else if statusCode == 400 {
                        DispatchQueue.main.async { completionHandler(.failure(MPSError.RequestError.badRequest(code: 400))) }
                    } else if statusCode == 404 {
                        DispatchQueue.main.async { completionHandler(.failure(MPSError.RequestError.notFound)) }
                    }
                }
            }

            dataTask.resume()
        }

    }

    public func getDistanceMatrix(from origins: [MPSLocationCoordinate],
                                  to destinations: [MPSLocationCoordinate],
                                  options: MPSDistanceMatrixOptions = [],
                                  completionHandler: @escaping (Result<MPSDistanceMatrix, Error>) -> Void) {

        var query: String = "?"
        query += "origins="
        for origin in origins {
            let uuid = UUID()
            query += "\(uuid),\(origin.latitude),\(origin.longitude)|"
        }
        query.removeLast()
        query += "&destinations="
        for destination in destinations {
            let uuid = UUID()
            query += "\(uuid),\(destination.latitude),\(destination.longitude)|"
        }
        query.removeLast()
        if options.contains(.sorted) {
            query += "&sorted=true"
        }
        if !(options.contains(.distance) && options.contains(.duration)) {
            if options.contains(.distance) {
                query += "&$filter=type eq distance"
            }
            if options.contains(.duration) {
                query += "&$filter=type eq duration"
            }
        }

        guard let urlEncodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            completionHandler(.failure(MPSError.RequestError.InvalidArgument))
            return
        }

        guard let request = essentialRequest(withEndpoint: Endpoint.distanceMatrix, query: urlEncodedQuery, httpMethod: HTTPMethod.get) else {
            completionHandler(.failure(MPSError.RequestError.InvalidArgument))
            return
        }

        session.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                DispatchQueue.main.async { completionHandler(.failure(error)) }
                return
            }

            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                completionHandler(.failure(MPSError.InvalidResponse))
                return
            }

            let statusCode = urlResponse.statusCode

            switch statusCode {
            case 200:
                if let data = data {
                    do {
                        let decodedData = try self.decoder.decode(MPSDistanceMatrix.self, from: data)
                        DispatchQueue.main.async { completionHandler(.success(decodedData)) }
                        return
                    } catch let parseError {
                        completionHandler(.failure(parseError))
                    }
                }
            case 400:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.RequestError.badRequest(code: 400))) }
                return
            case 404:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.RequestError.notFound)) }
                return
            default:
                return
            }
        }
    }
}



protocol MPSRequest {
    var method: HTTPMethod { get set }
    var parameters: Parameters? { get set }
    func request(onCompletion: ((Error, Decodable) -> Void))
}
