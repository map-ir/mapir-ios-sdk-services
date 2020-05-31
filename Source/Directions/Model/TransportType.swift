//
//  TransportType.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 15/11/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

///  A `TransportType` specifies the mode of transportation used for part of a route.
public enum TransportType: String {

    /// The route requires the user to drive or ride a car, truck, or motorcycle.
    ///
    /// Available for automobile directions.
    case automobile

    /// The route requires the user to board a ferry.
    ///
    /// Available for automobile, walking and cycling directions. The user should verify
    /// whether the bicycle or automobile is allowed onboard or not.
    case ferry

    /// The route requires the user to cross a movable bridge.
    ///
    /// Available for automobile and cycling directions.
    case movableBridge = "movable bridge"

    /// The route becomes impassable at this point.
    ///
    /// Available for automobile, walking and cycling directions. You should not
    /// encounter this transport type under normal circumstances.
    case inaccessible

    /// The route requires the user to walk.
    ///
    /// Available for walking and cycling directions. For cycling means that user is
    /// expected to dismount the bicycle.
    case walking

    /// The route requires the user to ride a bicycle.
    ///
    /// Available for cycling directions.
    case cycling

    /// The route requires the user to board a train.
    ///
    /// Available for cycling directions. User should verify whether bicycles are
    /// allowed onboard the train.
    case train
}

extension TransportType: CustomStringConvertible {
    public var description: String { self.rawValue }
}
