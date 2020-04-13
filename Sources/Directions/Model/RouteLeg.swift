//
//  RouteLeg.swift
//  MapirServices
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

@objc(SHRouteLeg)
public final class RouteLeg: NSObject {
    /// Depends on the `steps` parameter.
    @objc public let steps: [RouteStep]

    /// The distance traveled by this route leg, in `Double` meters.
    @objc public let distance: CLLocationDistance

    /// The estimated travel time, in `Double` number of seconds.
    @objc public let expectedTravelTime: TimeInterval

    /// Summary of the route taken as string. Depends on the steps parameter
    @objc public let summary: String

    /// weight of the travel leg.
    @objc public let weight: Double

    init(
        steps: [RouteStep],
        distance: CLLocationDistance,
        expectedTravelTime: TimeInterval,
        summary: String,
        weight: Double
    ) {
        self.steps = steps
        self.distance = distance
        self.expectedTravelTime = expectedTravelTime
        self.summary = summary
        self.weight = weight
    }
}

// MARK: Decoding RouteLeg

extension RouteLeg {

    convenience init(from response: ResponseScheme) {
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
