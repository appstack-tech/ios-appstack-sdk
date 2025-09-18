import Foundation
import AdAttributionKit
import StoreKit
import SwiftUI

class AuthManager: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isLoading = false
    
    func login() async {
        isLoading = true
        
        // Simulate server delay
        //DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoggedIn = true
            self.isLoading = false
            
            // Send signup event
            TrackingManager.shared.trackEvent(eventType: Constants.Events.signup)
            //SKAdNetwork.updatePostbackConversionValue(1, coarseValue: .low)
            let postbackUpdate = PostbackUpdate(
                fineConversionValue: 1,
                lockPostback: false,
                coarseConversionValue: .low,
                conversionTypes: nil
            )
            do {
                try await AdAttributionKit.Postback.updateConversionValue(postbackUpdate)
            } catch {
                print("Attribution: AdAttributionKit postback failed")
            }
        //}
    }
    
    func logout() {
        isLoading = true
        
        // Simulate server delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoggedIn = false
            self.isLoading = false
            
            // Send logout event
            TrackingManager.shared.trackEvent(
                eventType: .CUSTOM,
                customEventName: Constants.Events.logout
            )
        }
    }
}
