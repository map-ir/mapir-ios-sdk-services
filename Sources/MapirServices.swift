//
//  MapirServices.swift
//  MapirServices
//
//  Created by Alireza Asadi on 31 Ordibehesht, 1398 AP.
//  Copyright © 1398 Map. All rights reserved.
//

// Include Foundation
@_exported import Foundation
import CoreLocation

#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

public final class MapirServices {

    /// Map.ir API endpoints.
    private struct Endpoint {
        static let reverseGeocode = "/reverse"
        static let fastReverseGeocode = "/fast-reverse"
        static let distanceMatrix = "/distancematrix"
        static let search = "/search"
        static let autocomleteSearch = "/search/autocomplete"
        static func route(forMode mode: MPSRoute.Mode) -> String {
            return "/routes/\(mode.rawValue)/v1/driving"
        }
        static let staticMap = "/static"

    }

    /// Singleton object of MPSMapirServices
    public private(set) static var shared = MapirServices()
    
    internal let host: String = "map.ir"
    
    public static var accessToken: String?

    internal var session: URLSession!

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private let dispatchQueue = DispatchQueue(label: "ir.map.services",
                                              qos: .default,
                                              attributes: .concurrent,
                                              autoreleaseFrequency: .inherit,
                                              target: nil)
    
    private init() {
        session = .shared
        if MapirServices.accessToken == nil {
            if let token = Bundle.main.object(forInfoDictionaryKey: "MAPIRAccessToken") as? String {
                MapirServices.accessToken = token
            }
        }

    }

    private let userAgent: String = {
        var components: [String] = []

        if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            components.append("\(appName)/\(version)")
        }

        let libraryBundle: Bundle? = Bundle(for: MapirServices.self)

        if let libraryName = libraryBundle?.infoDictionary?["CFBundleName"] as? String, let version = libraryBundle?.infoDictionary?["CFBundleShortVersionString"] as? String {
            components.append("\(libraryName)/\(version)")
        }

        let system: String
        #if os(OSX)
            system = "macOS"
        #elseif os(iOS)
            system = "iOS"
        #elseif os(watchOS)
            system = "watchOS"
        #elseif os(tvOS)
            system = "tvOS"
        #endif
        let systemVersion = ProcessInfo().operatingSystemVersion
        components.append("\(system)/\(systemVersion.majorVersion).\(systemVersion.minorVersion).\(systemVersion.patchVersion)")

        let chip: String
        #if arch(x86_64)
            chip = "x86_64"
        #elseif arch(arm)
            chip = "arm"
        #elseif arch(arm64)
            chip = "arm64"
        #elseif arch(i386)
            chip = "i386"
        #endif
        components.append("(\(chip))")

        return components.joined(separator: " ")
    }()

    private func urlRequest(withPath path: String,
                            queryItems: [URLQueryItem]?,
                            httpMethod: String) throws -> URLRequest {

        var urlComponents = URLComponents()
        urlComponents.scheme     = "https"
        urlComponents.host       = self.host
        urlComponents.path       = path
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            throw MPSError.urlEncodingError
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        request.httpMethod = httpMethod

        if let token = MapirServices.accessToken {
            request.addValue(token, forHTTPHeaderField: "x-api-key")
        } else {
            throw MPSError.ServiceError.invalidAccessToken
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(self.userAgent, forHTTPHeaderField: "User-Agent")

        return request
    }
}

// MARK: - Reverse Geocode

extension MapirServices {

    func urlRequestForReverseGeocode(coordinate: CLLocationCoordinate2D) throws -> URLRequest {
        let queryItems = [URLQueryItem(name: "lat", value: "\(coordinate.latitude)"),
                          URLQueryItem(name: "lon", value: "\(coordinate.longitude)")]

        let request = try urlRequest(withPath: Endpoint.reverseGeocode, queryItems: queryItems, httpMethod: HTTPMethod.get)

        return request
    }

