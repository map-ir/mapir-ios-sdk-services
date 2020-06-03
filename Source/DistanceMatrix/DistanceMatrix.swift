//
//  DistanceMatrix.swift
//  MapirServices
//
//  Created by Alireza Asadi on 5/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation
import CoreLocation

public class DistanceMatrix {

    public typealias DistanceMatrixCompletionHandler = (Swift.Result<DistanceMatrix.Result,Swift.Error>) -> Void

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

    lazy var allowedCharacters: CharacterSet = {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "_") // Underscore is allowed.
        return allowed
    }()

    /// Creates `DisanceMatrix` wrapper.
    public init() { }

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
            completionHandler(.failure(ServiceError.unauthorized(reason: .init())))
            return
        }

        if let validationError = validate(origins) {
            completionHandler(.failure(validationError))
            return
        }
        if let validationError = validate(destinations) {
            completionHandler(.failure(validationError))
            return
        }

        let urlRequest = urlRequestForDistanceMatrixTask(origins: origins,
                                                         destinations: destinations,
                                                         configurations: configuration)

        activeTask = Utilities.session.dataTask(
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
            guard !key.isEmpty else {
                return ServiceError.DistanceMatrixError.invalidCharacterInNames(name: key, characters: [Character("")])
            }

            let wrongCharacters = key.unicodeScalars.filter { !allowedCharacters.contains($0) }.map(Character.init)
            if !wrongCharacters.isEmpty {
                return ServiceError.DistanceMatrixError.invalidCharacterInNames(name: key, characters: wrongCharacters)
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

        var urlComponents = Utilities.baseURLComponents

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

        return URLRequest(url: urlComponents)
    }
}
