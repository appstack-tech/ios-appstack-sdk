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
            url: "https://github.com/appstack-tech/ios-appstack-sdk/releases/download/4.8.0/AppstackSDK.xcframework.zip",
            checksum: "0eddfb6b36febbe54828715329d025233b3906e7f569cec0fd8ee18b9154d62d")
    ]
)
