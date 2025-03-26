# Appstack iOS SDK Integration Guide for SKAN Measurement

## Introduction

This comprehensive guide demonstrates how to integrate multiple measurement SDKs (Appstack, Meta, TikTok, and Firebase) in your iOS application while ensuring that only Appstack handles SKAdNetwork (SKAN) postbacks. Following these best practices will help you avoid attribution conflicts and ensure accurate campaign measurement.

## Why Single-SDK SKAN Handling Matters

When multiple SDKs attempt to set conversion values, it can lead to:

- Inconsistent attribution data
- Campaign measurement discrepancies
- Potential violation of Apple's guidelines

This guide shows you how to properly configure each SDK while maintaining Appstack as your primary SKAN handler.

## Integration Walkthrough

### 1️⃣ Appstack SDK - Primary SKAN Handler

Appstack will serve as your single source of truth for SKAN measurement.

#### Appstack Installation

Add the Appstack SDK using Swift Package Manager:

```swift
// In Xcode: File > Add Packages...
// Enter the package URL:
https://github.com/appstack-io/appstack-ios
```

#### Appstack Configuration

```swift
// In your AppDelegate or appropriate initialization point
Appstack.shared.configure("YOUR_APPSTACK_VERIFICATION_KEY")

// For event tracking
Appstack.shared.sendEvent(event: "purchase")
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

To prevent Meta from sending conversion values to SKAdNetwork:

**In code:**

```swift
// Disable automatic event logging
Settings.shared.isAutoLogAppEventsEnabled = false
   
// Disable SKAdNetwork reporting
Settings.shared.isSKAdNetworkReportEnabled = false
   
// Disable data processing for conversion values
Settings.shared.setDataProcessingOptions([], country: 0, state: 0)
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

## Unified Event Tracking Implementation

For consistent event tracking across all SDKs, implement a centralized tracking manager:

```swift
class TrackingManager {
    static let shared = TrackingManager()
    
    func trackEvent(name: String, parameters: [String: Any]? = nil) {
        // Log to Appstack (primary SKAN handler)
        Appstack.shared.sendEvent(event: name)
        
        // Log to Meta
        AppEvents.shared.logEvent(AppEvents.Name(name))
        
        // Log to TikTok
        TikTokBusiness.trackTTEvent(TikTokBaseEvent(eventName: name))
        
        // Log to Firebase
        Analytics.logEvent(name, parameters: parameters)
    }
}
```

## App Tracking Transparency Implementation

For iOS 14.5+, implement the App Tracking Transparency request:

```swift
import AppTrackingTransparency

func requestTrackingPermission() {
    if #available(iOS 14.0, *) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    // User allowed tracking
                    print("ATTrackingManager: Authorized")
                case .denied, .restricted, .notDetermined:
                    // User denied tracking
                    print("ATTrackingManager: Not authorized")
                @unknown default:
                    break
                }
            }
        }
    }
}
```

## Debugging SKAN Events

### 🔍 Monitoring SKAN Logs in Xcode

To effectively debug and monitor SKAN events:

1. Open Xcode and run your app on a **real device** (not simulator, as SKAdNetwork only works on real hardware)
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
| ✅ Consistent Event Naming | Use identical event names across all SDKs | High |
| ✅ Centralized Tracking | Implement a central tracking manager | High |
| ✅ ATT Implementation | Properly request tracking permission | High |
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

#### Conversion Value Discrepancies

- Confirm Appstack is correctly setting conversion values
- Review conversion value mapping logic
- Verify event triggers for conversion value updates

#### No SKAN Logs Visible

- Ensure you're testing on a physical device, not simulator
- Verify SKAdNetworkDebugMode is properly enabled
- Check that your app's bundle ID is correctly entered in the Console app filter

## Additional Resources

- [Apple's SKAdNetwork Documentation](https://developer.apple.com/documentation/storekit/skadnetwork)
- [App Tracking Transparency Framework](https://developer.apple.com/documentation/apptrackingtransparency)
- [Appstack SKAN Documentation](https://docs.app-stack.tech/documentation/sdk/quickstart)

---
