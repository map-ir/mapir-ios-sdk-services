//
//  DistanceMatrix.swift
//  MapirServices
//
//  Created by Alireza Asadi on 5/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation
import CoreLocation

@objc(SHDistanceMatrix)
public class DistanceMatrix: NSObject {

    public typealias DistanceMatrixCompletionHandler = (_ result: DistanceMatrix.Result?, _ error: Swift.Error?) -> Void

    /// Configuration for distance matrix calculation.
    public var configuration: DistanceMatrix.Configuration = .default

    /// Current status of `DistanceMatrix` object.
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
                               configuration: DistanceMatrix.Configuration,
                               completionHandler: @escaping DistanceMatrixCompletionHandler) {

        cancel()
        self.configuration = configuration

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
                       configuration: configuration,
                       completionHandler: completionHandler)
    }

    public func cancel() {
        activeTask?.cancel()
        activeTask = nil
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
            completionHandler(nil, ServiceError.unauthorized)
            return
        }

        if let validationError = validate(origins) {
            completionHandler(nil, validationError)
            return
        }
        if let validationError = validate(destinations) {
            completionHandler(nil, validationError)
            return
        }

        let urlRequest = urlRequestForDistanceMatrixTask(origins: origins,
                                                         destinations: destinations,
                                                         configurations: configuration)

        activeTask = NetworkingManager.dataTask(
            with: urlRequest,
            decoderBlock: decoder,
            completionHandler: completionHandler)
        
        activeTask?.resume()
    }

    func validate(_ input: [String: CLLocationCoordinate2D]) -> Error? {
        guard !input.isEmpty else {
            return ServiceError.DistanceMatrixError.emptyWaypointDictionary
        }

        for (key, _) in input {
            guard !key.isEmpty, CharacterSet(charactersIn: key).isSubset(of: DistanceMatrix.allowedCharacters) else {
                return ServiceError.DistanceMatrixError.invalidCharacterInNames
            }
        }

        return nil
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
