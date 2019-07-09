//
//  ParameterEncoding.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 11/3/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

typealias Parameters = [String: String]

protocol ParameterEncodable {
    /// Creates a `URLRequest` by applying parameters onto an existing `URLRequest`
    ///
    /// - Parameters:
    ///   - urlRequest: request to apply parameters to it.
    ///   - parameters: parameters to apply at request.
    /// - Returns: a `URLRequest` encoded with parameters.
    /// - Throws: If encoding fails, throws a error.
    func encode(_ urlRequest: URLRequest, with parameters: Parameters) throws -> URLRequest
}
