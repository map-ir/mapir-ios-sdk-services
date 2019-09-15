import MapirServices
import CoreLocation

//: ## Replace the placeholder with your access token.
// let accessToken = <#add your access token here#>
let accessToken = "Helllllo!"

let services = MapirServices(accessToken: accessToken)

let coordinates = CLLocationCoordinate2D(latitude: 34.0123, longitude: 51.12345)
//services.reverseGeocode(for: coordinates) { result in
//    switch result {
//    case .failure(let error):
//        print(error)
//    case .success(let reverseGeocode):
//        print(reverseGeocode.postalAddress)
//    }
//}

let coordinatesA = CLLocationCoordinate2D(latitude: 34.0123, longitude: 51.1245)
let coordinatesB = CLLocationCoordinate2D(latitude: 33.4123, longitude: 52.1451)
let coordinatesC = CLLocationCoordinate2D(latitude: 35.4123, longitude: 51.9772)

let origins = ["aliz": coordinates, "Aliz245_": coordinatesB]
let destinations = ["c": coordinatesC]

services.distanceMatrix(from: origins, to: destinations) { result in
    switch result {
    case .failure(let error):
        print(error)
    case .success(let dismat):
        print(dismat.origins["aliz"])
    }
}

