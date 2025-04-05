import Foundation
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
        Appstack.shared.configure(Constants.appstackVerificationKey)
        
        // Configure SDKs
        configureFacebookSDK()
        configureTiktokSDK()
        configureFirebaseSDK()
        
        setupTracking()
        print("🔄 All SDKs have been configured")
    }
    
    /// Tracks an event across all integrated SDKs.
    ///
    /// - Parameters:
    ///   - name: The name of the event to track.
    ///   - parameters: Optional parameters to include with the event.
    ///     Note: For the purpose of this example, which focuses on SKAN integration,
    ///     these parameters are not being used for SKAN events
    ///     (as SKAN doesn't support parameters).
    ///     However, this parameter is included to demonstrate how this manager could be used
    ///     for centralizing all analytics tracking beyond SKAN, where sending additional
    ///     parameters with events would be valuable for more detailed analytics.
    func trackEvent(name: String, parameters: [String: Any]? = nil) {
        // Send event to Appstack
        Appstack.shared.sendEvent(event: name)
        
        // Send event to Meta
        AppEvents.shared.logEvent(AppEvents.Name(name))
        
        // Send event to TikTok
        TikTokBusiness.trackTTEvent(TikTokBaseEvent(eventName: name))
        
        // Send event to Firebase
        Analytics.logEvent(name, parameters: parameters)
        
        print("📊 Event '\(name)' sent to all SDKs")
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
        //FirebaseApp.configure()
        
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
                if #available(iOS 15.0, *) {
                    AppstackASAAttribution.shared.enableASAAttributionTracking()
                }
                switch status {
                case .authorized:
                    Settings.shared.isAdvertiserIDCollectionEnabled = true
                    Settings.shared.isAdvertiserTrackingEnabled = true
                case .denied, .notDetermined, .restricted:
                    Settings.shared.isAdvertiserIDCollectionEnabled = false
                    Settings.shared.isAdvertiserTrackingEnabled = true
                @unknown default:
                    fatalError("Invalid authorization status")
                }
            }
        }
    }
}
