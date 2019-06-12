import UIKit
import MapirServices

var str = "Hello, playground"

typealias Parameter = [String: Any]

let session = URLSession.shared

let url = URL(string: "https://map.ir/")

var request = URLRequest(url: url!)
request.httpMethod = "get"
request.timeoutInterval = 20


let lat = 34
let lng = 51
let params: Parameter = ["lat" : lat, "lng" : lng]



session.dataTask(with: request) { (data, response, error) in
    <#code#>
}
