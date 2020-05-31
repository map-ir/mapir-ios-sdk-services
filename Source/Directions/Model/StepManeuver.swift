//
//  StepManeuver.swift
//  MapirServices
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import CoreLocation
import Foundation

public struct StepManeuver {

    /// A `CLLocationCoordinate2D`  describing the location of the turn.
    public let coordinate: CLLocationCoordinate2D?

    /// The clockwise angle from true north to the direction of travel immediately after
    /// the maneuver. Range 0-359.
    public let finalHeading: CLLocationDirection?

    /// The clockwise angle from true north to the direction of travel immediately
    /// before the maneuver. Range 0-359.
    public let initialHeading: CLLocationDirection?

    /// An enum indicating the type of maneuver.
    public let maneuverType: StepManeuver.ManeuverType?

    /// An `Direction` indicating the direction change of the maneuver.
    public let directionInstruction: StepManeuver.Direction?

    /// An optional `Integer` indicating number of the exit to take.
    ///
    /// The field exists for the following `maneuverType`s: `roundabout`, `rotary` and
    /// `none`
    public let exitIndex: Int?
}

// MARK: Decoding StepManeuver

extension StepManeuver {

    init(from response: ResponseScheme) {
        self.init(
            coordinate: response.coordinate,
            finalHeading: response.bearingAfter,
            initialHeading: response.bearingBefore,
            maneuverType: response.maneuverType,
            directionInstruction: response.direction,
            exitIndex: response.exit
        )
    }

    struct ResponseScheme: Decodable {
        var coordinate: CLLocationCoordinate2D
        var bearingAfter: CLLocationDirection?
        var bearingBefore: CLLocationDirection?
        var maneuverType: ManeuverType?
        var direction: Direction?
        var exit: Int?

        private enum CodingKeys: String, CodingKey {
            case location
            case bearingBefore = "bearing_before"
            case bearingAfter = "bearing_after"
            case type
            case modifier
            case exit
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.coordinate = kCLLocationCoordinate2DInvalid
            if let coords = try? container.decode([Double].self, forKey: .location) {
                self.coordinate = (try? CLLocationCoordinate2D(fromGeoJSONGeometry: coords))
                    ?? kCLLocationCoordinate2DInvalid
            }

            bearingAfter = try container.decodeIfPresent(CLLocationDirection.self, forKey: .bearingAfter)
            bearingBefore = try container.decodeIfPresent(CLLocationDirection.self, forKey: .bearingBefore)

            if let manTypeString = try container.decodeIfPresent(String.self, forKey: .type) {
                maneuverType = ManeuverType(rawValue: manTypeString)
            }

            if let modifier = try container.decodeIfPresent(String.self, forKey: .modifier) {
                direction = Direction(rawValue: modifier)
            }

            exit = try container.decodeIfPresent(Int.self, forKey: .exit)
        }
    }
}
