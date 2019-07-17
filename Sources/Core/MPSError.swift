//
//  MPSError.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 22/3/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public enum MPSError: Error {

    case noAPIAccessToken

    case invalidResponse

    enum ServiceError: Error {
        case serviceUnavailabele
    }

    enum RequestError: Error {
        case badRequest
        case notFound
        case invalidArgument
    }

    case urlEncodingError

    case imageDecodingError
}
