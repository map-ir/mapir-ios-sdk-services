//
//  DrivingSide.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 15/11/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

@objc(DrivingSide)
public enum DrivingSide: Int {

    /// specifies that the legal driving side at the location is `right`.
    case right

    /// specifies that the legal driving side at the location is `left`.
    case left
}

extension DrivingSide: CustomStringConvertible {
    public var description: String {
        switch self {
        case .right:
            return "right"
        case .left:
            return "left"
        }
    }

    init?(description: String) {
        switch description {
        case "right":
            self = .right
        case "left":
            self = .left
        default:
            return nil
        }
    }
}
