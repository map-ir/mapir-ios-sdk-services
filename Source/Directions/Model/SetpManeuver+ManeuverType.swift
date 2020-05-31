//
//  StepManeuver+ManeuverType.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 15/11/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

extension StepManeuver {

    /// Specifies different types of a `StepManeuver`
    public enum ManeuverType: String {

        /// a basic turn into direction of the `modifier`
        case turn

        /// no turn is taken/possible, but the road name changes. The road can take a turn itself,
        /// following `modifier`.
        case newName = "new name"

        /// indicates the departure of the leg
        case depart

        /// indicates the destination of the leg
        case arrive

        /// merge onto a street (e.g. getting on the highway from a ramp,
        /// the `modifier` specifies the direction of the merge )
        case merge

        /// take a ramp to enter a highway (direction given by `modifier` )
        case onRamp = "on ramp"

        /// take a ramp to exit a highway (direction given by `modifier`)
        case offRamp = "off ramp"

        /// take the left/right side at a fork depending on `modifier`
        case fork

        /// road ends in a T intersection turn in direction of `modifier`
        case endOfRoad = "end of road"

        /// Turn in direction of `modifier` to stay on the same road
        case `continue`

        /// traverse `roundabout`, has additional field `exit` with NR if the `roundabout` is left.
        /// the `modifier` specifies the direction of entering the roundabout
        case roundabout

        /// a traffic circle. While very similar to a larger version of a roundabout,
        /// it does not necessarily follow roundabout rules for right of way.
        /// It can offer `rotary_name/rotary_pronunciation` in addition to the `exit` parameter.
        case rotary

        /// Describes a turn at a small roundabout that should be treated as normal turn.
        /// The modifier indicates the turn direction.
        case roundaboutTurn = "roundabout turn"

        /// not an actual turn but a change in the driving conditions. For example the travel mode.
        /// If the road takes a turn itself, the  modifier describes the direction
        case notification

        /// Describes a maneuver exiting a roundabout (usually preceded by a `roundabout` instruction)
        case exitRoundabout = "exit roundabout"

        /// Describes the maneuver exiting a rotary (large named `roundabout`)
        case exitRotary = "exit rotary"
    }
}

extension StepManeuver.ManeuverType: CustomStringConvertible {
    public var description: String { rawValue }
}
