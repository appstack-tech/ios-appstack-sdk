# Appstack iOS SDK Integration Guide for SKAN Measurement

## Introduction

This comprehensive guide demonstrates how to integrate multiple measurement SDKs (Appstack, Meta, TikTok, and Firebase) in your iOS application while ensuring that only Appstack handles SKAdNetwork (SKAN) postbacks. Following these best practices will help you avoid attribution conflicts and ensure accurate campaign measurement.

**🆕 New in SDK v2.1.0:**
- Enhanced revenue parameter support for better conversion tracking
- Improved Apple Search Ads attribution with iOS 14.3+ compatibility
- Automatic revenue range matching for optimized conversion values
- Simplified configuration process
- **NEW API**: Updated to use `AppstackAttributionSdk` with `EventType` enum
- **NEW API**: Enhanced configuration with debug mode and custom endpoints

## Why Single-SDK SKAN Handling Matters

When multiple SDKs attempt to set conversion values, it can lead to:

- Inconsistent attribution data
- Campaign measurement discrepancies
- Potential violation of Apple's guidelines

This guide shows you how to configure each SDK properly while maintaining Appstack as your primary SKAN handler.

## Integration Walkthrough

### 1️⃣ Appstack SDK - Primary SKAN Handler

Appstack will serve as your single source of truth for SKAN measurement with enhanced revenue tracking.

#### Appstack Installation

Add the Appstack SDK using Swift Package Manager:

```swift
// In Xcode: File > Add Packages...
// Enter the package URL:
https://github.com/appstack-tech/ios-appstack-sdk
```

#### Appstack Configuration

**Step 1: Configure Attribution Endpoint**

Add the following entry to your `Info.plist` file:

```xml
<key>NSAdvertisingAttributionReportEndpoint</key>
<string>https://ios-appstack.com/</string>
```

**Step 2: Initialize the SDK**

```swift
// In your AppDelegate or appropriate initialization point
AppstackAttributionSdk.shared.configure(
    apiKey: "YOUR_APPSTACK_VERIFICATION_KEY",
    isDebug: true,  // Use development URL for testing
    endpointBaseUrl: nil,  // Use default endpoint
    logLevel: .info  // Set log level
)
```

**Step 3: Track Events with Revenue Parameters**

```swift
// Standard events using EventType enum
AppstackAttributionSdk.shared.sendEvent(event: .LOGIN)
AppstackAttributionSdk.shared.sendEvent(event: .PURCHASE, revenue: 29.99)
AppstackAttributionSdk.shared.sendEvent(event: .SUBSCRIBE, revenue: 10.99)

// Custom events
AppstackAttributionSdk.shared.sendEvent(
    event: .CUSTOM, 
    name: "user_registered"
)
AppstackAttributionSdk.shared.sendEvent(
    event: .CUSTOM, 
    name: "purchase_completed", 
    revenue: 29.99
)

// Revenue parameter supports Decimal type
AppstackAttributionSdk.shared.sendEvent(
    event: .CUSTOM, 
    name: "subscription", 
    revenue: Decimal(10.99)
)
```

**Step 4: Enable Apple Search Ads Attribution**

```swift
// For iOS 14.3+ compatibility
if #available(iOS 14.3, *) {
    AppstackASAAttribution.shared.enableAppleAdsAttribution()
}
```

