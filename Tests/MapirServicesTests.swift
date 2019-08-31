//
//  MapirServicesTests.swift
//  MapirServicesTests
//
//  Created by Alireza Asadi on 31 Ordibehesht, 1398 AP.
//  Copyright © 1398 Map. All rights reserved.
//

@testable import MapirServices
import XCTest

class URLProtocolMock: URLProtocol {
    static var testURLs: [URL?: Data] = [:]

    override class func canInit(with task: URLSessionTask) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let url = request.url {
            if let data = URLProtocolMock.testURLs[url] {
                self.client?.urlProtocol(self, didLoad: data)
            }

            self.client?.urlProtocolDidFinishLoading(self)
        }
    }
    override func stopLoading() {
        return
    }
}

class MapirServicesInitsTests: XCTestCase {
    static let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjBjNTc5MzRiN2JjN2MzYzM2ODRiNDc5NWE5Y2E5MWY0Mzk1ZWU1ZmExMGZiMDQxZjg2Nzg5NTZiMmJmMGQ3NTc2MTgyMzYxY2ZkMDcxN2E0In0.eyJhdWQiOiI3MyIsImp0aSI6IjBjNTc5MzRiN2JjN2MzYzM2ODRiNDc5NWE5Y2E5MWY0Mzk1ZWU1ZmExMGZiMDQxZjg2Nzg5NTZiMmJmMGQ3NTc2MTgyMzYxY2ZkMDcxN2E0IiwiaWF0IjoxNTU3OTA2ODI4LCJuYmYiOjE1NTc5MDY4MjgsImV4cCI6MTU2MDMyNTkwNiwic3ViIjoiIiwic2NvcGVzIjpbImJhc2ljIl19.Cmx41bGBRvaqU3ig_ySLQPA13XZaWCq3Ml2JMejJbXng4SlSutUgKk_tVt_IoS3U81MWk1zwQs18LmSITZf5Qhme_jbecNElY2RNflMssVGYXVcq6PxcHHvOol2pOyGzUeqPL0-sBVPMr80QDXqJyy9m8OZlbvbmNE_9ZLS88JFolyEAbSLY2sulS6J5lPDEv2coCVf17eEQuXgLtNzvpIgyIBOofsxhreWI7YNW5w7cpv-uzzTpW0DBligx-0sSE5zxkVjQztVkDFiAglYkaAjR56LEZrsL5eQNKKrOtDsATLl04EEkJ6Vi7UO6T49POhbEAl-DG7D8gszAnXAgXA"

    func testInitWithToken_initializesServiceWithTokenAssigned() {
        let service = MPSMapirServices(apiKey: MapirServicesInitsTests.token)
        XCTAssertNotNil(service)
        XCTAssertNotNil(service.token)
        XCTAssertEqual(service.token, MapirServicesInitsTests.token)
    }
}

class MapirServicesTests: XCTestCase {

    static let token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjBjNTc5MzRiN2JjN2MzYzM2ODRiNDc5NWE5Y2E5MWY0Mzk1ZWU1ZmExMGZiMDQxZjg2Nzg5NTZiMmJmMGQ3NTc2MTgyMzYxY2ZkMDcxN2E0In0.eyJhdWQiOiI3MyIsImp0aSI6IjBjNTc5MzRiN2JjN2MzYzM2ODRiNDc5NWE5Y2E5MWY0Mzk1ZWU1ZmExMGZiMDQxZjg2Nzg5NTZiMmJmMGQ3NTc2MTgyMzYxY2ZkMDcxN2E0IiwiaWF0IjoxNTU3OTA2ODI4LCJuYmYiOjE1NTc5MDY4MjgsImV4cCI6MTU2MDMyNTkwNiwic3ViIjoiIiwic2NvcGVzIjpbImJhc2ljIl19.Cmx41bGBRvaqU3ig_ySLQPA13XZaWCq3Ml2JMejJbXng4SlSutUgKk_tVt_IoS3U81MWk1zwQs18LmSITZf5Qhme_jbecNElY2RNflMssVGYXVcq6PxcHHvOol2pOyGzUeqPL0-sBVPMr80QDXqJyy9m8OZlbvbmNE_9ZLS88JFolyEAbSLY2sulS6J5lPDEv2coCVf17eEQuXgLtNzvpIgyIBOofsxhreWI7YNW5w7cpv-uzzTpW0DBligx-0sSE5zxkVjQztVkDFiAglYkaAjR56LEZrsL5eQNKKrOtDsATLl04EEkJ6Vi7UO6T49POhbEAl-DG7D8gszAnXAgXA"

    var service: MPSMapirServices!

    override func setUp() {
        self.service = MPSMapirServices.init(apiKey: MapirServicesTests.token)

        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.protocolClasses = [URLProtocolMock.self]

        let session = URLSession(configuration: sessionConfig)
        service.session = session
    }

    override func tearDown() {
        self.service = nil
    }

    func testURLRequestForReverseGeocode_createsURLRequest() {
        let coordinate = CLLocationCoordinate2D(latitude: 35.732590, longitude: 51.422456)
        let sut = try? service.urlRequestForReverseGeocode(coordinate: coordinate)
        XCTAssertNotNil(sut)
        if let url = sut?.url {
            XCTAssertEqual("https://map.ir/reverse?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)", url.absoluteString)
        }
    }

    func testReverseGeocode_receivesAndDecodesData() {
        let url = URL(string: "https://map.ir/reverse/fast-reverse?lat=35.732590&lon=51.422456")
        let data = """
        {
            "address": "ایران، تهران، منطقه ۷، محله نیلوفر - شهید قندی، آیت الله بهشتی، پاکستان، عباس ساوجی نیا",
            "postal_address": "تهران، آیت الله بهشتی، عباس ساوجی نیا",
            "address_compact": "تهران، محله نیلوفر - شهید قندی، آیت الله بهشتی، پاکستان، عباس ساوجی نیا",
            "primary": " آیت الله بهشتی",
            "name": "عباس ساوجی نیا",
            "poi": "",
            "country": "ایران",
            "province": "تهران",
            "county": "تهران",
            "district": "تهران",
            "rural_district": "تهران",
            "city": "تهران",
            "village": "",
            "region": "منطقه ۷",
            "neighbourhood": "محله نیلوفر - شهید قندی",
            "last": "عباس ساوجی نیا",
            "plaque": "",
            "postal_code": "",
            "geom": {
                "type": "Point",
                "coordinates": [
                    "51.422456",
                    "35.732590"
                ]
            }
        }
        """.data(using: .utf8)!
        URLProtocolMock.testURLs = [url: data]
        let coordinates = CLLocationCoordinate2D(latitude: 35.732590, longitude: 51.422456)
        service.reverseGeocode(for: coordinates) { (result) in
            switch result {
            case .success(let address):
                XCTAssertEqual(address.coordinates!.latitude, coordinates.latitude)
                XCTAssertEqual(address.coordinates!.longitude, coordinates.longitude)
            case .failure(_):
                XCTAssertTrue(false)
            }
        }
        
    }
    
}
