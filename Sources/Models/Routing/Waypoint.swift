//
//  Waypoint.swift
//  MapirServices
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import CoreLocation
import Foundation

public struct Waypoint {
    /// Unique internal identifier of the segment
    var hint: String

    /// Name of the street the coordinate snapped to.
    public var name: String

    /// The distance, in metres, from the input coordinate to the snapped coordinate
    public var distance: Double

    /// `CLLocationCoordinate2D` of the snapped coordinate.
    public var coordinates: CLLocationCoordinate2D?
}

extension Waypoint: Decodable {
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

        let coords = try? container.decode([Double].self, forKey: .coordinates)
        if let coords = coords {
            coordinates = CLLocationCoordinate2D(latitude: coords[1], longitude: coords[0])
        }
    }
}
