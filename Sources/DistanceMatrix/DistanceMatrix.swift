//
//  DistanceMatrix.swift
//  MapirServices
//
//  Created by Alireza Asadi on 5/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

@objc(DistanceMatrix)
public class DistanceMatrix: NSObject {

    public typealias DistanceMatrixCompletionHandler = (_ result: DistanceMatrix.Result?, _ error: Swift.Error?) -> Void

    /// Configuration for distance matrix calculation.
    public var configuration: DistanceMatrix.Configuration = .default

    /// Current status of `MapSnapshotter` object.
    public var isActive: Bool {
        if let task = activeTask {
            switch task.state {
            case .running:
                return true
            case .canceling, .suspended, .completed:
                return false
            @unknown default:
                fatalError("Unknown Task Status.")
            }
        } else {
            return false
        }
    }

    var activeTask: URLSessionDataTask?

    static var allowedCharacters: CharacterSet = {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "_") // Underscore is allowed.
        allowed.remove(charactersIn: "-") // Hyphen is not allowed.
        return allowed
    }()

    public func distanceMatrix(from origins: [String: CLLocationCoordinate2D],
                               to destinations: [String: CLLocationCoordinate2D],
                               configuartion: DistanceMatrix.Configuration,
                               completionHandler: @escaping DistanceMatrixCompletionHandler) {

        cancel()
        self.configuration = configuartion

        performDistanceMatrix(from: origins,
                              to: destinations,
                              using: self.configuration,
                              completionHandler: completionHandler,
                              decoder: decodeDistanceMatrix(from:))
    }

    public func distanceMatrix(from origins: [String: CLLocationCoordinate2D],
                               to destinations: [String: CLLocationCoordinate2D],
                               completionHandler: @escaping DistanceMatrixCompletionHandler) {

        distanceMatrix(from: origins,
                       to: destinations,
                       configuartion: configuration,
                       completionHandler: completionHandler)
    }

    public func cancel() {
        activeTask?.cancel()
        activeTask = nil
    }
}

// MARK: Errors

extension DistanceMatrix {

    @objc(DistanceMatrixError)
    public enum Error: UInt, Swift.Error {

        /// Indicates that you are not using a Map.ir API key or your key is invalid.
        case unauthorized

        /// Indicates that network was unavailable or a network error occured.
        case network

        /// Indicates that the task was canceled.
        case canceled

        /// Indicates that snapshot creation task had no result.
        case noResult

        /// Invalid input arguments.
        ///
        /// Errors in arguments contain issues like inserting no origins and/or no
        /// destinations, having empty string as key for any of input dictionaries or
        /// having "-" in the name.
        case invalidArguments
    }
}

// MARK: Running Task

extension DistanceMatrix {

    func performDistanceMatrix(from origins: [String: CLLocationCoordinate2D],
                               to destinations: [String: CLLocationCoordinate2D],
                               using config: Configuration,
                               completionHandler: @escaping DistanceMatrixCompletionHandler,
                               decoder: @escaping DecodingHandler) {
        guard AccountManager.isAuthorized else {
            completionHandler(nil, Error.unauthorized)
            return
        }

        guard validate(origins), validate(destinations) else {
            completionHandler(nil, Error.invalidArguments)
            return
        }

        let urlRequest = urlRequestForDistanceMatrixTask(origins: origins,
                                                         destinations: destinations,
                                                         configurations: configuration)

        activeTask = NetworkingManager.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            if error != nil {
                if let nsError = error as NSError?, nsError.code == NSURLErrorCancelled {
                    completionHandler(nil, Error.canceled)
                } else {
                    completionHandler(nil, Error.network)
                }
                return
            }

            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200:
                    if let data = data, let distanceMatrix = self?.decodeDistanceMatrix(from: data) {
                        completionHandler(distanceMatrix, nil)
                    } else {
                        completionHandler(nil, Error.noResult)
                    }
                case 401:
                    completionHandler(nil, Error.unauthorized)
                case 400, 402..<500:
                    completionHandler(nil, Error.noResult)
                case 300..<400, 500..<600:
                    completionHandler(nil, Error.network)
                default:
                    fatalError("Unknown response status code.")
                }
            } else {
                completionHandler(nil, Error.network)
            }
        }

        activeTask?.resume()
    }

    func validate(_ input: [String: CLLocationCoordinate2D]) -> Bool {
        guard !input.isEmpty else {
            return false
        }

        for (key, _) in input {
            guard !key.isEmpty, CharacterSet(charactersIn: key).isSubset(of: DistanceMatrix.allowedCharacters) else {
                return false
            }
        }

        return true
    }
}

// MARK: Decoder

extension DistanceMatrix {

    typealias DecodingHandler = (Data) -> Result?

    func decodeDistanceMatrix(from data: Data) -> DistanceMatrix.Result? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        if let decoded = try? decoder.decode(DistanceMatrix.Result.ResponseScheme.self, from: data) {
            return DistanceMatrix.Result(from: decoded)
        }
        return nil
    }
}

// MARK: Creating URL Request

extension DistanceMatrix {
    func urlRequestForDistanceMatrixTask(origins: [String: CLLocationCoordinate2D],
                                         destinations: [String: CLLocationCoordinate2D],
                                         configurations: Configuration) -> URLRequest {

        var urlComponents = NetworkingManager.baseURLComponents

        var queryParams: [String: String] = [:]

        let originsValue = origins
            .map { ["\($0.key)", "\($0.value.latitude)", "\($0.value.longitude)"].joined(separator: ",") }
            .joined(separator: "|")

        let destinationsValue = destinations
            .map { ["\($0.key)", "\($0.value.latitude)", "\($0.value.longitude)"].joined(separator: ",") }
            .joined(separator: "|")

        queryParams["origins"] = originsValue
        queryParams["destinations"] = destinationsValue

        queryParams["sorted"] = configuration.sortResults ? "true" : "false"

        if !configuration.includeDistances || !configuration.includeDurations {
            if configuration.includeDistances {
                 queryParams["$filter"] = "type eq distance"
            } else if configuration.includeDurations {
                queryParams["$filter"] = "type eq duration"
            }
        }

        urlComponents.queryItems = URLQueryItem.queryItems(from: queryParams)
        urlComponents.path = "/distancematrix"

        return NetworkingManager.request(url: urlComponents)
    }
}
