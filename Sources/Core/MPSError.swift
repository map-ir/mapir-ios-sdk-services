//
//  MPSError.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 22/3/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

public enum MPSError: Error {
    
    enum ServiceError {
        case serviceUnavailabele
    }
    
    enum RequestError {
        case badRequest(code: Int)
        case notFound
    }
}
