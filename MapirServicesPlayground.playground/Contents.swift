import MapirServices
import CoreLocation

//: ## Replace the placeholder with your access token.
// let accessToken = <#add your access token here#>
let accessToken = "Helllllo!"

let services = MapirServices(accessToken: accessToken)

let coordinates = CLLocationCoordinate2D(latitude: 34.0123, longitude: 51.12345)
services.reverseGeocode(for: coordinates) { result in
    switch result {
    case .failure(let error):
        print(error)
    case .success(let reverseGeocode):
        print(reverseGeocode.postalAddress)
    }
}
