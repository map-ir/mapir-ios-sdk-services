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

    /// The configuration is consisted of camera information that is used to take
    /// snapshot of the map.
    ///
    /// `MapSnapshotter` requires a configuration for a snapshotting task.
    @objc(SHMapSnapshotterConfiguration)
    final class Configuration: NSObject {

        /// Shows the center snapshotting camera.
        @objc public var centerCoordinate: CLLocationCoordinate2D

        /// Indicates the size of the output image.
        @objc public var size: CGSize

        /// `zoomLevel` of the camera used for snapshotting.
        @objc public var zoomLevel: UInt

        /// List of `Marker`s that will be added on the result snapshot.
        @objc public var markers: [Marker]

        /// Creates a snapshot configuration.
        ///
        /// - Parameters:
        ///   - centerCoordinate: Center of the snapshotting camera, as a
        ///     `CLLocationCoordinate2D` object.
        ///   - size: Size of the result image. Unit of measurement is in `pixel`.
        ///   - zoomLevel: Zoom level of the the snapshotting camera.
        ///   - markers: Markers that are needed to be added to the map.
        @objc public init(
            centerCoordinate: CLLocationCoordinate2D,
            size: CGSize,
            zoomLevel: UInt,
            markers: [Marker] = []
        ) {
            self.centerCoordinate = centerCoordinate
            self.size = size
            self.zoomLevel = zoomLevel
            self.markers = []
        }

        /// Creates a snapshot configuration.
        ///
        /// - Parameters:
        ///   - center: Center of the snapshotting camera, as a `CLLocation` object.
        ///   - size: Size of the result image. Unit of measurement is in `pixel`.
        ///   - zoomLevel: Zoom level of the the snapshotting camera.
        ///   - markers: Markers that are needed to be added to the map.
        @objc public convenience init(
            center: CLLocation,
            size: CGSize,
            zoomLevel: UInt,
            markers: [Marker] = []
        ) {
            self.init(
                centerCoordinate: center.coordinate,
                size: size,
                zoomLevel: zoomLevel,
                markers: markers)
        }

        /// Adds a marker to the configuration.
        ///
        /// - Parameters:
        ///   - coordinate: The coordinate of the marker.
        ///   - name: The name of the marker that will shown as a label under the marker icon.
        ///   - style: The style of the marker.
        @objc(addMarkerAtCoordinate:name:style:)
        public func addMarker(
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
        @objc(addMarkerAtLocation:name:style:)
        public func addMarker(
            at location: CLLocation,
            name: String,
            style: Marker.Style
        ) {
            addMarker(at: location.coordinate, name: name, style: style)
        }
    }
}
