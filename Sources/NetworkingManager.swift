//
//  NetworkingManager.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 8/9/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

class NetworkingManager {

    var session: URLSession = .shared
    var timeoutInterval: TimeInterval = 10.0

    static let shared = NetworkingManager()

    static let baseURLComponents: URLComponents = {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "map.ir"
        return urlComponents
    }()

    static let userAgent: String = {
        var components: [String] = []

        if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ??
            Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            components.append("\(appName)/\(version)")
        }

        let libraryBundle: Bundle? = Bundle(for: NetworkingManager.self)

        if let libraryName = libraryBundle?.infoDictionary?["CFBundleName"] as? String,
            let version = libraryBundle?.infoDictionary?["CFBundleShortVersionString"] as? String {
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
        let sysVersionString = [
            "\(systemVersion.majorVersion)",
            "\(systemVersion.minorVersion)",
            "\(systemVersion.patchVersion)"
        ].joined(separator: ".")
        components.append("\(system)/\(sysVersionString)")

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

    static let sdkIDForHeader: String = {
        var components: [String] = []

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
        let systemVersion = ProcessInfo().operatingSystemVersion
        let sysVersionString = [
            "\(systemVersion.majorVersion)",
            "\(systemVersion.minorVersion)",
            "\(systemVersion.patchVersion)(\(chip))"
        ].joined(separator: ".")
        components.append("\(system)/\(sysVersionString)")

        let libraryBundle: Bundle? = Bundle(for: NetworkingManager.self)
        if let libraryName = libraryBundle?.infoDictionary?["CFBundleName"] as? String,
            let version = libraryBundle?.infoDictionary?["CFBundleShortVersionString"] as? String {
            components.append("\(libraryName)/\(version)")
        }

        if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ??
            Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            components.append("\(appName)/\(version)")
        }

        return components.joined(separator: "-")
    }()

    private init() { }

    static func request(url urlComponents: URLComponents,
                        httpMethod: URLRequest.HTTPMethod = .get) -> URLRequest {

        var request = URLRequest(url: urlComponents, httpMethod: httpMethod, timeoutInterval: shared.timeoutInterval)

        if let accessToken = AccountManager.shared.apiKey {
            request.addValue(accessToken, forHTTPHeaderField: "x-api-key")
        }

        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.addValue(sdkIDForHeader, forHTTPHeaderField: "MapIr-SDK")
        return request
    }

    typealias NetworkingCompletionHandler = (Data?, URLResponse?, Error?) -> Void

    static let session: URLSession = URLSession(configuration: .default)

    static func dataTask(with urlRequest: URLRequest,
                         completionHandler: @escaping NetworkingCompletionHandler) -> URLSessionDataTask {
        session.dataTask(with: urlRequest, completionHandler: completionHandler)
    }
}
