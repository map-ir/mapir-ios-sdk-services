//
//  Search+Configuration.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 7/10/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

extension Search {
    @objc(SearchConfiguration)
    public class Configuration: NSObject {

        /// Default configuration with no categories, filter and center coordinate provided.
        public static let empty: Configuration = Configuration()

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

// MARK: Adding and removing filter in Obj-C

extension Search.Configuration {
    @objc(setFilterWithName:value:)
    public func setFilter(name: String, value: String) {
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
        case "neghborhood":
            filter = .neighborhood(name: value)
        case "district":
            if let number = Int(value) {
                filter = .district(number: number)
            }
        default:
            filter = nil
        }

        self.filter = filter
    }

    @objc(removeFilter)
    public func removeFilter() {
        filter = nil
    }
}

// MARK: Adding and removing Center Coordinate in Obj-C

extension Search.Configuration {
    @objc(setCenterLatitude:longitude:)
    public func setCenter(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    @objc(setCenterUsingLocation:)
    public func setCenter(using location: CLLocation) {
        center = location.coordinate
    }

    @objc(removeCenter)
    public func removeCenter() {
        center = nil
    }
}
