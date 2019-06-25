//
//  MPIRGeomtry.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 11/3/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public class MPSMultipointGeometry: Codable {
    public var type: String?
    public var coordinates: [[Int]]?
    
    private enum CodingKeys: String, CodingKey {
        case type
        case coordinates
    }
}

public class MPSPointGeometry {
    public var type: String?
    public var coordinates: [Int]?

    private enum CodingKeys: String, CodingKey {
        case type
        case coordinates
    }
}
