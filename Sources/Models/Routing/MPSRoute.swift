//
//  MPSRoute.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 11/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation
import Polyline

public struct MPSRoute {

    /// The distance traveled by the route, in `Double` meters.
    public var distance: Double

    /// The estimated travel time, in `Double` number of seconds.
    public var duration: Double

    /// The whole `geometry` of the route value depending on overview parameter, format depending on the geometries parameter.
    public var geometry: [MPSLocationCoordinate]!

    /// The calculated weight of the route.
    public var weight: Double

    /// The name of the weight profile used during extraction phase.
    public var weightName: String?

    /// The legs between the given waypoints, an array of RouteLeg objects.
    public var legs: [MPSLeg]
}

extension MPSRoute: Decodable {
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
        if let dp = decodedPolyline {
            geometry = dp.asMPSLocationCoordintes
        } else {
            assertionFailure("Can't decode geometry from polyline hash.")
            geometry = nil
        }
        weight = try container.decode(Double.self, forKey: .weight)
        weightName = try container.decode(String.self, forKey: .weightName)
        legs = try container.decode([MPSLeg].self, forKey: .legs)
    }
}

public enum MPSRouteType: String {
    case drivingExcludeAirPollutionZone = "zojofard"
    case drivingExcludeTrafficControlZone = "tarh"
    case drivingNoExclusion = "route"
    case onFoot = "foot"
    case bicycle = "bicycle"
}

public struct MPSRouteOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let calculateAlternatives = MPSRouteOptions(rawValue: 1 << 0)
    public static let overview = MPSRouteOptions(rawValue: 1 << 1)
}
