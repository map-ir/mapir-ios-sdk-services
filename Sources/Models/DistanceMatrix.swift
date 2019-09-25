//
//  DistanceMatrix.swift
//  MapirServices
//
//  Created by Alireza Asadi on 5/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public struct DistanceMatrix {

    public private(set) var distances: Table<String, Double>
    public private(set) var durations: Table<String, Double>
    public private(set) var origins: [String: Place]
    public private(set) var destinations: [String: Place]
}

// MARK: - Distance methods
extension DistanceMatrix {
    public func distance(from origin: Place, to destination: Place) -> Double? {
        guard let (origin, _) = origins.first(where: { $0.value == origin }) else { return nil }
        guard let (destination, _) = destinations.first(where: { $0.value == destination }) else { return nil }
        return distance(from: origin, to: destination)
    }

    public func distance(from origin: String, to destination: String) -> Double? {
        return distances[origin, destination]
    }

    public func allDistances(from origin: String) -> [String: Double]? {
        return distances.valuesOf(row: origin)
    }

    public func allDistances(to destination: String) -> [String: Double]? {
        return distances.valuesOf(column: destination)
    }

    public func distance(from origins: Set<String>, to destination: String) -> [String: Double]? {
        return distances.valuesOf(column: destination)?.filter { origins.contains($0.key) }
    }

    public func distance(from origin: String, to destinations: Set<String>) -> [String: Double]? {
        return distances.valuesOf(row: origin)?.filter { destinations.contains($0.key) }
    }
}

// MARK: - Duration methods
extension DistanceMatrix {
    public func duration(from origin: Place, to destination: Place) -> Double? {
        guard let (origin, _) = origins.first(where: { $0.value == origin }) else { return nil }
        guard let (destination, _) = destinations.first(where: { $0.value == destination }) else { return nil }
        return duration(from: origin, to: destination)
    }

    public func duration(from origin: String, to destination: String) -> Double? {
        return durations[origin, destination]
    }

    public func allDurations(from origin: String) -> [String: Double]? {
        return durations.valuesOf(row: origin)
    }

    public func allDurations(to destination: String) -> [String: Double]? {
        return durations.valuesOf(column: destination)
    }

    public func duration(from origins: Set<String>, to destination: String) -> [String: Double]? {
        return durations.valuesOf(column: destination)?.filter { origins.contains($0.key) }
    }

    public func duration(from origin: String, to destinations: Set<String>) -> [String: Double]? {
        return durations.valuesOf(row: origin)?.filter { destinations.contains($0.key) }
    }

}

// MARK: - Related Structures
extension DistanceMatrix {
    public struct Options: OptionSet {

        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// Calculate distances.
        public static let distance = DistanceMatrix.Options(rawValue: 1 << 0)

        /// Calculate durations.
        public static let duration = DistanceMatrix.Options(rawValue: 1 << 1)

        /// Sort results by distance and duration.
        public static let sorted = DistanceMatrix.Options(rawValue: 1 << 2)
    }
}

// MARK: - Utilities
extension DistanceMatrix: Decodable {

    private struct DistanceResponseScheme: Decodable {
        var origin: String
        var destination: String
        var distance: Double

        enum CodingKeys: String, CodingKey {
            case origin = "origin_index"
            case destination = "destination_index"
            case distance
        }
    }

    private struct DurationResponseScheme: Decodable {
        var origin: String
        var destination: String
        var duration: Double

        enum CodingKeys: String, CodingKey {
            case origin = "origin_index"
            case destination = "destination_index"
            case duration
        }
    }

    enum CodingKeys: String, CodingKey {
        case distances = "distance"
        case durations = "duration"
        case origins
        case destinations
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        origins = try container.decode([String: Place].self, forKey: .origins)
        destinations = try container.decode([String: Place].self, forKey: .destinations)
        let durationResponse = try? container.decode([DurationResponseScheme].self, forKey: .durations)
        let distanceResponse = try? container.decode([DistanceResponseScheme].self, forKey: .distances)

        durations = Table()
        distances = Table()

        for (name, origin) in origins {
            origins.updateValue(origin, forKey: name)
        }

        for (name, destination) in destinations {
            destinations.updateValue(destination, forKey: name)
        }
        
        if let durationResponse = durationResponse {
            for aDuration in durationResponse {
                durations[aDuration.origin, aDuration.destination] = aDuration.duration
            }
        }

        if let distanceResponse = distanceResponse {
            for aDistance in distanceResponse {
                distances[aDistance.origin, aDistance.destination] = aDistance.distance
            }
        }
    }
}

// MARK: - Errors
public enum DistanceMatrixError: Error, LocalizedError {
    case invalidCharacterInName(String)

    case emptyName

    case noOriginsSpecified

    case noDestinationsSpecified

    var localizedDescription: String {
        switch self {
        case .invalidCharacterInName(let name):
            return "\"\(name)\" contains invalid characters. Names must only contain alphanumeric characters"
        case .emptyName:
            return "Found an empty name. Names can't be empty."
        case .noOriginsSpecified:
            return "No origin is specified. At least one is needed."
        case .noDestinationsSpecified:
            return "No destination is specified. At least one is needed."
        }
    }
}
