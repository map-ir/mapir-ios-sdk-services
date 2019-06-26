//
//  MPSCoordinate.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 5/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation
import CoreLocation

public struct MPSCoordinate {
    public var latitude: Double
    public var longitude: Double

    public init(from clLocationCoordainte2D: CLLocationCoordinate2D) {
        self.latitude = clLocationCoordainte2D.latitude
        self.longitude = clLocationCoordainte2D.longitude
    }

    public var asCLLocatoinCoordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }

}

extension MPSCoordinate: Codable {
    enum GeometryKeys: String, CodingKey {
        case coordinates
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: GeometryKeys.self)

        let array = try values.decode([Double].self, forKey: .coordinates)
        self.latitude = array[1]
        self.longitude = array[0]
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: GeometryKeys.self)
        try container.encode([longitude, latitude], forKey: .coordinates)
    }
}
