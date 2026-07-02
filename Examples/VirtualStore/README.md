# VirtualStore — Appstack iOS SDK Example

A small SwiftUI e-commerce demo that shows how to integrate the **Appstack iOS SDK** and
track a typical shopping funnel. Auth and checkout are simulated — the point of the app is
to demonstrate SDK setup and event tracking, not to be a real store.

## Requirements

- Xcode 16+
- iOS 18.2+ (deployment target; the SDK itself supports older versions)
- An Appstack API key from the [dashboard](https://dashboard.appstack.com/settings)

## Setup

1. Open `VirtualStore.xcodeproj`.
2. This example references the SDK as a **local Swift package** (`../..`, the root of this
   repository) so it always builds against the xcframework shipped here. In your own app,
   add it as a remote package instead — File ▸ Add Package Dependencies… ▸
   `https://github.com/appstack-tech/ios-appstack-sdk`.
3. Add your API key in [`Constants.swift`](VirtualStore/Shared/Constants.swift):

   ```swift
   static let appstackApiKey = "YOUR_APPSTACK_API_KEY"
   ```

4. Build and run.

## Integration overview

### 1. Configure once at launch

Configuration lives in [`TrackingManager.swift`](VirtualStore/Managers/TrackingManager.swift)
and is called from the app's `init()`:

```swift
AppstackAttributionSdk.shared.configure(
    apiKey: Constants.appstackApiKey,
    logLevel: .debug  // use .info or .error in production
)

// Optional: Apple Search Ads attribution (iOS 15+)
if #available(iOS 15.0, *) {
    AppstackASAAttribution.shared.enableAppleAdsAttribution()
}
```

`configure(...)` returns immediately. The config fetch, attribution match, and the automatic
install events all run on a background task, so there is no measurable impact on
launch time. It is safe to call `sendEvent(...)` before configuration finishes — those events
are buffered and flushed once the SDK is ready.

### 2. What the SDK tracks automatically

You do **not** send these yourself:

| Event | When |
|-------|------|
| `INSTALL` | First real install, decided by the SDK's install classifier |
| **Purchases** | StoreKit / in-app purchases are captured automatically |

Because this demo *simulates* checkout (no real StoreKit transaction), it sends a manual
`.PURCHASE` event so you can see one in the dashboard. In a real StoreKit app you would omit
that — the SDK captures the real purchase for you.

### 3. Funnel events the app sends manually

Every call goes through `TrackingManager.shared.trackEvent(...)`, which forwards to
`AppstackAttributionSdk.shared.sendEvent(...)`. This demo uses **only standard `EventType`
values** — no custom events:

| User action | Event |
|-------------|-------|
| Register | `.SIGN_UP` |
| Open a product | `.VIEW_ITEM` |
| Add to cart | `.ADD_TO_CART` |
| Tap "Pay" | `.INITIATE_CHECKOUT` |
| Complete purchase | `.PURCHASE` (simulated here) |

Cart housekeeping (removing an item, changing quantity, viewing a screen) is intentionally
**not** tracked — those have no standard event and aren't attribution signals.

The SDK still supports `.CUSTOM` events (with a `name`) for genuinely app-specific actions;
this example just doesn't need any.

### 4. Revenue events

For any revenue event, include `revenue` (or `price`) and `currency` in `parameters` — the
SDK reads them directly:

```swift
AppstackAttributionSdk.shared.sendEvent(
    event: .PURCHASE,
    parameters: ["revenue": 149.97, "currency": "USD", "item_count": 3]
)
```

If you do need a custom event, `.CUSTOM` requires a `name`:

```swift
AppstackAttributionSdk.shared.sendEvent(
    event: .CUSTOM,
    name: "tutorial_step_completed",
    parameters: ["step": 3]
)
```

## Screens

| Screen | File |
|--------|------|
| Register / Sign up | [`SignupView.swift`](VirtualStore/Views/SignupView.swift) |
| Home | [`ContentView.swift`](VirtualStore/Views/ContentView.swift) |
| Product list | [`ProductListView.swift`](VirtualStore/Views/ProductListView.swift) |
| Product detail | [`ProductDetailView.swift`](VirtualStore/Views/ProductDetailView.swift) |
| Cart & checkout | [`CartView.swift`](VirtualStore/Views/CartView.swift) |

## Project structure

```
VirtualStore/
├── VirtualStoreApp.swift        # App entry point; configures the SDK
├── Managers/
│   ├── TrackingManager.swift    # Appstack configuration + event forwarding
│   ├── AuthManager.swift        # Simulated auth (sends SIGN_UP / logout)
│   └── CartManager.swift        # Cart state + ADD_TO_CART / PURCHASE events
├── Models/Product.swift
├── Views/                       # SwiftUI screens
└── Shared/Constants.swift       # API key, event names, sample products
```

## Useful SDK APIs

```swift
// Stable identifier
let id = AppstackAttributionSdk.shared.getAppstackId()

// Attribution params (waits for the launch match to finish)
let params = await AppstackAttributionSdk.shared.getAttributionParams()

// GDPR: request server-side deletion + clear local cache
try await AppstackAttributionSdk.shared.deleteUserData()
```

See the [Appstack iOS SDK documentation](https://docs.app-stack.tech/documentation/sdk/quickstart)
for the full API.

---

📩 **[Contact](https://www.appstack.tech/contact)**
