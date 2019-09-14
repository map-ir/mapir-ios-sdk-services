//
//  MPSDistanceMatrix.swift
//  MapirServices
//
//  Created by Alireza Asadi on 5/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public struct DistanceMatrix {

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

    public var distances: [DistanceMatrix.Distance]
    public var durations: [DistanceMatrix.Duration]
    public var origins: [Place]
    public var destinations: [Place]

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
        origins = [Place]()
        destinations = [Place]()

        for (_, origin) in originsHelper {
            origins.append(origin)
        }

        for (_, destination) in destinationHelper {
            destinations.append(destination)
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