    /// Generates address of a location coordinate.
    ///
    /// - Parameter coordinate: The input coordinates to find address for it.
    /// - Parameter completionHandler: the completion handler to call when result is received or an error occurs.
    /// - Parameter result: a `Result` of types `MPSReverseGeocode` if execution succeeds and `Error` if it fails.
    ///
    ///
    /// This methods calls APIs to find address of a location based on its coordinates.
    /// `completionHandler` gets called whenever execution finishes with success or error.
    public func reverseGeocode(for coordinate: CLLocationCoordinate2D,
                               completionHandler: @escaping (_ result: Result<MPSReverseGeocode, Error>) -> Void) {

        let request: URLRequest
        do {
            request = try urlRequestForReverseGeocode(coordinate: coordinate)
        } catch let requestError {
            completionHandler(.failure(requestError))
            return
        }

        let dataTask = session.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                DispatchQueue.main.async { completionHandler(.failure(error)) }
                return
            }
            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                completionHandler(.failure(MPSError.ResponseError.invalidResponse))
                return
            }

            switch urlResponse.statusCode {
            case 200:
                if let data = data {
                    do {
                        let decodedData = try self.decoder.decode(MPSReverseGeocode.self, from: data)
                        DispatchQueue.main.async { completionHandler(.success(decodedData)) }
                        return
                    } catch let parseError {
                        DispatchQueue.main.async { completionHandler(.failure(parseError)) }
                        return
                    }
                }
            case 400:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.badRequest)) }
            case 404:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.notFound)) }
            default:
                return
            }
        }

        dataTask.resume()
    }
}

// MARK: - Fast Reverse Geocode

extension MapirServices {
    func urlRequestForFastReverseGeocode(coordinate: CLLocationCoordinate2D) throws -> URLRequest {
        let queryItems = [URLQueryItem(name: "lat", value: "\(coordinate.latitude)"),
                          URLQueryItem(name: "lon", value: "\(coordinate.longitude)")]

        let request = try urlRequest(withPath: Endpoint.reverseGeocode,
                                     queryItems: queryItems,
                                     httpMethod: HTTPMethod.get)
        return request
    }

    /// generates address of a location. It's faster than normal `reverseGeocode` method.
    ///
    /// - Parameter point: the coordinate of the location.
    /// - Parameter completionHandler: Closure which is called when execution finishes either successfull or with error.
    /// - Parameter result: a `Result` of types `MPSReverseGeocode` if execution succeeds and `Error` if it fails.
    ///
    /// this method is a faster way to access to the address of a location. result will be available about 50ms faster than usual with this method.
    public func fastReverseGeocode(for coordinate: CLLocationCoordinate2D,
                                   completionHandler: @escaping (_ result: Result<MPSReverseGeocode, Error>) -> Void) {

        let request: URLRequest
        do {
            request = try urlRequestForReverseGeocode(coordinate: coordinate)
        } catch let requestError {
            completionHandler(.failure(requestError))
            return
        }

        let dataTask = session.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                DispatchQueue.main.async { completionHandler(.failure(error)) }
                return
            }

            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                completionHandler(.failure(MPSError.ResponseError.invalidResponse))
                return
            }

            switch urlResponse.statusCode {
            case 200:
                if let data = data {
                    do {
                        let decodedData = try self.decoder.decode(MPSReverseGeocode.self, from: data)
                        DispatchQueue.main.async { completionHandler(.success(decodedData)) }
                        return
                    } catch let parseError {
                        DispatchQueue.main.async { completionHandler(.failure(parseError)) }
                        return
                    }
                }
            case 400:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.badRequest)) }
                return
            case 404:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.notFound)) }
                return
            default:
                return
            }
        }

        dataTask.resume()

    }
}

// MARK: - Distance Matrix

