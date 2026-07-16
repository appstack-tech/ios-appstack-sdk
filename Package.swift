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
            url: "https://github.com/appstack-tech/ios-appstack-sdk/releases/download/4.4.0-rc1/AppstackSDK.xcframework.zip",
            checksum: "10243016f89726f0da5e4367ccc48102809fec12ec80db10de4c34018f2ca80b")
    ]
)
