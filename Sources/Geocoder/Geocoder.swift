//
//  Geocoder.swift
//  MapirServices
//
//  Created by Alireza Asadi on 29/8/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

@objc(MSGeocoder)
public class Geocoder: NSObject {

    /// Geocoder or ReverseGeocoder
    public typealias GeocodeCompletionHandler = (_ results: [Placemark]?, _ error: Swift.Error?) -> Void

    /// Current status of `Geocoder` object.
    @objc public var isGeocoding: Bool {
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

    /// Creates a request to reverse geocode the given location.
    ///
    /// - Parameters:
    ///   - location: `CLLocation` object to find its address.
    ///   - completionHandler: Completion handler block to run after the reverse geocode
    ///   result is available.
    ///
    /// Array of `Placemark` objects has only one `Placemark` after a reverse geocoding
    /// task.
    @objc(reverseGeocodeLocation:completionHandler:)
    public func reverseGeocode(_ location: CLLocation,
                               completionHandler: @escaping GeocodeCompletionHandler) {
        reverseGeocode(location.coordinate, completionHandler: completionHandler)
    }

    /// Creates a request to reverse geocode the given coordinates.
    ///
    /// - Parameters:
    ///   - coordinate: Coordainte to find its address.
    ///   - completionHandler: Completion handler block to run after the reverse geocode
    ///   result is available.
    ///
    /// Array of `Placemark` objects has only one `Placemark` after a reverse geocoding
    /// task.
    @objc(reverseGeocodeCoordinate:completionHandler:)
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
    @objc(fastReverseGeocodeLocation:completionHandler:)
    public func fastReverseGeocode(_ location: CLLocation,
                                   completionHandler: @escaping GeocodeCompletionHandler) {
        fastReverseGeocode(location.coordinate, completionHandler: completionHandler)
    }

    /// Creates a request to reverse geocode the given coordinate in shorter time.
    ///
    /// - Parameters:
    ///   - coordinate: Coordainte to find its address.
    ///   - completionHandler: Completion handler block to run after the reverse geocode.
    ///
    /// Array of `Placemark` objects has only one `Placemark` after a reverse geocoding
    /// task.
    @objc(fastReverseGeocodeCoordainte:completionHandler:)
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
    @objc(geocodeAddress:city:completionHandler:)
    public func geocode(_ address: String,
                        city: String? = nil,
                        completionHandler: @escaping GeocodeCompletionHandler) {
        cancel()

        perform(.forwardGeocode(address, city),
                completionHandler: completionHandler,
                decoder: decodeForwardReverseGeocode(from:))
    }

    /// Cancels the current running geocoding or reverseGeocoding task.
    @objc public func cancel() {
        activeTask?.cancel()
        activeTask = nil
    }
}

// MARK: Geocoding Errors

extension Geocoder {

    /// Errors related to geocoding.
    @objc(GeocoderError)
    public enum Error: UInt, Swift.Error {

        /// Indicates that you are not using a Map.ir API key or your key is invalid.
        case unauthorized

        /// Indicates that network was unavailable or a network error occured.
        case network

        /// Indicates that the task was canceled.
        case canceled

        /// Indicates that geocode or reverse geocode had no result.
        case noResult
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
            completionHandler(nil, Error.unauthorized)
            return
        }

        var request: URLRequest
        switch task {
        case let .fastReverseGeocode(coordaintes):
            request = self.urlRequestForReverseGeocodingTask(coordinate: coordaintes)
        case let .reverseGeocode(coordaintes):
            request = self.urlRequestForFastReverseGeocodingTask(coordinate: coordaintes)
        case let .forwardGeocode(address, city):
            request = self.urlRequestForGeocodeTask(string: address, city: city)
        }

        self.activeTask = NetworkingManager.dataTask(with: request) { (data, response, error) in
            if error != nil {
                if let nsError = error as NSError?, nsError.code == NSURLErrorCancelled {
                    completionHandler(nil, Error.canceled)
                } else {
                    completionHandler(nil, Error.network)
                }
                return
            }

            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200:
                    if let data = data, let placemarks = decoder(data) {
                        completionHandler(placemarks, nil)
                    } else {
                        completionHandler(nil, Error.noResult)
                    }
                case 401:
                    completionHandler(nil, Error.unauthorized)
                case 400, 402..<500:
                    completionHandler(nil, Error.noResult)
                case 300..<400, 500..<600:
                    completionHandler(nil, Error.network)
                default:
                    fatalError("Unknown response status code.")
                }
            } else {
                completionHandler(nil, Error.network)
            }
        }
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
        var urlComponents = NetworkingManager.baseURLComponents
        let queryItemsDict = [
            "lat": String(coordinate.latitude),
            "lon": String(coordinate.longitude)
        ]

        urlComponents.queryItems = URLQueryItem.queryItems(from: queryItemsDict)
        urlComponents.path = "/reverse"

        let request = NetworkingManager.request(url: urlComponents)

        return request
    }

    func urlRequestForFastReverseGeocodingTask(coordinate: CLLocationCoordinate2D) -> URLRequest {
        var urlComponents = NetworkingManager.baseURLComponents
        let queryItemsDict = [
            "lat": String(coordinate.latitude),
            "lon": String(coordinate.longitude)
        ]

        urlComponents.queryItems = URLQueryItem.queryItems(from: queryItemsDict)
        urlComponents.path = "/fast-reverse"

        let request = NetworkingManager.request(url: urlComponents)

        return request
    }

    func urlRequestForGeocodeTask(string: String, city: String?) -> URLRequest {
        var urlComponents = NetworkingManager.baseURLComponents
        var queryItemsDict = ["text": string]
        if let city = city {
            queryItemsDict["$filter"] = "city eq \(city)"
        }

        urlComponents.queryItems = URLQueryItem.queryItems(from: queryItemsDict)
        urlComponents.path = "/search/v2"

        let request = NetworkingManager.request(url: urlComponents)

        return request
    }
}