extension MapirServices {
    func urlRequestForDistanceMatrix(origins: [(name: String, coordinate: CLLocationCoordinate2D)],
                                     destinations: [(name: String, coordinate: CLLocationCoordinate2D)],
                                     options: MPSDistanceMatrix.Options) throws -> URLRequest {

        var queryItems: [URLQueryItem] = []
        let originsValue = origins
            .map { ["\($0.name)", "\($0.coordinate.latitude)", "\($0.coordinate.longitude)"].joined(separator: ",") }
            .joined(separator: "|")

        queryItems.append(URLQueryItem(name: "origins", value: originsValue))

        let destinationsValue = destinations
            .map { ["\($0.name)", "\($0.coordinate.latitude)", "\($0.coordinate.longitude)"].joined(separator: ",") }
            .joined(separator: "|")

        queryItems.append(URLQueryItem(name: "destinations", value: destinationsValue))

        if options.contains(.sorted) {
            queryItems.append(URLQueryItem(name: "sorted", value: "true"))
        }

        if !(options.contains(.distance) && options.contains(.duration)) {
            if options.contains(.distance) {
                queryItems.append(URLQueryItem(name: "$filter", value: "type eq distance"))

            }
            if options.contains(.duration) {
                queryItems.append(URLQueryItem(name: "$filter", value: "type eq duration"))
            }
        }

        let request = try urlRequest(withPath: Endpoint.distanceMatrix, queryItems: queryItems, httpMethod: HTTPMethod.get)
        return request
    }

    func argumentCheck(origins: [(name: String, coordinate: CLLocationCoordinate2D)],
                       destinations: [(name: String, coordinate: CLLocationCoordinate2D)]) throws {

        var notAllowedCharacters = CharacterSet.alphanumerics.inverted
        notAllowedCharacters.insert(charactersIn: "_")

        let originNames = try origins.map { (origin) -> String in
            let name = origin.name
            if name.isEmpty { throw DistanceMatrixError.emptyName }
            let chars = CharacterSet(charactersIn: name).intersection(notAllowedCharacters)
            if !chars.isEmpty {
                throw DistanceMatrixError.invalidCharacterInName(name)
            }
            return name
        }

        let originDuplicates = originNames.duplicates()
        if !originDuplicates.isEmpty {
            throw DistanceMatrixError.duplicateCoordinateName(originDuplicates)
        }

        let destinationNames = try destinations.map { (destination) -> String in
            let name = destination.name
            if name.isEmpty { throw DistanceMatrixError.emptyName }
            let chars = CharacterSet(charactersIn: name).intersection(notAllowedCharacters)
            if !chars.isEmpty {
                throw DistanceMatrixError.invalidCharacterInName(name)
            }
            return name
        }

        let destinationDuplicates = destinationNames.duplicates()
        if !destinationDuplicates.isEmpty {
            throw DistanceMatrixError.duplicateCoordinateName(destinationDuplicates)
        }
    }

    /// Generates a matrix of distance and duration between origins and destinations.
    ///
    /// - Parameter origins: Coordinates of origin.
    /// - Parameter destinations: Coordinates of destinations.
    /// - Parameter options: Options of matrix calculation. By default it's `nil`.
    /// - Parameter result: a `Result` of types `MPSDistanceMatrix` if execution succeeds and `Error` if it fails.
    ///
    /// This method is used to find distance and duration between some origins and destinations. The result durations are in seconds and distances are in meters.
    /// It's important to know that the result is calculated with consideration of traffic and land routes.
    public func distanceMatrix(from origins: [(name: String, coordinate: CLLocationCoordinate2D)],
                               to destinations: [(name: String, coordinate: CLLocationCoordinate2D)],
                               options: MPSDistanceMatrix.Options = [],
                               completionHandler: @escaping (_ result: Result<MPSDistanceMatrix, Error>) -> Void) {

        dispatchQueue.async {
            do {
                try self.argumentCheck(origins: origins, destinations: destinations)
            } catch let argumentError {
                DispatchQueue.main.async { completionHandler(.failure(argumentError)) }
            }

            let request: URLRequest
            do {
                request = try self.urlRequestForDistanceMatrix(origins: origins, destinations: destinations, options: options)
            } catch let requestError {
                DispatchQueue.main.async { completionHandler(.failure(requestError)) }
                return
            }

            let dataTask = self.session.dataTask(with: request) { (data, urlResponse, error) in
                if let error = error {
                    DispatchQueue.main.async { completionHandler(.failure(error)) }
                    return
                }

                guard let urlResponse = urlResponse as? HTTPURLResponse else {
                    DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.invalidResponse)) }
                    return
                }

                let statusCode = urlResponse.statusCode

