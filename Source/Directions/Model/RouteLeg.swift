//
//  RouteLeg.swift
//  MapirServices
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation
import CoreLocation

public struct RouteLeg {
    /// Depends on the `steps` parameter.
    public let steps: [RouteStep]

    /// The distance traveled by this route leg, in `Double` meters.
    public let distance: CLLocationDistance

    /// The estimated travel time, in `Double` number of seconds.
    public let expectedTravelTime: TimeInterval

    /// Summary of the route taken as string. Depends on the steps parameter
    public let summary: String

    /// weight of the travel leg.
    public let weight: Double
}

// MARK: Decoding RouteLeg

extension RouteLeg {

    init(from response: ResponseScheme) {
        self.init(
            steps: response.steps,
            distance: response.distance,
            expectedTravelTime: response.duration,
            summary: response.summary,
            weight: response.weight
        )
    }

    struct ResponseScheme: Decodable {
        var distance: Double
        var duration: Double
        var summary: String
        var weight: Double
        var steps: [RouteStep]

        enum CodingKeys: String, CodingKey {
            case steps
            case distance
            case duration
            case summary
            case weight
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            distance = try container.decode(Double.self, forKey: .distance)
            duration = try container.decode(Double.self, forKey: .duration)
            summary = try container.decode(String.self, forKey: .summary)
            weight = try container.decode(Double.self, forKey: .weight)
            
            let steps = try container.decode([RouteStep.ResponseScheme].self, forKey: .steps)
            self.steps = steps.compactMap { RouteStep(from: $0) }
        }
    }
}
