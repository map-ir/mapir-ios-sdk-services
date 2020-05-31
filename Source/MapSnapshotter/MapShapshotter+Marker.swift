//
//  MapShapshotter+Marker.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 7/10/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: Marker

extension MapSnapshotter {

    /// A marker is placed on the snapshot of the map. It can be of different styles and
    /// show a string label under it.
    public struct Marker {

        /// The Label of the marker that will be shown under the marker.
        public var label: String?

        /// Coordinate at which marker will be placed.
        public var coordinate: CLLocationCoordinate2D

        /// Style of the marker.
        public var style: Marker.Style

        /// Creates marker for the snapshot at specified coordinate.
        ///
        /// - Parameters:
        ///   - coordinate: The coordinate of the marker.
        ///   - label: The text to show under the marker.
        ///   - style: The style of the marker.
        public init(at coordinate: CLLocationCoordinate2D, label: String?, style: Marker.Style) {
            self.coordinate = coordinate
            self.style = style
            self.label = label
        }
    }
}

// MARK: Styles

extension MapSnapshotter.Marker {

    /// Defines different style that a marker can have on the snapshot of the map.
    ///
    /// - note: In the future, new cases may be added.
    public enum Style: String {
        case origin
        case destination
        case black
        case white
        case red
        case blue
        case navyBlue = "navyblue"
        case skyBlue = "skyblue"
        case green
        case teal
        case yellow
        case orange
        case magenta
        case pink
    }
}
