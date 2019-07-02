//
//  MPSIntersection.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public struct MPSIntersection {

    /// A `MPSLocationCoordinate` describing the location of the turn.
    public var location: MPSLocationCoordinate

    /// A list of `bearing` values (e.g. [0,90,180,270]) that are available at the intersection. The `bearings` describe all available roads at the intersection.
    public var bearings: [Int]

    /// An array of strings signifying the classes of the road exiting the intersection.
    public var classes: [String]

    /// A list of entry flags, corresponding in a 1:1 relationship to the bearings.
    /// - A value of true indicates that the respective road could be entered on a valid route. false indicates that the turn onto the respective road would violate a restriction.
    public var entry: [Bool]

    /// index into the bearings/entry array.
    /// - Used to extract the bearing just after the turn. Namely, The clockwise angle from true north to the direction of travel immediately after the maneuver/passing the intersection. The value is not supplied for arrive maneuvers.
    public var out: Int

    /// index into bearings/entry array.
    /// - Used to calculate the bearing just before the turn. Namely, the clockwise angle from true north to the direction of travel immediately before the maneuver/passing the intersection. Bearings are given relative to the intersection. To get the bearing in the direction of driving, the bearing has to be rotated by a value of 180. The value is not supplied for depart maneuvers.
    public var `in`: Int

    /// Array of Lane objects that denote the available turn lanes at the intersection.
    /// - If no lane information is available for an intersection, the lanes property will not be present.
    public var lanes: [MPSLane]?
}
