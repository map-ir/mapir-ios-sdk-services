//
//  MPSLane.swift
//  MapirServices
//
//  Created by Alireza Asadi on 11/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

/// A Lane represents a turn lane at the corresponding turn location.
public struct Lane {

    public enum Indication: String, Codable {

        /// No dedicated indication is shown.
        case none

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

    /// a indication (e.g. marking on the road) specifying the turn lane.
    /// - A road can have multiple indications (e.g. an arrow pointing straight and left).
    ///     The indications are given in an array, each containing one of the following types.
    public var indications: [Lane.Indication]

    /// a boolean flag indicating whether the lane is a valid choice in the current maneuver.
    public var valid: Bool
}

extension Lane: Decodable {

    enum CodingKeys: String, CodingKey {
        case indications
        case valid
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        valid = try container.decode(Bool.self, forKey: .valid)
        indications = try container.decode([Lane.Indication].self, forKey: .indications)
    }
}
