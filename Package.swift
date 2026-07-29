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
            url: "https://github.com/appstack-tech/ios-appstack-sdk/releases/download/4.4.1-rc1/AppstackSDK.xcframework.zip",
            checksum: "1da212fb8e65ba26c41507bc8a49bc5624e7201940e1b09907859b4574e71ae4")
    ]
)
