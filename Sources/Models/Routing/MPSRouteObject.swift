//
//  MPSRouteObject.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 17/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public struct MPSRouteObject {
    public var routes: [MPSRoute]
    public var waypoints: [MPSWaypoint]
}

extension MPSRouteObject: Decodable {
    enum CodingKeys: String, CodingKey {
        case routes
        case waypoints
    }
}
