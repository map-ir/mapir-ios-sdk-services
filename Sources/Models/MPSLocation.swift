//
//  MPSLocation.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 5/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public struct MPSLocation {
    public var name: String?
    public var province: String?
    public var county: String?
    public var district: String?
    public var ruralDistrict: String?
    public var suburb: String?
    public var neighbourhood: String?
    public var coordinate: MPSLocationCoordinate?
}

extension MPSLocation: Decodable {
    enum CodingKeys: String, CodingKey {
        case name
        case province = "province_name"
        case county = "county_name"
        case district = "district_title"
        case ruralDistrict = "ruraldistrict_title"
        case suburb = "suburb_title"
        case neighbourhood = "neighbourhood_title"
        case coordinate
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)
        province = try container.decode(String.self, forKey: .province)
        county = try container.decode(String.self, forKey: .county)
        district = try container.decode(String.self, forKey: .district)
        ruralDistrict = try container.decode(String.self, forKey: .ruralDistrict)
        suburb = try container.decode(String.self, forKey: .suburb)
        neighbourhood = try container.decode(String.self, forKey: .neighbourhood)
    }
}
