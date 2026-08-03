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
            url: "https://github.com/appstack-tech/ios-appstack-sdk/releases/download/4.5.0-rc0/AppstackSDK.xcframework.zip",
            checksum: "49e7a69d39ca765ae735760d20fb219416e9ed6b8d5a9eb7d7b3811618df5b19")
    ]
)
