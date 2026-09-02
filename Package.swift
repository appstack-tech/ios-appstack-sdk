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
            url: "https://github.com/appstack-tech/ios-appstack-sdk/releases/download/4.6.0/AppstackSDK.xcframework.zip",
            checksum: "60f9c41142e5cfc176cfc87fd334bfabbf13d59dca124e7cec8582849db15f72")
    ]
)
