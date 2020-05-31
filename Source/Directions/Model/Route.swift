//
//  Route.swift
//  MapirServices
//
//  Created by Alireza Asadi on 11/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import CoreLocation
import Foundation

public struct Route {

    /// The distance traveled by the route, in `Double` meters.
    public let distance: Double

    /// The estimated travel time, in `Double` number of seconds.
    public let expectedTravelTime: TimeInterval

    /// The whole `geometry` of the route value depending on overview parameter,
    /// format depending on the geometries parameter.
    public let coordinates: [CLLocationCoordinate2D]?

    /// The calculated weight of the route.
    public let weight: Double

    /// The name of the weight profile used during extraction phase.
    public let weightName: String?

    /// The legs between the given waypoints, an array of RouteLeg objects.
    public let legs: [RouteLeg]
}

// MARK: Decoding Route

extension Route {

    init(from response: ResponseScheme) {
        self.init(
            distance: response.distance,
            expectedTravelTime: response.duration,
            coordinates: response.geometry,
            weight: response.weight,
            weightName: response.weightName,
            legs: response.legs
        )
    }

    struct ResponseScheme: Decodable {
        var distance: Double
        var duration: Double
        var geometry: [CLLocationCoordinate2D]?
        var weight: Double
        var weightName: String?
        var legs: [RouteLeg]

        enum CodingKeys: String, CodingKey {
            case distance
            case duration
            case geometry
            case weight
            case weightName = "weight_name"
            case legs
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            distance = try container.decode(Double.self, forKey: .distance)
            duration = try container.decode(Double.self, forKey: .duration)

            if let polylineHash = try container.decodeIfPresent(String.self, forKey: .geometry),
                let decodedPolyline = GooglePolyline(encodedPolyline: polylineHash).coordinates {
                geometry = decodedPolyline
            }

            weight = try container.decode(Double.self, forKey: .weight)
            weightName = try? container.decode(String.self, forKey: .weightName)

            let legs = try container.decode([RouteLeg.ResponseScheme].self, forKey: .legs)
            self.legs = legs.compactMap { RouteLeg(from: $0) }
        }
    }
}
