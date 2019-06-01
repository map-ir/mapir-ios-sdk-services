//
//  MPIRReverseGeocode.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 11/3/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

struct MPIRReverseGeocode: Encodable {
    
    var address: String?
    var postalAddress: String?
    var last: String?
    var name: String?
    var poi: String?
    var country: String?
    var province: String?
    var county: String?
    var district: String?
    var ruralDistrict: String?
    var city: String?
    var village: String?
    var region: String?
    var neighbourhood: String?
    var primary: String?
    var plaque: String?
    var postalCode: String?
    var geometry: MPIRGeometry?
    
    enum CodingKeys: String, CodingKey {
        case address
        case postalAddress = "postal_address"
        case last
        case name
        case poi
        case country
        case province
        case county
        case district
        case ruralDistrict = "rural_district"
        case city
        case village
        case region
        case neighbourhood
        case primary
        case plaque
        case postalCode = "postal_code"
        case geometry = "geom"
    }
}
