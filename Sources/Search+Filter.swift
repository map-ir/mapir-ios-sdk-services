//
//  Search+Filter.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 7/10/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

extension Search {

    /// It is used to filter the search result by a condition.
    public enum Filter {

        /// Indicates filter by distance. Associated value must be a distance value in meters provided as a `Double`.
        case distance(meter: Double)

        /// Indicates filter by city name. Associated value must be name of the city.
        case city(name: String)

        /// Indicates filter by country name. Associated value must be name of the country.
        case county(name: String)

        /// Indicates filter by province name. Associated value must be name of the province.
        case province(name: String)

        /// Indicates filter by neighborhood name. Associated value must be name of the neighborhood.
        case neighborhood(name: String)

        /// Indicates filter by district number. Associated value must be number of the district.
        case district(number: Int)
    }
}

extension Search.Filter {
    func urlRepresentation() -> String {
        var textToEncode = ""
        
        switch self {
        case .distance(let amount):
            textToEncode = "distance eq \(amount)m"
        case .city(let name):
            textToEncode = "city eq \(name)"
        case .province(let name):
            textToEncode = "province eq \(name)"
        case .county(let name):
            textToEncode = "county eq \(name)"
        case .neighborhood(let name):
            textToEncode = "neighbourhood eq \(name)"
        case .district(let name):
            textToEncode = "district eq \(name)"
        }

        return textToEncode
    }
}
