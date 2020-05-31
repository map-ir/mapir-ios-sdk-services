//
//  MapSnapshotter+Configuration.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 7/10/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

// MARK: Snapshotter Configuration

extension MapSnapshotter {

    /// The configuration is consisted of camera information that is used to take
    /// snapshot of the map.
    ///
    /// `MapSnapshotter` requires a configuration for a snapshotting task.
    public struct Configuration {

        /// Indicates the size of the output image.
        public var size: CGSize

        /// `zoomLevel` of the camera used for snapshotting.
        public var zoomLevel: Int

        /// List of `Marker`s that will be added on the result snapshot.
        ///
        /// - note: Since markers are used to specify the area that is shown by the map, at
        ///   least one marker is required in a configuration object to be used as the center
        ///   of the snap shotting area.
        public var markers: [Marker]

        /// Creates a snapshot configuration.
        ///
        /// - Parameters:
        ///   - size: Size of the result image. Unit of measurement is in `pixel`.
        ///   - zoomLevel: Zoom level of the the snapshotting camera.
        ///   - markers: Markers that are needed to be added to the map.
        public init(
            size: CGSize,
            zoomLevel: Int,
            markers: [Marker] = []
        ) {
            self.size = size
            self.zoomLevel = zoomLevel
            self.markers = markers
        }

        /// Adds a marker to the configuration.
        ///
        /// - Parameters:
        ///   - coordinate: The coordinate of the marker.
        ///   - name: The name of the marker that will shown as a label under the marker icon.
        ///   - style: The style of the marker.
        mutating public func addMarker(
            at coordinate: CLLocationCoordinate2D,
            name: String,
            style: Marker.Style
        ) {
            let aMarker = Marker(at: coordinate, label: name, style: style)
            markers.append(aMarker)
        }

        /// Adds a marker to the configuration.
        ///
        /// - Parameters:
        ///   - location: The location of the marker.
        ///   - name: The name of the marker that will shown as a label under the marker icon.
        ///   - style: The style of the marker.
        mutating public func addMarker(
            at location: CLLocation,
            name: String,
            style: Marker.Style
        ) {
            addMarker(at: location.coordinate, name: name, style: style)
        }
    }
}
