//
//  DistanceMatrix.swift
//  MapirServices
//
//  Created by Alireza Asadi on 5/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public struct DistanceMatrix {

    public private(set) var distances: [DistanceMatrix.Distance]
    public private(set) var durations: [DistanceMatrix.Duration]
    public private(set) var origins: [String: Place]
    public private(set) var destinations: [String: Place]
}

// MARK: - Distance methods
extension DistanceMatrix {
    public func distance(from origin: Place, to destination: Place) -> Double? {
        return distances.first { $0.origin == origin && $0.destination == destination }?.distance
    }

    public func distance(from originName: String, to destinationName: String) -> Double? {
        guard let origin = origins[originName] else { return nil }
        guard let destination = destinations[destinationName] else { return nil }
        return distance(from: origin, to: destination)
    }

    public func distance(from originNames: [String], to destinationName: String) -> [String: Double]? {
        guard let destination = destinations[destinationName] else { return nil }
        var output: [String: Double] = [:]

        for name in originNames {
            if let origin = origins[name] {
                if let distance = distance(from: origin, to: destination) {
                    output.updateValue(distance, forKey: name)
                }
            }
        }

        return output
    }

    public func distance(from originName: String, to destinationNames: [String]) -> [String: Double]? {
        guard let origin = origins[originName] else { return nil }

        var output: [String: Double] = [:]
        for name in destinationNames {
            if let destination = destinations[name] {
                if let distance = distance(from: origin, to: destination) {
                    output.updateValue(distance, forKey: name)
                }
            }
        }

        return output
    }
}

// MARK: - Duration methods
extension DistanceMatrix {
    public func duration(from origin: Place, to destination: Place) -> Double? {
        return durations.first { $0.origin == origin && $0.destination == destination }?.duration
    }

    public func duration(from originName: String, to destinationName: String) -> Double? {
        guard let origin = origins[originName] else { return nil }
        guard let destination = destinations[destinationName] else { return nil }
        return duration(from: origin, to: destination)
    }

    public func duration(from originNames: [String], to destinationName: String) -> [String: Double]? {
        guard let destination = destinations[destinationName] else { return nil }
        var output: [String: Double] = [:]

        for name in originNames {
            if let origin = origins[name] {
                if let duration = duration(from: origin, to: destination) {
                    output.updateValue(duration, forKey: name)
                }
            }
        }

        return output
    }

    public func duration(from originName: String, to destinationNames: [String]) -> [String: Double]? {
        guard let origin = origins[originName] else { return nil }

        var output: [String: Double] = [:]
        for name in destinationNames {
            if let destination = destinations[name] {
                if let duration = duration(from: origin, to: destination) {
                    output.updateValue(duration, forKey: name)
                }
            }
        }

        return output
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

    public struct Distance {
        public var origin: Place
        public var destination: Place
        public var distance: Double
    }

    public struct Duration {
        public var origin: Place
        public var destination: Place
        public var duration: Double
    }
}

// MARK: - Utilities
extension DistanceMatrix: Decodable {

    private struct DistanceHelper: Decodable {
        var origin: String
        var destination: String
        var distance: Double

        enum CodingKeys: String, CodingKey {
            case origin = "origin_index"
            case destination = "destination_index"
            case distance
        }
    }

    private struct DurationHelper: Decodable {
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
        let originsHelper = try container.decode([String: Place].self, forKey: .origins)
        let destinationHelper = try container.decode([String: Place].self, forKey: .destinations)
        let durationHelper = try? container.decode([DurationHelper].self, forKey: .durations)
        let distanceHelper = try? container.decode([DistanceHelper].self, forKey: .distances)

        durations = [DistanceMatrix.Duration]()
        distances = [DistanceMatrix.Distance]()
        origins = [:]
        destinations = [:]

        for (name, origin) in originsHelper {
            origins.updateValue(origin, forKey: name)
        }

        for (name, destination) in destinationHelper {
            destinations.updateValue(destination, forKey: name)
        }
        
        if let durationHelper = durationHelper {
            for helper in durationHelper {
                if let origin = originsHelper[helper.origin], let destination = destinationHelper[helper.destination] {
                    let newDuration = DistanceMatrix.Duration(origin: origin,
                                                  destination: destination,
                                                  duration: helper.duration)
                    durations.append(newDuration)
                }
            }
        }

        if let distanceHelper = distanceHelper {
            for helper in distanceHelper {
                if let origin = originsHelper[helper.origin], let destination = destinationHelper[helper.destination] {
                    let newDistance = DistanceMatrix.Distance(origin: origin,
                                                  destination: destination,
                                                  distance: helper.distance)
                    distances.append(newDistance)
                }
            }
        }
    }
}

// MARK: - Errors
public enum DistanceMatrixError: Error, LocalizedError {
    case duplicateCoordinateName([String])

    case invalidCharacterInName(String)

    case emptyName

    case noOriginsSpecified

    case noDestinationsSpecified

    var localizedDescription: String {
        switch self {
        case .duplicateCoordinateName(let name):
            return "Duplicate name found. \"\(name)\" is/are duplicate."
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
