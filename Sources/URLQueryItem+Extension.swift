//
//  Array+Extension.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 8/9/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

extension URLQueryItem {
    static func queryItems(from dictionary: [String: String]) -> [URLQueryItem] {
        dictionary.map { URLQueryItem(name: $0, value: $1) }
    }
}

