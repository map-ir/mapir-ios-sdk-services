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

        /// Invalid input arguments.
        ///
        /// Errors in arguments contain issues like inserting no origins and/or no
        /// destinations, having empty string as key for any of input dictionaries or
        /// having "-" in the name.
        case invalidArguments
    }

    @objc(SHDirectionsError)
    enum DirectionsError: UInt, Error {

        /// Invalid input arguments.
        ///
        /// Errors in arguments contain issues like inserting no waypoints.
        case invalidArguments
    }

    @objc(SHDirectionsError)
    enum GeofenceError: UInt, Error {

        /// Invalid input arguments.
        ///
        /// Errors in arguments contain issues like inserting no waypoints.
        case invalidArguments
    }
}
