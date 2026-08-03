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
            url: "https://github.com/appstack-tech/ios-appstack-sdk/releases/download/4.4.1/AppstackSDK.xcframework.zip",
            checksum: "9d283d972b6ea47e6ddf48b46fa7da7ff5dc934d2478800503d95c2379b89776")
    ]
)
