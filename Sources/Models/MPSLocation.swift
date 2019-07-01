//
//  MPSLocation.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 5/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public struct MPSLocation {
    public var name: String?
    public var province: String?
    public var county: String?
    public var district: String?
    public var ruralDistrict: String?
    public var suburb: String?
    public var neighbourhood: String?
    public var coordinate: MPSLocationCoordinate?
}

extension MPSLocation: Decodable {
    enum CodingKeys: String, CodingKey {
        case name
        case province
        case county
        case district
        case ruralDistrict = "rural_district"
        case suburb
        case neighbourhood
        case coordinate
    }
}
