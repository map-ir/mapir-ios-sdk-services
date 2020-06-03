//
//  ServiceError.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 19/1/1399 AP.
//  Copyright © 1399 AP Map. All rights reserved.
//

import Foundation

public enum ServiceError: LocalizedError {

    /// Indicates that you are not using a Map.ir API key or your key is invalid.
    case unauthorized(reason: UnauthorizedReason)

    /// Indicates that network was unavailable or a network error occurred.
    case network

    /// Indicates that the task was canceled.
    case canceled

    /// Indicates that a task is finished with no result.
    case noResult

    /// Indicates that there was an issue with processing this request on the server.
    ///
    /// In case of this error, contact developers via [support
    /// email](mailto:support@map.ir) or website.
    case serverError(httpStatusCode: Int)

    public enum UnauthorizedReason {

        case notSet

        case wrong

        init() {
            if AccountManager.isAPIKeySet {
                self = .notSet
            } else {
                self = .wrong
            }
        }
    }

    public enum DistanceMatrixError: LocalizedError {

        /// Shows that origins and/or destinations dictionary are empty.
        case emptyWaypointDictionary

        /// Indicates that there is an invalid character in names of origins and/or
        /// destinations waypoints.
        case invalidCharacterInNames(name: String, characters: [Character])
    }

    public enum DirectionsError: LocalizedError {

        /// Shows that number of specified waypoints are less than two.
        case invalidWaypoints(count: Int)
    }

    public enum GeofenceError: LocalizedError {

        /// Shows that array of input polygons is empty while creating a new
        /// polygon.
        case emptyPolygonsArray
    }

    public enum MapSnapshotterError: LocalizedError {

        /// Shows that the array of input markers is empty. At least one is required.
        case emptyMarkersArray
    }
}

extension ServiceError {
    public var errorDescription: String? {
        switch self {
        case .unauthorized(let reason):
            switch reason {
            case .notSet:
                return "You are not using a Map.ir API key which is required to use the services."
            case .wrong:
                return """
                You are using an API key which is evaluated as invalid by Map.ir. Try visiting your profile \
                at https://corp.map.ir/registraion to correct or update your API key.
                If you believe this is wrong, contact Map.ir support via \
                support@map.ir or at the website: https://support.map.ir.
                """
            }
        case .network:
            return "Network was unavailable or a network error occurred."
        case .canceled:
            return "Task has been canceled."
        case .noResult:
            return "Task is finished with no result."
        case .serverError(let statusCode):
            return """
            There was an issue with processing this request on the server. (status code: \(statusCode))
            Please contact developers via support@map.ir or website at https://support.map.ir.
            """
        }
    }

    var localizedDescription: String { errorDescription! }
}

extension ServiceError.DistanceMatrixError {
    public var errorDescription: String? {
        switch self {
        case .emptyWaypointDictionary:
            return "Origins and/or destinations dictionary are empty."
        case let .invalidCharacterInNames(name, characters):
            return """
            There are invalid characters (\(characters)) in of the names (\(name)) \
            of origins or destinations waypoints.
            """
        }
    }

    var localizedDescription: String { errorDescription! }
}

extension ServiceError.DirectionsError {
    public var errorDescription: String? {
        switch self {
        case .invalidWaypoints(count: let count):
            return "Number of specified waypoints are less than two. (currently it is \(count))"
        }
    }

    var localizedDescription: String { errorDescription! }
}

extension ServiceError.GeofenceError {
    public var errorDescription: String? {
        switch self {
        case .emptyPolygonsArray:
            return "Array of input polygons is empty while creating a new polygon."
        }
    }

    var localizedDescription: String { errorDescription! }
}

extension ServiceError.MapSnapshotterError {
    public var errorDescription: String? {
        switch self {
        case .emptyMarkersArray:
            return "Array of input markers is empty. At least one is required."
        }
    }

    var localizedDescription: String { errorDescription! }
}
