//
//  Geocoder.swift
//  MapirServices
//
//  Created by Alireza Asadi on 29/8/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation
import CoreLocation

public class Geocoder {

    /// Geocoder or ReverseGeocoder
    public typealias GeocodeCompletionHandler = (Result<[Placemark], Error>) -> Void

    /// Current status of `Geocoder` object.
    public var isGeocoding: Bool {
        if let task = activeTask {
            switch task.state {
            case .running:
                return true
            case .canceling, .suspended, .completed:
                return false
            @unknown default:
                fatalError("Unknown Geocoding Status.")
            }
        } else {
            return false
        }
    }

    private var activeTask: URLSessionDataTask?

    /// Creates a `Geocoder` wrapper.
    public init() { }

    /// Creates a request to reverse geocode the given location.
    ///
    /// - Parameters:
    ///   - location: `CLLocation` object to find its address.
    ///   - completionHandler: Completion handler block to run after the reverse geocode
    ///   result is available.
    ///
    /// Array of `Placemark` objects has only one `Placemark` after a reverse geocoding
    /// task.
    public func reverseGeocode(_ location: CLLocation,
                               completionHandler: @escaping GeocodeCompletionHandler) {
        reverseGeocode(location.coordinate, completionHandler: completionHandler)
    }

    /// Creates a request to reverse geocode the given coordinates.
    ///
    /// - Parameters:
    ///   - coordinate: The coordinate to find its address.
    ///   - completionHandler: Completion handler block to run after the reverse geocode
    ///   result is available.
    ///
    /// Array of `Placemark` objects has only one `Placemark` after a reverse geocoding
    /// task.
    public func reverseGeocode(_ coordinate: CLLocationCoordinate2D,
                               completionHandler: @escaping GeocodeCompletionHandler) {
        cancel()

        perform(.reverseGeocode(coordinate),
                completionHandler: completionHandler,
                decoder: decodeReverseGeocode(from:))
    }

    /// Creates a request to reverse geocode the given location in shorter time.
    ///
    /// - Parameters:
    ///   - location: `CLLocation` object to find its address.
    ///   - completionHandler: Completion handler block to run after the reverse geocode
    ///   result is available.
    ///
    /// Array of `Placemark` objects has only one `Placemark` after a reverse geocoding
    /// task.
    public func fastReverseGeocode(_ location: CLLocation,
                                   completionHandler: @escaping GeocodeCompletionHandler) {
        fastReverseGeocode(location.coordinate, completionHandler: completionHandler)
    }

    /// Creates a request to reverse geocode the given coordinate in shorter time.
    ///
    /// - Parameters:
    ///   - coordinate: The coordinate to find its address.
    ///   - completionHandler: Completion handler block to run after the reverse geocode.
    ///
    /// Array of `Placemark` objects has only one `Placemark` after a reverse geocoding
    /// task.
    public func fastReverseGeocode(_ coordinate: CLLocationCoordinate2D,
                                   completionHandler: @escaping GeocodeCompletionHandler) {
        cancel()

        perform(.fastReverseGeocode(coordinate),
                completionHandler: completionHandler,
                decoder: decodeReverseGeocode(from:))
    }

    /// Initiates a request to find goecode for specified address.
    ///
    /// - Parameters:
    ///   - address: A `String` containing address of the location.
    ///   - city: City in which the address is located. specify the city for more accuracy.
    ///   - completionHandler: Completion handler block to execute with the results.
    ///   The geocoder will execute the result regardless of whether the request was
    ///   successful or not.
    func geocode(_ address: String,
                 city: String? = nil,
                 completionHandler: @escaping GeocodeCompletionHandler) {
        cancel()

        perform(.forwardGeocode(address, city),
                completionHandler: completionHandler,
                decoder: decodeForwardReverseGeocode(from:))
    }

    /// Cancels the current running geocoding or reverseGeocoding task.
    public func cancel() {
        activeTask?.cancel()
        activeTask = nil
    }
}

// MARK: Running Tasks

extension Geocoder {
    enum Task {
        case forwardGeocode(String, String?)
        case reverseGeocode(CLLocationCoordinate2D)
        case fastReverseGeocode(CLLocationCoordinate2D)
    }

    func perform(_ task: Task,
                 completionHandler: @escaping GeocodeCompletionHandler,
                 decoder: @escaping (Data) -> ([Placemark]?)) {
        
        guard AccountManager.isAuthorized else {
            completionHandler(.failure(ServiceError.unauthorized(reason: ServiceError.UnauthorizedReason())))
            return
        }

        var request: URLRequest
        switch task {
        case let .fastReverseGeocode(coordinates):
            request = self.urlRequestForFastReverseGeocodingTask(coordinate: coordinates)
        case let .reverseGeocode(coordinates):
            request = self.urlRequestForReverseGeocodingTask(coordinate: coordinates)
        case let .forwardGeocode(address, city):
            request = self.urlRequestForGeocodeTask(string: address, city: city)
        }

        activeTask = Utilities.session.dataTask(
            with: request,
            decoderBlock: decoder,
            completionHandler: completionHandler)

        activeTask?.resume()
    }
}

// MARK: Decoders

extension Geocoder {
    func decodeReverseGeocode(from data: Data) -> [Placemark]? {
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(Placemark.ReverseGeocodeResponseScheme.self, from: data) {
            let placemark = Placemark(from: decoded)
            return [placemark]
        } else {
            return nil
        }
    }

    func decodeForwardReverseGeocode(from data: Data) -> [Placemark]? {
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(Placemark.ReverseGeocodeResponseScheme.self, from: data) {
            let placemark = Placemark(from: decoded)
            return [placemark]
        } else {
            return nil
        }
    }
}

// MARK: Generating URL Requests

extension Geocoder {
    func urlRequestForReverseGeocodingTask(coordinate: CLLocationCoordinate2D) -> URLRequest {
        var urlComponents = Utilities.baseURLComponents
        let queryItemsDict = [
            "lat": String(coordinate.latitude),
            "lon": String(coordinate.longitude)
        ]

        urlComponents.queryItems = URLQueryItem.queryItems(from: queryItemsDict)
        urlComponents.path = "/reverse"

        let request = URLRequest(url: urlComponents)

        return request
    }

    func urlRequestForFastReverseGeocodingTask(coordinate: CLLocationCoordinate2D) -> URLRequest {
        var urlComponents = Utilities.baseURLComponents
        let queryItemsDict = [
            "lat": String(coordinate.latitude),
            "lon": String(coordinate.longitude)
        ]

        urlComponents.queryItems = URLQueryItem.queryItems(from: queryItemsDict)
        urlComponents.path = "/fast-reverse"

        let request = URLRequest(url: urlComponents)

        return request
    }

    func urlRequestForGeocodeTask(string: String, city: String?) -> URLRequest {
        var urlComponents = Utilities.baseURLComponents
        var queryItemsDict = ["text": string]
        if let city = city {
            queryItemsDict["$filter"] = "city eq \(city)"
        }

        urlComponents.queryItems = URLQueryItem.queryItems(from: queryItemsDict)
        urlComponents.path = "/search/v2"

        let request = URLRequest(url: urlComponents)

        return request
    }
}
