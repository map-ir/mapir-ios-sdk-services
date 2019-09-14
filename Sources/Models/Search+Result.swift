//
//  Search+Result.swift
//  MapirServices
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import CoreLocation

extension Search {
    public struct Result {
        public var text: String
        public var title: String
        public var address: String
        public var province: String
        public var city: String
        public var type: String
        public var fClass: String
        public var coordinates: CLLocationCoordinate2D
    }
}

extension Search.Result: Decodable {

    enum CodingKeys: String, CodingKey {
        case text = "Text"
        case title = "Title"
        case address = "Address"
        case province = "Province"
        case city = "City"
        case type = "Type"
        case fClass = "FClass"
        case coordinates = "Coordinate"
    }

    enum CoordinateKeys: String, CodingKey {
        case lat
        case lon
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        title = try container.decode(String.self, forKey: .title)
        address = try container.decode(String.self, forKey: .address)
        province = try container.decode(String.self, forKey: .province)
        city = try container.decode(String.self, forKey: .city)
        type = try container.decode(String.self, forKey: .type)
        fClass = try container.decode(String.self, forKey: .fClass)

        let coordinateContainer = try container.nestedContainer(keyedBy: CoordinateKeys.self, forKey: .coordinates)
        let latitude = try coordinateContainer.decode(Double.self, forKey: .lat)
        let longitude = try coordinateContainer.decode(Double.self, forKey: .lon)

        coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