                switch statusCode {
                case 200:
                    if let data = data {
                        do {
                            let decodedData = try self.decoder.decode(MPSDistanceMatrix.self, from: data)
                            DispatchQueue.main.async { completionHandler(.success(decodedData)) }
                            return
                        } catch let parseError {
                            DispatchQueue.main.async { completionHandler(.failure(parseError)) }
                        }
                    }
                case 400:
                    DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.badRequest)) }
                    return
                case 404:
                    DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.notFound)) }
                    return
                default:
                    return
                }
            }
            dataTask.resume()
        }
    }
}

// MARK: - Search

extension MapirServices {

    /// Searching around a location about a specific place.
    ///
    /// - Parameter text: the name or any data about the place.
    /// - Parameter location: center of search.
    /// - Parameter categories: type of places, e.g. Road, POI, city, etc. more selected options will result in more accurte search.
    /// - Parameter filter: filters of search. e.g. places with distance less that specified meters.
    /// - Parameter result: a `Result` of types array of `MPSSearchResult`s if execution succeeds and `Error` if it fails.
    ///
    /// Search will result in different kind of places. Text can even be an address which will result in a geocode result.
    /// Using more accurate filters and options will result in more accurate results. Number of results will not be more than 16 results.
    public func search(for text: String,
                       around coordinate: CLLocationCoordinate2D,
                       categories: MPSSearch.Categories = [],
                       filter: MPSSearch.Filter? = nil,
                       completionHandler: @escaping (_ result: Result<MPSSearch, Error>) -> Void) {

        var request: URLRequest
        do {
            request = try urlRequest(withPath: Endpoint.search,
                                     queryItems: nil,
                                     httpMethod: HTTPMethod.post)
        } catch let requestError {
            completionHandler(.failure(requestError))
            return
        }

        var search = MPSSearch(text: text,
                               categories: categories,
                               filter: filter,
                               coordinates: coordinate)

        do {
            let httpBody = try encoder.encode(search)
            request.httpBody = httpBody
        } catch let encoderError {
            completionHandler(.failure(encoderError))
            return
        }

        let dataTask = session.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error { DispatchQueue.main.async { completionHandler(.failure(error)) } }

            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.invalidResponse)) }
                return
            }

            switch urlResponse.statusCode {
            case 200:
                if let data = data {
                    do {
                        let decodedData = try self.decoder.decode(MPSSearch.self, from: data)
                        let searchResults = decodedData.results
                        search.results = searchResults
                        DispatchQueue.main.async { completionHandler(.success(search)) }
                        return
                    } catch let parseError {
                        DispatchQueue.main.async { completionHandler(.failure(parseError)) }
                        return
                    }
                }
            case 400:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.badRequest)) }
                return
            case 404:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.notFound)) }
                return
            default:
                return
            }
        }

        dataTask.resume()
    }
}

// MARK: - Autocomplete

extension MapirServices {
    /// Autocompletes for text around a location.
    /// - Parameter text: Input text.
    /// - Parameter location: Center of autocomplete search
    /// - Parameter categories: type of places, e.g. Road, POI, city, etc. more selected options will result in more accurte search.
    /// - Parameter filter: filters of search. e.g. places with distance less that specified meters.
    /// - Parameter result: a `Result` of types array of `MPSAutocompleteResult`s if execution succeeds and `Error` if it fails.
    ///
    /// Using more accurate filters and options will result in more accurate results. Number of results will not be more than 16 results.
    public func autocomplete(for text: String,
                             around coordinate: CLLocationCoordinate2D,
                             categories: MPSSearch.Categories = [],
                             filter: MPSSearch.Filter? = nil,
                             completionHandler: @escaping (_ result: Result<MPSSearch, Error>) -> Void) {

        var request: URLRequest
        do {
            request = try urlRequest(withPath: Endpoint.autocomleteSearch,
                                     queryItems: nil,
                                     httpMethod: HTTPMethod.post)
        } catch let requestError {
            completionHandler(.failure(requestError))
            return
        }

        var autocomplete = MPSSearch(text: text,
                                               categories: categories,
                                               filter: filter,
                                               coordinates: coordinate)

        do {
            let httpBody = try encoder.encode(autocomplete)
            request.httpBody = httpBody
        } catch let encoderError {
            completionHandler(.failure(encoderError))
            return
        }

        let dataTask = session.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error { DispatchQueue.main.async { completionHandler(.failure(error)) } }

            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.invalidResponse)) }
                return
            }

            switch urlResponse.statusCode {
            case 200:
                if let data = data {
                    do {
                        let decodedData = try self.decoder.decode(MPSSearch.self, from: data)
                        let autocompleteResult = decodedData.results
                        autocomplete.results = autocompleteResult
                        DispatchQueue.main.async { completionHandler(.success(autocomplete)) }
                        return
                    } catch let parseError {
                        DispatchQueue.main.async { completionHandler(.failure(parseError)) }
                        return
                    }
                }
            case 400:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.badRequest)) }
                return
            case 404:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.notFound)) }
                return
            default:
                return
            }
        }

        dataTask.resume()
    }
}

