// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "MapirServices",
    platform: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "MapirServices",
            targets: ["MapirServices"]
        ),
    ],
    targets: [
        .target(
            name: "MapirServices",
            path: "Source"
        ),
    ]
)
