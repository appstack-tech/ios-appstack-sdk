<p align="center">
  <a href="https://www.appstack.tech">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset=".github/assets/appstack_logo_white_wordmark.png">
      <img alt="Appstack" src=".github/assets/appstack_logo_black_wordmark.png" width="280">
    </picture>
  </a>
</p>

<p align="center">
  Mobile attribution and ad-network optimization for iOS apps.
</p>

<p align="center">
  <a href="https://github.com/appstack-tech/ios-appstack-sdk/releases/latest"><img alt="Latest release" src="https://img.shields.io/github/v/release/appstack-tech/ios-appstack-sdk?label=version"></a>
  <a href="https://swift.org/package-manager"><img alt="SPM compatible" src="https://img.shields.io/badge/SPM-compatible-brightgreen.svg"></a>
  <img alt="Platforms" src="https://img.shields.io/badge/platforms-iOS%2015%2B-blue.svg">
  <a href="LICENSE.txt"><img alt="License" src="https://img.shields.io/badge/license-MIT-lightgrey.svg"></a>
</p>

<p align="center">
  <a href="https://docs.appstack.tech/SDKs/swift"><b>Documentation</b></a>
  &nbsp;·&nbsp;
  <a href="https://docs.appstack.tech/reference/swift">API reference</a>
  &nbsp;·&nbsp;
  <a href="CHANGELOG.md">Changelog</a>
  &nbsp;·&nbsp;
  <a href="https://www.appstack.tech/contact">Support</a>
</p>

---

The Appstack iOS SDK tracks installs and in-app events, attributes them to your ad campaigns, and sends conversions back to Meta, Google, TikTok, Apple Ads and other networks.

## Installation

Add the package with Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/appstack-tech/ios-appstack-sdk.git", from: "4.7.0")
]
```

Or in Xcode: **File ▸ Add Package Dependencies…** and enter `https://github.com/appstack-tech/ios-appstack-sdk.git`.

## Quick start

```swift
import AppstackSDK

AppstackAttributionSdk.shared.configure(apiKey: "your_api_key")

AppstackAttributionSdk.shared.sendEvent(
    event: .PURCHASE,
    parameters: ["revenue": 29.99, "currency": "USD"]
)
```

Setup, event types, Apple Ads attribution, integrations (RevenueCat, Superwall) and troubleshooting are covered in the **[official documentation](https://docs.appstack.tech/SDKs/swift)**.

## Documentation

- **[Swift SDK guide](https://docs.appstack.tech/SDKs/swift)**: installation, configuration and event tracking
- **[API reference](https://docs.appstack.tech/reference/swift)**: every public type and method
- **[Apple Ads](https://docs.appstack.tech/Integrations/apple-ads)**: Apple Ads attribution setup
- **[RevenueCat](https://docs.appstack.tech/Integrations/revenuecat)** and **[Superwall](https://docs.appstack.tech/Integrations/superwall)**: subscription platform integrations
- **[Changelog](CHANGELOG.md)**: release notes for every version

## Example app

[`Examples/VirtualStore`](Examples/VirtualStore) is a small SwiftUI store that shows SDK setup and funnel event tracking.

## Other platforms

[Android](https://docs.appstack.tech/SDKs/kotlin) · [React Native](https://docs.appstack.tech/SDKs/react-native) · [Flutter](https://docs.appstack.tech/SDKs/flutter) · [Unity](https://docs.appstack.tech/SDKs/unity)

## Support

Questions or issues? [Open an issue](https://github.com/appstack-tech/ios-appstack-sdk/issues) or [contact us](https://www.appstack.tech/contact).

## License

Released under the [MIT License](LICENSE.txt).
