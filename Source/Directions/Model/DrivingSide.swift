//
//  DrivingSide.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 15/11/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public enum DrivingSide: String {

    /// specifies that the legal driving side at the location is `right`.
    case right

    /// specifies that the legal driving side at the location is `left`.
    case left
}

extension DrivingSide: CustomStringConvertible {
    public var description: String { self.rawValue }
}
