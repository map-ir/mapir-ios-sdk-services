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
import UIKit

public class MPSMapirServices {

    private struct Endpoint {
        static let reverseGeocode = "/reverse"
        static let fastReverseGeocode = "/fast-reverse"
        static let distanceMatrix = "/distancematrix"
        static let search = "/search"
        static let autocomleteSearch = "/search/autocomplete"
        static func route(forType type: MPSRouteType) -> String {
            return "/routes/\(type.rawValue)/v1/driving"
        }
        static let staticMap = "/static"

    }

    public static let shared = MPSMapirServices()
    
    let baseURL: URL! = URL(string: "https://map.ir")
    
    private var token: String?

    private let session: URLSession = .shared

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private init() {
        let token = Bundle.main.object(forInfoDictionaryKey: "MAPIRAccessToken") as? String
        if let token = token {
            self.token = token
        } else {
            assertionFailure("API key not found in the info.plist file. consider adding it.")
        }
    }

    private func essentialRequest(withEndpoint endpoint: String, query: String?, httpMethod: String) -> URLRequest? {
        guard let url = URL(string: baseURL.absoluteString + endpoint + (query ?? "")) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        request.httpMethod = httpMethod
        if let token = token {
            request.addValue(token, forHTTPHeaderField: "x-api-key")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        return request
    }

    public func getReverseGeocode(for point: CLLocationCoordinate2D,
                                  completionHandler: @escaping (Result<MPSReverseGeocode, Error>) -> Void) {

        let query: String = "?lat=\(point.latitude)&lon=\(point.longitude)"
        guard let request = essentialRequest(withEndpoint: Endpoint.reverseGeocode, query: query, httpMethod: HTTPMethod.get) else {
            completionHandler(.failure(MPSError.RequestError.invalidArgument))
            return
        }

        let dataTask = session.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                DispatchQueue.main.async { completionHandler(.failure(error)) }
                return
            }
            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                completionHandler(.failure(MPSError.invalidResponse))
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
                DispatchQueue.main.async { completionHandler(.failure(MPSError.RequestError.badRequest(code: 400))) }
            case 404:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.RequestError.notFound)) }
            default:
                return
            }
        }

        dataTask.resume()
    }

    public func getFastReverseGeocode(for point: CLLocationCoordinate2D,
                                      completionHandler: @escaping (Result<MPSFastReverseGeocode, Error>) -> Void) {

        let query: String = "?lat=\(point.latitude)&lon=\(point.longitude)"
        guard let request = essentialRequest(withEndpoint: Endpoint.reverseGeocode,
                                             query: query,
                                             httpMethod: HTTPMethod.get) else {
            completionHandler(.failure(MPSError.RequestError.invalidArgument))
            return
        }

        session.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                DispatchQueue.main.async { completionHandler(.failure(error)) }
                return
            }

            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                completionHandler(.failure(MPSError.invalidResponse))
                return
            }

            switch urlResponse.statusCode {
            case 200:
                if let data = data {
                    do {
                        let decodedData = try self.decoder.decode(MPSFastReverseGeocode.self, from: data)
                        DispatchQueue.main.async { completionHandler(.success(decodedData)) }
                        return
                    } catch let parseError {
                        DispatchQueue.main.async { completionHandler(.failure(parseError)) }
                        return
                    }
                }
            case 400:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.RequestError.badRequest(code: 400))) }
                return
            case 404:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.RequestError.notFound)) }
                return
            default:
                return
            }
        }.resume()

    }

    public func getDistanceMatrix(from origins: [CLLocationCoordinate2D],
                                  to destinations: [CLLocationCoordinate2D],
                                  options: MPSDistanceMatrixOptions = [],
                                  completionHandler: @escaping (Result<MPSDistanceMatrix, Error>) -> Void) {

        var query: String = "?"
        query += "origins="
        for origin in origins {
            let uuid = UUID()
            let uuidString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
            query += "\(uuidString),\(origin.latitude),\(origin.longitude)|"
        }
        query.removeLast()
        
        query += "&destinations="
        for destination in destinations {
            let uuid = UUID()
            let uuidString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
            query += "\(uuidString),\(destination.latitude),\(destination.longitude)|"
        }
        query.removeLast()
        if options.contains(.sorted) {
            query += "&sorted=true"
        }
        if !(options.contains(.distance) && options.contains(.duration)) {
            if options.contains(.distance) {
                query += "&$filter=type eq distance"
            }
            if options.contains(.duration) {
                query += "&$filter=type eq duration"
            }
        }

        guard let urlEncodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completionHandler(.failure(MPSError.RequestError.invalidArgument))
            return
        }

        guard let request = essentialRequest(withEndpoint: Endpoint.distanceMatrix,
                                             query: urlEncodedQuery,
                                             httpMethod: HTTPMethod.get) else {
            completionHandler(.failure(MPSError.RequestError.invalidArgument))
            return
        }

        session.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                DispatchQueue.main.async { completionHandler(.failure(error)) }
                return
            }

            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                completionHandler(.failure(MPSError.invalidResponse))
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
                        completionHandler(.failure(parseError))
                    }
                }
            case 400:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.RequestError.badRequest(code: 400))) }
                return
            case 404:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.RequestError.notFound)) }
                return
            default:
                return
            }
        }.resume()
    }

    public func getSearchResult(for text: String,
                                around location: CLLocationCoordinate2D,
                                selectionOptions: MPSSearchOptions = [],
                                filter: MPSSearchFilter? = nil,
                                completionHandler: @escaping (Result<MPSSearch, Error>) -> Void) {

        guard var request = essentialRequest(withEndpoint: Endpoint.search,
                                             query: nil,
                                             httpMethod: HTTPMethod.post) else {
            completionHandler(.failure(MPSError.RequestError.invalidArgument))
            return
        }

        let searchBody = SearchInput(text: text,
                                     selectionOptions: selectionOptions,
                                     filter: filter,
                                     coordinates: location)

        do {
            let httpBody = try encoder.encode(searchBody)
            request.httpBody = httpBody
        } catch let encoderError {
            completionHandler(.failure(encoderError))
            return
        }

        session.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error { DispatchQueue.main.async { completionHandler(.failure(error)) } }

            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                DispatchQueue.main.async { completionHandler(.failure(MPSError.invalidResponse)) }
                return
            }

            switch urlResponse.statusCode {
            case 200:
                if let data = data {
                    do {
                        let decodedData = try self.decoder.decode(MPSSearch.self, from: data)
                        DispatchQueue.main.async { completionHandler(.success(decodedData)) }
                        return
                    } catch let parseError {
                        DispatchQueue.main.async { completionHandler(.failure(parseError)) }
                        return
                    }
                }
            case 400:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.RequestError.badRequest(code: 400))) }
                return
            case 404:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.RequestError.notFound)) }
                return
            default:
                return
            }
        }.resume()
    }

    public func getAutocompleteSearchResult(for text: String,
                                            around location: CLLocationCoordinate2D,
                                            selectionOptions: MPSSearchOptions = [],
                                            filter: MPSSearchFilter? = nil,
                                            completionHandler: @escaping (Result<MPSAutocompleteSearch, Error>) -> Void) {

        guard var request = essentialRequest(withEndpoint: Endpoint.autocomleteSearch,
                                             query: nil,
                                             httpMethod: HTTPMethod.post) else {

            completionHandler(.failure(MPSError.RequestError.invalidArgument))
            return
        }

        let autocompleteSearchBody = SearchInput(text: text,
                                                 selectionOptions: selectionOptions,
                                                 filter: filter,
                                                 coordinates: location)

        do {
            let httpBody = try encoder.encode(autocompleteSearchBody)
            request.httpBody = httpBody
        } catch let encoderError {
            completionHandler(.failure(encoderError))
            return
        }

        session.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error { DispatchQueue.main.async { completionHandler(.failure(error)) } }

            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                DispatchQueue.main.async { completionHandler(.failure(MPSError.invalidResponse)) }
                return
            }

            switch urlResponse.statusCode {
            case 200:
                if let data = data {
                    do {
                        let decodedData = try self.decoder.decode(MPSAutocompleteSearch.self, from: data)
                        DispatchQueue.main.async { completionHandler(.success(decodedData)) }
                        return
                    } catch let parseError {
                        DispatchQueue.main.async { completionHandler(.failure(parseError)) }
                        return
                    }
                }
            case 400:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.RequestError.badRequest(code: 400))) }
                return
            case 404:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.RequestError.notFound)) }
                return
            default:
                return
            }
        }.resume()
    }

    public func getRoute(from origin: CLLocationCoordinate2D,
                         to destinations: [CLLocationCoordinate2D],
                         routeType: MPSRouteType,
                         routeOptions: MPSRouteOptions = [],
                         completionHandler: @escaping (Result<MPSRouteObject, Error>) -> Void) {

        guard !destinations.isEmpty else {
            completionHandler(.failure(MPSError.RequestError.invalidArgument))
            return
        }

        var query = "/"
        query += "\(origin.longitude),\(origin.latitude);"

        for dest in destinations {
            query += "\(dest.longitude),\(dest.latitude);"
        }
        query.removeLast()
        query += "?steps=true"

        if routeOptions.contains(.calculateAlternatives) {
            query += "&alternatives=true"
        }
        if routeOptions.contains(.overview) {
            query += "&overview=true"
        }

        guard let urlEncodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completionHandler(.failure(MPSError.RequestError.invalidArgument))
            return
        }

        guard let request = essentialRequest(withEndpoint: Endpoint.route(forType: routeType),
                                             query: urlEncodedQuery,
                                             httpMethod: HTTPMethod.get) else {
                                                
            completionHandler(.failure(MPSError.RequestError.invalidArgument))
            return
        }

        session.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                DispatchQueue.main.async { completionHandler(.failure(error)) }
            }

            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                DispatchQueue.main.async { completionHandler(.failure(MPSError.invalidResponse)) }
                return
            }

            switch urlResponse.statusCode {
            case 200:
                if let data = data {
                    do {
                        let decodedData = try self.decoder.decode(MPSRouteObject.self, from: data)
                        DispatchQueue.main.async { completionHandler(.success(decodedData)) }
                    } catch let decoderError {
                        DispatchQueue.main.async { completionHandler(.failure(decoderError)) }
                        return
                    }
                }
            case 400:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.RequestError.badRequest(code: 400))) }
                return
            case 404:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.RequestError.notFound)) }
                return
            default:
                return
            }
        }.resume()
    }

    public func getStaticMap(center: CLLocationCoordinate2D,
                             size: CGSize,
                             zoomLevel: Int,
                             markers: [MPSStaticMapMarker] = [],
                             completionHandler: @escaping (Result<UIImage, Error>) -> Void) {

        guard !markers.isEmpty else {
            completionHandler(.failure(MPSError.RequestError.invalidArgument))
            return
        }

        var query = "?width=\(Int(size.width))&height=\(Int(size.height))&zoom_level=\(zoomLevel)"

        for marker in markers {
            query += "&markers=color:\(marker.style.rawValue)|label:\(marker.label)|\(marker.coordinate.longitude),\(marker.coordinate.latitude)"
        }

        guard let urlEncodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completionHandler(.failure(MPSError.urlEncodingError))
            return
        }

        guard let request = essentialRequest(withEndpoint: Endpoint.staticMap,
                                             query: urlEncodedQuery,
                                             httpMethod: HTTPMethod.get) else {
            completionHandler(.failure(MPSError.RequestError.invalidArgument))
            return
        }

        session.dataTask(with: request) { (data, urlResponse, error) in
            if let error = error {
                DispatchQueue.main.async { completionHandler(.failure(error)) }
                return
            }

            guard let urlResponse = urlResponse as? HTTPURLResponse else {
                DispatchQueue.main.async { completionHandler(.failure(MPSError.invalidResponse)) }
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
                DispatchQueue.main.async { completionHandler(.failure(MPSError.RequestError.badRequest(code: 400))) }
                return
            case 404:
                DispatchQueue.main.async { completionHandler(.failure(MPSError.RequestError.notFound)) }
                return
            default:
                return
            }
        }.resume()
    }
}
