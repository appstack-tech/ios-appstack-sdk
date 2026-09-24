import AppstackSDK

// Touches the public API a typical integration uses, so the build fails if the
// module interface or any of these symbols is missing.
enum SDKUsage {
    static func run() {
        let sdk = AppstackAttributionSdk.shared
        sdk.configure(apiKey: "smoke-test", logLevel: .info)
        sdk.setCustomerUserId("smoke-user")
        sdk.sendEvent(event: .PURCHASE, parameters: ["revenue": 1.0, "currency": "USD"])
        _ = sdk.getAppstackId()
        _ = sdk.isSdkDisabled()
        Task { _ = await sdk.getAttributionParams() }
    }
}