// MARK: - Route

extension MapirServices {
    func urlRequestForRoute(origin: CLLocationCoordinate2D,
                            destinations: [CLLocationCoordinate2D],
                            mode: MPSRoute.Mode,
                            options: MPSRoute.Options) throws -> URLRequest {

        var path = Endpoint.route(forMode: mode) + "/"
        path += "\(origin.longitude),\(origin.latitude);"

        for dest in destinations {
            path += "\(dest.longitude),\(dest.latitude);"
        }
        path.removeLast()

        var queryItems = [URLQueryItem(name: "steps", value: "true")]

        if options.contains(.calculateAlternatives) {
            queryItems.append(URLQueryItem(name: "alternatives", value: "true"))
        }

        if options.contains(.steps) {
            queryItems.append(URLQueryItem(name: "steps", value: "true"))
        }

        if options.contains(.fullOverview) {
            queryItems.append(URLQueryItem(name: "overview", value: "full"))
        } else if options.contains(.simplifiedOverview) {
            queryItems.append(URLQueryItem(name: "overview", value: "simplified"))
        } else if options.contains(.noOverview) {
            queryItems.append(URLQueryItem(name: "overview", value: "false"))
        }

        let request = try urlRequest(withPath: path, queryItems: queryItems, httpMethod: HTTPMethod.get)
        return request
    }

    /// Calculates routes from an origin to one or more destinations.
    ///
    /// - Parameter origin: origin point.
    /// - Parameter destinations: coordinates of destinations. may be one or more destination in order.
    /// - Parameter routeType: type of route. e.g. bicycle.
    /// - Parameter routeOptions: options of routing.
    /// - Parameter result: a `Result` of types `MPSRouteResult` if execution succeeds and `Error` if it fails.
    ///
    /// Route method is used to find paths between one ore more places. This method considers traffic for finding path for some of route types.
    /// OSRM is used for route calculation. for more information use
    /// [OSRM documentation](http://project-osrm.org/docs/v5.22.0/api/?language=Swift#general-options).
    public func route(from origin: CLLocationCoordinate2D,
                      to destinations: [CLLocationCoordinate2D],
                      mode: MPSRoute.Mode,
                      options: MPSRoute.Options = [],
                      completionHandler: @escaping (_ result: Result<([MPSWaypoint], [MPSRoute]), Error>) -> Void) {

        guard !destinations.isEmpty else {
            completionHandler(.failure(MPSError.RequestError.invalidArgument))
            return
        }

        let request: URLRequest
        do {
            request = try urlRequestForRoute(origin: origin, destinations: destinations, mode: mode, options: options)
        } catch let requestError {
            completionHandler(.failure(requestError))
            return
        }

        

        let dataTask = session.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                DispatchQueue.main.async { completionHandler(.failure(error)) }
            }

            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.invalidResponse)) }
                return
            }

            switch urlResponse.statusCode {
            case 200:
                if let data = data {
                    do {
                        let decodedData = try self.decoder.decode(MPSRouteResult.self, from: data)
                        DispatchQueue.main.async {
                            completionHandler(.success(
                                (decodedData.waypoints, decodedData.routes)
                            ))
                        }
                    } catch let decoderError {
                        DispatchQueue.main.async { completionHandler(.failure(decoderError)) }
                        return
                    }
                }
            case 400:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.badRequest)) }
                return
            case 404:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.notFound)) }
                return
            default:
                return
            }
        }

        dataTask.resume()
    }
}

