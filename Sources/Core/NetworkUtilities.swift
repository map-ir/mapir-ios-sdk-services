//
//  NetworkUtilities.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 23/6/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

internal struct Utilities {

    /// Map.ir API endpoints.
    struct Endpoints {
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

    let host: String = "map.ir"

    var session: URLSession

    let decoder = JSONDecoder()
    let encoder = JSONEncoder()

    let userAgent: String = {
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

    func urlRequest(withPath path: String,
                    queryItems: [URLQueryItem]?,
                    httpMethod: String) throws -> URLRequest {

        var urlComponents = URLComponents()
        urlComponents.scheme     = "https"
        urlComponents.host       = self.host
        urlComponents.path       = path
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            preconditionFailure("Couldn't create URL.")
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        request.httpMethod = httpMethod

        if let token = MapirServices.accessToken {
            request.addValue(token, forHTTPHeaderField: "x-api-key")
        } else {
            throw ServiceError.invalidAccessToken
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(self.userAgent, forHTTPHeaderField: "User-Agent")

        return request
    }

}
