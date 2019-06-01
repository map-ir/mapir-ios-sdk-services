//
//  MapirServices.swift
//  MapirServices
//
//  Created by Alireza Asadi on 31 Ordibehesht, 1398 AP.
//  Copyright © 1398 Map. All rights reserved.
//

// Include Foundation
@_exported import Foundation

let baseURL = URL(string: "https://map.ir")

class MPIRServices {
    
    var shared = MPIRServices()
    
    let baseURL = URL(string: "https://map.ir/api/")
    
    var token: String
    
    private init() {
        let token = Bundle.main.object(forInfoDictionaryKey: "MAPIRServicesToken") as? String
        self.token = token!
    }
}

protocol MPIRRequest {
//    func send(
}
