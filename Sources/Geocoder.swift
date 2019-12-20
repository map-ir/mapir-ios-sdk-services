//
//  Geocoder.swift
//  MapirServices
//
//  Created by Alireza Asadi on 29/8/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

@objc(MSGeocoder)
class Geocoder: NSObject {

    /// Geocoder or ReverseGeocoder
    public typealias GeocodeCompletionHandler = ([Placemark]?, Error?) -> ()

    /// Current status of `Geocoder` object.
    public var isGeocoding: Bool {
        if let task = dataTask {
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

    private var dataTask: URLSessionDataTask?

    var completionHandler: GeocodeCompletionHandler?

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
    func reverseGeocode(_ location: CLLocation, completionHandler: @escaping GeocodeCompletionHandler) {
        guard AccountManager.shared.isAuthorized else {
            completionHandler(nil, MSError.invalidAPIKey)
            return
        }

        self.completionHandler = completionHandler

        let request = self.urlRequestForReverseGeocodingTask(location: location)

        self.dataTask = NetworkingManager.dataTask(with: request, completionHandler: networkCompletionHandler(data:response:error:))
        self.dataTask?.resume()
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
    func geocode(_ address: String, city: String? = nil, completionHandler: @escaping GeocodeCompletionHandler) {
        guard AccountManager.shared.isAuthorized else {
            completionHandler(nil, MSError.invalidAPIKey)
            return
        }

        self.completionHandler = completionHandler

        let request = self.urlRequestForGeocodeTask(string: address, city: city)

        self.dataTask = NetworkingManager.dataTask(with: request, completionHandler: networkCompletionHandler(data:response:error:))
        self.dataTask?.resume()
    }

    func networkCompletionHandler(data: Data?, response: URLResponse?, error: Error?) {
        guard let completionHandler = self.completionHandler else { return }

        if error != nil {
            completionHandler(nil, MSError.network)
            return
        }

        let response = response as! HTTPURLResponse
        guard let data = data else {
            completionHandler(nil, MSError.network)
            return
        }

        switch response.statusCode {
        case 200:
            do {
                let decodedBody = try JSONDecoder().decode(Placemark.ReverseGeocodeResponseScheme.self, from: data)
                let placemark = Placemark(fromReverseGeocodeResponse: decodedBody)
                completionHandler([placemark], error)
                return
            } catch {
                completionHandler(nil, error)
                return
            }
        case 300..<500:
            fallthrough
        case 500..<600:
            completionHandler(nil, MSError.network)
        default:
            fatalError("Unknown response status code.")
        }

    }

    /// Cancels the current running geocoding or reverseGeocoding task.
    @objc public func cancel() {
        dataTask?.cancel()
        if completionHandler != nil {
            networkCompletionHandler(data: nil, response: nil, error: MSError.geocodingCanceled)
        }

        dataTask = nil
    }
}

// MARK: Generatin URL Requests

extension Geocoder {
    func urlRequestForReverseGeocodingTask(location: CLLocation) -> URLRequest {
        var urlComponents = NetworkingManager.baseURLComponents
        let coordinate = location.coordinate
        let queryItems = ["lat": "\(coordinate.latitude)", "lon": "\(coordinate.longitude)"].convertedToURLQueryItems()

        urlComponents.queryItems = queryItems
        urlComponents.path = "reverse"

        let request = NetworkingManager.request(url: urlComponents)

        return request
    }

    func urlRequestForGeocodeTask(string: String, city: String?) -> URLRequest {
        var urlComponents = NetworkingManager.baseURLComponents
        var queryItems = ["text": string]
        if let city = city {
            queryItems["$filter"] = "city eq \(city)"
        }

        urlComponents.queryItems = queryItems.convertedToURLQueryItems()
        urlComponents.path = "search/v2"

        let request = NetworkingManager.request(url: urlComponents)

        return request
    }
}
