//
//  MPSSearch.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public struct MPSSearch {
    var allResultsCount: Int
    var results: [MPSSearchResult]
}

extension MPSSearch: Decodable {
    enum CodingKeys: String, CodingKey {
        case allResultsCount = "odata.count"
        case results = "value"
    }
}

struct SearchInput: Encodable {
    var text: String
    var selectionOptions: MPSSearchOptions?
    var filter: MPSSearchFilter?
    var coordinates: MPSLocationCoordinate

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

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)

        if let selectionOptions = selectionOptions {
            var select = ""

            if selectionOptions.contains(.city) {
                select += "city,"
            }
            if selectionOptions.contains(.county) {
                select += "county,"
            }
            if selectionOptions.contains(.district) {
                select += "district,"
            }
            if selectionOptions.contains(.landuse) {
                select += "landuse,"
            }
            if selectionOptions.contains(.neighborhood) {
                select += "neighborhood,"
            }
            if selectionOptions.contains(.poi) {
                select += "poi,"
            }
            if selectionOptions.contains(.province) {
                select += "province,"
            }
            if selectionOptions.contains(.roads) {
                select += "roads,"
            }
            if selectionOptions.contains(.woodwater) {
                select += "woodwater,"
            }

            if !select.isEmpty {
                select.removeLast()
                try container.encode(select, forKey: .selectionOptions)
            }
        }

        if let filter = filter {
            var filterText = ""
            switch filter {
            case .distance(let amount, let unit):
                filterText = "distance eq \(amount)\(unit.rawValue)"
            case .city(let name):
                filterText = "city eq \(name)"
            case .province(let name):
                filterText = "province eq \(name)"
            case .county(let name):
                filterText = "county eq \(name)"
            case .neighbourhood(let name):
                filterText = "neighbourhood eq \(name)"
            case .district(let name):
                filterText = "district eq \(name)"
            }

            try container.encode(filterText, forKey: .filter)
        }

        var geometryContainer = container.nestedContainer(keyedBy: GeometryKeys.self, forKey: .coordinates)
        try geometryContainer.encode("Point", forKey: .type)
        let array = [coordinates.longitude, coordinates.latitude]
        try geometryContainer.encode(array, forKey: .coordinates)
    }

}

public struct MPSSearchOptions: OptionSet {

    public let rawValue: Int

    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let poi = MPSSearchOptions(rawValue: 1 << 0)
    public static let city = MPSSearchOptions(rawValue: 1 << 1)
    public static let roads = MPSSearchOptions(rawValue: 1 << 2)
    public static let neighborhood = MPSSearchOptions(rawValue: 1 << 3)
    public static let county = MPSSearchOptions(rawValue: 1 << 4)
    public static let district = MPSSearchOptions(rawValue: 1 << 5)
    public static let landuse = MPSSearchOptions(rawValue: 1 << 6)
    public static let province = MPSSearchOptions(rawValue: 1 << 7)
    public static let woodwater = MPSSearchOptions(rawValue: 1 << 8)
}

public enum MPSSearchFilter {

    public enum DistanceUnit: String {
        case kilometer = "km"
        case meter = "m"
    }

    //    public enum TimeUnit: String {
    //        case minute = "m"
    //        case second = "s"
    //    }

    case distance(Double, unit: DistanceUnit)
    //    case duration(Double, unit: TimeUnit)

    case city(String)
    case county(String)
    case province(String)
    case neighbourhood(String)
    case district(String)

}
