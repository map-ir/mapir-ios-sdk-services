//
//  MapirServices.swift
//  MapirServices
//
//  Created by Alireza Asadi on 31 Ordibehesht, 1398 AP.
//  Copyright © 1398 Map. All rights reserved.
//

// Include Foundation
@_exported import Foundation

public class MPSMapirServices {
    
    static let shared = MPSMapirServices()
    
    let baseURL = URL(string: "https://map.ir/api/")
    
    private let token: String
    
    private init() {
        let token = Bundle.main.object(forInfoDictionaryKey: "MAPIRServicesAccessToken") as? String
        self.token = token!
    }
}



protocol MPSRequest {
    var method: HTTPMethod { get set }
    var parameters: Parameters? { get set }
    func request(onCompletion: ((Error, Decodable) -> Void))
}
