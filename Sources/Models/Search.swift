//
//  MPSSearch.swift
//  MapirServices
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import CoreLocation
import Foundation

public struct Search {
    var text: String
    var categories: Search.Categories?
    var filter: Search.Filter?
    var coordinates: CLLocationCoordinate2D
    var results: [Search.Result] = []

    public struct Categories: OptionSet {

        public let rawValue: Int

        public init(rawValue: Int) { self.rawValue = rawValue }

        /// Points of interest.
        public static let poi                   = Search.Categories(rawValue: 1 << 0)

        /// City names.
        public static let city                  = Search.Categories(rawValue: 1 << 1)

        /// Any kind of road. Street, Freeway, Alley, Avenue, Tunnels, etc.
        public static let road                  = Search.Categories(rawValue: 1 << 2)

        /// Neighborhood names.
        public static let neighborhood          = Search.Categories(rawValue: 1 << 3)

        /// County names.
        public static let county                = Search.Categories(rawValue: 1 << 4)

        /// District names.
        public static let district              = Search.Categories(rawValue: 1 << 5)

        /// Landuse names.
        public static let landuse               = Search.Categories(rawValue: 1 << 6)

        /// Province names.
        public static let province              = Search.Categories(rawValue: 1 << 7)

        /// Body of water or jungle.
        public static let bodyOfWaterOrJungle   = Search.Categories(rawValue: 1 << 8)
    }

    public enum Filter {

        public enum DistanceUnit: String {
            case kilometer  = "km"
            case meter      = "m"
        }

        case distance(Double, unit: DistanceUnit)

        case city(String)
        case county(String)
        case province(String)
        case neighborhood(String)
        case district(String)
    }

}

extension Search: Encodable {

    enum CodingKeys: String, CodingKey {
        case text
        case selectionOptions = "$select"
        case filter = "$filter"
        case coordinates = "location"
    }

    enum GeometryKeys: String, CodingKey {
        case type
        case coordinates
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)

        if let selectionOptions = categories {
            try container.encode(selectionOptions, forKey: .selectionOptions)
        }

        if let filter = filter {
            try container.encode(filter, forKey: .filter)
        }

        var geometryContainer = container.nestedContainer(keyedBy: GeometryKeys.self, forKey: .coordinates)
        try geometryContainer.encode("Point", forKey: .type)
        let array = [coordinates.longitude, coordinates.latitude]
        try geometryContainer.encode(array, forKey: .coordinates)
    }
}

extension Search: Decodable {
    internal struct SearchResponseScheme: Decodable {
        var count: Int
        var results: [Search.Result]

        enum CodingKeys: String, CodingKey {
            case allResultsCount = "odata.count"
            case results = "value"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.results = try container.decode([Search.Result].self, forKey: .results)
            self.count = 0
        }
    }

    public init(from decoder: Decoder) throws {
        let scheme = try SearchResponseScheme(from: decoder)
        self.results = scheme.results
        self.text = ""
        self.coordinates = CLLocationCoordinate2D()
    }
}

extension Search.Filter: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        var textToEncode = ""
        switch self {
        case .distance(let amount, let unit):
            textToEncode = "distance eq \(amount)\(unit.rawValue)"
        case .city(let name):
            textToEncode = "city eq \(name)"
        case .province(let name):
            textToEncode = "province eq \(name)"
        case .county(let name):
            textToEncode = "county eq \(name)"
        case .neighborhood(let name):
            textToEncode = "neighbourhood eq \(name)"
        case .district(let name):
            textToEncode = "district eq \(name)"
        }

        try container.encode(textToEncode)
    }
}

extension Search.Categories: Encodable {
    enum CategoryKeys: String {
        case city
        case county
        case district
        case landuse
        case neighborhood = "neighbourhood"
        case poi
        case province
        case road = "roads"
        case bodyOfWaterOrJungle = "woodwater"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        var select: [CategoryKeys] = []
        if self.contains(.city) {
            select.append(.city)
        }
        if self.contains(.county) {
            select.append(.county)
        }
        if self.contains(.district) {
            select.append(.district)
        }
        if self.contains(.landuse) {
            select.append(.landuse)
        }
        if self.contains(.neighborhood) {
            select.append(.neighborhood)
        }
        if self.contains(.poi) {
            select.append(.poi)
        }
        if self.contains(.province) {
            select.append(.province)
        }
        if self.contains(.road) {
            select.append(.road)
        }
        if self.contains(.bodyOfWaterOrJungle) {
            select.append(.bodyOfWaterOrJungle)
        }

        let selectText = select.map { $0.rawValue }.joined(separator: ",")
        try container.encode(selectText)

    }
}
