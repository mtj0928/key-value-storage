// swift-tools-version: 6.0
import Foundation
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

let isDocCBuild = ProcessInfo.processInfo.environment["DOCC_BUILD"] == "1"
if isDocCBuild {
    package.dependencies += [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0"),
    ]
}
