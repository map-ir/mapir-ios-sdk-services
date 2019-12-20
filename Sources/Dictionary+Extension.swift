//
//  Array+Extension.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 8/9/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

extension Dictionary where Key == String, Value == String {
    func convertedToURLQueryItems() -> [URLQueryItem] {
        self.map { URLQueryItem(name: $0, value: $1) }
    }
}
