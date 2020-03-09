//
//  AccountManager.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 8/9/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

/// The `AccountManager` globally holds information about your API key and account
/// on [Map.ir](https://map.ir).
@objc class AccountManager: NSObject {

    /// Shared object
    private static let shared = AccountManager()

    private var apiKey: String?
    private var isAuthorized: Bool

    static var isAuthorized: Bool {
        get { shared.isAuthorized }
        set { shared.isAuthorized = newValue }
    }

    /// The [Map.ir](https://map.ir) API key, used by all of the services.
    ///
    /// Map.ir services require API key, which can be obtained at [Map.ir App
    /// Registration](https://corp.map.ir/registration) page. By default, this value is
    /// read from Info.plist file of the application.
    ///
    /// If you don't set your API key in `Info.plist` file, be sure to set this property
    /// before using services.
    @objc public static var apiKey: String? {
        get { shared.apiKey }
        set {
            shared.apiKey = newValue
            shared.isAuthorized = (newValue ?? "").isEmpty ? false : true
        }
    }

    private override init() {
        if let apiKey = (Bundle.main.object(forInfoDictionaryKey: "MapirAPIKey") ??
            Bundle.main.object(forInfoDictionaryKey: "MAPIRAccessToken")) as? String {
            self.apiKey = apiKey
            self.isAuthorized = true
        } else {
            self.isAuthorized = false
        }

        super.init()
        setupObservers()
    }

    deinit {
        if let observer = unauthorizedObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private var unauthorizedObserver: Any?

    private func setupObservers() {
        unauthorizedObserver = NotificationCenter.default.addObserver(
            forName: NetworkingManager.unauthorizedNotification,
            object: nil,
            queue: nil
        ) { [weak self] (_) in
            self?.isAuthorized = false
        }
    }
}
