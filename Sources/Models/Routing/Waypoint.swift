//
//  Waypoint.swift
//  MapirServices
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import CoreLocation
import Foundation

@objc(Waypoint)
public final class Waypoint: NSObject {

    /// Unique internal identifier of the segment (ephemeral, not constant over data
    /// updates).
    ///
    /// This can be used on subsequent request to significantly speed up the
    /// query and to connect multiple services. E.g. you can use the hint value obtained
    /// by the nearest query as hint values for route inputs.
    @objc public var reuseIdentifier: String

    /// Name of the street the coordinate snapped to.
    @objc public var name: String

    /// The distance, in metres, from the input coordinate to the snapped coordinate.
    @objc public var coordinateAccuracy: CLLocationAccuracy

    /// `CLLocationCoordinate2D` of the snapped coordinate.
    @objc public var coordinate: CLLocationCoordinate2D

    init(
        hint: String,
        name: String,
        distance: CLLocationAccuracy,
        coordinate: CLLocationCoordinate2D
    ) {
        self.reuseIdentifier = hint
        self.name = name
        self.coordinateAccuracy = distance
        self.coordinate = coordinate
    }
}

extension Waypoint {

    convenience init(from response: ResponseScheme) {
        self.init(
            hint: response.hint,
            name: response.name,
            distance: response.distance,
            coordinate: response.coordinate
        )
    }

    struct ResponseScheme: Decodable {
        var hint: String
        var name: String
        var distance: CLLocationAccuracy
        var coordinate: CLLocationCoordinate2D

        enum CodingKeys: String, CodingKey {
            case hint
            case name
            case distance
            case coordinates = "location"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            hint = try container.decode(String.self, forKey: .hint)
            name = try container.decode(String.self, forKey: .name)
            distance = try container.decode(Double.self, forKey: .distance)

            coordinate = kCLLocationCoordinate2DInvalid
            if let coords = try? container.decode([Double].self, forKey: .coordinates) {
                coordinate = CLLocationCoordinate2D(from: coords) ?? kCLLocationCoordinate2DInvalid
            }
        }
    }
}
