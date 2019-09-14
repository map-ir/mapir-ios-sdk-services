//
//  Route.swift
//  MapirServices
//
//  Created by Alireza Asadi on 11/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import CoreLocation
import Foundation
import Polyline

public struct Route {

    public enum Mode: String {
        case drivingExcludeAirPollutionZone     = "zojofard"
        case drivingExcludeTrafficControlZone   = "tarh"
        case drivingNoExclusion                 = "route"
        case onFoot                             = "foot"
        case bicycle                            = "bicycle"
    }

    public struct Options: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) { self.rawValue = rawValue }

        public static let calculateAlternatives = Route.Options(rawValue: 1 << 0)
        public static let fullOverview          = Route.Options(rawValue: 1 << 1)
        public static let simplifiedOverview    = Route.Options(rawValue: 1 << 2)
        public static let noOverview            = Route.Options(rawValue: 1 << 3)
        public static let steps                 = Route.Options(rawValue: 1 << 4)
    }

    /// The distance traveled by the route, in `Double` meters.
    public var distance: Double

    /// The estimated travel time, in `Double` number of seconds.
    public var duration: Double

    /// The whole `geometry` of the route value depending on overview parameter,
    /// format depending on the geometries parameter.
    public var geometry: [CLLocationCoordinate2D]?

    /// The calculated weight of the route.
    public var weight: Double

    /// The name of the weight profile used during extraction phase.
    public var weightName: String?

    /// The legs between the given waypoints, an array of RouteLeg objects.
    public var legs: [RouteLeg]
}

extension Route: Decodable {
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

        let polylineHash = try container.decode(String.self, forKey: .geometry)
        let polyline = Polyline(encodedPolyline: polylineHash)
        let decodedPolyline = polyline.coordinates
        if let decodedPolyline = decodedPolyline {
            geometry = decodedPolyline
        } else {
            assertionFailure("Can't decode geometry from polyline hash.")
            geometry = nil
        }
        weight = try container.decode(Double.self, forKey: .weight)
        weightName = try? container.decode(String.self, forKey: .weightName)
        legs = try container.decode([RouteLeg].self, forKey: .legs)
    }
}

public enum RouteError: Error, LocalizedError {

    case noDestinationsSpecified

    var localizedDescription: String {
        return "No destination is specified. At least one is needed."
    }
}
