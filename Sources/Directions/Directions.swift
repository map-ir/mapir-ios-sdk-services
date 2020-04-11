//
//  Directions.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 11/12/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

/// <#Description#>
@objc public final class Directions: NSObject {

    ///
    public typealias DirectionsCompletionHandler = (_ result: Directions.Result?, _ Error: Swift.Error?) -> Void

    @objc public var configuration: Directions.Configuration = Configuration()

    /// Current status of `Directions` object.
    @objc public var isRunning: Bool {
        if let task = activeTask {
            switch task.state {
            case .running:
                return true
            case .canceling, .suspended, .completed:
                return false
            @unknown default:
                fatalError("Unknown URLSessionTask state.")
            }
        } else {
            return false
        }
    }

    private var activeTask: URLSessionDataTask?

    /// Finds routes among at least two coordinates.
    ///
    ///
    /// 
    /// - Parameters:
    ///   - coordinates: <#coordinates description#>
    ///   - configuration: <#configuration description#>
    ///   - completionHandler: <#completionHandler description#>
    @objc(calculateDirectionAmongCoordinates:withConfiguration:completionHandler:)
    public func calculateDirections(
        among coordinates: [CLLocationCoordinate2D],
        configuration: Directions.Configuration,
        completionHandler: @escaping DirectionsCompletionHandler
    ) {
        cancel()
        self.configuration = configuration

        guard AccountManager.isAuthorized else {
            completionHandler(nil, Error.unauthorized)
            return
        }

        guard validate(coordinates) else {
            completionHandler(nil, Error.invalidArguments)
            return
        }

        let urlRequest = urlRequestForDirections(
            coordinates: coordinates,
            configuration: self.configuration)

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
                    if let data = data, let directions = self?.decodeDirectionsResult(from: data) {
                        directions.configuration = configuration.copy() as? Directions.Configuration
                        completionHandler(directions, nil)
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

    /// Cancels the current running task.
    @objc public func cancel() {
        activeTask?.cancel()
        activeTask = nil
    }
}

extension Directions {
    func validate(_ coordinates: [CLLocationCoordinate2D]) -> Bool {
        guard coordinates.count > 1 else {
            return false
        }

        let x = coordinates.first { (coordinate) -> Bool in
            !CLLocationCoordinate2DIsValid(coordinate)
        }

        guard x == nil else {
            return false
        }

        return true
    }
}

extension Directions {
    @objc public enum Error: Int, Swift.Error {

        /// Indicates that you are not using a Map.ir API key or your key is invalid.
        case unauthorized

        /// Indicates that network was unavailable or a network error occurred.
        case network

        /// Indicates that the task was canceled.
        case canceled

        /// Indicates that snapshot creation task had no result.
        case noResult

        /// Invalid input arguments.
        ///
        /// Errors in arguments contain issues like inserting no waypoints.
        case invalidArguments
    }
}

extension Directions {
    func urlRequestForDirections(coordinates: [CLLocationCoordinate2D],
                                 configuration: Directions.Configuration) -> URLRequest {
        
        var urlComponents = NetworkingManager.baseURLComponents

        var queryParams: [String: String] = [:]

        queryParams["alternatives"] = configuration.numberOfAlternatives == 0 ?
            "false" : String(configuration.numberOfAlternatives)

        queryParams["steps"] = configuration.includeSteps ? "true" : "false"

        queryParams["geometries"] = "polyline"

        switch configuration.routeOverviewStyle {
        case .none: queryParams["overview"] = "false"
        case .full: queryParams["overview"] = "full"
        case .simplified: queryParams["overview"] = "simplified"
        }

        urlComponents.queryItems = URLQueryItem.queryItems(from: queryParams)

        let coordinateValues = coordinates
            .map { [String($0.longitude), String($0.latitude)].joined(separator: ",") }
            .joined(separator: ";")

        var path: String
        switch configuration.vehicleType {
        case .privateCar:
            switch configuration.areaToExclude {
            case .none: path = "/route"
            case .airPollutionControlArea: path = "/zojofard"
            case .trafficControlArea: path = "/tarh"
            }
        case .foot: path = "/foot"
        case .bicycle: path = "/bicycle"
        }

        urlComponents.path = "/routes" + path + "/v1/driving/" + coordinateValues

        return NetworkingManager.request(url: urlComponents)
    }
}

extension Directions {

    typealias DecodingHandler = (Data) -> Result?

    func decodeDirectionsResult(from data: Data) -> Directions.Result? {
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(Directions.Result.ResponseScheme.self, from: data) {
            return Directions.Result(from: decoded)
        }
        return nil
    }
}
