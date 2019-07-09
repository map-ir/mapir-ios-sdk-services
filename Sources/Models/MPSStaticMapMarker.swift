//
//  MPSStaticMapMarker.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 16/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public struct MPSStaticMapMarker {
    public var coordinate: MPSLocationCoordinate
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

    public init(coordinate: MPSLocationCoordinate, style: MPSStaticMapMarker.Style, label: String) {
        self.coordinate = coordinate
        self.style = style
        self.label = label
    }
}
