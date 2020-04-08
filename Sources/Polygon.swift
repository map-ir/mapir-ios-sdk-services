//
//  Polygon.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 18/1/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import Foundation

/// A Polygon object represents a closed shape with 4 or more vertices specified as
/// `CLLocationCoordinate2D` objects. Polygons are used to demonstrate a building,
/// island, lake or any other area that you want to highlight.
///
/// The vertices are connected in the order that you provide. You should close the
/// polygon by specifying same `CLLocationCoordinate2D`s as the first and the last
/// vertex.
@objc public final class Polygon: NSObject {

    /// Coordinates of vertices in the polygon.
    public var coordinates: [CLLocationCoordinate2D]

    /// Polygons nested inside the main polygon.
    ///
    /// The area of interior polygons are excluded from the main polygon.
    public var interiorPolygons: [Polygon]

    /// Creates a Polygon object.
    ///
    /// - Parameters:
    ///   - coordinates: Coordinates of the vertices.
    ///   - interiorPolygons: An array of Polygon objects to exclude from the overall
    ///     shape. Empty array means that the overall shape has no interior polygons.
    ///
    /// - Throws: Throws `GeoJSON.insufficientCoordinates` if coordinate count is less
    ///   than 4 (Which is required by polygon definition in GeoJSON).
    public init(
        coordinates: [CLLocationCoordinate2D],
        interiorPolygons: [Polygon] = []
    ) throws {
        guard coordinates.count > 3 else {
            throw GeoJSONError.insufficientCoordinates
        }
        self.coordinates = coordinates
        self.interiorPolygons = interiorPolygons
    }

    /// Creates a `Polygon` using GeoJSON values of polygon.
    ///
    /// Fails if input array of polygons is empty or any of polygons have less than 4
    /// coordinates.
    convenience init(fromGeoJSONGeometry geometry: [[[Double]]]) throws {
        guard let outerRing = geometry.first else {
            throw GeoJSONError.insufficientPolygons
        }

        let outerRingCoordinates = try outerRing.compactMap { try CLLocationCoordinate2D(fromGeoJSONGeometry: $0) }

        let interiorRings: [Polygon] = try geometry[1...].map { (rings) in
            let coordinates = try rings.compactMap { try CLLocationCoordinate2D(fromGeoJSONGeometry: $0) }
            let polygon = try Polygon(coordinates: coordinates)
            return polygon
        }

        try self.init(coordinates: outerRingCoordinates, interiorPolygons: interiorRings)
    }
}

extension Polygon {

    /// Tests a coordinate to findout whether it is inide the receiver or not.
    ///
    /// - Parameters:
    ///   - coordinate: A coordinate to test.
    ///   - includeBoundary: Indicates that boundaries are considered as part of
    ///     the `Polygon` or not.
    ///
    /// - Returns: A `Bool` value. `true` means that the coordinate is inside the
    ///   polygon.
    @objc public func contains(_ coordinate: CLLocationCoordinate2D, includeBoundary: Bool = true) -> Bool {
        let bbox = BoundingBox(polygon: self)
        guard bbox.contains(coordinate) else {
            return false
        }

        var angles: [Double] = []

        for (offset, vertex) in coordinates.enumerated() {
            guard offset + 1 < coordinates.endIndex else { break }
            let nextIndex = offset + 1
            let nextVertex = coordinates[nextIndex]

            // y - y2 = (y2 - y1) / (x2 - x1) * (x - x2)
            let onBoundary = (coordinate.latitude - vertex.latitude ==
                (vertex.latitude - nextVertex.latitude) / (vertex.longitude - nextVertex.longitude) *
                (coordinate.longitude - vertex.longitude))
            if onBoundary == true {
                return includeBoundary
            }

            let slopeLine1 = slope(origin: coordinate, coordinate: vertex)
            let angleLine1 = atan(slopeLine1)
            let q1 = Quarter(of: vertex, relativeTo: coordinate)
            let angleOfLine1WithPosX = angleWithPostiveX(angle: angleLine1, inQuarter: q1)

            let slopeLine2 = slope(origin: coordinate, coordinate: nextVertex)
            let angleLine2 = atan(slopeLine2)
            let q2 = Quarter(of: nextVertex, relativeTo: coordinate)
            let angleOfLine2WithPosX = angleWithPostiveX(angle: angleLine2, inQuarter: q2)

            var angleBetweenLines = angleOfLine2WithPosX - angleOfLine1WithPosX
            if angleBetweenLines < -Double.pi {
                angleBetweenLines = angleOfLine2WithPosX + 2 * Double.pi - angleOfLine1WithPosX
            } else if angleBetweenLines > Double.pi {
                angleBetweenLines = angleOfLine2WithPosX - angleOfLine1WithPosX - 2 * Double.pi
            }

            angles.append(angleBetweenLines)
        }

        let sum = angles.reduce(0.0, +)
        let sumDevidedByPi = Int((sum / Double.pi).rounded(.toNearestOrEven))

        return sumDevidedByPi == 2 || sumDevidedByPi == -2
    }

    private enum Quarter {
        case one
        case two
        case three
        case four

        init(of coordinate: CLLocationCoordinate2D, relativeTo origin: CLLocationCoordinate2D) {
            let x = (coordinate.longitude - origin.longitude) >= 0
            let y = (coordinate.latitude - origin.latitude) >= 0

            switch (x, y) {
            case (true, true):
                self = .one
            case (true, false):
                self = .four
            case (false, true):
                self = .two
            case (false, false):
                self = .three

            }
        }
    }

    private func abs(_ value: Double) -> Double {
        value >= 0 ? value : -value
    }

    private func angleWithPostiveX(angle: Double, inQuarter quarter: Quarter) -> Double {
        let value = abs(angle)

        switch quarter {
        case .one: return value
        case .two: return Double.pi - value
        case .three: return Double.pi + value
        case .four: return 2 * Double.pi - value
        }
    }

    private func slope(origin: CLLocationCoordinate2D, coordinate: CLLocationCoordinate2D) -> Double {
        if coordinate.longitude - origin.longitude == 0 {
            return Double.infinity * (coordinate.latitude - origin.latitude > 0 ? 1 : -1)
        } else {
            return (coordinate.latitude - origin.latitude) / (coordinate.longitude - origin.longitude)
        }
    }

    private func convertToDegree(radianValue: Double) -> Double {
        radianValue * 180 / Double.pi
    }
}

extension Polygon: GeoJSONGeometryConvertible {
    func convertedToGeoJSONGeometry() -> [[[Double]]] {
        let exteriorPolygon = coordinates.map { $0.convertedToGeoJSONGeometry() }
        var coordinates: [[[Double]]] = [exteriorPolygon]
        for interiorPolygon in interiorPolygons {
            coordinates.append(
                interiorPolygon.coordinates.map { $0.convertedToGeoJSONGeometry() })

        }
        return coordinates
    }
}
