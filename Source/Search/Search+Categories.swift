//
//  Search+Categories.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 7/10/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

// MARK: Search Categories

extension Search {

    /// Search `Categories` is an `OptionSet` You can create a `Categories` object using
    /// multiple values in `Categories` class.
    public struct Categories: OptionSet {

        /// Raw value for option set.
        public let rawValue: Int

        /// Initializes a category set with raw value. Do not use directly.
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
        public static let region                = Search.Categories(rawValue: 1 << 5)

        /// Land-use names.
        public static let landUse               = Search.Categories(rawValue: 1 << 6)

        /// Province names.
        public static let province              = Search.Categories(rawValue: 1 << 7)

        /// Body of water or jungle.
        public static let bodyOfWaterOrJungle   = Search.Categories(rawValue: 1 << 8)

        /// Nearby search.
        public static let nearby                = Search.Categories(rawValue: 1 << 9)
    }
}

extension Search.Categories {
    init?(description: String) {
        switch description {
        case "nearby":
            self.rawValue = Search.Categories.nearby.rawValue
        case "city":
            self.rawValue = Search.Categories.city.rawValue
        case "county":
            self.rawValue = Search.Categories.county.rawValue
        case "region":
            self.rawValue = Search.Categories.region.rawValue
        case "landUse", "landuse":
            self.rawValue = Search.Categories.landUse.rawValue
        case "neighborhood", "neighbourhood":
            self.rawValue = Search.Categories.neighborhood.rawValue
        case "poi":
            self.rawValue = Search.Categories.poi.rawValue
        case "province":
            self.rawValue = Search.Categories.province.rawValue
        case "road", "roads":
            self.rawValue = Search.Categories.road.rawValue
        case "bodyOfWaterOrJungle", "woodwater":
            self.rawValue = Search.Categories.bodyOfWaterOrJungle.rawValue
        default: return nil
        }
    }
}

extension Search.Categories {

    var stringValues: [String] {
        enum CategoryKeys: String {
            case nearby
            case city
            case county
            case region
            case landUse = "landuse"
            case neighborhood //= "neighborhood"
            case poi
            case province
            case road = "roads"
            case bodyOfWaterOrJungle = "woodwater"
        }

        var select: [CategoryKeys] = []
        if self.contains(.city) {
            select.append(.city)
        }
        if self.contains(.county) {
            select.append(.county)
        }
        if self.contains(.region) {
            select.append(.region)
        }
        if self.contains(.landUse) {
            select.append(.landUse)
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
        if self.contains(.nearby) {
            select.append(.nearby)
        }

        return select.map { $0.rawValue }
    }
    var urlRepresentation: String {
        stringValues.joined(separator: ",")
    }
}
