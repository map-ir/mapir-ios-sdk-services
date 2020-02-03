//
//  DistanceMatrix+Options.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 9/10/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

// MARK: Distance matrix options

extension DistanceMatrix {

    /// Distance matrix calculation options.
    @objc(DistanceMatrixOptions)
    public final class Options: NSObject, OptionSet {

        @objc public var rawValue: Int

        /// Initilizes an `Options` object with rawValue. Do not use directly.
        @objc public init(rawValue: Int) { self.rawValue = rawValue }

        /// Calculate distances.
        @objc public static let distance = DistanceMatrix.Options(rawValue: 1 << 0)

        /// Calculate durations.
        @objc public static let duration = DistanceMatrix.Options(rawValue: 1 << 1)

        /// Sort results by distance and duration.
        @objc public static let sorted = DistanceMatrix.Options(rawValue: 1 << 2)
    }
}
