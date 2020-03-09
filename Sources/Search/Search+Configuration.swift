//
//  Search+Configuration.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 7/10/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

extension Search {

    /// Holds configurations of a `Search` object.
    ///
    /// `Search` uses a `Configuration` object for each search request.
    @objc(SearchConfiguration)
    public class Configuration: NSObject {

        /// Default configuration with no categories, filter and center coordinate provided.
        @objc(emptyConfiguration)
        public static var empty: Configuration { Configuration() }

        /// Categories of search
        @objc var categories: Search.Categories?

        /// It is a condition to filter the results based on it.
        var filter: Search.Filter?

        /// Center coordinate for search.
        ///
        /// providing a center coordiante will change search type to nearby search.
        /// otherwise results will be global.
        var center: CLLocationCoordinate2D?
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

    /// Returns `center` propery of the configuration.
    ///
    /// - note: This method is intended to be used in Objective-C only. In Swift use
    /// `center` property.
    @objc public func getCenter() -> CLLocationCoordinate2D {
        return center ?? kCLLocationCoordinate2DInvalid
    }

    /// Removes the current value in center `propery`.
    ///
    /// - note: This method is intended to be used in Objective-C only. In Swift use
    /// `center` property.
    @objc public func removeCenter() {
        center = nil
    }
}
