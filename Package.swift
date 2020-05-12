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
    targets: [
        .target(
            name: "MapirServices",
            path: "Source"
        ),
    ]
)
