//
//  Directions+Configuration.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 11/12/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

extension Directions {

    /// Holds configurations of a `Directions` object.
    ///
    /// `Directions` request is customizable. It uses a `Configuration` object for each
    /// directions request.
    @objc public final class Configuration: NSObject, NSCopying {

        @objc public static var `default`: Configuration { Configuration() }

        /// The type of the transportation used.
        @objc public var vehicleType: Directions.VehicleType = .privateCar

        /// Traffic restricted areas that needed to be excluded from the result.
        ///
        /// - note: At this moment, this property will considered when the `vehicleType` is
        /// `.privateCar`. Otherwise, this will be ignored
        @objc public var areaToExclude: Directions.TrafficRestriction = .none

        /// Search for alternative routes. Passing a number `n` searches for up to `n`
        /// alternative routes.
        ///
        /// Accepts an integer value between 0 to 3. Values greater than 3 or less than 0,
        /// will be changed to 3 and 0 respectively.
        ///
        /// - note: even if alternative routes are requested, a result cannot be guaranteed
        @objc public var numberOfAlternatives: Int = 0 {
            didSet {
                if numberOfAlternatives < 0 {
                    numberOfAlternatives = 0
                } else if numberOfAlternatives > 3 {
                    numberOfAlternatives = 3
                }
            }
        }

        /// Specifies whether the directions result, needs to have `RouteStep` instructions
        /// or not. Steps are the detail of each leg in the route.
        @objc public var includeSteps: Bool = false

        /// Indicates the style of the overview.
        ///
        /// Add overview geometry either `.full`, `.simplified` according to highest zoom
        /// level it could be display on, or `.none` to not have at all.
        @objc public var routeOverviewStyle: Directions.OverviewStyle = .none

        /// Creates a new `Configuration` object for `Directions`.
        init(
            vehicleType: VehicleType = .privateCar,
            areaToExclude: TrafficRestriction = .none,
            numberOfAlternatives: Int = 0,
            includeSteps: Bool = false,
            routeOverviewStyle: OverviewStyle = .none
        ) {
            self.vehicleType = vehicleType
            self.areaToExclude = areaToExclude
            self.numberOfAlternatives = numberOfAlternatives
            self.includeSteps = includeSteps
            self.routeOverviewStyle = routeOverviewStyle
        }

        /// Creates a copy of current `Directions.Configuration` object.
        @objc public func copy(with zone: NSZone? = nil) -> Any {
            return Configuration(
                vehicleType: vehicleType,
                areaToExclude: areaToExclude,
                numberOfAlternatives: numberOfAlternatives,
                includeSteps: includeSteps,
                routeOverviewStyle: routeOverviewStyle
            )
        }
    }
}

extension Directions {

    /// Defines different types of transportation modes available in the directions service.
    @objc(SHDirectionsVehicleType)
    public enum VehicleType: Int {

        /// Indicates that the direction needs to be calculated for driving.
        ///
        /// Private cars are consist of cars that have to obey the normal traffic rules,
        /// such as personal cars and private taxi services.
        case privateCar

        /// Indicates that the direction needs to be calculated for walking.
        ///
        /// walking routes do not have as much restrictions as driving routes have.
        case foot

        /// Indicates that the direction needs to be calculated for bicycle.
        ///
        /// Usually this includes the paths that are safe for bicycling, or are strictly designed
        /// for them.
        case bicycle
    }

    /// Defines different types of traffic restrictions in Iran.
    ///
    /// Usually there are 2 levels of traffic restriction in Iran. The main and smaller
    /// one is called "Traffic Control Area". The larger one which also includes the
    /// traffic control area, is called "Even/Odd Area" or in some cities such as
    /// Tehran, "Air Pollution Control Area".
    ///
    /// - note: At this moment, traffic restrictions only apply to the route when the
    /// `VehicleType` is `.privateCar`.
    @objc(SHDirectionsTrafficRestriction)
    public enum TrafficRestriction: Int {

        /// No traffic restrictions.
        case none

        /// Restricts routing to traffic control area only.
        case trafficControlArea

        /// Restricts routing to air pollution control area. This also includes the area
        /// that `.trafficControlArea` contains.
        case airPollutionControlArea

    }

    /// Use to add overview geometry either full, simplified according to highest zoom
    /// level it could be display on, or not at all.
    @objc(SHDirectionsOverviewStyle)
    public enum OverviewStyle: Int {

        /// Result object will not have any overview geometry.
        case none

        /// Result object will have simplified geometry. Best for showing on map at high
        /// zoom levels.
        case simplified

        /// Result object will complete overview geometry.
        case full
    }
}
