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
            url: "https://github.com/appstack-tech/ios-appstack-sdk/releases/download/4.7.0/AppstackSDK.xcframework.zip",
            checksum: "e7ed3bbb8bf2e4260e9e357891f166823553f6e40d84fb53e7198cc957894cf3")
    ]
)
