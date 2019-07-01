//
//  MPSDistanceMatrix.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 5/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public struct MPSDistanceMatrix {
    public var distances: [MPSDistance]
    public var durations: [MPSDuration]
    public var origins: [MPSLocation]
    public var destinations: [MPSLocation]
    
    private struct DistanceHelper: Decodable {
        var origin: String
        var destination: String
        var distance: Double
        
        enum CodingKeys: String, CodingKey {
            case origin = "origin_index"
            case destination = "destination_index"
            case distance
        }
    }
    
    private struct DurationHelper: Decodable {
        var origin: String
        var destination: String
        var duration: Double
        
        enum CodingKeys: String, CodingKey {
            case origin = "origin_index"
            case destination = "destination_index"
            case duration
        }
    }
}

extension MPSDistanceMatrix: Decodable {
    enum CodingKeys: String, CodingKey {
        case distances = "distance"
        case durations = "duration"
        case origins
        case destinations
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let originsHelper = try container.decode([String : MPSLocation].self, forKey: .origins)
        let destinationHelper = try container.decode([String : MPSLocation].self, forKey: .destinations)
        let durationHelper = try? container.decode([DurationHelper].self, forKey: .durations)
        let distanceHelper = try? container.decode([DistanceHelper].self, forKey: .distances)
        
        durations = [MPSDuration]()
        distances = [MPSDistance]()
        origins = [MPSLocation]()
        destinations = [MPSLocation]()

        for (_, value) in originsHelper {
            origins.append(value)
        }

        for (_, value) in destinationHelper {
            destinations.append(value)
        }
        
        if let durationHelper = durationHelper {
            for helper in durationHelper {
                if let origin = originsHelper[helper.origin], let destination = destinationHelper[helper.destination] {
                    let newDuration = MPSDuration(origin: origin,
                                                  destination: destination,
                                                  duration: helper.duration)
                    durations.append(newDuration)
                }
            }
        }

        if let distanceHelper = distanceHelper {
            for helper in distanceHelper {
                if let origin = originsHelper[helper.origin], let destination = destinationHelper[helper.destination] {
                    let newDistance = MPSDistance(origin: origin,
                                                  destination: destination,
                                                  distance: helper.distance)
                    distances.append(newDistance)
                }
            }
        }
    }
}

