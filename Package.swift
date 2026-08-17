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
            url: "https://github.com/appstack-tech/ios-appstack-sdk/releases/download/4.5.1-rc1/AppstackSDK.xcframework.zip",
            checksum: "8ae5580785ff6b66bde409728e3b6982ac9d2c4cf7441c16366540293c2d1fb9")
    ]
)
