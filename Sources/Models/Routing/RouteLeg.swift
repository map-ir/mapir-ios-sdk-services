//
//  RouteLeg.swift
//  MapirServices
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public struct RouteLeg {
    /// Depends on the `steps` parameter.
    public var steps: [RouteStep]

    /// The distance traveled by this route leg, in `Double` meters.
    public var distance: Double

    /// The estimated travel time, in `Double` number of seconds.
    public var duration: Double

    /// Summary of the route taken as string. Depends on the steps parameter
    public var summary: String

    /// /// weight of the travel leg.
    public var weight: Double
}

extension RouteLeg: Decodable {
    enum CodingKeys: String, CodingKey {
        case steps
        case distance
        case duration
        case summary
        case weight
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        distance = try container.decode(Double.self, forKey: .distance)
        duration = try container.decode(Double.self, forKey: .duration)
        summary = try container.decode(String.self, forKey: .summary)
        weight = try container.decode(Double.self, forKey: .weight)
        steps = try container.decode([RouteStep].self, forKey: .steps)
    }
}
