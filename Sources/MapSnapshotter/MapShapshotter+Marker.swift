//
//  MapShapshotter+Marker.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 7/10/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

// MARK: Marker

extension MapSnapshotter {

    /// A marker is placed on the snapshot of the map. It can be of different styles and
    /// show a string label under it.
    @objc(MapSnapshotterMarker)
    final class Marker: NSObject {

        /// The Label of the marker tht will be shown under the marker.
        @objc public var label: String?

        /// Coordinate at which marker will be placed.
        @objc public var coordinate: CLLocationCoordinate2D

        /// Style of the marker.
        @objc public var style: Marker.Style

        /// Creates marker for the snapshot at specified coordinate.
        ///
        /// - Parameters:
        ///   - coordinate: Coordiante of the marker.
        ///   - label: The text to show under the marker.
        ///   - style: The style of the marker.
        @objc public init(at coordinate: CLLocationCoordinate2D, label: String, style: Marker.Style) {
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
    @objc(MapSnapshotterMarkerStyle)
    public enum Style: UInt {
        case black
        case blue
        case destination
        case green
        case magenta
        case navyblue
        case orange
        case origin
        case pink
        case red
        case skyblue
        case teal
        case white
        case yellow
    }
}

// MARK: Marker Style Additions

extension MapSnapshotter.Marker.Style {
    var stringValue: String {
        var string = ""
        switch self {
        case .black:
            string = "black"
        case .blue:
            string = "blue"
        case .destination:
            string = "destination"
        case .green:
            string = "green"
        case .magenta:
            string = "magenta"
        case .navyblue:
            string = "navyblue"
        case .orange:
            string = "orange"
        case .origin:
            string = "origin"
        case .pink:
            string = "pink"
        case .red:
            string = "red"
        case .skyblue:
            string = "skyblue"
        case .teal:
            string = "teal"
        case .white:
            string = "white"
        case .yellow:
            string = "yellow"
        }
        return string
    }
}
