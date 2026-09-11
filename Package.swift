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
            url: "https://github.com/appstack-tech/ios-appstack-sdk/releases/download/4.7.1/AppstackSDK.xcframework.zip",
            checksum: "e2ee8a3143afbde8f3e50f18a876c8d931ab546f67100e759466a7deb56313c9")
    ]
)
