# iOS Appstack SDK - Usage Guide

Track events and revenue with Apple Search Ads attribution in your iOS app.

## Installation

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

## Quick Start

```swift
import AppstackSDK

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Appstack SDK
        AppstackAttributionSdk.shared.configure(
            apiKey: "your-ios-api-key",
            logLevel: .info
        )

        // Enable Apple Search Ads attribution (iOS 15.0+)
        if #available(iOS 15.0, *) {
            AppstackASAAttribution.shared.enableAppleAdsAttribution()
        }

        return true
    }
}

// Track events in your view controllers
class ViewController: UIViewController {
    private func trackPurchase() {
        AppstackAttributionSdk.shared.sendEvent(
            event: .PURCHASE,
            parameters: ["revenue": 29.99, "currency": "USD"]
        )
    }

    private func trackSignup() {
        AppstackAttributionSdk.shared.sendEvent(event: .SIGN_UP)
    }
}
```

## Installation ID + attribution parameters

```swift
let appstackId = AppstackAttributionSdk.shared.getAppstackId()
let attributionParams = await AppstackAttributionSdk.shared.getAttributionParams() ?? [:]
```

`getAttributionParams()` is `async` and suspends until the initial attribution match completes (success or failure). Call it inside a `Task { }` or another async context.

## Identifying users (optional)

If you want to associate Appstack events with your own user identifier, pass `customerUserId` at configure time:

```swift
AppstackAttributionSdk.shared.configure(
    apiKey: "your-ios-api-key",
    logLevel: .info,
    customerUserId: "your-internal-user-id"
)
```

## Deleting user data

For GDPR/CCPA flows you can ask Appstack to delete the stored data for the current installation:

```swift
Task {
    do {
        try await AppstackAttributionSdk.shared.deleteUserData()
    } catch {
        // Handle network/auth errors
    }
}
```

## Integrations

To attribute purchases and subscriptions from third-party monetization tools, the SDK integrates with **Superwall** and **RevenueCat**. See the [Readme](./Readme.md#integrations) for setup instructions.

## iOS Configuration

### App Tracking Transparency (Recommended)

ATT is optional — the SDK works without it. Request it only if you want detailed Apple Search Ads attribution. If you do, you **must** add the `NSUserTrackingUsageDescription` key to your `Info.plist`, otherwise the prompt won't appear (the system treats it as denied) and App Store review may reject the build:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>We use your data to measure ad performance and improve your experience.</string>
```

Then request user permission:

```swift
import AppTrackingTransparency

if #available(iOS 15.0, *) {
    ATTrackingManager.requestTrackingAuthorization { status in
        switch status {
        case .authorized:
            // Detailed attribution available
            print("Tracking authorized")
        case .denied, .restricted, .notDetermined:
            // Standard attribution still works
            print("Tracking not authorized")
        @unknown default:
            break
        }
    }
}
```

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

## Advanced Topics

### Event Examples

<details>
<summary>Common Events</summary>

| Event | Usage |
|-------|-------|
| `PURCHASE` | User buys something (include revenue) |
| `SIGN_UP` | User creates account |
| `LOGIN` | User signs in |
| `TUTORIAL_COMPLETE` | Onboarding finished |
| `CUSTOM` | App-specific events |

```swift
// E-commerce Events
AppstackAttributionSdk.shared.sendEvent(
    event: .PURCHASE,
    parameters: ["revenue": 89.97, "order_id": "456", "items_count": 3]
)

// Gaming Events
AppstackAttributionSdk.shared.sendEvent(
    event: .LEVEL_COMPLETE,
    parameters: ["level": 1, "score": 1500, "time_seconds": 45]
)
```
</details>

<details>
<summary>Complete Event List</summary>

> The SDK also sends an automatic `INSTALL` event on first launch, so you don't need to send it manually.

**Authentication & account:**
- `LOGIN` - User signed in
- `SIGN_UP` - Account created
- `REGISTER` - Alias for `SIGN_UP`

**Monetization:**
- `PURCHASE` - Purchase completed
- `ADD_TO_CART` - Item added to cart
- `ADD_TO_WISHLIST` - Item added to wishlist
- `INITIATE_CHECKOUT` - Checkout started
- `START_TRIAL` - Free trial started
- `SUBSCRIBE` - Subscription started

**Games / progression:**
- `LEVEL_START` - Level started
- `LEVEL_COMPLETE` - Level completed

**Engagement:**
- `TUTORIAL_COMPLETE` - Onboarding finished
- `SEARCH` - In-app search performed
- `VIEW_ITEM` - Product or item viewed
- `VIEW_CONTENT` - Generic content viewed
- `SHARE` - Content shared

**Catch-all:**
- `CUSTOM` - App-specific events (requires a `name`)
</details>

### Best Practices

<details>
<summary>Using Parameters</summary>

The `sendEvent` method supports flexible parameters for rich event tracking:

```swift
// ✅ Track purchases with revenue and additional context
AppstackAttributionSdk.shared.sendEvent(
    event: .PURCHASE,
    parameters: [
        "revenue": 29.99,
        "currency": "USD",
        "product_id": "premium_monthly",
        "subscription_type": "monthly"
    ]
)

