//
//  Placemark.swift
//  MapirServices
//
//  Created by Alireza Asadi on 29/8/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation
import CoreLocation

public struct Placemark: Identifiable {

    /// Unique identifier of the placemark.
    public let id: UUID

    /// Full address
    public let address: String?

    /// Postal Address: City / Main Street / Last Street
    public let postalAddress: String?

    /// Compact Address: City / District / Main Street / Last Street
    public let compactAddress: String?

    /// Name of the Last street or place.
    public let last: String?

    /// Name of the Last street or place.
    public let name: String?

    /// Name of the place.
    public let poi: String?

    /// Country of the place.
    public let country: String?

    /// Province of the place.
    public let province: String?

    /// County of the place.
    public let county: String?

    /// District of the place.
    public let district: String?

    /// Rural district of the place if it is located in a rural area.
    public let ruralDistrict: String?

    /// City of the place.
    public let city: String?

    /// Village of the place.
    public let village: String?

    /// Region of the place based on municipal information.
    public let region: String?

    /// Neighborhood name of the place based on municipal information.
    public let neighborhood: String?

    /// Name of the last primary street leading to the place.
    public let primary: String?

    /// Building number (Plaque) of the place.
    public let plaque: String?

    /// Postal code of the place.
    public let postalCode: String?

    /// Location of the place.
    public let location: CLLocation?
}

// MARK: Equatable conformance
extension Placemark: Hashable, Equatable {
    public static func == (_ rhs: Placemark, _ lhs: Placemark) -> Bool {
        rhs.id == lhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Placemark {
    struct ReverseGeocodeResponseScheme: Decodable {
        var address: String?
        var postalAddress: String?
        var compactAddress: String?
        var last: String?
        var name: String?
        var poi: String?
        var country: String?
        var province: String?
        var county: String?
        var district: String?
        var ruralDistrict: String?
        var city: String?
        var village: String?
        var region: String?
        var neighborhood: String?
        var primary: String?
        var plaque: String?
        var postalCode: String?
        var coordinates: CLLocationCoordinate2D?

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
            case district = "region"
            case ruralDistrict = "rural_district"
            case city
            case village
            case region = "district"
            case neighborhood = "neighbourhood"
            case primary
            case plaque
            case postalCode = "postal_code"
            case geometry = "geom"
        }

        enum GeometryKeys: String, CodingKey {
            case coordinates
        }

        init(from decoder: Decoder) throws {
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
            neighborhood = try value.decode(String.self, forKey: .neighborhood)
            primary = try value.decode(String.self, forKey: .primary)
            plaque = try value.decode(String.self, forKey: .plaque)
            postalCode = try value.decode(String.self, forKey: .postalCode)

            let geomContainer = try value.nestedContainer(keyedBy: GeometryKeys.self, forKey: .geometry)
            let arr = try geomContainer.decode([String].self, forKey: .coordinates)
            if let long = Double(arr[0]), let lat = Double(arr[1]) {
                coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
            }
        }
    }
}

extension Placemark {

    init(from r: ReverseGeocodeResponseScheme) {
        var location: CLLocation?
        if let coordinate = r.coordinates {
            location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
        self.init(
            id: UUID(),
            address: r.address,
            postalAddress: r.postalAddress,
            compactAddress: r.compactAddress,
            last: r.last,
            name: r.name,
            poi: r.postalAddress,
            country: r.country,
            province: r.province,
            county: r.county,
            district: r.district,
            ruralDistrict: r.ruralDistrict,
            city: r.city,
            village: r.village,
            region: r.region,
            neighborhood: r.neighborhood,
            primary: r.primary,
            plaque: r.plaque,
            postalCode: r.postalCode,
            location: location
        )
    }

    init(from d: DistanceMatrix.Result.ResponseScheme.PlaceScheme) {
        self.init(
            id: UUID(),
            address: nil,
            postalAddress: nil,
            compactAddress: nil,
            last: nil,
            name: d.name,
            poi: nil,
            country: nil,
            province: d.provinceName,
            county: d.countyName,
            district: d.districtName,
            ruralDistrict: d.ruralDistrictName,
            city: nil,
            village: nil,
            region: nil,
            neighborhood: d.neighbourhoodTitle,
            primary: nil,
            plaque: nil,
            postalCode: nil,
            location: nil
        )
    }
}
