//
//  Search+Categories.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 7/10/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

// MARK: Search Categories

extension Search {
    @objc public final class Categories: NSObject, OptionSet {

        /// Raw value for option set.
        @objc public let rawValue: Int

        /// Initializes a category set with raw value. Do not use directly.
        @objc public init(rawValue: Int) { self.rawValue = rawValue }

        /// Points of interest.
        @objc public static let poi                   = Search.Categories(rawValue: 1 << 0)

        /// City names.
        @objc public static let city                  = Search.Categories(rawValue: 1 << 1)

        /// Any kind of road. Street, Freeway, Alley, Avenue, Tunnels, etc.
        @objc public static let road                  = Search.Categories(rawValue: 1 << 2)

        /// Neighborhood names.
        @objc public static let neighborhood          = Search.Categories(rawValue: 1 << 3)

        /// County names.
        @objc public static let county                = Search.Categories(rawValue: 1 << 4)

        /// District names.
        @objc public static let district              = Search.Categories(rawValue: 1 << 5)

        /// Land-use names.
        @objc public static let landUse               = Search.Categories(rawValue: 1 << 6)

        /// Province names.
        @objc public static let province              = Search.Categories(rawValue: 1 << 7)

        /// Body of water or jungle.
        @objc public static let bodyOfWaterOrJungle   = Search.Categories(rawValue: 1 << 8)

        /// Nearby search.
        @objc public static let nearby                = Search.Categories(rawValue: 1 << 9)
    }
}

extension Search.Categories {
    func urlRepresentation() -> String {

        enum CategoryKeys: String {
            case nearby
            case city
            case county
            case district
            case landUse = "landuse"
            case neighborhood = "neighbourhood"
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
        if self.contains(.district) {
            select.append(.district)
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

        return select.map { $0.rawValue }.joined(separator: ",")
    }
}
