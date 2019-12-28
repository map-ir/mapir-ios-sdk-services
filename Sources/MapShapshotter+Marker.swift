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

    @objc(MapSnapshotterMarker)
    final class Marker: NSObject {
        public var label: String
        public var location: CLLocation
        public var style: Style

        public init(label: String, location: CLLocation, style: Style) {
            self.location = location
            self.style = style
            self.label = label
        }
    }
}

// MARK: Styles

extension MapSnapshotter.Marker {
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
