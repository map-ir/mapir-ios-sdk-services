//
//  DistanceMatrix+Result.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 9/10/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

extension DistanceMatrix {

    /// Indicates result of a distance matrix request.
    public struct Result {

        /// A 2D table containing distance values from every origin to every destination
        public let distances: Table<String, Double>

        /// A 2D table containing duration values from every origin to every destination
        public let durations: Table<String, Double>

        /// Connects name of input coordinate to its `Placemark` object. contains origins placemarks.
        public let origins: [String: Placemark]

        /// Connects name of input coordinate to its `Placemark` object. contains destination placemarks.
        public let destinations: [String: Placemark]

        public var configuration: Configuration?

        init(
            distances: Table<String, Double>,
            durations: Table<String, Double>,
            origins: [String: Placemark],
            destinations: [String: Placemark]
        ) {
            self.distances = distances
            self.durations = durations
            self.origins = origins
            self.destinations = destinations
        }
    }
}

// MARK: Distance convenience methods

extension DistanceMatrix.Result {

    /// Finds distance between an origin placemark to a destination placemark, using placemark objects.
    ///
    /// If specified placemarks aren't available in origins or destniations, result will be `nil`.
    public func distance(from origin: Placemark, to destination: Placemark) -> Double? {
        guard let (origin, _) = origins.first(where: { $0.value == origin }) else { return nil }
        guard let (destination, _) = destinations.first(where: { $0.value == destination }) else { return nil }
        return distance(from: origin, to: destination)
    }

    /// Finds distance between an origin placemark to a destination placemark, using their labels.
    ///
    /// If specified labels aren't available in origins or destniations, result will be `nil`.
    public func distance(from origin: String, to destination: String) -> Double? {
        return distances[origin, destination]
    }

    /// Finds distance between an origin placemark to all of destination placemarks, using its label.
    ///
    /// If specified label isn't available in origins, result will be `nil`.
    public func distances(from origin: String) -> [String: Double]? {
        return distances.valuesOf(row: origin)
    }

    /// Finds distance between all origin placemarks to a destination placemark, using its label.
    ///
    /// If specified label isn't available in destinations, result will be `nil`.
    public func distances(to destination: String) -> [String: Double]? {
        return distances.valuesOf(column: destination)
    }

    /// Finds distance between some origin placemarks to a destination placemark, using their label.
    ///
    /// If specified labels aren't available in origins or destinations, result will be `nil`.
    public func distances(from origins: Set<String>, to destination: String) -> [String: Double]? {
        return distances.valuesOf(column: destination)?.filter { origins.contains($0.key) }
    }

    /// Finds distance between an origin placemark to some destination placemarks, using their label.
    ///
    /// If specified labels aren't available in origins or destinations, result will be `nil`.
    public func distances(from origin: String, to destinations: Set<String>) -> [String: Double]? {
        return distances.valuesOf(row: origin)?.filter { destinations.contains($0.key) }
    }

    /// Finds distance between some origin placemarks to some destination placemarks, using their label.
    ///
    /// If specified labels aren't available in origins or destinations, result will be `nil`.
    public func distances(from origins: Set<String>, to destinations: Set<String>) -> Table<String, Double> {
        let table = Table<String, Double>()
        for o in origins {
            for d in destinations {
                table[o, d] = distances[o, d]
            }
        }
        return table
    }
}

// MARK: Duration convenience methods

extension DistanceMatrix.Result {

    /// Finds duration between an origin placemark to a destination placemark, using placemark objects.
    ///
    /// If specified placemarks aren't available in origins or destniations, result will be `nil`.
    public func duration(from origin: Placemark, to destination: Placemark) -> Double? {
        guard let (origin, _) = origins.first(where: { $0.value == origin }) else { return nil }
        guard let (destination, _) = destinations.first(where: { $0.value == destination }) else { return nil }
        return duration(from: origin, to: destination)
    }

    /// Finds duration between an origin placemark to a destination placemark, using their labels.
    ///
    /// If specified labels aren't available in origins or destniations, result will be `nil`.
    public func duration(from origin: String, to destination: String) -> Double? {
        return durations[origin, destination]
    }

    /// Finds duration between an origin placemark to all of destination placemarks, using its label.
    ///
    /// If specified label isn't available in origins, result will be `nil`.
    public func durations(from origin: String) -> [String: Double]? {
        return durations.valuesOf(row: origin)
    }

    /// Finds duration between all origin placemarks to a destination placemark, using its label.
    ///
    /// If specified label isn't available in destinations, result will be `nil`.
    public func durations(to destination: String) -> [String: Double]? {
        return durations.valuesOf(column: destination)
    }

    /// Finds duration between some origin placemarks to a destination placemark, using their label.
    ///
    /// If specified labels aren't available in origins or destinations, result will be `nil`.
    public func durations(from origins: Set<String>, to destination: String) -> [String: Double]? {
        return durations.valuesOf(column: destination)?.filter { origins.contains($0.key) }
    }

    /// Finds duration between an origin placemark to some destination placemarks, using their label.
    ///
    /// If specified labels aren't available in origins or destinations, result will be `nil`.
    public func durations(from origin: String, to destinations: Set<String>) -> [String: Double]? {
        return durations.valuesOf(row: origin)?.filter { destinations.contains($0.key) }
    }

    /// Finds duration between some origin placemarks to some destination placemarks, using their label.
    ///
    /// If specified labels aren't available in origins or destinations, result will be `nil`.
    public func durations(from origins: Set<String>, to destinations: Set<String>) -> Table<String, Double> {
        let table = Table<String, Double>()
        for o in origins {
            for d in destinations {
                table[o, d] = durations[o, d]
            }
        }
        return table
    }
}

// MARK: Decoding result of distance matrix

extension DistanceMatrix.Result {

    /// Create a `DistanceMatrix.Result` from its network response.
    init(from responseScheme: ResponseScheme) {
        var resultOrigins: [String: Placemark] = [:]
        if let origins = responseScheme.origins {
            for o in origins {
                resultOrigins[o.key] = Placemark(from: o.value)
            }
        }
        var resultDestinations: [String: Placemark] = [:]
        if let destinations = responseScheme.destinations {
            for d in destinations {
                resultDestinations[d.key] = Placemark(from: d.value)
            }
        }

        let resultDistances = Table<String, Double>()
        if let distances = responseScheme.distance {
            for d in distances {
                resultDistances[d.originIndex, d.destinationIndex] = d.distance
            }
        }
        let resultDurations = Table<String, Double>()
        if let durations = responseScheme.duration {
            for d in durations {
                resultDurations[d.originIndex, d.destinationIndex] = d.duration
            }
        }

        self.init(
            distances: resultDistances,
            durations: resultDurations,
            origins: resultOrigins,
            destinations: resultDestinations
        )
    }

    struct ResponseScheme: Decodable {
        var distance: [DistanceScheme]?
        var duration: [DurationScheme]?
        var origins: [String: PlaceScheme]?
        var destinations: [String: PlaceScheme]?

        struct PlaceScheme: Decodable {
            var name: String?
            var provinceName: String?
            var countyName: String?
            var districtName: String?
            var ruralDistrictName: String?
            var suburbTitle: String?
            var neighbourhoodTitle: String?
        }

        struct DistanceScheme: Decodable {
            var originIndex: String
            var destinationIndex: String
            var distance: Double?
        }

        struct DurationScheme: Decodable {
            var originIndex: String
            var destinationIndex: String
            var duration: Double?
        }
    }
}
