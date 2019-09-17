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
let coordinatesC = CLLocationCoordinate2D(latitude: 35.4123, longitude: 50.5646)
let coordinatesD = CLLocationCoordinate2D(latitude: 35.1345, longitude: 52.3453)
let coordinatesE = CLLocationCoordinate2D(latitude: 36.7645, longitude: 50.4323)
let coordinatesF = CLLocationCoordinate2D(latitude: 33.0986, longitude: 51.6345)

let origins = ["1": coordinates, "2": coordinatesB, "3": coordinatesC]
let destinations = ["a": coordinatesD, "b": coordinatesE, "c": coordinatesF ]

services.distanceMatrix(from: origins, to: destinations) { result in
    switch result {
    case .failure(let error):
        print(error)
    case .success(let dismat):
        dismat.durations["2", "c"]
        dismat.origins["1"]
        dismat.allDurations(to: "c")
        dismat.duration(from: ["1", "2"], to: "c")
    }
}

