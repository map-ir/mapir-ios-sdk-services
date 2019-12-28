//
//  MapSnapshotter+Configuration.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 7/10/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import UIKit

// MARK: Snapshotter Configuration

extension MapSnapshotter {
    @objc(MapSnapshotterConfiguration)
    final class Configuration: NSObject {
        public var center: CLLocation
        public var size: CGSize
        public var zoomLevel: UInt
        public var markers: [Marker]

        public init(center: CLLocation, size: CGSize, zoomLevel: UInt) {
            self.center = center
            self.size = size
            self.zoomLevel = zoomLevel
            self.markers = []
        }

        public func addMarker(name: String, at location: CLLocation, style: Marker.Style) {
            let aMarker = Marker(label: name, location: location, style: style)
            markers.append(aMarker)
        }
    }
}
