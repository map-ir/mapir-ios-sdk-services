//
//  MPSStaticMapMarker.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 16/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public struct MPSStaticMapMarker {
    var coordinate: MPSLocationCoordinate
    var style: MPSStaticMapMarkerStyle
    var label: String
}

public enum MPSStaticMapMarkerStyle: String {
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
