import SwiftUI
import FacebookCore

@main
struct VirtualStoreApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var cartManager = CartManager()
    
    init() {
        TrackingManager.shared.configureSDKs()
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
