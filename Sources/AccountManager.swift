//
//  AccountManager.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 8/9/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

class AccountManager {
    static let shared = AccountManager()

    var apiKey: String?
    var isAuthorized: Bool {
        if let apiKey = apiKey {
            return !apiKey.isEmpty
        } else {
            return false
        }
    }

    @objc static var isAuthorized: Bool { shared.isAuthorized }

    @objc public static var apiKey: String? { shared.apiKey }

    private init() {
        if let apiKey = (Bundle.main.object(forInfoDictionaryKey: "MapirAPIKey") ??
            Bundle.main.object(forInfoDictionaryKey: "MAPIRAccessToken")) as? String {
            self.apiKey = apiKey
        }
    }
}
