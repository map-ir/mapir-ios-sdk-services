//
//  Directions.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 11/12/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

/// `Directions` is a service that is used to find route between places.
///
/// Use `Directions` to find optimal route among multiple coordinates. This service
/// considers the traffic data wherever the date is available. [See the full list of
/// the cities](https://support.map.ir/developers/api/route/1-0-0/document/) . This
/// service also provides alternative routes, ETA, duration and distance between the
/// coordinates.
///
/// Using Map.ir `Directions` service, not only you can find routes for driving with
/// a car, but also routes for bicycling, walking.
///
/// It is also possible to exclude traffic restrictions of cities, such as air
/// pollution control area and traffic control area in Tehran.
@objc(SHDirections)
public final class Directions: NSObject {

    /// Completion handler type of Directions.
    public typealias DirectionsCompletionHandler = (_ result: Directions.Result?, _ Error: Error?) -> Void

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

    /// Finds routes among at least two coordinates with the given configuration.
    ///
    /// - Parameters:
    ///   - coordinates: The coordintes to find the path among them.
    ///   - configuration: Configuration object to use to find the route.
    ///   - completionHandler: Completion handler block to use when the results are
    ///     available or an error occurs.
    @objc(calculateDirectionAmongCoordinates:withConfiguration:completionHandler:)
    public func calculateDirections(
        among coordinates: [CLLocationCoordinate2D],
        configuration: Directions.Configuration,
        completionHandler: @escaping DirectionsCompletionHandler
    ) {
        cancel()
        self.configuration = configuration

        guard AccountManager.isAuthorized else {
            completionHandler(nil, ServiceError.unauthorized)
            return
        }

        guard validate(coordinates) else {
            completionHandler(nil, ServiceError.DirectionsError.invalidArguments)
            return
        }

        let urlRequest = urlRequestForDirections(
            coordinates: coordinates,
            configuration: self.configuration)

        activeTask = NetworkingManager.dataTask(
            with: urlRequest,
            decoderBlock: decodeDirectionsResult(from:)) { (directions, error) in
                guard let directions = directions, error == nil else {
                    completionHandler(nil, error)
                    return
                }

                directions.configuration = configuration.copy() as? Directions.Configuration
                completionHandler(directions, nil)
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
        guard coordinates.count > 1 &&
            coordinates.allSatisfy({ CLLocationCoordinate2DIsValid($0) }) else {
            return false
        }

        return true
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
