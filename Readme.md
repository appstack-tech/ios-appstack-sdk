# AppstackSDK
[![License](https://img.shields.io/cocoapods/l/RevenueCat.svg?style=flat)](http://cocoapods.org/pods/RevenueCat)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
![Version](https://img.shields.io/github/v/tag/appstack-tech/ios-appstack-sdk?label=version)

SDK for integrating Appstack into iOS applications.

## Overview

The Appstack iOS SDK lets you:

- Track standardized and custom events
- Track revenue events with currency (for ROAS / optimization)
- Enable Apple Ads attribution
- Retrieve the Appstack installation ID and attribution parameters

## Features (with examples)

### SDK initialization

```swift
import AppstackSDK

AppstackAttributionSdk.shared.configure(
    apiKey: "your_api_key",
    isDebug: false,
    endpointBaseUrl: nil,
    logLevel: .info
)
```

### Event tracking (standard + custom)

```swift
// Standard
AppstackAttributionSdk.shared.sendEvent(event: .LOGIN)

// Custom
AppstackAttributionSdk.shared.sendEvent(
    event: .CUSTOM,
    name: "level_completed",
    parameters: ["level": 12]
)
```

### Revenue tracking (recommended for all ad networks)

```swift
AppstackAttributionSdk.shared.sendEvent(
    event: .PURCHASE,
    parameters: ["revenue": 29.99, "currency": "EUR"]
)
// `price` is also accepted instead of `revenue`
```

### Installation ID + attribution parameters

```swift
let appstackId = AppstackAttributionSdk.shared.getAppstackId()
let attributionParams = await AppstackAttributionSdk.shared.getAttributionParams() ?? [:]
```

### `getAttributionParams() async -> [String: Any]?`
Retrieve attribution parameters from the SDK. This returns all available attribution data that the SDK has collected.

**Returns:** A dictionary containing attribution parameters (key-value pairs), or `nil` if not yet available.

**Returns data on success:** Dictionary with various attribution-related data depending on availability.

**Returns empty dictionary:** `[:]` if no attribution parameters are available.

**Example:**
```swift
let attributionParams = await AppstackAttributionSdk.shared.getAttributionParams() ?? [:]
print("Attribution parameters:", attributionParams)

// Example output (varies by device / store install):
// [
//   "attribution_source": "app_store",
//   "install_timestamp": "1733629800",
//   "attributed": "true",
//   ...
// ]
```

**Use Cases:**
- Retrieve attribution data for analytics
- Check if the app was attributed to a specific campaign
- Log attribution parameters for debugging
- Send attribution data to your backend server
- Analyze user acquisition sources

### Apple Ads attribution

```swift
import AppstackSDK

if #available(iOS 14.3, *) {
    AppstackASAAttribution.shared.enableAppleAdsAttribution()
}
```

## Sending S2S Events with Superwall

The SDK integrates with Superwall so you can track lifecycle events (trial started, subscription started, in-app purchase, etc.) and forward them to your ad networks.

To make this integration work end-to-end:

1. Activate the Appstack integration in the Superwall dashboard.
2. Add the following code:

```swift
Task {
  Superwall.shared.setUserAttributes(await AppstackAttributionSdk.shared.getAttributionParams() ?? [:])
}
Superwall.shared.register(placement: "onboarding_paywall")
```

## 📋 Requirements

- **iOS** 13.0+
- **Xcode** 14.0+
- **Swift** 5.0+

---

## 📦 Installation

### Swift Package Manager

You can install the SDK via **Swift Package Manager (SPM)** by adding the following dependency to your `Package.swift` file:

```swift
 dependencies: [
    .package(url: "https://github.com/appstack-tech/ios-appstack-sdk.git", from: "3.1.1")
 ]
```

Or directly from Xcode:

1. Go to **File > Add Packages**.
2. Enter the repository URL: `https://github.com/appstack/ios-appstack-sdk.git`.
3. Select the desired version and click **Add Package**.

---

## ⚙️ Initial Setup

Before using the SDK, configure the attribution endpoint using one of the following methods:

### **Option 1: Through Info.plist**

Add the following entry to your `Info.plist` file:

```xml
<key>NSAdvertisingAttributionReportEndpoint</key>
<string>https://ios-appstack.com/</string>
```

### **Option 2: Through Xcode**

1. Open your `Info.plist` file.
2. Add a new entry with the key: **Advertising attribution report endpoint URL**.
3. Set the value to: `https://ios-appstack.com/`.

---

## 🚀 Initialization

```swift
import AppstackSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Appstack SDK v2.1.0
        AppstackAttributionSdk.shared.configure(
            apiKey: "your_api_key",
            isDebug: true,  // Use development URL for testing
            endpointBaseUrl: nil,  // Use default endpoint
            logLevel: .info  // Set log level
        )
        return true
    }
}
```

### **SceneDelegate**

```swift
import AppstackSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        AppstackAttributionSdk.shared.configure(
            apiKey: "your_api_key",
            isDebug: true,
            endpointBaseUrl: nil,
            logLevel: .info
        )
    }
}
```

### **SwiftUI**

```swift
import SwiftUI
import AppstackSDK

@main
struct MyApp: App {
    init() {
        AppstackAttributionSdk.shared.configure(
            apiKey: "your_api_key",
            isDebug: true,
            endpointBaseUrl: nil,
            logLevel: .info
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

---

## 📡 Sending Events

### **Using EventType Enum**

The SDK provides better type safety with predefined event types:

```swift
// Standard events using EventType enum
AppstackAttributionSdk.shared.sendEvent(event: .LOGIN)
AppstackAttributionSdk.shared.sendEvent(event: .PURCHASE, parameters: ["revenue": 29.99, "currency": "EUR"])
AppstackAttributionSdk.shared.sendEvent(event: .SUBSCRIBE, parameters: ["revenue": 9.99, "currency": "EUR"])

// Custom events
AppstackAttributionSdk.shared.sendEvent(
    event: .CUSTOM, 
    name: "user_registered"
)
AppstackAttributionSdk.shared.sendEvent(
    event: .CUSTOM, 
    name: "purchase_completed", 
    parameters: ["revenue": 49.99, "currency": "EUR"]
)
```

### **Available EventType Values:**

```swift
public enum EventType: String {
    case PURCHASE = "PURCHASE"
    case SUBSCRIBE = "SUBSCRIBE" 
    case LOGIN = "LOGIN"
    case INSTALL = "INSTALL"
    case TUTORIAL_COMPLETE = "TUTORIAL_COMPLETE"
    case CUSTOM = "CUSTOM"  // For custom events
}
```

### **Revenue Range Matching**

The SDK automatically matches events with revenue parameters to configured **revenue ranges** in the Appstack platform:

- Events are tracked with their revenue values
- The SDK evaluates if the revenue falls within the configured ranges
- Conversion values are triggered when revenue requirements are met
- Multiple events can contribute to the same conversion value

### ⚠️ **Important Notes:**

- Always **initialize the SDK** before sending events
- Event names **must match** those defined in the **Appstack platform**
- For revenue events, always pass a `revenue` (or `price`) and a `currency` parameter
- Revenue ranges are configured in the Appstack platform and automatically synchronized

---

## 🔎 Apple Search Ads Attribution

### ✅ **Compatibility**

- Requires **iOS 14.3+**
- Works with **AppstackSDK version 2.1.0 or later**

### 📊 **Attribution Data Collection**

Apple Search Ads attribution is a **two-step process**:

1. **Collect the user's attribution token** and send it to Appstack.
2. **Appstack requests attribution data** from Apple within **24 hours**.

### 📌 **Standard vs. Detailed Attribution**

| Data Type  | Requires ATT Consent |
|------------|---------------------|
| Standard   | No                  |
| Detailed   | Yes                 |

### 🟢 **Standard Attribution (No User Consent Required)**

```swift
import AppstackSDK

if #available(iOS 14.3, *) {
    AppstackASAAttribution.shared.enableAppleAdsAttribution()
}
```

### 🔵 **Detailed Attribution (Requires User Consent)**

```swift
import AppTrackingTransparency
import AppstackSDK

if #available(iOS 14.3, *) {
    ATTrackingManager.requestTrackingAuthorization { status in
        // Enable ASA Attribution after getting permission
        AppstackASAAttribution.shared.enableAppleAdsAttribution()
        
        switch status {
        case .authorized:
            // User allowed tracking - detailed attribution available
            print("ATTrackingManager: Authorized")
        case .denied, .restricted, .notDetermined:
            // User denied tracking - standard attribution still works
            print("ATTrackingManager: Not authorized")
        @unknown default:
            break
        }
    }
}
```

### ✅ **Complete Implementation Example**

```swift
import UIKit
import AppTrackingTransparency
import AppstackSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Appstack SDK v2.1.0
        AppstackAttributionSdk.shared.configure(
            apiKey: "your_api_key",
            isDebug: true,  // Use development URL for testing
            endpointBaseUrl: nil,
            logLevel: .info
        )
        
        // Request tracking permission and enable ASA Attribution
        if #available(iOS 14.3, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                AppstackASAAttribution.shared.enableAppleAdsAttribution()
            }
        }
        
        return true
    }
}
```

⚠️ **Important Notes:**

- **Detailed attribution** requires **user consent**.
- **Standard attribution** works even if the user denies tracking.
- **Attribution data may take up to 24 hours** to appear in the Appstack dashboard.
- **iOS 14.3+**: Implement **ATT permission request** before enabling ASA tracking.

---

## ⚙️ Configuration Parameters

The `AppstackAttributionSdk.shared.configure()` method supports additional parameters:

### **Parameters:**

- **`apiKey`** (String, required): Your Appstack API key
- **`isDebug`** (Bool, default: false): If `true`, uses development URL automatically
- **`endpointBaseUrl`** (String?, default: nil): Custom endpoint URL (optional)
- **`logLevel`** (LogLevel, default: .info): Logging level for debugging

### **Configuration Examples:**

```swift
// Development configuration
AppstackAttributionSdk.shared.configure(
    apiKey: "your_api_key",
    isDebug: true,  // Uses https://api.event.dev.appstack.tech
    endpointBaseUrl: nil,
    logLevel: .debug
)

