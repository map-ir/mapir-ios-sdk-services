//
//  Search.swift
//  MapirServices
//
//  Created by Alireza Asadi on 10/4/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import CoreLocation
import Foundation

/// Customizable search using Map.ir searching services.
@objc(Search)
public class Search: NSObject {

    /// Completion handler type of searching.
    public typealias SearchCompletionHandler = (_ results: [Search.Result]?, _ error: Swift.Error?) -> Void

    /// Current configuration for search.
    ///
    /// Default is set to `Configuration.empty`.
    public var configuration: Search.Configuration = .empty

    private var activeTask: URLSessionDataTask?

    /// Searches for the specified text, using current configuration.
    ///
    /// - Parameters:
    ///   - text: A `String` to search for it.
    ///   - completionHandler: A handler block to run once the search is finished.
    @objc(searchForText:completionHanlder:)
    public func search(for text: String,
                       completionHandler: @escaping SearchCompletionHandler) {

        search(for: text, configuration: configuration, completionHandler: completionHandler)
    }

    /// Searches for the specified text, using the provided configuration.
    ///
    /// - Parameters:
    ///   - text: A `String` to search for it.
    ///   - configuration: Configuration of the search. Contains categories, filter and center of the search.
    ///   - completionHandler: A handler block to run once the search is finished.
    @objc(searchForText:withConfiguration:completionHandler:)
    public func search(for text: String,
                       configuration: Search.Configuration,
                       completionHandler: @escaping SearchCompletionHandler) {

        cancel()
        self.configuration = configuration

        perform(.search(text, configuration),
                completionHandler: completionHandler,
                decoder: deocdeSearchResults(from:))
    }

    /// Searches for completion suggestions for the input text, using current configuration.
    ///
    /// - Parameters:
    ///   - text: A `String` to find completion suggestions for it.
    ///   - completionHandler: A handler block to run once the searching for suggenstions is finished.
    @objc(suggestionForText:completionHandler:)
    public func suggestions(for text: String,
                            completionHandler: @escaping SearchCompletionHandler) {

        suggestions(for: text, configuration: configuration, completionHandler: completionHandler)
    }

    /// Searches for completion suggestions for the input text considering the provided configuration.
    ///
    /// - Parameters:
    ///   - text: A `String` to find completion suggestions for it.
    ///   - configuration: Configuration of the search. Contains categories, filter and center of the search.
    ///   - completionHandler: A handler block to run once the searching for suggenstions is finished.
    @objc(suggestionForText:withConfiguration:completionHandler:)
    public func suggestions(for text: String,
                            configuration: Configuration,
                            completionHandler: @escaping SearchCompletionHandler) {

        cancel()
        self.configuration = configuration

        perform(.suggestion(text, configuration),
                completionHandler: completionHandler,
                decoder: deocdeSearchResults(from:))
    }

    /// Cancels the current running task.
    public func cancel() {
        activeTask?.cancel()
        activeTask = nil
    }
}

// MARK: Errors

extension Search {

    /// Errors related to search.
    @objc(SearchError)
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

extension Search {
    enum Task {
        case search(String, Configuration)
        case suggestion(String, Configuration)
    }

    func perform(_ task: Task,
                 completionHandler: @escaping SearchCompletionHandler,
                 decoder: @escaping (Data) -> [Search.Result]?) {

        guard AccountManager.isAuthorized else {
            completionHandler(nil, Error.unauthorized)
            return
        }

        var request: URLRequest
        switch task {
        case let .search(text, configuration):
            request = urlRequestForSearch(text: text, configuration: configuration)
        case let .suggestion(text, configuration):
            request = urlRequestForSearch(text: text, configuration: configuration)
        }

        activeTask = NetworkingManager.dataTask(with: request) { (data, response, error) in
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
                    if let data = data, let results = decoder(data) {
                        completionHandler(results, nil)
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

// MARK: Decoder

extension Search {
    func deocdeSearchResults(from data: Data) -> [Search.Result]? {
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode(Search.Result.SearchResponseScheme.self, from: data) {
            return decoded.value.map { Search.Result(from: $0) }
        }
        return nil
    }
}

// MARK: Generating URLRequest

extension Search {
    func urlRequestForSearch(text: String, configuration: Search.Configuration) -> URLRequest {
        var urlComponents = NetworkingManager.baseURLComponents

        urlComponents.queryItems = queryItems(for: configuration)
        urlComponents.path = "/search/v2"

        let request = NetworkingManager.request(url: urlComponents)

        return request
    }

    func urlRequestForSuggestion(text: String, configuration: Search.Configuration) -> URLRequest {
        var urlComponents = NetworkingManager.baseURLComponents

        urlComponents.queryItems = queryItems(for: configuration)
        urlComponents.path = "/search/v2/autocomplete"

        let request = NetworkingManager.request(url: urlComponents)

        return request
    }

    func queryItems(for configuration: Search.Configuration) -> [URLQueryItem] {
        var query: [String: String] = [:]

        if let center = configuration.center {
            configuration.categories?.insert(.nearby)

            query["lat"] = String(center.latitude)
            query["lon"] = String(center.longitude)
        }

        if let filter = configuration.filter {
            query["$filter"] = filter.urlRepresentation
        }

        if let categories = configuration.categories, !categories.isEmpty {
            query["$select"] = categories.urlRepresentation()
        }

        return URLQueryItem.queryItems(from: query)
    }
}