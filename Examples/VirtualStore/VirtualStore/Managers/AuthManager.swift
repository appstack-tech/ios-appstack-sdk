import Foundation
import SwiftUI

class AuthManager: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isLoading = false

    func login() async {
        isLoading = true

        // Simulated auth — no real backend in this example.
        self.isLoggedIn = true
        self.isLoading = false

        // Send the sign-up event (this screen registers a new account).
        TrackingManager.shared.trackEvent(event: Constants.Events.signup)
    }

    func logout() {
        isLoading = true

        // Simulate server delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoggedIn = false
            self.isLoading = false
        }
    }
}
