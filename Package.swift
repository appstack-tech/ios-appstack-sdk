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
            url: "https://github.com/appstack-tech/ios-appstack-sdk/releases/download/4.5.2/AppstackSDK.xcframework.zip",
            checksum: "4bd649a8057de07c93febc75a80d9c714763f250f2ae2859ee3bde872e26f002")
    ]
)
