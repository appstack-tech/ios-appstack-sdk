// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "AppstackSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "AppstackSDK",
            targets: ["AppstackSDK"])
    ],
    targets: [
        .binaryTarget(
            name: "AppstackSDK",
            path: "./AppstackSDK.xcframework")
    ]
)

