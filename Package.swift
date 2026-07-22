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
            url: "https://github.com/appstack-tech/ios-appstack-sdk/releases/download/4.4.1-rc0/AppstackSDK.xcframework.zip",
            checksum: "ca645bc56c6681ea73995b36d93a2674a0b58802ece1cd5b46dbeb836d97909b")
    ]
)
