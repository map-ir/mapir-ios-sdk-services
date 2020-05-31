//
//  MapSnapshotter.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 29/9/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import UIKit
import Foundation

/// `MapSnapshotter` or Static Map service, is a service that creates a png image from
/// part of the map.
public class MapSnapshotter {

    /// Snapshoting completion handler type.
    public typealias SnapshotCompletionHandler = (Result<UIImage, Error>) -> Void

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

    /// Creates a snapshot of map according to the specified configuration.
    ///
    /// - Parameters:
    ///   - configuration: The configuration of snapshotting task.
    ///   - completionHandler: Completion handler block to run after the snapshot is available.
    public func createSnapshot(
        with configuration: Configuration,
        completionHandler: @escaping SnapshotCompletionHandler
    ) {

        cancel()
        
        guard AccountManager.isAuthorized else {
            completionHandler(.failure(ServiceError.unauthorized))
            return
        }

        if let validationError = validate(configuration) {
            completionHandler(.failure(validationError))
            return
        }

        let request = self.urlRequestForSnapshotterTask(with: configuration)

        activeTask = NetworkingManager.dataTask(
            with: request,
            decoderBlock: decodeImage(from:),
            completionHandler: completionHandler)
        
        activeTask?.resume()
    }

    /// Cancels the current running geocoding or reverseGeocoding task.
    public func cancel() {
        activeTask?.cancel()
        activeTask = nil
    }
}

extension MapSnapshotter {
    func validate(_ configuration: MapSnapshotter.Configuration) -> Error? {

        if configuration.markers.isEmpty {
            return ServiceError.MapSnapshotterError.emptyMarkersArray
        }
        return nil
    }
}

// MARK: Generating URL Request

extension MapSnapshotter {
    func urlRequestForSnapshotterTask(with configuration: Configuration) -> URLRequest {
        var urlComponents = NetworkingManager.baseURLComponents

        var queryItems = URLQueryItem.queryItems(from: [
            "width": String(Int(configuration.size.width)),
            "height": String(Int(configuration.size.height)),
            "zoom_level": String(configuration.zoomLevel),
        ])

        for marker in configuration.markers {
            var components: [String] = []
            let coords = marker.coordinate

            components.append("color:\(marker.style.rawValue)")
            if let label = marker.label {
                components.append("label:\(label)")
            }
            components.append("\(coords.longitude),\(coords.latitude)")

            queryItems.append(
                URLQueryItem(name: "markers", value: components.joined(separator: "|")))
        }

        urlComponents.queryItems = queryItems
        urlComponents.path = "/static"

        return NetworkingManager.request(url: urlComponents)
    }
}

// MARK: Decoder

extension MapSnapshotter {
    func decodeImage(from data: Data) -> UIImage? { return UIImage(data: data) }
}