> 📘 **Note**: For complete implementation details, refer to the [Appstack iOS SDK Documentation](https://docs.app-stack.tech/documentation/sdk/quickstart).

### 2️⃣ Meta (Facebook) SDK

#### Meta Installation

Add the Meta SDK using Swift Package Manager:

```swift
// In Xcode: File > Add Packages...
// Enter the package URL:
https://github.com/facebook/facebook-ios-sdk
```

#### Meta Configuration

```swift
// In your AppDelegate
ApplicationDelegate.shared.application(
    UIApplication.shared,
    didFinishLaunchingWithOptions: launchOptions
)
```

#### ⚠️ Meta SKAN Deactivation (Critical)

To prevent Meta from sending conversion values to SKAdNetwork (do it in both code and platform):

**In code:**

```swift
// Disable automatic event logging
Settings.shared.isAutoLogAppEventsEnabled = false
```

**In Meta Business Manager:**

1. Navigate to business.facebook.com
2. Go to "Data Sources" → "Settings"
3. Under "Apple's SKAdNetwork" → "View Additional Settings"
4. Toggle off "SKAdNetwork for the Facebook SDK"

> 📘 **Resources**: [Meta iOS SDK Documentation](https://developers.facebook.com/docs/ios/) | [Meta SKAdNetwork Integration](https://developers.facebook.com/docs/SKAdNetwork)

### 3️⃣ TikTok SDK

#### TikTok Installation

Add the TikTok SDK using Swift Package Manager:

```swift
// In Xcode: File > Add Packages...
// Enter the package URL:
https://github.com/tiktok/tiktok-business-ios-sdk

// Make sure to select version 1.3.8 or higher
```

> 📘 **Note**: Version 1.3.8 or higher is required for Swift Package Manager support.

#### TikTok Configuration

```swift
let tiktokConfig = TikTokConfig(appId: "YOUR_APP_ID", tiktokAppId: "YOUR_TIKTOK_APP_ID")
TikTokBusiness.initializeSdk(tiktokConfig)
```

#### ⚠️ TikTok SKAN Deactivation (Critical)

```swift
// Disable SKAdNetwork support
tiktokConfig?.disableSKAdNetworkSupport()
```

> 📘 **Resources**: [TikTok iOS SDK Documentation](https://ads.tiktok.com/marketing_api/docs?id=1739381752981505) | [TikTok App Events SDK Integration Guide](https://ads.tiktok.com/help/article/how-to-integrate-tiktok-app-events-sdk)

### 4️⃣ Firebase (Google) SDK

#### Firebase Installation

Add the Firebase SDK using Swift Package Manager:

```swift
// In Xcode: File > Add Packages...
// Enter the package URL:
https://github.com/firebase/firebase-ios-sdk
```

Add your `GoogleService-Info.plist` file to your project.

#### Firebase Configuration

```swift
FirebaseApp.configure()
```

#### ⚠️ Firebase SKAN Deactivation (Critical)

Add the following key to your `Info.plist` file:

```xml
<key>GOOGLE_ANALYTICS_REGISTRATION_WITH_AD_NETWORK_ENABLED</key>
<false/>
```

> 📘 **Resources**: [Firebase iOS SDK Documentation](https://firebase.google.com/docs/ios/setup) | [Firebase Analytics Documentation](https://firebase.google.com/docs/analytics/get-started?platform=ios)

## Enhanced Event Tracking Implementation

For consistent event tracking across all SDKs with revenue optimization, implement a centralized tracking manager:

```swift
class TrackingManager {
    static let shared = TrackingManager()
    
    // Using EventType enum for type safety
    func trackEvent(eventType: EventType, customEventName: String? = nil, parameters: [String: Any]? = nil) {
        // Send to Appstack with revenue parameter extraction
        if let parameters = parameters, let revenue = extractRevenue(from: parameters) {
            if eventType == .CUSTOM, let customName = customEventName {
                AppstackAttributionSdk.shared.sendEvent(event: eventType, name: customName, revenue: revenue)
            } else {
                AppstackAttributionSdk.shared.sendEvent(event: eventType, revenue: revenue)
            }
        } else {
            if eventType == .CUSTOM, let customName = customEventName {
                AppstackAttributionSdk.shared.sendEvent(event: eventType, name: customName)
            } else {
                AppstackAttributionSdk.shared.sendEvent(event: eventType)
            }
        }
        
        // Send to other SDKs using the event name
        let eventName = eventType == .CUSTOM ? (customEventName ?? "custom_event") : eventType.rawValue.lowercased()
        
        // Send to other SDKs
        AppEvents.shared.logEvent(AppEvents.Name(eventName))
        TikTokBusiness.trackTTEvent(TikTokBaseEvent(eventName: eventName))
        Analytics.logEvent(eventName, parameters: parameters)
    }
    
    private func extractRevenue(from parameters: [String: Any]) -> Decimal? {
        let revenueKeys = ["revenue", "value", "price", "amount"]
        for key in revenueKeys {
            if let value = parameters[key] {
                return value as? Decimal
            }
        }
        return nil
    }
}
```

## Revenue Range Matching

**🆕 New Feature**: The SDK now automatically matches events with revenue parameters to configured revenue ranges in the Appstack platform:

- Events are tracked with their revenue values
- The SDK evaluates if the revenue falls within configured ranges
- Conversion values are triggered when revenue requirements are met
- Multiple events can contribute to the same conversion value

### Example Revenue Events:

```swift
// Add to cart with product price
TrackingManager.shared.trackEvent(
    eventType: .CUSTOM,
    customEventName: "add_to_cart",
    parameters: ["revenue": 29.99, "product_id": "123"]
)

// Purchase with total order value (using standard PURCHASE event)
TrackingManager.shared.trackEvent(
    eventType: .PURCHASE,
    parameters: ["revenue": 149.97, "currency": "USD", "item_count": 3]
)
```

## Apple Search Ads Attribution (Enhanced)

### ✅ **Compatibility**

- Requires **iOS 14.3+** (improved from previous iOS 15.0+ requirement)
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
            apiKey: "your_verification_key",
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
- **iOS 14.3+**: Now supports both standard and detailed attribution.

## Debugging SKAN Events

### 🔍 Monitoring SKAN Logs in Xcode

To effectively debug and monitor SKAN events:

1. Open Xcode and run your app on a **real device** (not the simulator, as SKAdNetwork only works on real hardware)
2. Open the Console app on your Mac (`Applications` > `Utilities` > `Console`)
3. Filter logs by `process: your-app-bundle-id`
4. Look for messages related to `SKAdNetwork`

### 🐞 Enabling Enhanced SKAN Debugging

For more detailed SKAN logs:

1. Add the following environment variable when launching your app:

   ```bash
   -SKAdNetworkDebugMode YES
   ```

   To set this in Xcode:
   - Select your target
   - Go to "Edit Scheme" > "Run" > "Arguments"
   - Add `-SKAdNetworkDebugMode YES` to "Arguments Passed On Launch"

2. Check for messages like:
   - `SKAdNetwork: Sending postback for...`
   - `SKAdNetwork: Successfully submitted postback`
   - `SKAdNetwork: Conversion value updated to...`

3. Look for potential errors:
   - `SKAdNetwork: Failed to submit postback...`
   - Issues with conversion value updates

> ⚠️ **Important**: SKAdNetwork debugging only works on physical devices, not in the simulator.

## Best Practices Checklist

| Practice | Description | Importance |
|----------|-------------|------------|
| ✅ Single SKAN Handler | Use Appstack exclusively for SKAN postbacks | Critical |
| ✅ Revenue Parameters | Use revenue parameters for all purchase events | High |
| ✅ Consistent Event Naming | Use identical event names across all SDKs | High |
| ✅ Centralized Tracking | Implement a central tracking manager | High |
| ✅ ASA Attribution | Enable Apple Search Ads attribution tracking | High |
| ✅ Thorough Testing | Verify only Appstack sends conversion values | High |

## Troubleshooting Guide

### Common Issues and Solutions

#### Multiple Postbacks Detected

- Verify SKAN reporting is disabled in all third-party SDKs
- Check for correct implementation of disabling code
- Confirm settings in respective dashboards (especially Meta)

#### Missing Events in Dashboards

- Ensure event names are consistent across all SDKs
- Verify network connectivity during event triggers
- Check for SDK initialization issues
- Confirm revenue parameters are being sent correctly

#### Conversion Value Discrepancies

- Confirm Appstack is correctly setting conversion values
- Review conversion value mapping logic in dashboard
- Verify event triggers for conversion value updates
- Check revenue range configuration

#### Revenue Parameters Not Working

- Ensure you're using the correct parameter key: `.revenue`
- Verify revenue values are numeric (Double, Int, Float, or String)
- Check that events with revenue are configured in the Appstack dashboard
- Review revenue range settings

#### No SKAN Logs Visible

- Ensure you're testing on a physical device, not the simulator
- Verify SKAdNetworkDebugMode is correctly enabled
- Check that your app's bundle ID is correctly entered in the Console app filter

## Additional Resources

- [Apple's SKAdNetwork Documentation](https://developer.apple.com/documentation/storekit/skadnetwork)
- [App Tracking Transparency Framework](https://developer.apple.com/documentation/apptrackingtransparency)
- [Appstack SDK Documentation](https://docs.app-stack.tech/documentation/sdk/quickstart)
- [Apple Search Ads Attribution](https://searchads.apple.com/help/reporting/0028-apple-search-ads-attribution-api)

---

📩 **[Contact](https://www.appstack.tech/contact)**
