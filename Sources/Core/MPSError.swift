//
//  MPSError.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 22/3/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public enum MPSError: Error {

    /// Errors related to the service.
    enum ServiceError: Error {

        /// Indicates token-related errors. either not defined or invalid one.
        case invalidAccessToken

        var localizedDescription: String {
            switch self {
            case .invalidAccessToken:
                return "Token is not defined. use MPSMapirServices(accessToken:) at least once or add your token to Info.plist with key MAPIRAccessToken."
            }
        }
    }

    /// Response related errors.
    enum ResponseError: Error {

        /// Response form is not valid
        case invalidResponse

        /// HTTP 400: Bad Reuqest.
        case badRequest

        /// HTTP 404: Not Found.
        case notFound
    }

    /// Request related errors.
    enum RequestError: Error {

        /// Error due to invalid input arguments.
        case invalidArgument
    }

    /// Error due to generating request URL
    case urlEncodingError

    /// Error due to decoding image into UIImage
    case imageDecodingError
}

public struct NetworkError: Error {

    enum Defenition: Int {
        case badRequest = 400
        case Unauthorized = 401
        case Forbidden = 403
        case NotFound = 404
        case internalServerError = 500
        case badGateway = 502
        case serviceUnavailable = 503
        case gatewayTimeout = 504
        case other = -1

        init(code: RawValue) {
            if let def = Defenition(rawValue: code) {
                self = def
            } else {
                self = .other
            }
        }
    }

    enum Side {
        case server
        case client

        init(code: Int) {
            if code < 500 && code >= 400 {
                self = .client
            } else if code < 600 && code >= 500 {
                self = .server
            } else {
                fatalError("Invalid Status Code.")
            }
        }
    }

    let code: Int
    let defenition: Defenition
    let side: Side

    init(code: Int) {
        self.defenition = Defenition(code: code)
        self.side = Side(code: code)
        self.code = code
    }
}
