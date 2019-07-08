//
//  MPSSearchResult.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public struct MPSSearchResult {
    public var text: String
    public var title: String
    public var address: String
    public var province: String
    public var city: String
    public var type: String
    public var fClass: String
    public var coordinates: MPSLocationCoordinate
}

extension MPSSearchResult: Decodable {

    enum CodingKeys: String, CodingKey {
        case text
        case title
        case address
        case province
        case city
        case type
        case fClass = "FClass"
        case coordinates = "coordinate"
    }

    enum CoordinateKeys: String, CodingKey {
        case lat
        case lng
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
        let longitude = try coordinateContainer.decode(Double.self, forKey: .lng)

        coordinates = MPSLocationCoordinate(latitude: latitude, longitude: longitude)
    }
}
