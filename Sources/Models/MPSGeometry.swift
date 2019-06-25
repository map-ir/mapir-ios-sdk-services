//
//  MPIRGeomtry.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 11/3/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation
import CoreLocation

public class MPSMultipointGeometry: Codable {
    public var type: String?
    public var coordinates: [[Int]]?
    
    private enum CodingKeys: String, CodingKey {
        case type
        case coordinates
    }
}

public class MPSPointGeometry: Codable {
    private var type: String?
    private var arrayOfCoordinates: [String]?

    public var coordinates: CLLocationCoordinate2D?

    private enum CodingKeys: String, CodingKey {
        case type
        case arrayOfCoordinates = "coordinates"
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try values.decode(String.self, forKey: .type)
        self.arrayOfCoordinates = try values.decode([String].self, forKey: .arrayOfCoordinates)
        if let arrayOfCoords = self.arrayOfCoordinates {
            self.coordinates = CLLocationCoordinate2D(latitude: Double(arrayOfCoords[1])!, longitude: Double(arrayOfCoords[0])!)
        }

    }
}
