//
//  MPSWaypoint.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public struct MPSWaypoint {
    /// Unique internal identifier of the segment
    var hint: String

    /// Name of the street the coordinate snapped to.
    public var name: String

    /// `MPSLocationCoordinate` of the snapped coordinate.
    public var coordinates: MPSLocationCoordinate
}
