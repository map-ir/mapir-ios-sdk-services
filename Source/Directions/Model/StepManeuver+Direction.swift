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
    @objc(SHStepManeuverDirection)
    public enum Direction: Int {

        /// The step does not have a particular maneuver direction associated with it.
        ///
        /// This maneuver direction is used as a workaround for bridging to Objective-C
        /// which does not support nullable enumeration-typed values.
        case none

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
    public var description: String {
        switch self {
        case .none:
            return "none"
        case .right:
            return "right"
        case .left:
            return "left"
        case .slightRight:
            return "slight right"
        case .slightLeft:
            return "slight left"
        case .sharpRight:
            return "sharp right"
        case .sharpLeft:
            return "sharp left"
        case .uTurn:
            return "uturn"
        case .straight:
            return "straight"
        }
    }

    init(description: String) {
        switch description {
        case "right":
            self = .right
        case "left":
            self = .left
        case "sharp right":
            self = .sharpRight
        case "sharp left":
            self = .sharpLeft
        case "slight right":
            self = .slightRight
        case "slight left":
            self = .slightLeft
        case "straight":
            self = .straight
        case "uturn":
            self = .uTurn
        default:
            self = .none
        }
    }
}
