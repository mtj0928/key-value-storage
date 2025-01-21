// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "key-value-storage",
    platforms: [.iOS(.v17), .macOS(.v14), .watchOS(.v10), .visionOS(.v1), .tvOS(.v17)],
    products: [
        .library(name: "KeyValueStorage", targets: ["KeyValueStorage"]),
    ],
    targets: [
        .target(name: "KeyValueStorage"),
        .testTarget(name: "KeyValueStorageTests", dependencies: ["KeyValueStorage"]),
    ]
)
