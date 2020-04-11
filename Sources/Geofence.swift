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
    ///   - skipCount: Number of fences to skip. latest uploaded fences come first.
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

        let request = urlRequestForBatchLoadingFences(range: range)

        loadingTask = dataTask(
            with: request,
            decoderBlock: decodeBatchLoadingResult(from:)
        ) { (fences, error) in
            guard let fences = fences, error == nil else {
                completionHandler(nil, error)
                return
            }

            fences.forEach { Geofence.fences.update(with: $0) }
            completionHandler(fences, error)
        }
        loadingTask?.resume()
    }

    @objc(loadFenceWithID:completionHandler:)
    public func loadFence(
        withID id: Int,
        completionHandler: @escaping FenceLoadingCompletionHandler
    ) {
        loadingTask?.cancel()

        let request = urlRequestForLoadingFence(id: id)

        loadingTask = dataTask(
            with: request,
            decoderBlock: decodeLoadingResult(from:)
        ) { (fence, error) in
            guard let fence = fence, error == nil else {
                completionHandler(nil, error)
                return
            }
            Geofence.fences.update(with: fence)
            completionHandler(fence, error)
        }

        loadingTask?.resume()

    }

    @objc(createFenceWithBoundaries:completionHandler:)
    public func createFence(
        withBoundaries boundaries: [Polygon],
        completionHandler: @escaping CreationCompletionHandler
    ) {
        let request = urlRequestForCreatingFence(polygons: boundaries)

        let createTask = dataTask(
            with: request,
            decoderBlock: decodeCreatingResult(from:)
        ) { (id, error) in
            guard let id = id, error == nil else {
                completionHandler(nil, error)
                return
            }
            let fence = Fence(id: id, boundaries: boundaries)
            completionHandler(fence, nil)
        }

        createTask.resume()
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

        let request = urlRequestForLoadingFence(id: id)

        loadingTask = dataTask(
            with: request,
            decoderBlock: decodeDeletingResult(from:)
        ) { (fence, error) in
            guard let fence = fence else {
                completionHandler(nil, error)
                return
            }
            Geofence.fences.remove(fence)
            completionHandler(fence, error)
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

        /// Indicates that network was unavailable or a network error occurred.
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

    func urlRequestForCreatingFence(polygons: [Polygon]) -> URLRequest {
        var urlComponents = NetworkingManager.baseURLComponents

        urlComponents.path = "/geofence/stages"

        var request = NetworkingManager.request(url: urlComponents, httpMethod: .post)

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let geometry: Geometry
        if polygons.count == 1 {
            geometry = .polygon(polygons.first!)
        } else {
            geometry = .multiPolygon(polygons)
        }
        let feature = Feature(geometry: geometry)
        let featureCollection = FeatureCollection(features: [feature])
        let encoder = JSONEncoder()
        let geoJSONData = try? encoder.encode(featureCollection)

        let boundaryStart = "--\(boundary)\r\n"
        let contentDisposition =
            "Content-Disposition: form-data; name=\"polygons\"; filename=\"polygons.geojson\"\r\n"
        let contentType = "Content-Type: application/json\r\n\r\n"
        let boundaryEnd = "\r\n--\(boundary)--\r\n"

        var body = Data()
        body.append(boundaryStart.data(using: .utf8)!)
        body.append(contentDisposition.data(using: .utf8)!)
        body.append(contentType.data(using: .utf8)!)
        if let geoJSONData = geoJSONData {
            body.append(geoJSONData)
        }
        body.append(boundaryEnd.data(using: .utf8)!)

        request.httpBody = body
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

    func decodeCreatingResult(from data: Data) -> Int? {

        struct GeofenceCreateResponse: Decodable {
            var id: Int
            var message: String
        }

        let decoder = JSONDecoder()
        if let decodedData = try? decoder.decode(GeofenceCreateResponse.self, from: data) {
            return decodedData.id
        } else {
            return nil
        }
    }
}

extension Geofence {
    @discardableResult
    func dataTask<R>(
        with urlRequest: URLRequest,
        decoderBlock: @escaping (Data) -> R?,
        completionHandler: @escaping (_ result: R?, _ error: Error?) -> Void
    ) -> URLSessionDataTask {

        guard AccountManager.isAuthorized else {
            completionHandler(nil, Error.unauthorized)
            return URLSessionDataTask()
        }

        let dataTask = NetworkingManager.dataTask(with: urlRequest) { (data, response, error) in
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
                case 200, 201:
                    if let data = data, let decoded = decoderBlock(data) {
                        completionHandler(decoded, nil)
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

        return dataTask
    }
}
