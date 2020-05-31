//
//  RouteStep.swift
//  MapirServices
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import CoreLocation
import Foundation

public struct RouteStep {

    /// The distance of travel from the maneuver to the subsequent step, in `Double`
    /// meters.
    public let distance: CLLocationDistance

    /// The estimated travel time, in `Double` number of seconds.
    public let expectedTravelTime: TimeInterval

    /// A list of Intersection objects that are passed along the segment, the very first
    /// belonging to the `StepManeuver`
    public let intersections: [Intersection]

    /// The unsimplified geometry of the route segment, depending on the geometries
    /// parameter.
    public let coordinates: [CLLocationCoordinate2D]?

    /// A reference number or code for the way. Optionally included, if ref data is
    /// available for the given way.
    public let referenceCode: String?

    /// The name of the way along which travel proceeds.
    public let name: String

    /// A string containing an IPA phonetic transcription indicating how to pronounce
    /// the name in the name property.
    public let namePronunciation: String?

    /// The destinations of the way. Will be undefined if there are no destinations.
    public let destinations: [String]?

    /// The name for the rotary. Optionally included, if the step is a rotary and a
    /// rotary name is available.
    public let rotaryName: String?

    /// The pronunciation hint of the rotary name. Optionally included, if the step is a
    /// rotary and a rotary pronunciation is available.
    public let rotaryPronunciation: String?

    /// A string signifying the mode of transportation.
    public let transportType: TransportType?

    /// The exit numbers or names of the way. Will be undefined if there are no exit
    /// numbers or names.
    public let exits: [String]?

    /// A `MPSManeuver` object representing the maneuver.
    public let maneuver: StepManeuver

    /// The calculated weight of the step.
    public let weight: Double

    /// The legal driving side at the location for this step. Either `left` or `right`.
    public let drivingSide: DrivingSide
}

// MARK: Decoding RouteStep

extension RouteStep {
    init(from response: ResponseScheme) {
        self.init(
            distance: response.distance,
            expectedTravelTime: response.duration,
            intersections: response.intersections,
            coordinates: response.coordinates,
            referenceCode: response.ref,
            name: response.name,
            namePronunciation: response.pronunciation,
            destinations: response.destinations,
            rotaryName: response.rotaryName,
            rotaryPronunciation: response.rotaryPronunciation,
            transportType: response.transportType,
            exits: response.exits,
            maneuver: response.maneuver,
            weight: response.weight,
            drivingSide: response.drivingSide
        )
    }

    struct ResponseScheme: Decodable {
        var distance: CLLocationDistance
        var duration: TimeInterval
        var intersections: [Intersection]
        var coordinates: [CLLocationCoordinate2D]?
        var ref: String?
        var name: String
        var pronunciation: String?
        var destinations: [String]?
        var rotaryName: String?
        var rotaryPronunciation: String?
        var transportType: TransportType?
        var exits: [String]?
        var maneuver: StepManeuver
        var weight: Double
        var drivingSide: DrivingSide

        enum CodingKeys: String, CodingKey {
            case distance
            case duration
            case intersections
            case geometry
            case name
            case ref
            case pronunciation
            case destination
            case exits = "exit"
            case rotaryName = "rotary_name"
            case rotaryPronunciation = "rotary_pronunciation"
            case mode
            case maneuver
            case weight
            case drivingSide = "driving_side"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            distance = try container.decode(Double.self, forKey: .distance)
            duration = try container.decode(Double.self, forKey: .duration)

            let intersections = try container.decode([Intersection.ResponseScheme].self, forKey: .intersections)
            self.intersections = intersections.compactMap { Intersection(from: $0) }

            let polylineHash = try container.decode(String.self, forKey: .geometry)
            let polyline = GooglePolyline(encodedPolyline: polylineHash)
            let decodedPolyline = polyline.coordinates
            if let decodedPolyline = decodedPolyline {
                self.coordinates = decodedPolyline
            }

            name = try container.decode(String.self, forKey: .name)
            ref = try container.decodeIfPresent(String.self, forKey: .ref)
            pronunciation = try container.decodeIfPresent(String.self, forKey: .pronunciation)

            destinations = try container.decodeIfPresent([String].self, forKey: .destination)
            exits = try container.decodeIfPresent([String].self, forKey: .exits)
            rotaryName = try container.decodeIfPresent(String.self, forKey: .rotaryName)
            rotaryPronunciation = try container.decodeIfPresent(String.self, forKey: .rotaryPronunciation)

            if let transportTypeString = try container.decodeIfPresent(String.self, forKey: .mode) {
                transportType = TransportType(rawValue: transportTypeString)
            }

            let maneuver = try container.decode(StepManeuver.ResponseScheme.self, forKey: .maneuver)
            self.maneuver = StepManeuver(from: maneuver)

            weight = try container.decode(Double.self, forKey: .weight)

            if let drivingSideString = try container.decodeIfPresent(String.self, forKey: .drivingSide) {
                drivingSide = DrivingSide(rawValue: drivingSideString) ?? .right
            } else {
                drivingSide = .right
            }
        }
    }
}
