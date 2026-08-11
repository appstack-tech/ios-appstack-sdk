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
            url: "https://github.com/appstack-tech/ios-appstack-sdk/releases/download/4.5.0/AppstackSDK.xcframework.zip",
            checksum: "4745e8d48767daf034fdaa4e347c0a7f52e5589cba265af7bc3e7da12e0c57e9")
    ]
)
