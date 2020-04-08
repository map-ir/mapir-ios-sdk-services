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
        @objc let province: String?

        /// The name of county accociated with the result.
        @objc let county: String?

        /// The district accociated with the result.
        @objc let district: String?

        /// The city accociated with the result.
        @objc let city: String?

        /// The region accociated with the result.
        @objc let region: String?

        /// The neighborhood name accociated with the result.
        @objc let neighborhood: String?

        /// Title of the result.
        @objc let title: String?

        /// Address of the result.
        @objc let address: String?

        /// Type of the result.
        @objc let type: String?

        /// FClass of the result.
        @objc let fclass: String?

        /// Coordinate associtated with the result.
        let coordinate: CLLocationCoordinate2D?

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

    /// Returns the coordinate of the result.
    ///
    /// - returns: A `CLLocationCoordinate2D` object indicating the coordinate of the
    /// result. If there is no coordinate associated with the result, return value will
    /// be `kCLLocationCoordinate2DInvalid`.
    ///
    /// - note: This method is intended to be used in Objective-C only. In Swift use
    /// `coordinate` property.
    func getCoordinate() -> CLLocationCoordinate2D {
        return coordinate ?? kCLLocationCoordinate2DInvalid
    }
}

// MARK: Decoding Result

extension Search.Result {
    struct SearchResponseScheme: Decodable {
        var count: Int
        var value: [Search.Result.ResultScheme]

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
            let coords = try coordContainer.decode(CLLocationCoordinate2D.GeoJSONType.self, forKey: .coordinates)
            coordinate = try CLLocationCoordinate2D(fromGeoJSONGeometry: coords)
        }
    }
}