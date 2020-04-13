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
    @objc(StepManeuverType)
    public enum ManeuverType: Int {

        /// The step does not have a particular maneuver type associated with it.
        ///
        ///This maneuver type is used as a workaround for bridging to Objective-C which
        ///does not support nullable enumeration-typed values.
        case none = 0

        /// a basic turn into direction of the `modifier`
        case turn

        /// no turn is taken/possible, but the road name changes. The road can take a turn itself,
        /// following `modifier`.
        case newName

        /// indicates the departure of the leg
        case depart

        /// indicates the destination of the leg
        case arrive

        /// merge onto a street (e.g. getting on the highway from a ramp,
        /// the `modifier` specifies the direction of the merge )
        case merge

        /// take a ramp to enter a highway (direction given by `modifier` )
        case onRamp

        /// take a ramp to exit a highway (direction given by `modifier`)
        case offRamp

        /// take the left/right side at a fork depending on `modifier`
        case fork

        /// road ends in a T intersection turn in direction of `modifier`
        case endOfRoad

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
        case roundaboutTurn

        /// not an actual turn but a change in the driving conditions. For example the travel mode.
        /// If the road takes a turn itself, the  modifier describes the direction
        case notification

        /// Describes a maneuver exiting a roundabout (usually preceded by a `roundabout` instruction)
        case exitRoundabout

        /// Describes the maneuver exiting a rotary (large named `roundabout`)
        case exitRotary
    }
}

extension StepManeuver.ManeuverType: CustomStringConvertible {

    public var description: String {
        switch self {
        case .none:
            return "none"
        case .turn:
            return "turn"
        case .newName:
            return "new name"
        case .depart:
            return "depart"
        case .arrive:
            return "arrive"
        case .merge:
            return "merge"
        case .onRamp:
            return "on ramp"
        case .offRamp:
            return "off ramp"
        case .fork:
            return "fork"
        case .endOfRoad:
            return "end of road"
        case .continue:
            return "continue"
        case .roundabout:
            return "roundabout"
        case .rotary:
            return "rotary"
        case .roundaboutTurn:
            return "roundabout turn"
        case .notification:
            return "notification"
        case .exitRoundabout:
            return "exit roundabout"
        case .exitRotary:
            return "exit rotary"
        }
    }

    public init(description: String) {
        switch description {
        case "turn":
            self = .turn
        case "new name":
            self = .newName
        case "depart":
            self = .depart
        case "arrive":
            self = .arrive
        case "merge":
            self = .merge
        case "or ramp":
            self = .onRamp
        case "off ramp":
            self = .offRamp
        case "fork":
            self = .fork
        case "end of road":
            self = .endOfRoad
        case "continue":
            self = .continue
        case "roundabout":
            self = .roundabout
        case "rotary":
            self = .rotary
        case "roundabout turn":
            self = .roundaboutTurn
        case "notification":
            self = .notification
        case "exit roundabout":
            self = .exitRoundabout
        case "exit rotary":
            self = .exitRotary
        default:
            self = .none
        }
    }
}
