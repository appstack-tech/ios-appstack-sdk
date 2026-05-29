# AppstackSDK
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

if #available(iOS 15.0, *) {
    AppstackASAAttribution.shared.enableAppleAdsAttribution()
}
```

## Integrations

### Superwall

Forward Appstack attribution to Superwall so lifecycle events (trial started, subscription started, in-app purchase, etc.) can be attributed back to the install.

**Requires Superwall SDK ≥ 4.12.11.**

1. Activate the Appstack integration in the Superwall dashboard.
2. After both SDKs are configured, pass the Appstack ID and attribution params:

```swift
// 1. Pass the Appstack ID — this is the key the Appstack pipeline joins on.
await Superwall.shared.setIntegrationAttribute(
    IntegrationAttribute.appstackId,
    AppstackAttributionSdk.shared.getAppstackId()
)

// 2. Pass attribution params as user attributes (available for campaign filters).
Task {
    Superwall.shared.setUserAttributes(
        await AppstackAttributionSdk.shared.getAttributionParams() ?? [:]
    )
}

Superwall.shared.register(placement: "onboarding_paywall")
```

See the [Superwall integration docs](https://docs.appstack.tech/Integrations/superwall) for the canonical reference.

### RevenueCat

Forward Appstack attribution to RevenueCat so subscription events carry `$appstackId`, campaign attributes (`$mediaSource`, `$campaign`, `$adGroup`, `$ad`, `$keyword`), and click IDs (`fbclid`, `gclid`, `wbraid`, `gbraid`, `ttclid`).

**Requires RevenueCat iOS SDK ≥ 5.61.0.**

After configuring both SDKs and before the first purchase, build the params dictionary from both `getAttributionParams()` and `getAppstackId()` and pass it to RevenueCat. A single call sets all attributes and refreshes offerings so AppStack-based targeting is applied before it returns.

```swift
Task {
    var params = await AppstackAttributionSdk.shared.getAttributionParams() ?? [:]
    if let id = AppstackAttributionSdk.shared.getAppstackId() {
        params["appstack_id"] = id
    }
    do {
        _ = try await Purchases.shared.attribution.setAppstackAttributionParams(params)
    } catch {
        // Handle sync / offerings fetch error
    }
}
```

If you later request ATT permission, call `setAppstackAttributionParams()` again after the customer grants permission, rebuilding `params` from the latest values. The `AdSupport` framework is required to collect the IDFA on iOS.

See the [RevenueCat integration docs](https://docs.appstack.tech/Integrations/revenuecat) for the canonical reference.

## 📋 Requirements

- **iOS** 15.0+
- **Xcode** 14.0+
- **Swift** 5.0+

---

## 📦 Installation

### Swift Package Manager

You can install the SDK via **Swift Package Manager (SPM)** by adding the following dependency to your `Package.swift` file:

```swift
 dependencies: [
    .package(url: "https://github.com/appstack-tech/ios-appstack-sdk.git", from: "4.1.0")
 ]
```

Or directly from Xcode:

1. Go to **File > Add Packages**.
2. Enter the repository URL: `https://github.com/appstack-tech/ios-appstack-sdk.git`.
3. Select the desired version and click **Add Package**.

---

## 🚀 Initialization

```swift
import AppstackSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppstackAttributionSdk.shared.configure(
            apiKey: "your_api_key",
            isDebug: false,
            logLevel: .info
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
            isDebug: false,
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
            isDebug: false,
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

> The SDK also sends an automatic `INSTALL` event on first launch, so you don't need to send it manually.

```swift
public enum EventType: String {
    // Authentication & account
    case LOGIN
    case SIGN_UP
    case REGISTER          // Alias for SIGN_UP

    // Monetization
    case PURCHASE
    case ADD_TO_CART
    case ADD_TO_WISHLIST
    case INITIATE_CHECKOUT
    case START_TRIAL
    case SUBSCRIBE

    // Games / progression
    case LEVEL_START
    case LEVEL_COMPLETE

    // Engagement
    case TUTORIAL_COMPLETE
    case SEARCH
    case VIEW_ITEM
    case VIEW_CONTENT
    case SHARE

    // Catch-all
    case CUSTOM
}
```

### ⚠️ **Important Notes:**

- Always **initialize the SDK** before sending events
- Event names **must match** those defined in the **Appstack platform**
- For revenue events, always pass a `revenue` (or `price`) and a `currency` parameter

---

## 🔎 Apple Search Ads Attribution

### ✅ **Compatibility**

- Requires **iOS 15.0+**

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

if #available(iOS 15.0, *) {
    AppstackASAAttribution.shared.enableAppleAdsAttribution()
}
```

### 🔵 **Detailed Attribution (Requires User Consent)**

```swift
import AppTrackingTransparency
import AppstackSDK

if #available(iOS 15.0, *) {
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
        AppstackAttributionSdk.shared.configure(
            apiKey: "your_api_key",
            isDebug: false,
            logLevel: .info
        )
        
        // Request tracking permission and enable ASA Attribution
        if #available(iOS 15.0, *) {
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
- **iOS 15.0+**: Implement **ATT permission request** before enabling ASA tracking.

---

## ⚙️ Configuration Parameters

The `AppstackAttributionSdk.shared.configure()` method supports the following parameters:

### **Parameters:**

- **`apiKey`** (String, required): Your Appstack API key
- **`isDebug`** (Bool, default: false): If `true`, the SDK targets the Appstack development environment. Set to `false` for production builds
- **`logLevel`** (LogLevel, default: .info): Logging level for debugging
- **`customerUserId`** (String?, default: nil): Optional identifier for your own user, associated with this installation

### **Configuration Examples:**

```swift
// Production configuration
AppstackAttributionSdk.shared.configure(
    apiKey: "your_api_key",
    isDebug: false,
    logLevel: .info
)

// With a customer user id
AppstackAttributionSdk.shared.configure(
    apiKey: "your_api_key",
    isDebug: false,
    logLevel: .info,
    customerUserId: "your-internal-user-id"
)
```

---

## 🧹 Deleting user data

For GDPR/CCPA flows you can request that Appstack delete the data stored for the current installation:

```swift
Task {
    do {
        try await AppstackAttributionSdk.shared.deleteUserData()
    } catch {
        // Handle network or auth errors
    }
}
```

On success, locally cached attribution data is also cleared.

---

## 🔧 Advanced Configuration

### **SDK Behavior**

The SDK automatically:

- Fetches configuration from Appstack servers on launch
- Sends an `INSTALL` event on first launch
- Runs a single attribution match at launch
- Queues events when configuration is not ready

### **Event Processing**

- Events are processed asynchronously to avoid blocking the main thread
- The SDK queues events if configuration is not yet loaded
- Revenue parameters are automatically validated and converted to numeric values

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
