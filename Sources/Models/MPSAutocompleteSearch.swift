//
//  MPSAutocompleteSearch.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public struct MPSAutocompleteSearch {
    var allResultsCount: Int
    var results: [MPSAutocompleteSearchResult]
}

extension MPSAutocompleteSearch: Decodable {
    enum CodingKeys: String, CodingKey {
        case allResultsCount = "odata.count"
        case results = "value"
    }
}
