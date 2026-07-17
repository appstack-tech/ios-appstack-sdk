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
            url: "https://github.com/appstack-tech/ios-appstack-sdk/releases/download/4.4.0/AppstackSDK.xcframework.zip",
            checksum: "2c3cc1b61b555763aa9264f13501d36dae51e224c66d631d8e17216be13e38fc")
    ]
)
