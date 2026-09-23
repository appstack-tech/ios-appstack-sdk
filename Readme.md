# AppstackSDK
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
![Version](https://img.shields.io/github/v/release/appstack-tech/ios-appstack-sdk?label=version)

SDK for integrating Appstack into iOS applications.

## Overview

The Appstack iOS SDK lets you:

- Track standardized and custom events
- Track revenue events with currency (for ROAS / optimization)
- Enable Apple Ads attribution
- Retrieve the Appstack installation ID and attribution parameters
- Handle Universal Links for already-installed apps

## Features (with examples)

### SDK initialization

```swift
import AppstackSDK

AppstackAttributionSdk.shared.configure(
    apiKey: "your_api_key",
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
Retrieve the attribution parameters for this install. The call suspends until the initial attribution match completes (success or failure), so there is no need to add a delay after `configure()`.

**Returns:** The query parameters of the matched ad click (for example `appstack_campaign`, `utm_source`, `gclid`), plus an `appstack_match_status` key that is always present. The result is never `nil`; the optional return type is kept only so existing `?? [:]` call sites keep compiling.

**`appstack_match_status` values:**

| Value | Meaning |
|-------|---------|
| `matched` | The install was attributed and the parameters are included. |
| `matched_no_params` | The install was attributed, but the link carried no tracking parameters. |
| `organic` | No matching click. The install is organic. |
| `skipped` | No match was attempted for this install (for example, an app update rather than a new install). |
| `failed` | The match request failed (offline, timeout, server error). The SDK retries; read the value again later. |
| `not_configured` | `configure()` has not been called. |

Only `failed` is worth re-reading later. The other values are final. The key name is also available as `AppstackAttributionSdk.attributionMatchStatusKey`.

**Example:**
```swift
let attributionParams = await AppstackAttributionSdk.shared.getAttributionParams() ?? [:]
let status = attributionParams[AppstackAttributionSdk.attributionMatchStatusKey] as? String

// Example output for an attributed install:
// [
//   "appstack_match_status": "matched",
//   "appstack_campaign": "summer_sale",
//   "utm_source": "google",
//   "gclid": "...",
//   ...
// ]
```

> Since 4.5.0 the result is never empty. If your code treated an empty result as "not attributed", check `appstack_match_status` instead.

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

### Universal Links

When a user taps an Appstack link and the app is already installed, iOS opens the app directly with the tapped URL. `handleUniversalLink` parses that URL locally, with no network request, and returns the `deeplinkId` and the link's query parameters so your app can route the user.

**Requirements:**

- A custom HTTPS domain provisioned for your app in Appstack (for example `links.example.com`). Shared `appstack.link` hosts are not supported.
- That domain in your app's **Associated Domains** entitlement: `applinks:links.example.com`. Add only the custom domain.
- Only standard links shaped as `https://links.example.com/{deeplinkId}` are parsed. Extra path segments, non-HTTPS URLs, and hosts not listed in `allowedHosts` (when you supply it) return `nil`.

**SwiftUI:**

```swift
import SwiftUI
import AppstackSDK

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // SwiftUI delivers Universal Links here, on cold start and while running.
                .onOpenURL { url in
                    route(url)
                }
        }
    }

    private func route(_ url: URL) {
        let options = LinkOptions(allowedHosts: ["links.example.com"])
        guard let link = AppstackAttributionSdk.shared.handleUniversalLink(url, options: options) else { return }
        // link.deeplinkId, link.queryParams (e.g. a custom "deep_link_path"), link.url
    }
}
```

**UIKit (SceneDelegate):** handle both the cold start and the already-running case:

```swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Cold start: the link arrives in the connection options.
    if let activity = connectionOptions.userActivities.first {
        handle(activity)
    }
}

func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    // App already running.
    handle(userActivity)
}

private func handle(_ activity: NSUserActivity) {
    guard let link = AppstackAttributionSdk.shared.handleUniversalLink(activity) else { return }
    // Route using link.deeplinkId / link.queryParams
}
```

Apps without a `SceneDelegate` can call the same method from `application(_:continue:restorationHandler:)`.

**Notes:**

- Safe to call before `configure()`.
- It does not send an event and does not change install attribution. If you want to count the tap as a re-engagement, call `sendEvent(...)` yourself.
- `allowedHosts` filters by hostname only. It does not verify that you own the domain.

## Integrations

### Superwall

Forward Appstack attribution to Superwall so lifecycle events (trial started, subscription started, in-app purchase, etc.) can be attributed back to the install.

**Requires Superwall SDK ≥ 4.12.11.**

1. Activate the Appstack integration in the Superwall dashboard.
2. After both SDKs are configured, pass the Appstack ID and attribution params:

```swift
// 1. Pass the Appstack ID — this is the key the Appstack pipeline joins on.
Superwall.shared.setIntegrationAttribute(
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

If you later request ATT permission, call `setAppstackAttributionParams()` again after the customer grants permission, rebuilding `params` from the latest values.

See the [RevenueCat integration docs](https://docs.appstack.tech/Integrations/revenuecat) for the canonical reference.

## 📋 Requirements

- **iOS** 15.0+ (Mac Catalyst 15.0+ supported since 4.4.0)
- **Xcode** 16.0+
- **Swift** 5.5+ (Swift 6 language mode supported since 4.7.1)

The SDK ships an Apple privacy manifest (since 4.5.1) declaring its required-reason API usage, so you don't need to add those entries to your app's manifest.

---

## 📦 Installation

### Swift Package Manager

You can install the SDK via **Swift Package Manager (SPM)** by adding the following dependency to your `Package.swift` file:

```swift
 dependencies: [
    .package(url: "https://github.com/appstack-tech/ios-appstack-sdk.git", from: "4.7.0")
 ]
```

Or directly from Xcode:

1. Go to **File > Add Packages**.
2. Enter the repository URL: `https://github.com/appstack-tech/ios-appstack-sdk.git`.
3. Select the desired version and click **Add Package**.

Since 4.4.0, SPM downloads the prebuilt `AppstackSDK.xcframework.zip` from the GitHub release instead of cloning the framework from the repository. Projects pinned to older versions keep resolving as before. We recommend updating to the latest 4.x release.

### Manual installation

Download `AppstackSDK.xcframework.zip` from the [latest release](https://github.com/appstack-tech/ios-appstack-sdk/releases/latest), unzip it, and drag `AppstackSDK.xcframework` into your Xcode project. In your app target's **Frameworks, Libraries, and Embedded Content**, set it to **Embed & Sign**.

---

## 🚀 Initialization

```swift
import AppstackSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppstackAttributionSdk.shared.configure(
            apiKey: "your_api_key",
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

Requesting ATT requires the `NSUserTrackingUsageDescription` key in your `Info.plist` — without it the prompt won't appear (treated as denied) and App Store review may reject the build:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>We use your data to measure ad performance and improve your experience.</string>
```

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

- **`apiKey`** (String, required): Your Appstack API key. Use your **development** API key for test builds and your **production** API key for App Store releases — this is how Appstack separates test traffic from production data.
- **`logLevel`** (LogLevel, default: .info): Logging level for debugging
- **`customerUserId`** (String?, default: nil): Optional identifier for your own user, associated with this installation. If the id is only known later (for example after login), use `setCustomerUserId(_:)` instead.

### **Configuration Examples:**

```swift
// Production configuration
AppstackAttributionSdk.shared.configure(
    apiKey: "your_api_key",
    logLevel: .info
)

// With a customer user id
AppstackAttributionSdk.shared.configure(
    apiKey: "your_api_key",
    logLevel: .info,
    customerUserId: "your-internal-user-id"
)
```

### **Setting the customer user id after login**

```swift
// After the user logs in
AppstackAttributionSdk.shared.setCustomerUserId("your-internal-user-id")
```

The id applies to every event sent from that point on, including events still buffered. It is safe to call from any thread, before or after `configure()`.

### **Separating development and production**

Appstack keeps test traffic isolated from production data by **environment**, and the environment is selected by the **API key** you configure. There is no debug flag to toggle — each key belongs to one environment:

- **Development API key** → events land in your Appstack development environment. Use it for local builds, QA, and TestFlight. These events are **not** forwarded to your ad networks, so they never pollute production conversions.
- **Production API key** → events land in your production environment and are eligible for ad-network forwarding. Use it only for App Store releases.

The recommended way to wire this is to select the key at compile time so you can never ship a debug build pointing at production:

```swift
import AppstackSDK

enum AppstackConfig {
    static var apiKey: String {
        #if DEBUG
        return "your_development_api_key"
        #else
        return "your_production_api_key"
        #endif
    }

    static var logLevel: LogLevel {
        #if DEBUG
        return .debug  // most verbose: adds attribution-match troubleshooting details
        #else
        return .error  // production: only log errors
        #endif
    }
}

AppstackAttributionSdk.shared.configure(
    apiKey: AppstackConfig.apiKey,
    logLevel: AppstackConfig.logLevel
)
```

> **Log levels** (least to most verbose, since 4.3.1): `.off` (no SDK logs), `.error` (actionable errors only, such as an invalid API key or incorrect SDK usage), `.info` (errors plus lifecycle confirmations such as "Appstack SDK initialized"), and `.debug` (info plus troubleshooting details such as the attribution match outcome). Use `.debug` while developing and `.error` in production.

> **Verifying your setup:** run a debug build, trigger a few events, and confirm they appear in the **development** environment of the Appstack dashboard (not production). With `logLevel: .debug` the SDK logs its initialization and the attribution match result in the Xcode console.

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

On success, locally cached attribution data and the stored customer user id are also cleared.

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

- Check the [Troubleshooting guide](./USAGE.md#troubleshooting) in `USAGE.md` for common issues (events not appearing, ASA attribution, RevenueCat/Superwall integration coverage).
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
