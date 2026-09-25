import SwiftUI

@main
struct SmokeApp: App {
    init() {
        SDKUsage.run()
    }

    var body: some Scene {
        WindowGroup {
            Text("Appstack SDK smoke test")
        }
    }
}