// MARK: - Static Map

extension MapirServices {
    func urlRequestForStaticMap(center: CLLocationCoordinate2D, size: CGSize, zoomLevel: Int, markers: [MPSStaticMapMarker]) throws -> URLRequest {
        var queryItems = [URLQueryItem(name: "width",       value: "\(Int(size.width))"),
                          URLQueryItem(name: "height",      value: "\(Int(size.height))"),
                          URLQueryItem(name: "zoom_level",  value: "\(zoomLevel))")]

        if !markers.isEmpty {
            for marker in markers {
                let value = "color:\(marker.style.rawValue)|label:\(marker.label)|\(marker.coordinate.longitude),\(marker.coordinate.latitude)"
                queryItems.append(URLQueryItem(name: "markers", value: value))
            }
        }

        let request = try urlRequest(withPath: Endpoint.staticMap, queryItems: queryItems, httpMethod: HTTPMethod.get)
        return request
    }

    #if os(iOS) || os(watchOS) || os(tvOS)
    /// Generates static map of an area of the map.
    ///
    /// - Parameter center: Center point of the map.
    /// - Parameter size: size of the image. in pixels.
    /// - Parameter zoomLevel: Zoom level of the map.
    /// - Parameter markers: List of markers which is needed on the map.
    /// - Parameter result: a `Result` of types `UIImage` if execution succeeds and `Error` if it fails.
    public func staticMap(center: CLLocationCoordinate2D,
                          size: CGSize,
                          zoomLevel: Int,
                          markers: [MPSStaticMapMarker] = [],
                          completionHandler: @escaping (_ result: Result<UIImage, Error>) -> Void) {

        let request: URLRequest
        do {
            request = try urlRequestForStaticMap(center: center, size: size, zoomLevel: zoomLevel, markers: markers)
        } catch let requestError {
            completionHandler(.failure(requestError))
            return
        }

        let dataTask = session.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                DispatchQueue.main.async { completionHandler(.failure(error)) }
                return
            }

            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.invalidResponse)) }
                return
            }

            switch urlResponse.statusCode {
            case 200:
                if let data = data {
                    if let decodedImage = UIImage(data: data) {
                        DispatchQueue.main.async { completionHandler(.success(decodedImage)) }
                        return
                    } else {
                        DispatchQueue.main.async { completionHandler(.failure(MPSError.imageDecodingError)) }
                    }
                }
            case 400:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.badRequest)) }
                return
            case 404:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.notFound)) }
                return
            default:
                return
            }
        }

        dataTask.resume()
    }

    #elseif os(macOS)
    /// Generates static map of an area of the map.
    ///
    /// - Parameter center: Center point of the map.
    /// - Parameter size: size of the image. in pixels.
    /// - Parameter zoomLevel: Zoom level of the map.
    /// - Parameter markers: List of markers which is needed on the map.
    /// - Parameter result: a `Result` of types `NSImage` if execution succeeds and `Error` if it fails.
    public func staticMap(center: CLLocationCoordinate2D,
                          size: CGSize,
                          zoomLevel: Int,
                          markers: [MPSStaticMapMarker] = [],
                          completionHandler: @escaping (_ result: Result<NSImage, Error>) -> Void) {

        let request: URLRequest
        do {
            request = try urlRequestForStaticMap(center: center, size: size, zoomLevel: zoomLevel, markers: markers)
        } catch let requestError {
            completionHandler(.failure(requestError))
            return
        }

        let dataTask = session.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                DispatchQueue.main.async { completionHandler(.failure(error)) }
                return
            }

            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.invalidResponse)) }
                return
            }

            switch urlResponse.statusCode {
            case 200:
                if let data = data {
                    if let decodedImage = NSImage(data: data) {
                        DispatchQueue.main.async { completionHandler(.success(decodedImage)) }
                        return
                    } else {
                        DispatchQueue.main.async { completionHandler(.failure(MPSError.imageDecodingError)) }
                    }
                }
            case 400:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.badRequest)) }
                return
            case 404:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.ResponseError.notFound)) }
                return
            default:
                return
            }
        }

        dataTask.resume()
    }
    #endif
}
