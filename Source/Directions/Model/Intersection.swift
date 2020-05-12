//
//  Intersection.swift
//  MapirServices
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import CoreLocation
import Foundation

/// An intersection gives a full representation of any cross-way the path passes
/// bay.
///
/// For every step, the very first intersection (intersections[0]) corresponds
/// to the location of the StepManeuver. Further intersections are listed for every
/// cross-way until the next turn instruction.
@objc(SHIntersection)
public final class Intersection: NSObject {

    /// A `CLLocationCoordinate2D` describing the location of the turn.
    @objc public var coordinate: CLLocationCoordinate2D

    /// A list of `bearing` values (e.g. [0,90,180,270]) that are available at the
    /// intersection.
    ///
    /// The `bearings` describe all available roads at the intersection.
    @objc public var headings: [CLLocationDirection]

    /// An array of strings signifying the classes of the road exiting the intersection.
    @objc public var roadClasses: RoadClass?

    /// The indices of the items in the `bearings` array that correspond to the roads
    /// that may be used to leave the intersection.
    @objc public var usableOutletIndexes: IndexSet

    /// index into the bearings/entry array.
    ///
    /// Used to extract the bearing just after the turn. Namely,
    /// The clockwise angle from true north to the direction of travel immediately
    /// after the maneuver/passing the intersection.
    /// The value is not supplied for arrive maneuvers.
    @objc public var outletIndex: Int

    /// index into bearings/entry array.
    ///
    /// Used to calculate the bearing just before the turn. Namely, the clockwise angle
    /// from true north to the direction of travel immediately before the
    /// maneuver/passing the intersection. Bearings are given relative to the
    /// intersection. To get the bearing in the direction of driving, the bearing has to
    /// be rotated by a value of 180. The value is not supplied for depart maneuvers.
    @objc public var inletIndex: Int

    /// Array of Lane objects that denote the available turn lanes at the intersection.
    ///
    /// If no lane information is available for an intersection, the lanes property will
    /// not be present.
    @objc public var availableOutlets: [Lane]?

    init(
        coordinate: CLLocationCoordinate2D,
        headings: [CLLocationDirection],
        roadClasses: RoadClass?,
        usableOutletIndexes: IndexSet,
        outletIndex: Int,
        inletIndex: Int,
        availableOutlets: [Lane]?
    ) {
        self.coordinate = coordinate
        self.headings = headings
        self.roadClasses = roadClasses
        self.usableOutletIndexes = usableOutletIndexes
        self.outletIndex = outletIndex
        self.inletIndex = inletIndex
        self.availableOutlets = availableOutlets
    }
}

// MARK: Decoding Intersection

extension Intersection {

    convenience init(from response: ResponseScheme) {
        self.init(
            coordinate: response.coordinate,
            headings: response.bearings,
            roadClasses: response.roadClasses,
            usableOutletIndexes: response.usableOutletIndexes,
            outletIndex: response.outletIndex,
            inletIndex: response.inletIndex,
            availableOutlets: response.availableOutlets
        )
    }

    struct ResponseScheme: Decodable {
        var coordinate: CLLocationCoordinate2D
        var bearings: [CLLocationDirection]
        var roadClasses: RoadClass?
        var usableOutletIndexes: IndexSet
        var outletIndex: Int
        var inletIndex: Int
        var availableOutlets: [Lane]?

        private enum CodingKeys: String, CodingKey {
            case location
            case bearings
            case classes
            case entry
            case out
            case `in`
            case lanes
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let coords = try container.decode(CLLocationCoordinate2D.GeoJSONType.self, forKey: .location)
            coordinate = (try? CLLocationCoordinate2D(fromGeoJSONGeometry: coords)) ?? kCLLocationCoordinate2DInvalid

            bearings = try container.decode([CLLocationDirection].self, forKey: .bearings)

            roadClasses = nil
            if let classesArray = try container.decodeIfPresent([String].self, forKey: .classes) {
                roadClasses = RoadClass(descriptions: classesArray)
            }

            usableOutletIndexes = IndexSet()
            if let entry = try container.decodeIfPresent([Bool].self, forKey: .entry) {
                let indexes = entry.enumerated().filter { $1 }.map { $0.offset }
                usableOutletIndexes = IndexSet(indexes)
            }

            inletIndex = try container.decodeIfPresent(Int.self, forKey: .in) ?? -1
            outletIndex = try container.decodeIfPresent(Int.self, forKey: .out) ?? -1

            let availableOutlets = try? container.decodeIfPresent([Lane.ResponseScheme].self, forKey: .lanes)
            self.availableOutlets = availableOutlets?.compactMap { Lane(from: $0) }
        }
    }
}
