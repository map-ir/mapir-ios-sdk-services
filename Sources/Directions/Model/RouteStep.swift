//
//  RouteStep.swift
//  MapirServices
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import CoreLocation
import Foundation
import Polyline

@objc(RouteStep)
public final class RouteStep: NSObject {

    /// The distance of travel from the maneuver to the subsequent step, in `Double`
    /// meters.
    @objc public let distance: CLLocationDistance

    /// The estimated travel time, in `Double` number of seconds.
    @objc public let expectedTravelTime: TimeInterval

    /// A list of Intersection objects that are passed along the segment, the very first
    /// belonging to the `StepManeuver`
    @objc public let intersections: [Intersection]

    /// The unsimplified geometry of the route segment, depending on the geometries
    /// parameter.
    @objc public let coordinates: [CLLocationCoordinate2D]?

    /// A reference number or code for the way. Optionally included, if ref data is
    /// available for the given way.
    @objc public let referenceCode: String?

    /// The name of the way along which travel proceeds.
    @objc public let name: String

    /// A string containing an IPA phonetic transcription indicating how to pronounce
    /// the name in the name property.
    @objc public let namePronunciation: String?

    /// The destinations of the way. Will be undefined if there are no destinations.
    @objc public let destinations: [String]?

    /// The name for the rotary. Optionally included, if the step is a rotary and a
    /// rotary name is available.
    @objc public let rotaryName: String?

    /// The pronunciation hint of the rotary name. Optionally included, if the step is a
    /// rotary and a rotary pronunciation is available.
    @objc public let rotaryPronunciation: String?

    /// A string signifying the mode of transportation.
    @objc public let transportType: TransportType

    /// The exit numbers or names of the way. Will be undefined if there are no exit
    /// numbers or names.
    @objc public let exits: [String]?

    /// A `MPSManeuver` object representing the maneuver.
    @objc public let maneuver: StepManeuver

    /// The calculated weight of the step.
    @objc public let weight: Double

    /// The legal driving side at the location for this step. Either `left` or `right`.
    @objc public let drivingSide: DrivingSide

    init(
        distance: CLLocationDistance,
        expectedTravelTime: TimeInterval,
        intersections: [Intersection],
        coordinates: [CLLocationCoordinate2D]?,
        ref: String?,
        name: String,
        namePronunciation: String?,
        destinations: [String]?,
        rotaryName: String?,
        rotaryPronunciation: String?,
        transportType: TransportType,
        exits: [String]?,
        maneuver: StepManeuver,
        weight: Double,
        drivingSide: DrivingSide
    ) {
        self.distance = distance
        self.expectedTravelTime = expectedTravelTime
        self.intersections = intersections
        self.coordinates = coordinates
        self.referenceCode = ref
        self.name = name
        self.namePronunciation = namePronunciation
        self.destinations = destinations
        self.rotaryName = rotaryName
        self.rotaryPronunciation = rotaryPronunciation
        self.transportType = transportType
        self.exits = exits
        self.maneuver = maneuver
        self.weight = weight
        self.drivingSide = drivingSide
    }

}

// MARK: Objective-C Compatibility

extension RouteStep {

    @objc public var coordinatesCount: UInt {
        return UInt(coordinates?.count ?? 0)
    }

    /// Retrieve coordinates.
    ///
    /// - Parameter pointer: A pointer to a C array of `CLLocationCoordinate2D`
    /// instances.
    ///
    /// - precondition: Pointer must be large enough to hold `coordinatesCount`
    /// instances of `CLLocationCoordinate2D`.
    ///
    /// - note: this method is intended to be used in Objective-C. In Swift use
    /// `coordinates` property.
    @objc public func getCoordinates(_ pointer: UnsafeMutablePointer<CLLocationCoordinate2D>) {
        guard let coordinates = coordinates else {
            return
        }

        for (offset, coordinate) in coordinates.enumerated() {
            pointer.advanced(by: offset).pointee = coordinate
        }
    }
}

// MARK: Decoding RouteStep

extension RouteStep {
    convenience init(from response: ResponseScheme) {
        self.init(
            distance: response.distance,
            expectedTravelTime: response.duration,
            intersections: response.intersections,
            coordinates: response.coordinates,
            ref: response.ref,
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
        var transportType: TransportType
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
            case pronounciation
            case destination
            case exits = "exit"
            case rotaryName = "rotary_name"
            case rotaryPronounciation = "rotary_pronounciation"
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
            let polyline = Polyline(encodedPolyline: polylineHash)
            let decodedPolyline = polyline.coordinates
            if let decodedPolyline = decodedPolyline {
                self.coordinates = decodedPolyline
            }

            name = try container.decode(String.self, forKey: .name)
            ref = try container.decodeIfPresent(String.self, forKey: .ref)
            pronunciation = try container.decodeIfPresent(String.self, forKey: .pronounciation)

            destinations = try container.decodeIfPresent([String].self, forKey: .destination)
            exits = try container.decodeIfPresent([String].self, forKey: .exits)
            rotaryName = try container.decodeIfPresent(String.self, forKey: .rotaryName)
            rotaryPronunciation = try container.decodeIfPresent(String.self, forKey: .rotaryPronounciation)

            let transportTypeString = try container.decodeIfPresent(String.self, forKey: .mode) ?? ""
            transportType = TransportType(description: transportTypeString)

            let maneuver = try container.decode(StepManeuver.ResponseScheme.self, forKey: .maneuver)
            self.maneuver = StepManeuver(from: maneuver)

            weight = try container.decode(Double.self, forKey: .weight)

            let drivingSideString = try container.decodeIfPresent(String.self, forKey: .drivingSide) ?? "right"
            drivingSide = DrivingSide(description: drivingSideString) ?? .right
        }
    }
}
