//
//  GeoJSON.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 19/1/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import Foundation

struct FeatureCollection: Codable {
    var features: [Feature]

    init(features: [Feature]) {
        self.features = features
    }

    enum CodingKeys: String, CodingKey {
        case features, type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        features = try container.decode([Feature].self, forKey: .features)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode("FeatureCollection", forKey: .type)
        try container.encode(features, forKey: .features)
    }
}

struct Feature: Codable {
    var geometry: Geometry
    var properties: [String: Any] = [:]

    init(geometry: Geometry, properties: [String: Any] = [:]) {
        self.geometry = geometry
        self.properties = properties
    }

    enum CodingKeys: String, CodingKey {
        case geometry, properties, type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        geometry = try container.decode(Geometry.self, forKey: .geometry)
        properties = [:]
        if let properties = try container.decodeIfPresent([String: EncodingHelper].self, forKey: .properties) {
            properties.forEach { self.properties[$0] = $1.associatedValue }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode("Feature", forKey: .type)
        try container.encode(geometry, forKey: .geometry)
        var encodableProperties: [String: EncodingHelper] = [:]
        for (key, value) in properties {
            if let value = value as? Int {
                encodableProperties[key] = EncodingHelper(from: value)
            } else if let value = value as? Double {
                encodableProperties[key] = EncodingHelper(from: value)
            } else if let value = value as? String {
                encodableProperties[key] = EncodingHelper(from: value)
            }
        }
        if !encodableProperties.isEmpty {
            try container.encode(encodableProperties, forKey: .properties)
        }
    }
}

enum Geometry: Codable {
    case polygon(_ geoJSONRep: Polygon)
    case multiPolygon(_ geoJSONRep: [Polygon])

    enum GeometryType: String, Decodable {
        case polygon = "Polygon"
        case multiPolygon = "MultiPolygon"
    }

    enum CodingKeys: String, CodingKey {
        case type, coordinates
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(GeometryType.self, forKey: .type)

        switch type {
        case .polygon:
            let coordinates = try container.decode(Polygon.GeoJSONType.self, forKey: .coordinates)
            let polygon = try Polygon(fromGeoJSONGeometry: coordinates)
            self = .polygon(polygon)
        case .multiPolygon:
            let coordinates = try container.decode([Polygon].GeoJSONType.self, forKey: .coordinates)
            var polygons: [Polygon] = []
            for p in coordinates {
                let polygon = try Polygon(fromGeoJSONGeometry: p)
                polygons.append(polygon)
            }
            self = .multiPolygon(polygons)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .polygon(polygon):
            try container.encode("Polygon", forKey: .type)
            try container.encode(
                polygon.convertedToGeoJSONGeometry(), forKey: .coordinates)
        case let .multiPolygon(multiPolygon):
            try container.encode("MultiPolygon", forKey: .type)
            try container.encode(
                multiPolygon.convertedToGeoJSONGeometry(), forKey: .coordinates)
        }
    }
}

private enum EncodingHelper: Codable {
    case int(_ value: Int)
    case double(_ double: Double)
    case string(_ value: String)

    init(from stringValue: String) {
        self = .string(stringValue)
    }

    init(from doubleValue: Double) {
        self = .double(doubleValue)
    }

    init(from intValue: Int) {
        self = .int(intValue)
    }

    var associatedValue: Any {
        switch self {
        case let .int(value): return value
        case let .double(value): return value
        case let .string(value): return value
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .string(value):
            try container.encode(value)
        case let .int(value):
            try container.encode(value)
        case let .double(value):
            try container.encode(value)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .double(doubleValue)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Unknown type."))
        }
    }
}
