// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "AppstackSDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AppstackSDK",
            targets: ["AppstackSDK"])
    ],
    targets: [
        .binaryTarget(
            name: "AppstackSDK",
            url: "https://github.com/appstack-tech/ios-appstack-sdk/releases/download/4.4.0-rc2/AppstackSDK.xcframework.zip",
            checksum: "5a6423cc8e2992f114afbfc4d2ec15b95d90f1786a3dc2c17d1648378cb4a157")
    ]
)
