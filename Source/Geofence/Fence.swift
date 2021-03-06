//
//  Fence.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 10/1/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import CoreLocation
import Foundation

/// Fence represents an area which is used in a Geofence task to determine whether a
/// point is in or not.
public struct Fence: Identifiable {

    /// ID of the Fence. It is generated by Map.ir.
    public let id: Int

    /// Boundary is the a Polygon object that represents the area of the fence.
    public let boundaries: [Polygon]

    /// Additional data about the  geofence.
    public let meta: [String: String]?

    /// The date that the fence was created.
    public let creationDate: Date?

    /// The last date that the fence was updated.
    public let lastUpdateDate: Date?

    init(
        id: Int,
        boundaries: [Polygon],
        meta: [String: String]? = nil,
        creationDate: Date? = nil,
        lastUpdateDate: Date? = nil
    ) {
        self.id = id
        self.boundaries = boundaries
        self.meta = meta
        self.creationDate = creationDate
        self.lastUpdateDate = lastUpdateDate
    }

}

extension Fence: Hashable, Equatable {

    /// Checks the equality of two `Fence` objects. Fences are equal when their `id` is
    /// the same.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    /// Hashes the essential components of this value by feeding them into the given
    /// hasher.
    ///
    /// - Parameter hasher: `Hasher` object that combines components of the object and
    ///   creates the `hashValue`.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: Testing Coordinates in Fences

extension Fence {

    /// Determines whether a coordinate is located within the `Fence` or not. returns
    /// true if the coordinate is within the boundaries of the `Fence`.
    ///
    /// - Parameters:
    ///   - coordinate: The coordinate that is going to be tested in the `Fence`.
    ///   - includeBoundaries: Indicates that boundaries of polygons are considered inside
    ///     or outside of the `Polygon`. `true` means boundaries are considered as part of
    ///     the `Polygon`.
    ///
    /// - Returns: A `Bool` value. `true`
    public func contains(_ coordinate: CLLocationCoordinate2D, includeBoundaries: Bool = true) -> Bool {
        for polygon in boundaries {
            if polygon.contains(coordinate, includeBoundary: includeBoundaries) {
                return true
            }
        }
        return false
    }
}

extension Array where Element == Fence {
    public func fencesThatContain(_ coordinate: CLLocationCoordinate2D, includeBoundaries: Bool = true) -> [Fence] {
        var fences: [Fence] = []
        for fence in self {
            if fence.contains(coordinate, includeBoundaries: includeBoundaries) {
                fences.append(fence)
            }
        }
        return fences
    }
}

extension Fence {
    init(from response: ResponseScheme) {
        let polygons: [Polygon]
        switch response.boundary {
        case .polygon(let polygon):
            polygons = [polygon]
        case .multiPolygon(let multiPolygon):
            polygons = multiPolygon
        }

        self.init(
            id: response.id,
            boundaries: polygons,
            meta: response.meta,
            creationDate: response.createdAt,
            lastUpdateDate: response.updatedAt
        )
    }

    struct ResponseScheme: Decodable {
        var id: Int
        var boundary: Geometry
        var meta: [String: String]?
        var createdAt: Date?
        var updatedAt: Date?

        enum CodingKeys: String, CodingKey {
            case id
            case boundary
            case meta
            case createdAt = "created_at"
            case updatedAt = "updated_at"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            id = try container.decode(Int.self, forKey: .id)
            boundary = try container.decode(Geometry.self, forKey: .boundary)

            meta = try? container.decodeIfPresent([String: String].self, forKey: .meta)

            let creationDateString = try container.decodeIfPresent(String.self, forKey: .createdAt)
            let lastUpdateDateString = try container.decodeIfPresent(String.self, forKey: .updatedAt)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-DD hh:mm:ss"
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

            if let creationDateString = creationDateString, let lastUpdateDateString = lastUpdateDateString {
                updatedAt = dateFormatter.date(from: creationDateString)
                updatedAt = dateFormatter.date(from: lastUpdateDateString)
            }
        }
    }
}
