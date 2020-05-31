//
//  Lane+Indication.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 14/11/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

extension Lane {

    /// Each of these options specifies a maneuver direction for which a given lane can
    /// be used.
    ///
    /// A Lane object has zero or more indications that usually correspond to arrows on
    /// signs or pavement markings. If no options are specified, it may be the case that
    /// no maneuvers are indicated on signage or pavement markings for the lane.
    public struct Indication: OptionSet {

        public var rawValue: Int

        public init(rawValue: Int) { self.rawValue = rawValue }

        /// a normal turn to the right
        public static let right = Indication(rawValue: 1 << 1)

        /// a normal turn to the left
        public static let left = Indication(rawValue: 1 << 2)

        /// a slight turn to the right
        public static let slightRight = Indication(rawValue: 1 << 3)

        /// a slight turn to the left
        public static let slightLeft = Indication(rawValue: 1 << 4)

        /// a sharp right turn
        public static let sharpRight = Indication(rawValue: 1 << 5)

        /// a sharp turn to the left
        public static let sharpLeft = Indication(rawValue: 1 << 6)

        /// indicates reversal of direction
        public static let uTurn = Indication(rawValue: 1 << 7)

        /// no relevant change in direction
        public static let straight = Indication(rawValue: 1 << 8)
    }
}

extension Lane.Indication {

    init?(descriptions: [String]) {
        var indications: Lane.Indication = []
        for d in descriptions {
            switch d {
            case "sharp right":
                indications.insert(.sharpRight)
            case "sharp left":
                indications.insert(.sharpLeft)
            case "right":
                indications.insert(.right)
            case "left":
                indications.insert(.left)
            case "slight right":
                indications.insert(.slightRight)
            case "slight left":
                indications.insert(.slightLeft)
            case "straight":
                indications.insert(.straight)
            case "uturn", "uTurn":
                indications.insert(.uTurn)
            case "none":
                break
            default:
                return nil
            }
        }

        self.init(rawValue: indications.rawValue)
    }

    public var description: String {
        if isEmpty { return "none" }

        var descriptions: [String] = []
        if contains(.sharpRight) { descriptions.append("sharp right") }
        if contains(.sharpLeft) { descriptions.append("sharp left") }
        if contains(.right) { descriptions.append("right") }
        if contains(.left) { descriptions.append("left") }
        if contains(.slightRight) { descriptions.append("slight right") }
        if contains(.slightLeft) { descriptions.append("slight left") }
        if contains(.straight) { descriptions.append("straight") }
        if contains(.uTurn) { descriptions.append("uturn") }

        return descriptions.joined(separator: ", ")
    }
}
