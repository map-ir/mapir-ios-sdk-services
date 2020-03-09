//
//  Lane+Indication.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 14/11/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

extension Lane {

    @objc(LaneIndication)
    public final class Indication: NSObject, OptionSet {

        @objc public var rawValue: Int

        @objc public init(rawValue: Int) { self.rawValue = rawValue }

        /// a normal turn to the right
        @objc static let right = Indication(rawValue: 1 << 1)

        /// a normal turn to the left
        @objc static let left = Indication(rawValue: 1 << 2)

        /// a slight turn to the right
        @objc static let slightRight = Indication(rawValue: 1 << 3)

        /// a slight turn to the left
        @objc static let slightLeft = Indication(rawValue: 1 << 4)

        /// a sharp right turn
        @objc static let sharpRight = Indication(rawValue: 1 << 5)

        /// a sharp turn to the left
        @objc static let sharpLeft = Indication(rawValue: 1 << 6)

        /// indicates reversal of direction
        @objc static let uturn = Indication(rawValue: 1 << 7)

        /// no relevant change in direction
        @objc static let straight = Indication(rawValue: 1 << 8)
    }

}

extension Lane.Indication {

    convenience init?(descriptions: [String]) {
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
            case "uturn":
                indications.insert(.uturn)
            case "none":
                break
            default:
                return nil
            }
        }

        self.init(rawValue: indications.rawValue)
    }

    @objc override public var description: String {
        if isEmpty { return "none" }

        var descriptions: [String] = []
        if contains(.sharpRight) { descriptions.append("sharp right") }
        if contains(.sharpLeft) { descriptions.append("sharp left") }
        if contains(.right) { descriptions.append("right") }
        if contains(.left) { descriptions.append("left") }
        if contains(.slightRight) { descriptions.append("slight right") }
        if contains(.slightLeft) { descriptions.append("slight left") }
        if contains(.straight) { descriptions.append("straight") }
        if contains(.uturn) { descriptions.append("uturn") }

        return descriptions.joined(separator: ", ")
    }
}
