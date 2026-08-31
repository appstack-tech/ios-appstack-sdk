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
            url: "https://github.com/appstack-tech/ios-appstack-sdk/releases/download/4.6.0-rc1/AppstackSDK.xcframework.zip",
            checksum: "f5fbfdd7da6c42c99243aece2dba358683816b7f391b0bfeb6dfc9d40a0de034")
    ]
)
