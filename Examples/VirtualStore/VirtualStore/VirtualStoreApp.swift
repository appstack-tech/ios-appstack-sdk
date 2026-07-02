import SwiftUI

@main
struct VirtualStoreApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var cartManager = CartManager()

    init() {
        // Configure the Appstack SDK once, at launch.
        TrackingManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authManager.isLoggedIn {
                ContentView()
                    .environmentObject(authManager)
                    .environmentObject(cartManager)
                    .navigationViewStyle(StackNavigationViewStyle())
            } else {
                SignupView()
                    .environmentObject(authManager)
            }
        }
    }
}
