//
//  TransportType.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 15/11/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

///  A `TransportType` specifies the mode of transportation used for part of a route.
@objc(TransportType)
public enum TransportType: Int {

    /// The step does not have a particular transport type associated with it.
    ///
    /// This transport type is used as a workaround for bridging to Objective-C which
    /// does not support nullable enumeration-typed values.
    case none

    /// The route requires the user to drive or ride a car, truck, or motorcycle.
    ///
    /// Available for automobile directions.
    case automobile

    /// The route requires the user to board a ferry.
    ///
    /// Available for automobile, walking and cycling directions. The user should verify
    /// whether the bicylce or automobile is allowed onboard or not.
    case ferry

    /// The route requires the user to cross a movable bridge.
    ///
    /// Available for automobile and cycling directions.
    case movableBridge

    /// The route becomes impassable at this point.
    ///
    /// Available for automobile, walking and cycling directions. You should not
    /// encounter this transport type under normal circumstances.
    case inaccessible

    /// The route requires the user to walk.
    ///
    /// Available for walking and cycling directions. For cycling means that user is
    /// expected to dismount the bicylce.
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
    public var description: String {
        switch self {
        case .none:
            return "none"
        case .automobile:
            return "automobile"
        case .ferry:
            return "ferry"
        case .movableBridge:
            return "movable bridge"
        case .inaccessible:
            return "inaccessible"
        case .walking:
            return "walking"
        case .cycling:
            return "cycling"
        case .train:
            return "train"
        }
    }

    init(description: String) {
        switch description {
        case "automobile":
            self = .automobile
        case "ferry":
            self = .ferry
        case "movable bridge":
            self = .movableBridge
        case "inaccessible":
            self = .inaccessible
        case "walking":
            self = .walking
        case "cycling":
            self = .cycling
        case "train":
            self = .train
        default:
            self = .none
        }
    }

}
