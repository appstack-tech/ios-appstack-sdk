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
            url: "https://github.com/appstack-tech/ios-appstack-sdk/releases/download/4.5.1/AppstackSDK.xcframework.zip",
            checksum: "9e03558f04d2ee7eeb8aeea6808074eb9b2bc8fa8c29677383ced556b3ae266b")
    ]
)
