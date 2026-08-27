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
            url: "https://github.com/appstack-tech/ios-appstack-sdk/releases/download/4.6.0-rc0/AppstackSDK.xcframework.zip",
            checksum: "8b824ea91fe74a85d310b7daf46a6784942131e4c094caaab06f391be7035af6")
    ]
)
