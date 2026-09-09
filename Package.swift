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
            url: "https://github.com/appstack-tech/ios-appstack-sdk/releases/download/4.7.0-rc3/AppstackSDK.xcframework.zip",
            checksum: "db7f70dab3a53ce4dcac8c0e990aa775b2c61a25687bac6f83ab8c2283eb8a33")
    ]
)
