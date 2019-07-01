//
//  MPSSearch.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public struct MPSSearch {
    var allResultsCount: Int
    var results: [MPSSearchResult]

    // TODO: add filtering commands.
}

extension MPSSearch: Decodable {
    enum CodingKeys: String, CodingKey {
        case allResultsCount = "odata.count"
        case results = "values"
    }
}
