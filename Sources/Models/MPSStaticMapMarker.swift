//
//  MPSStaticMapMarker.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 16/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import CoreLocation
import Foundation

public struct MPSStaticMapMarker {
    public var coordinate: CLLocationCoordinate2D
    public var style: MPSStaticMapMarker.Style
    public var label: String

    public enum Style: String {
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

    public init(coordinate: CLLocationCoordinate2D, style: MPSStaticMapMarker.Style, label: String) {
        self.coordinate = coordinate
        self.style = style
        self.label = label
    }
}

enum StaticMapError: Error {
    /// Error due to decoding image into UIImage
    case imageDecodingError

    case zoomLevelOutOfRange

    var localizedDescription: String {
        switch self {
        case .imageDecodingError:
            return "Couldn't decode image"
        case .zoomLevelOutOfRange:
            return "Zoom level is out of valid range. Zoom level must be less than 20 or more than 0. (0 < zoomLevel < 20)"
        }
    }
}
