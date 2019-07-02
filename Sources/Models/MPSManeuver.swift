//
//  MPSManeuver.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public struct MPSManeuver {
    /// A `MPSLocationCoordinate`  describing the location of the turn.
    public var location: MPSLocationCoordinate

    /// The clockwise angle from true north to the direction of travel immediately after the maneuver. Range 0-359.
    public var bearingAfter: Int

    /// The clockwise angle from true north to the direction of travel immediately before the maneuver. Range 0-359.
    public var bearingBefore: Int

    /// An enum indicating the type of maneuver.
    public var type: MPSManeuverType

    /// An optional `String` indicating the direction change of the maneuver.
    public var modifier: MPSManeuverModifier?

    /// An optional `Integer` indicating number of the exit to take. The field exists for the following `type` field: `roundabout / rotary` and `else`
    public var exit: Int
}

public enum MPSManeuverType: String {
    /// a basic turn into direction of the `modifier`
    case turn

    /// no turn is taken/possible, but the road name changes. The road can take a turn itself, following  `modifier` .
    case newName = "new name"

    /// indicates the departure of the leg
    case depart

    /// indicates the destination of the leg
    case arrive

    /// merge onto a street (e.g. getting on the highway from a ramp, the `modifier` specifies the direction of the merge )
    case merge

    /// __Deprecated__. Replaced by `on_ramp` and `off_ramp `.
    case ramp

    /// take a ramp to enter a highway (direction given by `modifier` )
    case onRamp = "on ramp"

    /// take a ramp to exit a highway (direction given by `modifier`)
    case offRamp = "off ramp"

    /// take the left/right side at a fork depending on `modifier`
    case fork

    /// road ends in a T intersection turn in direction of `modifier`
    case endOfRoad = "end of road"

    /// __Deprecated__. going straight on a specific lane
    case useLane = "use lane"

    /// Turn in direction of `modifier` to stay on the same road
    case `continue`

    /// traverse `roundabout`, has additional field `exit` with NR if the `roundabout` is left. the `modifier` specifies the direction of entering the roundabout
    case roundabout

    /// a traffic circle. While very similar to a larger version of a roundabout, it does not necessarily follow roundabout rules for right of way. It can offer `rotary_name/rotary_pronunciation` in addition to the `exit` parameter.
    case rotary

    /// Describes a turn at a small roundabout that should be treated as normal turn. The modifier indicates the turn direciton.
    case roundaboutTurn = "roundabout trun"

    /// not an actual turn but a change in the driving conditions. For example the travel mode. If the road takes a turn itself, the  modifier describes the direction
    case notification

    /// Describes a maneuver exiting a roundabout (usually preceeded by a `roundabout` instruction)
    case exitRoundabout = "exit roundabout"

    /// Describes the maneuver exiting a rotary (large named `roundabout`)
    case exitRotary = "exit rotary"
}

public enum MPSManeuverModifier: String {

    /// a normal turn to the right
    case right

    /// a normal turn to the left
    case left

    /// a slight turn to the right
    case slightRight = "slight right"

    /// a slight turn to the left
    case slightLeft = "slight left"

    /// a sharp right turn
    case sharpRight = "sharp right"

    /// a sharp turn to the left
    case sharpLeft = "sharp left"

    /// indicates reversal of direction
    case uturn

    /// no relevant change in direction
    case straight
}
