import Foundation
import SwiftUI

class AuthManager: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isLoading = false
    
    func login() {
        isLoading = true
        
        // Simulate server delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoggedIn = true
            self.isLoading = false
            
            // Send signup event
            TrackingManager.shared.trackEvent(name: Constants.Events.signup)
        }
    }
    
    func logout() {
        isLoading = true
        
        // Simulate server delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoggedIn = false
            self.isLoading = false
            
            // Send logout event
            TrackingManager.shared.trackEvent(name: Constants.Events.logout)
        }
    }
}
