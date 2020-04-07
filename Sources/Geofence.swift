//
//  Geofence.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 24/12/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

@objc public final class Geofence: NSObject {

    public typealias CreationCompletionHandler = (_ fence: Fence?, _ error: Swift.Error?) -> Void
    public typealias DeletionCompletionHandler = (_ fence: Fence?, _ error: Swift.Error?) -> Void
    public typealias FenceBatchLoadingCompletionHandler = (_ fences: [Fence]?, _ error: Swift.Error?) -> Void
    public typealias FenceLoadingCompletionHandler = (_ fences: Fence?, _ error: Swift.Error?) -> Void

    public static var fences: Set<Fence> = []

    var loadingTask: URLSessionDataTask?

    /// Loads geofences associated with the API key, from Map.ir.
    ///
    /// - Parameters:
    ///   - count: Number of fences to load.
    ///   - skipCount: Number of fences to skip. latest uploaded fances come first.
    ///   - completionHandler: A block to run once the result is available.
    @objc(loadFencesCount:skippingCount:completionHandler:)
    public func loadFences(
        count: UInt,
        skipping skipCount: UInt,
        completionHandler: @escaping FenceBatchLoadingCompletionHandler
    ) {
        // swiftlint:disable:next empty_count
        let count = count > 0 ? count : 1
        let range = Int(skipCount)...Int(skipCount + count - 1)
        loadFences(inRange: range, completionHandler: completionHandler)
    }

    /// Loads geofences associated with the API key, from Map.ir.
    ///
    /// - Parameters:
    ///   - range: Range of the fence indexes to load.
    ///   - completionHandler: A block to run once the result is available.
    public func loadFences(
        inRange range: ClosedRange<Int>,
        completionHandler: @escaping FenceBatchLoadingCompletionHandler
    ) {
        loadingTask?.cancel()
        guard AccountManager.isAuthorized else {
            completionHandler(nil, Error.unauthorized)
            return
        }

        let request = urlRequestForBatchLoadingFences(range: range)

        loadingTask = NetworkingManager.dataTask(with: request) { [weak self] (data, response, error) in
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
                    if let data = data, let fences = self?.decodeBatchLoadingResult(from: data) {
                        fences.forEach { Geofence.fences.update(with: $0) }
                        completionHandler(fences, nil)
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

        loadingTask?.resume()
    }

    @objc(loadFenceWithID:completionHandler:)
    public func loadFence(
        withID id: Int,
        completionHandler: @escaping FenceLoadingCompletionHandler
    ) {
        loadingTask?.cancel()
        guard AccountManager.isAuthorized else {
            completionHandler(nil, Error.unauthorized)
            return
        }

        let request = urlRequestForLoadingFence(id: id)

        loadingTask = NetworkingManager.dataTask(with: request) { [weak self] (data, response, error) in
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
                    if let data = data, let fence = self?.decodeLoadingResult(from: data) {
                        Geofence.fences.update(with: fence)
                        completionHandler(fence, nil)
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

        loadingTask?.resume()

    }

    @objc(createFenceWithBoundaries:completionHandler:)
    public func createFence(
        withBoundaries boundaries: [Polygon],
        completionHandler: @escaping CreationCompletionHandler
    ) {

    }

    var deleteTask: URLSessionDataTask?

    @objc(deleteFence:completionHandler:)
    public func deleteFence(
        _ fence: Fence,
        completionHandler: @escaping DeletionCompletionHandler
    ) {
        deleteFence(withID: fence.id, completionHandler: completionHandler)
    }

    @objc(deleteFenceWithID:completionHandler:)
    public func deleteFence(
        withID id: Int,
        completionHandler: @escaping DeletionCompletionHandler
    ) {
        loadingTask?.cancel()
        guard AccountManager.isAuthorized else {
            completionHandler(nil, Error.unauthorized)
            return
        }

        let request = urlRequestForLoadingFence(id: id)

        loadingTask = NetworkingManager.dataTask(with: request) { [weak self] (data, response, error) in
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
                    if let data = data, let fence = self?.decodeLoadingResult(from: data) {
                        Geofence.fences.update(with: fence)
                        completionHandler(fence, nil)
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

        loadingTask?.resume()
    }
}

extension Geofence {

    /// Errors related to geofence.
    @objc(GeofenceError)
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

extension Geofence {
    func urlRequestForBatchLoadingFences(range: ClosedRange<Int>) -> URLRequest {
        var urlComponents = NetworkingManager.baseURLComponents

        var query: [String: String] = [:]
        query["$skip"] = range.lowerBound > 0 ? String(range.lowerBound) : "0"

        let numberOfItems: Int
        if range.lowerBound >= 0 && range.upperBound >= 0 {
            numberOfItems = range.upperBound - range.lowerBound + 1
        } else if range.lowerBound < 0 && range.upperBound > 0 {
            numberOfItems = range.upperBound + 1
        } else {
            numberOfItems = 0
        }
        query["$top"] = String(numberOfItems)

        urlComponents.queryItems = URLQueryItem.queryItems(from: query)
        urlComponents.path = "/geofence/stages"

        let request = NetworkingManager.request(url: urlComponents)
        return request
    }

    func urlRequestForLoadingFence(id: Int) -> URLRequest {
        var urlComponents = NetworkingManager.baseURLComponents

        urlComponents.path = "/geofence/stages/\(id)"

        let request = NetworkingManager.request(url: urlComponents)
        return request
    }

    func urlRequestForDeletingFence(id: Int) -> URLRequest {
        var urlComponents = NetworkingManager.baseURLComponents

        urlComponents.path = "/geofence/stages/\(id)"

        let request = NetworkingManager.request(url: urlComponents, httpMethod: .delete)
        return request
    }

}

extension Geofence {
    func decodeBatchLoadingResult(from data: Data) -> [Fence]? {

        struct GeofenceBatchLoadingResponseScheme: Decodable {
            var count: Int
            var value: [Fence.ResponseScheme]

            enum CodingKeys: String, CodingKey {
                case count = "odata.count"
                case value
            }
        }
        
        let decoder = JSONDecoder()
        if let decodedData = try? decoder.decode(GeofenceBatchLoadingResponseScheme.self, from: data) {
            let fences = decodedData.value.map { Fence(from: $0) }
            return fences
        } else {
            return nil
        }
    }

    func decodeLoadingResult(from data: Data) -> Fence? {

        struct GeofenceLoadingResponseScheme: Decodable {
            var data: Fence.ResponseScheme
        }

        let decoder = JSONDecoder()
        if let decodedData = try? decoder.decode(GeofenceLoadingResponseScheme.self, from: data) {
            let fence = Fence(from: decodedData.data)
            return fence
        } else {
            return nil
        }
    }

    func decodeDeletingResult(from data: Data) -> Fence? {

        struct GeofenceDeletingResponseScheme: Decodable {
            var data: Fence.ResponseScheme
            var message: String
        }

        let decoder = JSONDecoder()
        if let decodedData = try? decoder.decode(GeofenceDeletingResponseScheme.self, from: data) {
            let fence = Fence(from: decodedData.data)
            return fence
        } else {
            return nil
        }
    }
}
