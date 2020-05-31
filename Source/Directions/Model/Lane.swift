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

    /// a indication (e.g. marking on the road) specifying the turn lane.
    /// - A road can have multiple indications (e.g. an arrow pointing straight and left).
    ///     The indications are given in an array, each containing one of the following types.
    public let indications: Lane.Indication

    /// a boolean flag indicating whether the lane is a valid choice in the current maneuver.
    public let isValid: Bool
}

extension Lane {

    init(from response: ResponseScheme) {
        self.init(indications: response.indications, isValid: response.valid)
    }

    struct ResponseScheme: Decodable {
        var indications: Lane.Indication
        var valid: Bool

        private enum CodingKeys: String, CodingKey {
            case indications
            case valid
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            valid = try container.decode(Bool.self, forKey: .valid)
            indications = []
            if let indicationsArray = try container.decodeIfPresent([String].self, forKey: .indications) {
                indications = Indication(descriptions: indicationsArray) ?? []
            }
        }
    }
}
