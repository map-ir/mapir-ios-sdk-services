//
//  Search+Configuration.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 7/10/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation
import CoreLocation

extension Search {

    /// Holds configurations of a `Search` object.
    ///
    /// `Search` uses a `Configuration` object for each search request.
    public struct Configuration {

        /// Default configuration with no categories, filter and center coordinate provided.
        public static var empty: Configuration { Configuration() }

        /// Categories of search
        public var categories: Search.Categories

        /// It is a condition to filter the results based on it.
        public var filter: Search.Filter?

        /// Center coordinate for search.
        ///
        /// providing a center coordinate will change search type to nearby search.
        /// otherwise results will be global.
        public var center: CLLocationCoordinate2D?

        /// Creates a new `Configuration` object.
        public init(
            categories: Search.Categories = [],
            filter: Search.Filter? = nil,
            center: CLLocationCoordinate2D? = nil
        ) {
            self.categories = categories
            self.filter = filter
            self.center = center
        }
    }
}
