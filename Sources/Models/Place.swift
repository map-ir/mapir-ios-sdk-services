//
//  Place.swift
//  MapirServices
//
//  Created by Alireza Asadi on 5/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import CoreLocation
import Foundation

public struct Place {
    internal var uuid = UUID()

    // Name of the Place.
    public var name: String?

    // Province which places is located in
    public var province: String?

    // County which places is located in
    public var county: String?

    // District which places is located in
    public var district: String?

    // Rural district which places is located in
    public var ruralDistrict: String?

    // Suburb which places is located in
    public var suburb: String?

    // Neighbor which places is located in
    public var neighborhood: String?

    // Coordinates of the place.
    public var coordinates: CLLocationCoordinate2D?
}

extension Place: Equatable, Hashable {
    public static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

extension Place: Decodable {
    enum CodingKeys: String, CodingKey {
        case name
        case province = "province_name"
        case county = "county_name"
        case district = "district_title"
        case ruralDistrict = "ruraldistrict_title"
        case suburb = "suburb_title"
        case neighborhood = "neighbourhood_title"
        case coordinates
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)
        province = try container.decode(String.self, forKey: .province)
        county = try container.decode(String.self, forKey: .county)
        district = try container.decode(String.self, forKey: .district)
        ruralDistrict = try container.decode(String.self, forKey: .ruralDistrict)
        suburb = try container.decode(String.self, forKey: .suburb)
        neighborhood = try container.decode(String.self, forKey: .neighborhood)
        let array = try? container.decode([Double].self, forKey: .coordinates)
        if let array = array {
            coordinates = CLLocationCoordinate2D(latitude: array[1], longitude: array[0])
        }
    }
}
