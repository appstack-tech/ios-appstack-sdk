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
            url: "https://github.com/appstack-tech/ios-appstack-sdk/releases/download/4.7.0-rc4/AppstackSDK.xcframework.zip",
            checksum: "50995b351015b708ca8495db929fe9e8d2c283bcb5d8cd15f99e0675a106617a")
    ]
)
