//
//  DistanceMatrix+Configuration.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 9/10/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

// MARK: Distance matrix configurations

extension DistanceMatrix {

    @objc(DistanceMatrixConfiguration)
    public final class Configuration: NSObject {

        /// Default configuration.
        @objc(defaultConfiguration)
        public static var `default`: Configuration { Configuration() }

        /// Specifies that the result will include distances.
        ///
        /// - note: `includeDistances` and `includeDurations` can not be `false` at the same
        /// time.
        @objc public var includeDistances: Bool = true {
            didSet {
                updateProperties(lastUpdated: \.includeDistances)
            }
        }

        /// Specifies that the result will include durations.
        ///
        /// - note: `includeDistances` and `includeDurations` can not be `false` at the same
        /// time.
        @objc public var includeDurations: Bool = true {
            didSet {
                updateProperties(lastUpdated: \.includeDurations)
            }
        }

        /// Specifies that the result needs to be sorted or not.
        @objc public var sortResults: Bool = false
    }
}

// MARK: Validating properties

extension DistanceMatrix.Configuration {
    private func updateProperties(lastUpdated: ReferenceWritableKeyPath<DistanceMatrix.Configuration, Bool>) {
        if !includeDistances && !includeDurations {
            self[keyPath: lastUpdated] = true
        }
    }
}
