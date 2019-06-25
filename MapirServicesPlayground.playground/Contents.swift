import UIKit
import Foundation
import MapirServices

var str = "Hello, playground"

typealias Parameter = [String: Any]

let session = URLSession.shared

let lat = 34.0
let lng = 51.2
let params: Parameter = ["lat" : lat, "lng" : lng]

let url = URL(string: "https://map.ir/reverse?lat=\(params["lat"])&lon=\(params["lon"])")

var request = URLRequest(url: url!)
request.httpMethod = "get"
request.timeoutInterval = 20

//extension URL {
//    mutating func addParameters(params: [String : String]) {
//        let randomElement = params.randomElement()
//        self.appendingPathComponent("?\(randomElement?.key)=\(randomElement?.value)")
//        for (key, value) in params {
//            self.appendingPathComponent("&\(key)=\(value)")
//        }
//    }
//}


