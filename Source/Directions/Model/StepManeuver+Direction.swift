//
//  StepManeuver+Direction.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 15/11/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

extension StepManeuver {

    /// Shows different directions that a maneuver can take.
    public enum Direction: String {

        /// a normal turn to the right.
        case right

        /// a normal turn to the left.
        case left

        /// a slight turn to the right.
        case slightRight

        /// a slight turn to the left.
        case slightLeft

        /// a sharp right turn.
        case sharpRight

        /// a sharp turn to the left.
        case sharpLeft

        /// indicates reversal of direction.
        case uTurn

        /// no relevant change in direction.
        case straight
    }
}

extension StepManeuver.Direction: CustomStringConvertible {
    public var description: String { rawValue }
}