// ✅ Track custom events with rich metadata
AppstackAttributionSdk.shared.sendEvent(
    event: .CUSTOM,
    name: "video_watched",
    parameters: [
        "video_id": "intro_tutorial",
        "duration_seconds": 120,
        "completion_rate": 0.95,
        "quality": "1080p"
    ]
)

// ✅ Simple events without parameters
AppstackAttributionSdk.shared.sendEvent(event: .SIGN_UP)

// ⚠️ Revenue values should be in decimal dollars, not cents
AppstackAttributionSdk.shared.sendEvent(
    event: .PURCHASE,
    parameters: ["revenue": 2999.0] // This would be $2,999, not $29.99!
)
```

**Supported parameter types:**
- `String`, `Int`, `Double`, `Bool`
- Any JSON-serializable value
</details>

<details>
<summary>Recommended Patterns</summary>

**1. Use wrapper class:**
```swift
class Analytics {
    static func trackPurchase(item: String, price: Double, currency: String = "USD") {
        AppstackAttributionSdk.shared.sendEvent(
            event: .PURCHASE,
            parameters: ["revenue": price, "currency": currency, "item": item]
        )
    }

    static func trackSignup(method: String) {
        AppstackAttributionSdk.shared.sendEvent(
            event: .SIGN_UP,
            parameters: ["method": method]
        )
    }
}
```

**2. Always include revenue for purchases:**
```swift
AppstackAttributionSdk.shared.sendEvent(
    event: .PURCHASE,
    parameters: ["revenue": 14.99, "currency": "USD"]
)
```
</details>

### Apple Search Ads Attribution

<details>
<summary>Standard vs. Detailed Attribution</summary>

| Data Type  | Requires ATT Consent | Availability |
|------------|---------------------|--------------|
| Standard   | No                  | Immediate    |
| Detailed   | Yes                 | 24 hours     |

> Requires iOS 15.0+

**Standard Attribution (No User Consent Required):**
```swift
if #available(iOS 15.0, *) {
    AppstackASAAttribution.shared.enableAppleAdsAttribution()
}
```

**Detailed Attribution (Requires User Consent):**
```swift
import AppTrackingTransparency

if #available(iOS 15.0, *) {
    ATTrackingManager.requestTrackingAuthorization { status in
        AppstackASAAttribution.shared.enableAppleAdsAttribution()
    }
}
```

⚠️ **Important Notes:**
- Detailed attribution requires user consent via ATT
- Standard attribution works even if user denies tracking
- Attribution data may take up to 24 hours to appear
- Requires iOS 15.0+
</details>

### Troubleshooting

<details>
<summary>Common Issues</summary>

**Events not appearing:**
- Check API key is correct
- Increase log verbosity with `logLevel: .info` (currently the most verbose level; this ordering will change in a future release so `.debug` becomes the most verbose)
- Ensure network connectivity

**Apple Search Ads attribution not working:**
- Ensure `enableAppleAdsAttribution()` is called after `configure()`
- Check iOS version (15.0+ required)
- For detailed attribution, confirm ATT is requested and `NSUserTrackingUsageDescription` is set (see [App Tracking Transparency](#app-tracking-transparency-recommended))
- Apple Search Ads data can take up to 24 hours to appear (Apple-side delay)

**SDK initialization issues:**
- Initialize SDK in `application(_:didFinishLaunchingWithOptions:)`
- Call configuration before any tracking calls

**RevenueCat / Superwall events missing the Appstack ID (coverage below 50%):**

If your dashboard shows an *"Appstack is receiving RevenueCat (or Superwall) events without the Appstack ID"* banner — or integration coverage is stuck below the 50% threshold and you can't map events to Meta/TikTok/Google — the Appstack ID isn't reaching the integration:
- **Verify the wiring.** Confirm you call `getAppstackId()` and pass it through (`setIntegrationAttribute(.appstackId, …)` for Superwall, `setAppstackAttributionParams(...)` with `appstack_id` for RevenueCat). A missing or misconfigured call is the most common cause.
- **Configure all SDKs in the same place.** Initialize Appstack, RevenueCat, and Superwall in a single lifecycle entry point (e.g. all inside `application(_:didFinishLaunchingWithOptions:)`). Splitting them across `AppDelegate` and `SceneDelegate` can create a race where RevenueCat/Superwall start before the Appstack ID is ready, so their events go out without it.
- **Expect a ramp-up period.** Renewals from subscribers who installed *before* you shipped the SDK have no Appstack ID and drag the ratio down. Coverage rises as new installs adopt the SDK, so the banner can take time to clear after release.
</details>

---

Need help? Check the [GitHub repository](https://github.com/appstack-tech/ios-appstack-sdk) or contact support.
