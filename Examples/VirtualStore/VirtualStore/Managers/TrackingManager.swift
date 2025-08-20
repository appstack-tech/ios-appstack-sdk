import Foundation
import StoreKit
import AppstackSDK
import FacebookCore
import TikTokBusinessSDK
import Firebase
import AppTrackingTransparency

class TrackingManager: ObservableObject {
    static let shared = TrackingManager()
    
    private init() {
        // Private initialization to ensure singleton
    }
    
    func configureSDKs() {
        // Configure Appstack SDK
        Appstack.shared.configure(Constants.appstackApiKey)
        
        // Configure other SDKs
        configureFacebookSDK()
        configureTiktokSDK()
        configureFirebaseSDK()
        
        setupTracking()
        registerSKAdNetwork()
        print("🔄 All SDKs have been configured")
    }
    
    /// Tracks an event across all integrated SDKs.
    ///
    /// - Parameters:
    ///   - name: The name of the event to track.
    ///   - parameters: Optional parameters to include with the event.
    ///     For Appstack SDK, revenue parameters are automatically extracted
    ///     and sent using the new .revenue parameter format.
    func trackEvent(name: String, parameters: [String: Any]? = nil) {
        // Send event to Appstack with revenue parameter if available
        if let parameters = parameters, let revenue = extractRevenue(from: parameters) {
            Appstack.shared.sendEvent(event: name, revenue: revenue)
        } else {
            Appstack.shared.sendEvent(event: name)
        }
        
        // Send event to Meta
        AppEvents.shared.logEvent(AppEvents.Name(name))
        
        // Send event to TikTok
        TikTokBusiness.trackTTEvent(TikTokBaseEvent(eventName: name))
        
        // Send event to Firebase
        Analytics.logEvent(name, parameters: parameters)
        
        print("📊 Event '\(name)' sent to all SDKs")
    }
    
    /// Extracts revenue value from parameters dictionary
    /// Supports Double, Int, Float, and String values as per SDK documentation
    private func extractRevenue(from parameters: [String: Any]) -> Decimal? {
        // Check for common revenue parameter names
        let revenueKeys = ["value", "revenue", "price", "amount"]
        
        for key in revenueKeys {
            if let value = parameters[key] {
                // Return the value as-is since SDK supports multiple types
                return value as? Decimal
            }
        }
        
        return nil
    }
    
    private func configureFacebookSDK() {
        ApplicationDelegate.shared.application(
            UIApplication.shared,
            didFinishLaunchingWithOptions: nil
        )
        
        // Disable automatic event logging in Meta SDK
        // This prevents Meta from automatically logging app events
        Settings.shared.isAutoLogAppEventsEnabled = false
        
        // Disable SKAdNetwork reporting in Meta SDK
        // This prevents Meta from sending conversion values to Apple via SKAdNetwork
        // Note: You should also disable this in Meta Business Manager:
        // 1. Go to business.facebook.com
        // 2. Navigate to "Data Sources" -> "Settings"
        // 3. Under "Apple's SKAdNetwork" -> "View Additional Settings"
        // 4. Toggle off "SKAdNetwork for the Facebook SDK"
    }
    
    private func configureTiktokSDK() {
        // Configure TikTok SDK
        let tiktokConfig = TikTokConfig(appId: Constants.appId, tiktokAppId: Constants.tiktokAppId)
#if DEBUG
        // Enable debug mode only for testing purposes
        tiktokConfig?.enableDebugMode()
#endif
        // Disable SKAdNetwork support in TikTok SDK
        // This prevents TikTok from sending conversion values to Apple via SKAdNetwork
        // Documentation: https://ads.tiktok.com/marketing_api/docs?id=1739381752981505
        tiktokConfig?.disableSKAdNetworkSupport()
        
        TikTokBusiness.initializeSdk(tiktokConfig)
    }
    
    private func configureFirebaseSDK() {
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Disable SKAdNetwork reporting in Firebase
        // Firebase doesn't provide a programmatic way to disable SKAdNetwork reporting
        // You must add the following key to your Info.plist file:
        //
        // <key>GOOGLE_ANALYTICS_REGISTRATION_WITH_AD_NETWORK_ENABLED</key>
        // <false/>
        //
        // Documentation: https://firebase.google.com/docs/analytics/get-started?platform=ios#optional_disable_apple_ad_network_attribution_registration
        // Note: There is NO option to disable this in the Firebase Console.
    }
    
    private func setupTracking() {
        if #available(iOS 14.0, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                // Enable ASA Attribution tracking after getting permission
                if #available(iOS 14.3, *) {
                    AppstackASAAttribution.shared.enableASAAttributionTracking()
                }
                
                switch status {
                case .authorized:
                    Settings.shared.isAdvertiserIDCollectionEnabled = true
                case .denied, .notDetermined, .restricted:
                    Settings.shared.isAdvertiserIDCollectionEnabled = false
                @unknown default:
                    fatalError("Invalid authorization status")
                }
            }
        }
    }
    
    private func registerSKAdNetwork() {
        if !UserDefaults.standard.bool(forKey: "IsSkAdNetworkInstallReported") {
            if #available(iOS 15.4, *) {
                SKAdNetwork.updatePostbackConversionValue(0) { error in
                    if error == nil {
                        UserDefaults.standard.set(true, forKey: "IsSkAdNetworkInstallReported")
                    }
                }
            } else {
                SKAdNetwork.registerAppForAdNetworkAttribution()
                UserDefaults.standard.set(true, forKey: "IsSkAdNetworkInstallReported")
            }
        }
    }
}
