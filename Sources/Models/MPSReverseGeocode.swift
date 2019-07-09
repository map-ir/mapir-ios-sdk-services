//
//  MPIRReverseGeocode.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 11/3/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import CoreLocation
import Foundation

public struct MPSReverseGeocode {

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

extension MPSReverseGeocode: Decodable {
    public init(from decoder: Decoder) throws {
        let value = try decoder.container(keyedBy: CodingKeys.self)
        address = try value.decode(String.self, forKey: .address)
        postalAddress = try value.decode(String.self, forKey: .postalAddress)
        last = try value.decode(String.self, forKey: .last)
        name = try value.decode(String.self, forKey: .name)
        poi = try value.decode(String.self, forKey: .poi)
        country = try value.decode(String.self, forKey: .country)
        province = try value.decode(String.self, forKey: .province)
        county = try value.decode(String.self, forKey: .county)
        district = try value.decode(String.self, forKey: .district)
        ruralDistrict = try value.decode(String.self, forKey: .ruralDistrict)
        city = try value.decode(String.self, forKey: .city)
        village = try value.decode(String.self, forKey: .village)
        region = try value.decode(String.self, forKey: .region)
        neighbourhood = try value.decode(String.self, forKey: .neighbourhood)
        primary = try value.decode(String.self, forKey: .primary)
        plaque = try value.decode(String.self, forKey: .plaque)
        postalCode = try value.decode(String.self, forKey: .postalCode)

        let geomContainer = try value.nestedContainer(keyedBy: GeometryKeys.self, forKey: .geometry)
        let arr = try geomContainer.decode([String].self, forKey: .coordinates)
        if let long = Double(arr[0]), let lat = Double(arr[1]) {
            coordinates = MPSLocationCoordinate(latitude: lat, longitude: long)
        }
    }
}
