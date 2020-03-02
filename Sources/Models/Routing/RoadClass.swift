//
//  Intersection+RoadClass.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 14/11/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

@objc(RoadClass)
public final class RoadClass: NSObject, OptionSet {

    @objc public var rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// The road segment is [tolled](https://wiki.openstreetmap.org/wiki/Key:toll).
    @objc public static let toll = RoadClass(rawValue: 1 << 0)

    /// The road segment has access restrictions.
    ///
    /// A road segment may have this class if there are [general access
    /// restrictions](https://wiki.openstreetmap.org/wiki/Key:access) or a
    /// [high-occupancy vehicle](https://wiki.openstreetmap.org/wiki/Key:hov)
    /// restriction.
    @objc public static let restricted = RoadClass(rawValue: 1 << 1)

    /// The road segment is a
    /// [freeway](https://wiki.openstreetmap.org/wiki/Tag:highway%3Dmotorway) or
    /// [freeway ramp](https://wiki.openstreetmap.org/wiki/Tag:highway%3Dmotorway_link).
    ///
    /// It may be desirable to suppress the name of the freeway when giving instructions
    /// and give instructions at fixed distances before an exit (such as 1 mile or 1
    /// kilometer ahead).
    @objc public static let motorway = RoadClass(rawValue: 1 << 2)

    /// The user must travel this segment of the route by ferry.
    ///
    /// The user should verify that the ferry is in operation. For driving and cycling
    /// directions, the user should also verify that his or her vehicle is permitted
    /// onboard the ferry.
    /// In general, the transport type of the step containing the road segment is also
    /// `TransportType.ferry`.
    @objc public static let ferry = RoadClass(rawValue: 1 << 3)

    /// The user must travel this segment of the route through a
    /// [tunnel](https://wiki.openstreetmap.org/wiki/Key:tunnel).
    @objc public static let tunnel = RoadClass(rawValue: 1 << 4)
}

extension RoadClass {
    convenience init?(descriptions: [String]) {
        var indications: RoadClass = []
        for d in descriptions {
            switch d {
            case "toll":
                indications.insert(.toll)
            case "restricted":
                indications.insert(.restricted)
            case "motorway":
                indications.insert(.motorway)
            case "ferry":
                indications.insert(.ferry)
            case "tunnel":
                indications.insert(.tunnel)
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
        if contains(.toll) { descriptions.append("toll") }
        if contains(.restricted) { descriptions.append("restricted") }
        if contains(.motorway) { descriptions.append("motorway") }
        if contains(.ferry) { descriptions.append("ferry") }
        if contains(.tunnel) { descriptions.append("tunnel") }

        return descriptions.joined(separator: ", ")
    }
}
