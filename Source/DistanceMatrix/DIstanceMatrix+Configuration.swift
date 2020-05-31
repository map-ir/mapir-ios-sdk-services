//
//  DistanceMatrix+Configuration.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 9/10/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

// MARK: Distance matrix configurations

extension DistanceMatrix {

    /// <#DOC for configuration#>
    public struct Configuration {

        /// Default configuration.
        public static var `default`: Configuration { Configuration() }

        /// Specifies that the result will include distances.
        ///
        /// - note: `includeDistances` and `includeDurations` can not be `false` at the same
        /// time.
        public var includeDistances: Bool = true {
            didSet {
                updateProperties(lastUpdated: \.includeDistances)
            }
        }

        /// Specifies that the result will include durations.
        ///
        /// - note: `includeDistances` and `includeDurations` can not be `false` at the same
        /// time.
        public var includeDurations: Bool = true {
            didSet {
                updateProperties(lastUpdated: \.includeDurations)
            }
        }

        /// Specifies that the result needs to be sorted or not.
        public var sortResults: Bool = false
    }
}

// MARK: Validating properties

extension DistanceMatrix.Configuration {
    private mutating func updateProperties(lastUpdated: WritableKeyPath<DistanceMatrix.Configuration, Bool>) {
        if !includeDistances && !includeDurations {
            self[keyPath: lastUpdated] = true
        }
    }
}
