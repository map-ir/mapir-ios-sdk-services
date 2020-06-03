//
//  Utilities.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 8/9/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

import Foundation

enum Utilities {
    static let unauthorizedNotification = Notification.Name(rawValue: "unauthorizedAPIKeyNotification")

    static let session: URLSession = URLSession(configuration: .default)

    static let baseURLComponents: URLComponents = {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "map.ir"
        return urlComponents
    }()

    static var appName: String? {
        if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String ??
            Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String {
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            return "\(appName)/\(version)"
        }
        return nil
    }

    static var libraryName: String? {
        let libraryBundle: Bundle? = Bundle(for: Geocoder.self)
        if let libraryName = libraryBundle?.infoDictionary?["CFBundleName"] as? String,
            let version = libraryBundle?.infoDictionary?["CFBundleShortVersionString"] as? String {
            return "\(libraryName)/\(version)"
        }
        return nil
    }

    static var cpuInfo: String? {
        var info = ""
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
        info = "\(system)/\(sysVersionString)"

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
        info += "(\(chip))"

        return info
    }

    static let userAgent: String = {
        var components: [String] = []

        if let appName = Utilities.appName {
            components.append(appName)
        }
        if let libraryName = Utilities.libraryName {
            components.append(libraryName)
        }
        if let cpuInfo = Utilities.cpuInfo {
            components.append(cpuInfo)
        }
        return components.joined(separator: " ")
    }()

    static let sdkIDForHeader: String = {
        var components: [String] = []

        if let cpuInfo = Utilities.cpuInfo {
            components.append(cpuInfo)
        }
        if let libraryName = Utilities.libraryName {
            components.append(libraryName)
        }
        if let appName = Utilities.appName {
            components.append(appName)
        }
        return components.joined(separator: "-")
    }()
}
