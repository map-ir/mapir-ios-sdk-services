//
//  MPSStep.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public struct MPSStep {

    /// The distance of travel from the maneuver to the subsequent step, in `Double` meters.
    public var distance: Double

    /// The estimated travel time, in `Double` number of seconds.
    public var duration: Double

    /// A list of Intersection objects that are passed along the segment, the very first belonging to the `MPSManeuver`
    public var intersections: [MPSIntersection]

    /// The unsimplified geometry of the route segment, depending on the geometries parameter.
    public var geometry: String

    /// The name of the way along which travel proceeds.
    public var name: String

    /// A reference number or code for the way. Optionally included, if ref data is available for the given way.
    public var ref: String?

    /// A string signifying the mode of transportation.
    public var mode: String

    /// A `MPSManeuver` object representing the maneuver.
    public var maneuver: MPSManeuver

    /// The calculated weight of the step.
    public var wieght: Double

    /// The legal driving side at the location for this step. Either `left` or `right`.
    public var drivingSide: MPSDrivingSide

}

public enum MPSDrivingSide: String {

    /// specifies that the legal driving side at the location `right`.
    case right

    /// specifies that the legal driving side at the location `left`.
    case left
}
