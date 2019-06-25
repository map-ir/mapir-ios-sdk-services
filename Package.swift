// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "MapirServices",
    products: [
        .library(
            name: "MapirServices",
            targets: ["MapirServices"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MapirServices",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "MapirServicesTests",
            dependencies: ["MapirServices"],
            path: "Tests"
        ),
    ]
)
