//
//  AccountManager.swift
//  MapirServices-iOS
//
//  Created by Alireza Asadi on 8/9/1398 AP.
//  Copyright © 1398 AP Map. All rights reserved.
//

class AccountManager {

    internal var apiKey: String?

    static let shared = AccountManager()

    var isAuthorized: Bool {
        return apiKey?.isEmpty ?? false
    }

    private init() {
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "MAPIRAccessToken") as? String {
            self.apiKey = apiKey
        }
    }
}
