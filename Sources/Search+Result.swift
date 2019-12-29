//
//  Search+Result.swift
//  MapirServices
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import CoreLocation

// MARK: Search Result

extension Search {

    /// Description of a search result object
    @objc(SearchResult)
    public final class Result: NSObject {

        /// Province of the result.
        var province: String?

        /// The name of country accociated with the result.
        var county: String?

        /// The district accociated with the result.
        var district: String?

        /// The city accociated with the result.
        var city: String?

        /// The region accociated with the result.
        var region: String?

        /// The neighborhood name accociated with the result.
        var neighborhood: String?

        /// Title of the result.
        var title: String?

        /// Address of the result.
        var address: String?

        /// Type of the result.
        var type: String?

        /// FClass of the result.
        var fclass: String?

        /// Coordinate associtated with the result.
        var coordinate: CLLocationCoordinate2D?

        /// Creates an empty `Result` object.
        public override init() { }

        init(from resultResponse: Search.Result.ResultScheme) {
            province = resultResponse.province
            county = resultResponse.county
            district = resultResponse.district
            city = resultResponse.city
            region = resultResponse.region
            neighborhood = resultResponse.neighborhood
            title = resultResponse.title
            address = resultResponse.address
            type = resultResponse.type
            fclass = resultResponse.fclass
            coordinate = resultResponse.coordinate
        }
    }
}

extension Search.Result {
    struct SearchResponseScheme {
        var count: Int
        var value: [Search.Result.ResultScheme]
    }
}

extension Search.Result.SearchResponseScheme: Decodable {
    enum CodingKeys: String, CodingKey {
        case count = "odata.count"
        case value = "value"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        count = try container.decode(Int.self, forKey: .count)
        value = try container.decode([Search.Result.ResultScheme].self, forKey: .value)
    }
}

extension Search.Result {
    struct ResultScheme: Decodable {
        var province: String?
        var county: String?
        var district: String?
        var city: String?
        var region: String?
        var neighborhood: String?
        var title: String?
        var address: String?
        var type: String?
        var fclass: String?
        var coordinate: CLLocationCoordinate2D?
    }
}

extension Search.Result.ResultScheme {
    enum CodingKeys: String, CodingKey {
        case province
        case county
        case district
        case city
        case region
        case neighborhood
        case title
        case address
        case type
        case fclass
        case geom
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        province = try container.decode(String.self, forKey: .province)
        county = try container.decode(String.self, forKey: .county)
        district = try container.decode(String.self, forKey: .district)
        city = try container.decode(String.self, forKey: .city)
        region = try container.decode(String.self, forKey: .region)
        neighborhood = try container.decode(String.self, forKey: .neighborhood)
        title = try container.decode(String.self, forKey: .title)
        address = try container.decode(String.self, forKey: .address)
        type = try container.decode(String.self, forKey: .type)
        fclass = try container.decode(String.self, forKey: .fclass)
        address = try container.decode(String.self, forKey: .address)

        enum GeomCodingKeys: String, CodingKey {
            case type
            case coordinates
        }

        let coordContainer = try container.nestedContainer(keyedBy: GeomCodingKeys.self, forKey: .geom)
        let coords = try coordContainer.decode([Double].self, forKey: .coordinates)
        coordinate = CLLocationCoordinate2D(from: coords)
    }
}
