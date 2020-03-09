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

extension Search.Filter: CustomStringConvertible {

    public var description: String {
        switch self {
        case .distance: return "distance"
        case .city: return "city"
        case .province: return "province"
        case .county: return "county"
        case .neighborhood: return "neighbourhood"
        case .district: return "district"
        }
    }

    public var stringValue: String {
        switch self {
        case .distance(let amount): return String(amount)
        case .city(let name): return name
        case .province(let name): return name
        case .county(let name): return name
        case .neighborhood(let name): return name
        case .district(let number): return String(number)
        }
    }

    var urlRepresentation: String {
        var desc = ""

        switch self {
        case .distance(let amount):
            desc = "distance eq \(amount)"
        case .city(let name):
            desc = "city eq \(name)"
        case .province(let name):
            desc = "province eq \(name)"
        case .county(let name):
            desc = "county eq \(name)"
        case .neighborhood(let name):
            desc = "neighbourhood eq \(name)"
        case .district(let name):
            desc = "district eq \(name)"
        }

        return desc
    }
}