// Production configuration
AppstackAttributionSdk.shared.configure(
    apiKey: "your_api_key",
    isDebug: false,  // Uses production URL
    endpointBaseUrl: nil,
    logLevel: .info
)

// Custom endpoint configuration
AppstackAttributionSdk.shared.configure(
    apiKey: "your_api_key",
    isDebug: false,
    endpointBaseUrl: "https://your-custom-endpoint.com",
    logLevel: .warning
)
```

---

## 🔧 Advanced Configuration

### **SDK Behavior**

The SDK automatically:

- Fetches configuration from Appstack servers
- Manages conversion value updates based on event tracking
- Handles revenue range matching for conversion optimization
- Processes events in time-based windows (0-2 days, 3-7 days, 8-35 days)
- Queues events when configuration is not ready

### **Event Processing**

- Events are processed asynchronously to avoid blocking the main thread
- The SDK queues events if configuration is not yet loaded
- Revenue parameters are automatically validated and converted to numeric values
- Events are matched against configured revenue ranges in real-time

---



## ❓ Support

For any questions or issues, please:

- **Open an issue** in this repository.
- Contact our **support team** for further assistance.

📩 **[Contact](https://www.appstack.tech/contact)**

---

## EAC recommendations

### Revenue events (all ad networks)

For any event that represents revenue, we recommend sending:

- `revenue` **or** `price` (number)
- `currency` (string, e.g. `EUR`, `USD`)

```swift
AppstackAttributionSdk.shared.sendEvent(
    event: .PURCHASE,
    parameters: ["revenue": 4.99, "currency": "EUR"]
)
```

### Meta matching (send once per installation, as early as possible)

For Meta, we recommend sending **one time** (because the information will then be associated to every event sent with the same **installation ID**), **as early as possible**, the following parameters (if you have them):

- `email`
- `name` (first name + last name in the same parameter)
- `phone_number`
- `date_of_birth`
```
