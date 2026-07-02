import Foundation
import AppstackSDK

/// Thin wrapper around the Appstack SDK for the VirtualStore example.
///
/// The Appstack SDK tracks **installs**, **first-open**, and **StoreKit purchases**
/// automatically — you never fire those yourself. This manager only handles:
///   1. One-time SDK configuration at launch (`configure`).
///   2. Forwarding the funnel events the app chooses to send manually (`trackEvent`).
class TrackingManager: ObservableObject {
    static let shared = TrackingManager()

    private init() {
        // Private initialization to ensure singleton
    }

    /// Configure the Appstack SDK. Call once, as early as possible at launch.
    ///
    /// `configure` returns immediately: the config fetch, attribution match, and the
    /// automatic install / first-open events all run on a background task, so there is
    /// no measurable impact on launch time.
    func configure() {
        AppstackAttributionSdk.shared.configure(
            apiKey: Constants.appstackApiKey,
            logLevel: .debug  // .debug surfaces integration troubleshooting logs; use .info or .error in production
        )

        // Optional: enable Apple Search Ads attribution (iOS 15+).
        if #available(iOS 15.0, *) {
            AppstackASAAttribution.shared.enableAppleAdsAttribution()
        }

        print("✅ Appstack SDK configured")
    }

    /// Send a funnel event to Appstack.
    ///
    /// - Parameters:
    ///   - event: A standard `EventType` (e.g. `.SIGN_UP`, `.ADD_TO_CART`, `.PURCHASE`),
    ///            or `.CUSTOM` for app-specific events.
    ///   - name: Required when `event` is `.CUSTOM`; ignored otherwise.
    ///   - parameters: Optional key/value pairs. For revenue events include
    ///                 `revenue` (or `price`) and `currency` — the SDK reads them directly.
    func trackEvent(event: EventType, name: String? = nil, parameters: [String: Any]? = nil) {
        AppstackAttributionSdk.shared.sendEvent(event: event, name: name, parameters: parameters)

        let label = event == .CUSTOM ? (name ?? "custom_event") : event.eventName
        print("📊 Event '\(label)' sent to Appstack")
    }
}
