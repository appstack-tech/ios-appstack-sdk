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
            url: "https://github.com/appstack-tech/ios-appstack-sdk/releases/download/4.7.0-rc1/AppstackSDK.xcframework.zip",
            checksum: "bb5b43afb33123aebf029da61b26419dc486ed55ff7c06c7f8a48d08477b0517")
    ]
)
