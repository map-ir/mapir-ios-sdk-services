//
//  Array+Extension.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 13/6/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
