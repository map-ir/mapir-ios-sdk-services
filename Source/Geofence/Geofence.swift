//
//  Geofence.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 24/12/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

/// `Geofence` is a service to define geographical polygons as special areas. Then
/// you can determine the status of a geographical point relative to the `Fence`.
public class Geofence {

    public typealias CreationCompletionHandler = (Result<Fence, Error>) -> Void
    public typealias DeletionCompletionHandler = (Result<Fence, Error>) -> Void
    public typealias FenceBatchLoadingCompletionHandler = (Result<[Fence], Error>) -> Void
    public typealias FenceLoadingCompletionHandler = (Result<Fence, Error>) -> Void

    /// All the fences that are loaded using any instance of `Geofence` class.
    ///
    /// `Fence`s in this property are all related to a API key.
    ///
    /// - note: When the API key changes, this property updates and becomes empty.
    public static var fences: Set<Fence> = []

    /// Creates the `Geofence` wrapper.
    public init() { }

    /// Loads geofences associated with the API key, from Map.ir.
    ///
    /// - Parameters:
    ///   - count: Number of fences to load.
    ///   - skipCount: Number of fences to skip. latest uploaded fences come first.
    ///   - completionHandler: A block to run once the result is available.
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
    ///   - completionHandler: A completion handler block to run once the results are
    ///     available.
    public func loadFences(
        inRange range: ClosedRange<Int>,
        completionHandler: @escaping FenceBatchLoadingCompletionHandler
    ) {
        guard AccountManager.isAuthorized else {
            completionHandler(.failure(ServiceError.unauthorized(reason: .init())))
            return
        }

        let request = urlRequestForBatchLoadingFences(range: range)

        let loadingTask = Utilities.session.dataTask(
            with: request,
            decoderBlock: decodeBatchLoadingResult(from:)
        ) { (result) in
            switch result {
            case .failure(let error):
                completionHandler(.failure(error))
            case .success(let fences):
                fences.forEach { Geofence.fences.update(with: $0) }
                completionHandler(.success(fences))
            }
        }

        loadingTask?.resume()
    }

    /// Loads a specific `Fence` with its ID from the server.
    ///
    /// - Parameters:
    ///   - id: ID of the `Fence` that is needed.
    ///   - completionHandler: a completion handler block to run when the specified fence
    ///     becomes available.
    public func loadFence(
        withID id: Int,
        completionHandler: @escaping FenceLoadingCompletionHandler
    ) {
        guard AccountManager.isAuthorized else {
            completionHandler(.failure(ServiceError.unauthorized(reason: .init())))
            return
        }

        let request = urlRequestForLoadingFence(id: id)

        let loadingTask = Utilities.session.dataTask(
            with: request,
            decoderBlock: decodeLoadingResult(from:)
        ) { (result) in
            switch result {
            case .failure(let error):
                completionHandler(.failure(error))
            case .success(let fence):
                Geofence.fences.update(with: fence)
                completionHandler(.success(fence))
            }
        }

        loadingTask?.resume()

    }

    /// Creates a new `Fence` object from the specified boundaries.
    ///
    /// This method sends the boundaries to the server, If this task finishes
    /// successfully, creates a `Fence` with the boundary and the id that the server
    /// assigns to it.
    ///
    /// - Parameters:
    ///   - boundaries: An array of `Polygon`s representing the area that the `Fence` is
    ///     going to show.
    ///   - completionHandler: A completion handler block to run when the `Fence` is
    ///     genereted properly.
    public func createFence(
        withBoundaries boundaries: [Polygon],
        completionHandler: @escaping CreationCompletionHandler
    ) {
        guard AccountManager.isAuthorized else {
            completionHandler(.failure(ServiceError.unauthorized(reason: .init())))
            return
        }

        if let validationError = validateCreateArguments(boundaries) {
            completionHandler(.failure(validationError))
            return
        }

        let request = urlRequestForCreatingFence(polygons: boundaries)

        let createTask = Utilities.session.dataTask(
            with: request,
            decoderBlock: decodeCreatingResult(from:)
        ) { (result) in
            switch result {
            case .failure(let error):
                completionHandler(.failure(error))
            case .success(let id):
                let fence = Fence(id: id, boundaries: boundaries)
                completionHandler(.success(fence))
            }
        }

        createTask?.resume()
    }

    /// Deletes a given `Fence` from the server. If succeeds passes the deleted `Fence` to the
    /// `completionHandler`, Otherwise passes the error associated with the process.
    ///
    /// - Parameters:
    ///   - fence: The fence to delete
    ///   - completionHandler: A completion handler block to run once the task is
    ///     completed.
    public func deleteFence(
        _ fence: Fence,
        completionHandler: @escaping DeletionCompletionHandler
    ) {
        deleteFence(withID: fence.id, completionHandler: completionHandler)
    }

    /// Deletes the fence with the given ID. If succeeds passes the deleted `Fence` to the
    /// `completionHandler`, Otherwise passes the error associated with the process.
    ///
    /// - Parameters:
    ///   - id: ID of the fence that is wanted to be deleted.
    ///   - completionHandler: the completion handler block to run after the results are
    ///     available or process encounters an error.
    public func deleteFence(
        withID id: Int,
        completionHandler: @escaping DeletionCompletionHandler
    ) {
        guard AccountManager.isAuthorized else {
            completionHandler(.failure(ServiceError.unauthorized(reason: .init())))
            return
        }
        
        let request = urlRequestForLoadingFence(id: id)

        let deletingTask = Utilities.session.dataTask(
            with: request,
            decoderBlock: decodeDeletingResult(from:)
        ) { (result) in
            switch result {
            case .failure(let error):
                completionHandler(.failure(error))
            case .success(let fence):
                Geofence.fences.remove(fence)
                completionHandler(.success(fence))
            }
        }

        deletingTask?.resume()
    }
}

extension Geofence {
    func validateCreateArguments(_ polygons: [Polygon]) -> Error? {
        guard !polygons.isEmpty else {
            return ServiceError.GeofenceError.emptyPolygonsArray
        }

        return nil
    }
}

extension Geofence {
    func urlRequestForBatchLoadingFences(range: ClosedRange<Int>) -> URLRequest {
        var urlComponents = Utilities.baseURLComponents

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

        let request = URLRequest(url: urlComponents)
        return request
    }

    func urlRequestForLoadingFence(id: Int) -> URLRequest {
        var urlComponents = Utilities.baseURLComponents

        urlComponents.path = "/geofence/stages/\(id)"

        let request = URLRequest(url: urlComponents)
        return request
    }

    func urlRequestForDeletingFence(id: Int) -> URLRequest {
        var urlComponents = Utilities.baseURLComponents

        urlComponents.path = "/geofence/stages/\(id)"

        let request = URLRequest(url: urlComponents, httpMethod: .delete)
        return request
    }

    func urlRequestForCreatingFence(polygons: [Polygon]) -> URLRequest {
        var urlComponents = Utilities.baseURLComponents

        urlComponents.path = "/geofence/stages"

        let boundary = UUID().uuidString

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

        var request = URLRequest(url: urlComponents, httpMethod: .post, body: body)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

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
