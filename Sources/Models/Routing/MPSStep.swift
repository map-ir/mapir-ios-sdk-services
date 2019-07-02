//
//  MPSStep.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public struct MPSStep {

    /// The distance of travel from the maneuver to the subsequent step, in `Double` meters.
    public var distance: Double

    /// The estimated travel time, in `Double` number of seconds.
    public var duration: Double

    /// A list of Intersection objects that are passed along the segment, the very first belonging to the `MPSManeuver`
    public var intersections: [MPSIntersection]

    /// The unsimplified geometry of the route segment, depending on the geometries parameter.
    public var geometry: String

    /// The name of the way along which travel proceeds.
    public var name: String

    /// A reference number or code for the way. Optionally included, if ref data is available for the given way.
    public var ref: String?

    /// A string containing an IPA phonetic transcription indicating how to pronounce the name in the name property.
    public var pronunciation: String?

    /// The destinations of the way. Will be undefined if there are no destinations.
    public var destinations: String?

    /// The name for the rotary. Optionally included, if the step is a rotary and a rotary name is available.
    public var rotaryName: String?

    /// The pronunciation hint of the rotary name. Optionally included, if the step is a rotary and a rotary pronunciation is available.
    public var rotaryPronunciation: String?

    /// A string signifying the mode of transportation.
    public var mode: String

    /// The exit numbers or names of the way. Will be undefined if there are no exit numbers or names.
    public var exits: [String]?

    /// A `MPSManeuver` object representing the maneuver.
    public var maneuver: MPSManeuver

    /// The calculated weight of the step.
    public var wieght: Double

    /// The legal driving side at the location for this step. Either `left` or `right`.
    public var drivingSide: MPSDrivingSide

}

extension MPSStep: Decodable {
    enum CodingKeys: String, CodingKey {
        case distance
        case duration
        case intersections
        case geometry
        case name
        case ref
        case pronounciation
        case destination
        case exits
        case rotaryName = "rotary_name"
        case rotaryPronounciation = "rotary_pronounciation"
        case mode
        case maneuver
        case weight
        case drivingSide = "driving_side"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        distance = try container.decode(Double.self, forKey: .distance)
        duration = try container.decode(Double.self, forKey: .duration)
        intersections = try container.decode([MPSIntersection].self, forKey: .intersections)

        // TODO: different geometries.
        // geometry =

        name = try container.decode(String.self, forKey: .name)
        ref = try container.decode(String.self, forKey: .ref)
        pronunciation = try container.decode(String.self, forKey: .pronounciation)

        // WTF is the type?
        destinations = try container.decode(String.self, forKey: .destination)
        exits = try container.decode([String].self, forKey: .exits)
        rotaryName = try container.decode(String.self, forKey: .rotaryName)
        rotaryPronunciation = try container.decode(String.self, forKey: .rotaryPronounciation)
        mode = try container.decode(String.self, forKey: .mode)
        maneuver = try container.decode(MPSManeuver.self, forKey: .maneuver)
        wieght = try container.decode(Double.self, forKey: .weight)
        drivingSide = try container.decode(MPSDrivingSide.self, forKey: .drivingSide)

    }
}

public enum MPSDrivingSide: String, Codable {

    /// specifies that the legal driving side at the location `right`.
    case right

    /// specifies that the legal driving side at the location `left`.
    case left
}
