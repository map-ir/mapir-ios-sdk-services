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

    /// Full address
    ///
    /// In farsi: آدرس کامل
    public private(set) var address: String?

    /// Postal Address: City / Main Street / Last Street
    ///
    /// In farsi: آدرس پستی
    public private(set) var postalAddress: String?

    /// Compact Address: City / District / Main Street / Last Street
    ///
    /// In farsi: آدرس کوتاه
    public private(set) var compactAddress: String?

    /// Name of the Last street or place.
    ///
    /// In farsi: نام خود محل یا آخرین خیابان
    public private(set) var last: String?

    /// Name of the Last street or place.
    ///
    /// In farsi: نام خود محل یا آخرین خیابان
    public private(set) var name: String?

    /// Name of the place.
    ///
    /// In farsi: نام مکان در صورت وجود
    public private(set) var poi: String?

    /// Country of the place.
    ///
    /// In farsi: کشور
    public private(set) var country: String?

    /// Province of the place.
    ///
    /// In farsi: استان
    public private(set) var province: String?

    /// County of the place.
    ///
    /// In farsi: شهرستان
    public private(set) var county: String?

    /// District of the place.
    ///
    /// In farsi: منطقه شهرداری
    public private(set) var district: String?

    /// Rural district of the place if it is located in a rural aera.
    ///
    /// In farsi: دهستان
    public private(set) var ruralDistrict: String?

    /// City of the place.
    ///
    /// In farsi: شهر
    public private(set) var city: String?

    /// Village of the place.
    ///
    /// In farsi: روستا
    public private(set) var village: String?

    /// Region of the place based on municipal information.
    ///
    /// In farsi: بخش
    public private(set) var region: String?

    /// Neighbourhood name of the place based on municipal information.
    ///
    /// In farsi: نام محله شهرداری
    public private(set) var neighbourhood: String?

    /// Name of the last primary street leading to the place.
    ///
    /// In farsi: خیابان اصلی منتهی به محل
    public private(set) var primary: String?

    /// Building number (Plaque) of the place.
    ///
    /// In farsi: پلاک
    public private(set) var plaque: String?

    /// Postal code of the place.
    ///
    /// In farsi: کد پستی
    public private(set) var postalCode: String?

    /// Coordinates of the place.
    ///
    /// In farsi: مختصات
    public private(set) var coordinates: CLLocationCoordinate2D?

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
            coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
    }
}
