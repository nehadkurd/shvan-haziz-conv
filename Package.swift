// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ShvanHazizCONV",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(
            name: "ShvanHazizCONV",
            targets: ["ShvanHazizCONV"]
        )
    ],
    targets: [
        .executableTarget(
            name: "ShvanHazizCONV",
            path: "ShvanHazizCONV",
            resources: []
        )
    ]
)
