//
//  MPSFastReverseGeocode.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 5/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public struct MPSFastReverseGeocode {
    public var address: String?
    public var postalAddress: String?
    public var compactAddress: String?
    public var last: String?
    public var name: String?
    public var poi: String?
    public var country: String?
    public var province: String?
    public var county: String?
    public var district: String?
    public var ruralDistrict: String?
    public var city: String?
    public var village: String?
    public var region: String?
    public var neighbourhood: String?
    public var primary: String?
    public var plaque: String?
    public var postalCode: String?
    public var coordinates: MPSLocationCoordinate?

    enum CodingKeys: String, CodingKey {
        case address
        case postalAddress = "postal_address"
        case compactAddress = "address_compact"
        case last
        case name
        case poi
        case country
        case province
        case county
        case district
        case ruralDistrict = "rural_district"
        case city
        case village
        case region
        case neighbourhood
        case primary
        case plaque
        case postalCode = "postal_code"
        case geometry = "geom"
    }

    enum GeometryKeys: String, CodingKey {
        case coordinates
    }
}

extension MPSFastReverseGeocode: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(String.self, forKey: .address)
        postalAddress = try container.decode(String.self, forKey: .postalAddress)
        compactAddress = try container.decode(String.self, forKey: .compactAddress)
        postalAddress = try container.decode(String.self, forKey: .postalAddress)
        last = try container.decode(String.self, forKey: .last)
        name = try container.decode(String.self, forKey: .name)
        poi = try container.decode(String.self, forKey: .poi)
        country = try container.decode(String.self, forKey: .country)
        province = try container.decode(String.self, forKey: .province)
        county = try container.decode(String.self, forKey: .county)
        district = try container.decode(String.self, forKey: .district)
        ruralDistrict = try container.decode(String.self, forKey: .ruralDistrict)
        city = try container.decode(String.self, forKey: .city)
        village = try container.decode(String.self, forKey: .village)
        region = try container.decode(String.self, forKey: .region)
        neighbourhood = try container.decode(String.self, forKey: .neighbourhood)
        primary = try container.decode(String.self, forKey: .primary)
        plaque = try container.decode(String.self, forKey: .plaque)
        postalCode = try container.decode(String.self, forKey: .postalCode)

        let geomContainer = try container.nestedContainer(keyedBy: GeometryKeys.self, forKey: .geometry)
        let arr = try geomContainer.decode([String].self, forKey: .coordinates)
        coordinates = MPSLocationCoordinate(latitude: Double(arr[1])!, longitude: Double(arr[0])!)
    }
}
