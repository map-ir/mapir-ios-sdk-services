//
//  MPSLeg.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public struct MPSLeg {
    /// Depends on the `steps` parameter.
    public var steps: [MPSStep]

    /// The distance traveled by this route leg, in `Double` meters.
    public var distance: Double

    /// The estimated travel time, in `Double` number of seconds.
    public var duration: Double

    /// Summary of the route taken as string. Depends on the steps parameter
    public var summary: String

    /// /// weight of the travel leg.
    public var weight: Double
}
