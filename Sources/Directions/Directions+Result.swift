//
//  Directions+Result.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 11/12/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

extension Directions {

    /// The output object of a `Directions` request.
    @objc(SHDirectionsResult)
    public final class Result: NSObject {

        /// Array of `Waypoint` objects representing all waypoints along the path in order.
        @objc public let waypoints: [Waypoint]

        /// An array of `Route` objects, ordered by descending recommendation rank.
        ///
        /// If you specify `n` as number of alternative routes in configuration,
        /// you may have less than `(n + 1)` `Route`s in this property.
        @objc public let routes: [Route]

        /// The configuration of the `Directions` request which resulted in this `Route`s.
        @objc public internal(set) var configuration: Directions.Configuration?

        init(
            waypoints: [Waypoint],
            routes: [Route],
            configuration: Directions.Configuration? = nil
        ) {
            self.waypoints = waypoints
            self.routes = routes
            self.configuration = configuration
        }
    }
}

extension Directions.Result {

    convenience init(from response: ResponseScheme,
                     configuration: Directions.Configuration? = nil) {
        
        self.init(waypoints: response.waypoints, routes: response.routes)
    }

    struct ResponseScheme: Decodable {
        var waypoints: [Waypoint]
        var routes: [Route]

        enum CodingKeys: String, CodingKey {
            case waypoints
            case routes
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let waypoints = try container.decode([Waypoint.ResponseScheme].self, forKey: .waypoints)
            self.waypoints = waypoints.map { Waypoint(from: $0) }

            let routes = try container.decode([Route.ResponseScheme].self, forKey: .routes)
            self.routes = routes.map { Route(from: $0) }
        }
    }
}
