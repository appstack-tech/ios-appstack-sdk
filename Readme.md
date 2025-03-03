# AppstackSDK

SDK for integrating Appstack into iOS applications.

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
    .package(url: "https://github.com/appstack/ios-appstack-sdk.git", from: "1.0.0")
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

### **AppDelegate**

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

### **SceneDelegate**

```swift
import AppstackSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Appstack.shared.configure("your_verification_key")
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
        Appstack.shared.configure("your_verification_key")
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

To send events defined in the **Appstack platform (Mapping section)**:

```swift
Appstack.shared.sendEvent(event: "event_name")
```

### **Examples:**

```swift
// Send a purchase event
Appstack.shared.sendEvent(event: "purchase_completed")

// Send a registration event
Appstack.shared.sendEvent(event: "user_registered")
```

### ⚠️ **Important Notes:**

- Always **initialize the SDK** before sending events.
- Event names **must match** those defined in the **Appstack platform**.

---

## 🔎 Apple Search Ads Attribution

### ✅ **Compatibility**

- Requires **iOS 14.3+**
- Works with **AppstackSDK version 1.0.0 or later**

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
    AppstackASAAttribution.shared.enableASAAttributionTracking()
}
```

### 🔵 **Detailed Attribution (Requires User Consent)**

```swift
import AppTrackingTransparency
import AppstackSDK

if #available(iOS 14.3, *) {
    if ATTrackingManager.trackingAuthorizationStatus != .notDetermined {
        if #available(iOS 15.0, *) {
            AppstackASAAttribution.shared.enableASAAttributionTracking()
        }
    }
}
```

🔹 **Request user consent before enabling detailed attribution:**

```swift
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

### ✅ **Complete Implementation Example**

```swift
import UIKit
import AppTrackingTransparency
import AppstackSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Appstack
        Appstack.shared.configure("your_verification_key")
        
        // Enable ASA Attribution if tracking is already decided
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

// Request tracking permission at the appropriate time
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

⚠️ **Important Notes:**

- **Detailed attribution** requires **user consent**.
- **Standard attribution** works even if the user denies tracking.
- **Attribution data may take up to 24 hours** to appear in the Appstack dashboard.
- **iOS 14.3+**: Implement **ATT permission request** before enabling ASA tracking.

---

## ❓ Support

For any questions or issues, please:

- **Open an issue** in this repository.
- Contact our **support team** for further assistance.

📩 **Email:** <support@appstack.com>
