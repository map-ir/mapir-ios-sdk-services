//
//  MapSnapshotter.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 29/9/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import UIKit

@objc class MapSnapshotter: NSObject {

    /// Snapshot completion handler.
    public typealias SnapshotCompletionHandler = (UIImage?, Swift.Error?) -> Void

    /// Current status of `MapSnapshotter` object.
    public var isLoading: Bool {
        if let task = activeTask {
            switch task.state {
            case .running:
                return true
            case .canceling, .suspended, .completed:
                return false
            @unknown default:
                fatalError("Unknown Task Status.")
            }
        } else {
            return false
        }
    }

    private var activeTask: URLSessionDataTask?

    /// Creates an snapshot of map according to the specified configuration.
    ///
    /// - Parameters:
    ///   - configuration: Configutration of snapshotting task.
    ///   - completionHandler: Completion handler block to run after the snapshot is available.
    @objc(createSnapshotWithConfiguration:completionHandler:)
    public func createSnapshot(with configuration: Configuration,
                               completionHandler: @escaping SnapshotCompletionHandler) {
        guard AccountManager.isAuthorized else {
            completionHandler(nil, Error.unauthorized)
            return
        }

        let request = self.urlRequestForSnapshotterTask(with: configuration)

        activeTask = NetworkingManager.dataTask(with: request) { [weak self] (data, response, error) in
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
                    if let data = data, let placemarks = self?.decodeImage(from: data) {
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
        activeTask?.resume()
    }

    /// Cancels the current running geocoding or reverseGeocoding task.
    @objc public func cancel() {
        activeTask?.cancel()
        activeTask = nil
    }
}

// MARK: Errors

extension MapSnapshotter {

    /// Errors related to map snapshotting.
    @objc(MapSnapshotterError)
    public enum Error: UInt, Swift.Error {

        /// Indicates that you are not using a Map.ir API key or your key is invalid.
        case unauthorized

        /// Indicates that network was unavailable or a network error occured.
        case network

        /// Indicates that the task was canceled.
        case canceled

        /// Indicates that snapshot creation task had no result.
        case noResult
    }
}

// MARK: Generating URL Request

extension MapSnapshotter {
    func urlRequestForSnapshotterTask(with configuration: Configuration) -> URLRequest {
        var urlComponents = NetworkingManager.baseURLComponents

        var queryItems = [
            "width": "\(Int(configuration.size.width))",
            "height": "\(Int(configuration.size.height))",
            "zoom_level": "\(configuration.zoomLevel)"
        ].convertedToURLQueryItems()

        if !configuration.markers.isEmpty {
            for marker in configuration.markers {
                var components: [String] = []
                let coords = marker.location.coordinate

                components.append("color:\(marker.style.stringValue)")
                components.append("label:\(marker.label)")
                components.append("\(coords.longitude),\(coords.latitude)")

                queryItems.append(URLQueryItem(name: "markers", value: components.joined(separator: "|")))
            }
        }

        urlComponents.queryItems = queryItems
        urlComponents.path = "/static"

        return URLRequest(url: urlComponents)
    }
}

// MARK: Decoder

extension MapSnapshotter {
    func decodeImage(from data: Data) -> UIImage? { return UIImage(data: data) }
}
