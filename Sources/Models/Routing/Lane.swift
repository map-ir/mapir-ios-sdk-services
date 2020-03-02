//
//  MPSLane.swift
//  MapirServices
//
//  Created by Alireza Asadi on 11/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

/// A Lane represents a turn lane at the corresponding turn location.
@objc(Lane)
public final class Lane: NSObject {

    /// a indication (e.g. marking on the road) specifying the turn lane.
    /// - A road can have multiple indications (e.g. an arrow pointing straight and left).
    ///     The indications are given in an array, each containing one of the following types.
    @objc public var indications: Lane.Indication

    /// a boolean flag indicating whether the lane is a valid choice in the current maneuver.
    @objc public var isValid: Bool

    init(indications: Lane.Indication, isValid: Bool) {
        self.indications = indications
        self.isValid = isValid
    }
}

extension Lane {

    convenience init(from response: ResponseScheme) {
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
