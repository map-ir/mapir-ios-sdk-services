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

    /// Unique internal identifier of the segment (ephemeral, not constant over data
    /// updates).
    ///
    /// This can be used on subsequent request to significantly speed up the
    /// query and to connect multiple services. E.g. you can use the hint value obtained
    /// by the nearest query as hint values for route inputs.
    public let reuseIdentifier: String

    /// Name of the street the coordinate snapped to.
    public let name: String

    /// The distance, measured in meters, from the input coordinate to the snapped coordinate.
    public let coordinateAccuracy: CLLocationAccuracy

    /// `CLLocationCoordinate2D` of the snapped coordinate.
    public let coordinate: CLLocationCoordinate2D
}

extension Waypoint {

    init(from response: ResponseScheme) {
        self.init(
            reuseIdentifier: response.hint,
            name: response.name,
            coordinateAccuracy: response.distance,
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
            if let coords = try? container.decode(CLLocationCoordinate2D.GeoJSONType.self, forKey: .coordinates) {
                coordinate = (try? CLLocationCoordinate2D(fromGeoJSONGeometry: coords))
                    ?? kCLLocationCoordinate2DInvalid
            }
        }
    }
}
