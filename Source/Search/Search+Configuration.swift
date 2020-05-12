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
    @objc(SHSearchConfiguration)
    public class Configuration: NSObject, NSCopying {

        /// Default configuration with no categories, filter and center coordinate provided.
        @objc(emptyConfiguration)
        public static var empty: Configuration { Configuration() }

        /// Categories of search
        public var categories: Search.Categories = []

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

        /// Creates a copy of the receiver.
        @objc public func copy(with zone: NSZone? = nil) -> Any {
            return Configuration(
                categories: categories,
                filter: filter,
                center: center
            )
        }
    }
}

// MARK: Manipulate categories in Objective-C

extension Search.Configuration {

    /// Returns the string values of categories.
    ///
    /// - note: This method is intended to be used in Objective-C only. In Swift use
    /// `categories` property.
    ///
    /// - Returns: Categories as converted to `String`.
    @objc public func getCategories() -> [String] {
        categories.stringValues
    }

    /// Adds a category to the search configuration using its string description.
    ///
    /// - note: This method is intended to be used in Objective-C only. In Swift use
    /// `categories` property.
    ///
    /// - Parameter string: The description string of the category.
    ///
    /// - Returns: Correct form of the string format of the recently added category
    ///   object. If the description does not specify any of the `Categories` options,
    ///   returns `nil`.
    @discardableResult
    @objc public func addCategory(describing string: String) -> String? {
        if let category = Search.Categories(description: string) {
            categories.insert(category)
            return category.stringValues.first
        }
        return nil
    }

    /// Removes a category from the search configuration using its string description.
    ///
    /// - note: This method is intended to be used in Objective-C only. In Swift use
    /// `categories` property.
    ///
    /// - Parameter string: The description string of the category.
    ///
    /// - Returns: Correct form of the string format of the recently added category
    ///   object. If the description does not specify any of the `Categories` options, or
    ///   the specified category does not exist in the `categories`, returns `nil`.
    @discardableResult
    @objc public func removeCategory(describing string: String) -> String? {
        if let category = Search.Categories(description: string), categories.contains(category) {
            categories.remove(category)
            return category.stringValues.first
        }
        return nil
    }
}

// MARK: Manipulate filter in Objective-C

extension Search.Configuration {

    /// Adds a filter to the configuration using its name and value.
    ///
    /// - note: This method is intended to be used in Objective-C only. In Swift use
    /// `filter` property.
    ///
    /// - Parameters:
    ///   - name: name of the filter. can be either `distance`, `city`, `county`,
    ///     `province`, `neighborhood` or `district`.
    ///
    ///   - value: name, amount or number of the value. for example, `distance` accepts a
    ///     `Double` value converted to `String`.
    ///
    /// - returns: `true` for success.
    @discardableResult @objc(setFilterWithName:value:)
    public func setFilter(name: String, value: String) -> Bool {
        var filter: Search.Filter?

        switch name.lowercased() {
        case "city":
            filter = .city(name: value)
        case "country":
            filter = .county(name: value)
        case "distance":
            if let distance = Double(value) {
                filter = .distance(meter: distance)
            }
        case "province":
            filter = .province(name: value)
        case "neighborhood":
            filter = .neighborhood(name: value)
        case "district":
            if let number = Int(value) {
                filter = .district(number: number)
            }
        default:
            filter = nil
        }

        if let filter = filter {
            self.filter = filter
            return true
        } else {
            return false
        }
    }

    /// Returns the current `filter`. It will be empty if no filter is available.
    ///
    /// - returns: A single key-value pair dictionary which represents the filter and
    /// its associated value, when filter is set. Empty dictionary otherwise.
    @objc public func getFilter() -> [String: String] {
        if let filter = filter {
            return [filter.description: filter.stringValue]
        } else {
            return [:]
        }
    }

    /// removes the current active filter from the configuration.
    @objc public func removeFilter() {
        filter = nil
    }
}

// MARK: Adding and removing Center Coordinate in Obj-C

extension Search.Configuration {

    /// Sets the center coordinate for the configuration.
    ///
    /// - Parameters:
    ///   - latitude: latitude value of the coordinate.
    ///   - longitude: longitude value of the coordinate.
    ///
    /// - note: This method is intended to be used in Objective-C only. In Swift use
    /// `center` property.
    @objc(setCenterLatitude:longitude:)
    public func setCenter(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Sets the center coordinate for the configuration using a `CLLocation` object.
    ///
    /// - Parameter location: Input `CLLocation` object to use to set `center`.
    ///
    /// - note: This method is intended to be used in Objective-C only. In Swift use
    /// `center` property.
    @objc(setCenterUsingLocation:)
    public func setCenter(using location: CLLocation) {
        center = location.coordinate
    }

    /// Returns `center` property of the configuration.
    ///
    /// - note: This method is intended to be used in Objective-C only. In Swift use
    /// `center` property.
    @objc public func getCenter() -> CLLocationCoordinate2D {
        return center ?? kCLLocationCoordinate2DInvalid
    }

    /// Removes the current value in `center` property.
    ///
    /// - note: This method is intended to be used in Objective-C only. In Swift use
    /// `center` property.
    @objc public func removeCenter() {
        center = nil
    }
}
