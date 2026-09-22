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
            url: "https://github.com/appstack-tech/ios-appstack-sdk/releases/download/4.7.2/AppstackSDK.xcframework.zip",
            checksum: "bd3a688b95d4025caa4e3753858522ade5d2c99ec0fb3436258e4458709449cf")
    ]
)
