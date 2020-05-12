//
//  ServiceError.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 19/1/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import Foundation

@objc(SHServiceError)
public enum ServiceError: UInt, Error {

    /// Indicates that you are not using a Map.ir API key or your key is invalid.
    case unauthorized

    /// Indicates that network was unavailable or a network error occurred.
    case network

    /// Indicates that the task was canceled.
    case canceled

    /// Indicates that geocode or reverse geocode had no result.
    case noResult

    @objc(SHDistanceMatrixError)
    enum DistanceMatrixError: UInt, Error {

        /// Shows that origins and/or destinations dictionary are empty.
        case emptyWaypointDictionary

        /// Indicates that there is an invalid character in names of origins and/or
        /// destinations waypoints.
        case invalidCharacterInNames
    }

    @objc(SHDirectionsError)
    enum DirectionsError: UInt, Error {

        /// Shows that number of specified waypoints are less than two.
        case invalidWaypoints
    }

    @objc(SHDirectionsError)
    enum GeofenceError: UInt, Error {

        /// Shows that array of input polygons is empty while creating a new
        /// polygon.
        case emptyPolygonsArray
    }

    @objc(SHDirectionsError)
    enum MapSnapshotterError: UInt, Error {

        /// Shows that the array of input markers is empty. At least one is required.
        case emptyMarkersArray
    }
}