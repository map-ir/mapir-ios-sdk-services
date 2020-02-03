//
//  DIstanceMatrix+Configuration.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 9/10/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

// MARK: Distance matrix configurations

extension DistanceMatrix {

    @objc(DistanceMatrixConfiguration)
    public final class Configuration: NSObject {

        /// Default configuration.
        @objc(defaultConfiguration)
        public static var `default` = Configuration(options: [.distance, .duration])

        /// Options to calculate the matrix.
        @objc public var options: Options = []

        @objc public init(options: Options) {
            self.options = options
        }
    }
}
