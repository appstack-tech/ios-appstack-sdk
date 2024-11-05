# AppstackSDK

SDK for integrating Appstack into iOS applications.

## Requirements
- iOS 13.0+
- Xcode 14.0+
- Swift 5.0+

## Installation

### Swift Package Manager

The SDK can be installed through Swift Package Manager. Add the following dependency to your `Package.swift` file:

swift
dependencies: [
.package(url: "https://github.com/appstack/appstack-ios-sdk.git", from: "1.0.0")
]

Or directly from Xcode:
1. File > Add Packages
2. Enter the repository URL: `https://github.com/appstack/appstack-ios-sdk.git`
3. Select the desired version

## Initialization

### UIKit with AppDelegate

```swift
import AppstackSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Appstack.shared.configure("your_verification_key")
        return true
    }
}
```

### UIKit with SceneDelegate

```swift
import AppstackSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Appstack.shared.configure("your_verification_key")
    }
}
```

### SwiftUI

```swift
import SwiftUI
import AppstackSDK

@main
struct MyApp: App {
    init() {
        Appstack.shared.configure("your_verification_key")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Apple Search Ads Attribution

### Compatibility
- Requires iOS 14.3 or later
- AppstackSDK version 1.0.0 or later

### Attribution Data Collection

Apple Search Ads attribution data collection is a two-part process:

1. Collect the user's attribution token and send it to Appstack
2. With this token, Appstack will request attribution data directly from Apple within a 24-hour period

### Standard vs Detailed Attribution

Apple Search Ads provides two types of attribution data:

| Data Type | Requires ATT Consent |
|-----------|---------------------|
| Standard  | No                 |
| Detailed  | Yes                |

### Standard Attribution

To enable standard attribution data collection (no user consent required):

```swift
import AppstackSDK

if #available(iOS 14.3, *) {
    AppstackASAAttribution.shared.enableASAAttributionTracking()
}
```

### Detailed Attribution

To collect detailed attribution data, you first need to request user consent:

```swift
import AppTrackingTransparency
import AppstackSDK

if #available(iOS 14.3, *) {
    // Check if user has already seen the tracking request
    if ATTrackingManager.trackingAuthorizationStatus != .notDetermined {
        if #available(iOS 15.0, *) {
            AppstackASAAttribution.shared.enableASAAttributionTracking()
        }
    }
}

// Later in your app's lifecycle, request consent
if #available(iOS 14.3, *) {
    if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
        ATTrackingManager.requestTrackingAuthorization { status in
            if #available(iOS 15.0, *) {
                AppstackASAAttribution.shared.enableASAAttributionTracking()
            }
        }
    }
}
```

### Complete Implementation Example

```swift
import UIKit
import AppTrackingTransparency
import AppstackSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Appstack
        Appstack.shared.configure("your_verification_key")
        
        // Enable ASA attribution if user has already made a tracking decision
        if #available(iOS 14.3, *) {
            if ATTrackingManager.trackingAuthorizationStatus != .notDetermined {
                if #available(iOS 15.0, *) {
                    AppstackASAAttribution.shared.enableASAAttributionTracking()
                }
            }
        }
        
        return true
    }
}

// At an appropriate time in your app, request tracking permission
func requestTrackingPermission() {
    if #available(iOS 14.3, *) {
        ATTrackingManager.requestTrackingAuthorization { status in
            if #available(iOS 15.0, *) {
                AppstackASAAttribution.shared.enableASAAttributionTracking()
            }
        }
    }
}
```

⚠️ **Important**: 
- Detailed attribution will only be available if the user grants tracking permission
- If the user denies tracking, standard attribution data can still be collected
- Allow up to 24 hours for attribution data to be available in your Appstack dashboard

## Sending Events

To send events defined in the Appstack platform (Mapping section):

```swift
Appstack.shared.sendEvent(event: "event_name")
```

For example:

```swift
// Send a purchase event
Appstack.shared.sendEvent(event: "purchase_completed")

// Send a registration event
Appstack.shared.sendEvent(event: "user_registered")
```

## Important Notes
- Make sure to initialize the SDK before sending any events
- Events must exactly match the names defined in the Appstack platform
- For iOS 14.3+, it's recommended to implement ATT permission request before enabling ASA tracking

## Support

For any questions or issues, please open an issue in the repository or contact our support team.