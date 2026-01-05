# iOS Appstack SDK - Usage Guide

Track events and revenue with Apple Search Ads attribution in your iOS app.

## Installation

### Swift Package Manager

You can install the SDK via **Swift Package Manager (SPM)** by adding the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/appstack-tech/ios-appstack-sdk.git", from: "3.2.0")
]
```

Or directly from Xcode:

1. Go to **File > Add Packages**.
2. Enter the repository URL: `https://github.com/appstack-tech/ios-appstack-sdk.git`.
3. Select the desired version and click **Add Package**.

### CocoaPods

Add the following line to your Podfile:

```ruby
pod 'AppstackSDK', :git => 'https://github.com/appstack-tech/ios-appstack-sdk.git', :tag => '3.2.0'
```

## Quick Start

```swift
import AppstackSDK

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Appstack SDK
        AppstackAttributionSdk.shared.configure(
            apiKey: "your-ios-api-key",
            isDebug: false,
            endpointBaseUrl: nil,
            logLevel: .info
        )

        // Enable Apple Search Ads attribution (iOS 14.3+)
        if #available(iOS 14.3, *) {
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

    private fun trackSignup() {
        AppstackAttributionSdk.shared.sendEvent(event: .SIGN_UP, name: "email_signup")
    }
}
```

## Installation ID + attribution parameters

```swift
let appstackId = AppstackAttributionSdk.shared.getAppstackId()
let attributionParams = AppstackAttributionSdk.shared.getAttributionParams()
```

## iOS Configuration (Required)

### Advertising Attribution Report Endpoint

Add your Application's **Advertising attribution report endpoint** to enable Apple Search Ads attribution:

**Option 1: Through Info.plist**

Add the following entry to your `Info.plist` file:

```xml
<key>NSAdvertisingAttributionReportEndpoint</key>
<string>https://ios-appstack.com/</string>
```

**Option 2: Through Xcode**

1. Open your `Info.plist` file.
2. Add a new entry with the key: **Advertising attribution report endpoint URL**.
3. Set the value to: `https://ios-appstack.com/`.

### App Tracking Transparency (Recommended)

For detailed Apple Search Ads attribution, request user permission:

```swift
import AppTrackingTransparency

if #available(iOS 14.5, *) {
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
    event: .CUSTOM,
    name: "level_completed",
    parameters: ["level": 1, "score": 1500, "time_seconds": 45]
)
```
</details>

<details>
<summary>Complete Event List</summary>

**Monetization:**
- `PURCHASE` - Purchase completed
- `SUBSCRIBE` - Subscription started

**User Account:**
- `SIGN_UP` / `REGISTER` - Account created
- `LOGIN` - User signed in

**Engagement:**
- `TUTORIAL_COMPLETE` - Onboarding done
- `CUSTOM` - Custom events
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
AppstackAttributionSdk.shared.sendEvent(event: .SIGN_UP, name: "email_signup")

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
            name: "signup",
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

**Standard Attribution (No User Consent Required):**
```swift
if #available(iOS 14.3, *) {
    AppstackASAAttribution.shared.enableAppleAdsAttribution()
}
```

**Detailed Attribution (Requires User Consent):**
```swift
import AppTrackingTransparency

if #available(iOS 14.3, *) {
    ATTrackingManager.requestTrackingAuthorization { status in
        AppstackASAAttribution.shared.enableAppleAdsAttribution()
    }
}
```

⚠️ **Important Notes:**
- Detailed attribution requires user consent via ATT
- Standard attribution works even if user denies tracking
- Attribution data may take up to 24 hours to appear
- Requires iOS 14.3+
</details>

### Troubleshooting

<details>
<summary>Common Issues</summary>

**Events not appearing:**
- Check API key is correct
- Enable debug mode to see logs (`isDebug: true`)
- Ensure network connectivity

**Apple Search Ads attribution not working:**
- Verify Info.plist configuration
- Check iOS version (14.3+ required)
- Wait up to 24 hours for attribution data

**SDK initialization issues:**
- Initialize SDK in `AppDelegate.applicationDidFinishLaunching`
- Call configuration before any tracking calls
</details>

---

Need help? Check the [GitHub repository](https://github.com/appstack-tech/ios-appstack-sdk) or contact support.
