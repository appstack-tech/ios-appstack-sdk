# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Breaking
- Removed the public test-only API `AppstackAttributionSdk.setInstallDateForTesting(_:)`. Tests and internal SDK validation now use production-shaped dependency injection through internal environment seams.

### Changed
- `LogLevel.debug` is now a true public verbose level for sanitized SDK integration troubleshooting, while Appstack-only diagnostics use the internal `Logger.internalDebug` channel.
- Attribution match request logging moved from `.info` to `.debug`; `.info` is limited to high-level lifecycle output.
- Lower-level networking, persistence, purchase, and repository failures now log only on the internal diagnostics channel; public errors are sanitized at SDK API boundaries.
- Integrator-facing `Logger.error`, `Logger.info`, and `Logger.debug` messages are emitted as public unified-log strings so they remain readable in release-device Console output.

## [4.2.1] - 2026-06-05
### Changed
- Internal diagnostics logging (introduced in 4.2.0) is now gated behind a compile-time flag that the release workflow sets only for `-rc` builds. Production releases are fully silent; the flag is never enabled in app-store binaries.

## [4.2.0] - 2026-06-04
### Added
- **Install detection v2** — a new `InstallStateClassifier` replaces the previous heuristic. It correlates multiple signals (StoreKit `AppTransaction.originalAppVersion` / `appVersion`, keychain markers, bundle-container creation date, and an iTunes lookup for the current version's App Store release date) to distinguish fresh installs, reinstalls, and updates with a confidence level. The backend supplies configurable `DecisionThresholds` so the classification logic can be tuned server-side without an SDK update.
- `AppStoreLookupReader` fetches the current marketing version and its `currentVersionReleaseDate` from the iTunes lookup API to anchor time-based install classification.
- `hasMatchedKeychainId` and `matchedKeychainIdDiffersFromCurrent` signals added to `InstallSignals` for accurate reinstall detection (e.g. detecting App Store team transfers).
- `bundleContainerCreationDate` signal in `InstallSignals` to differentiate fresh installs from updates based on the app container's filesystem creation time.
- `storeKitAppVersionKey` added to `Config` to persist the current app version sourced from StoreKit.
- `AppTransactionInfo` now carries `appVersion` alongside `originalAppVersion` for version-comparison consistency across the SDK.
- Diagnostic logging channel in `Logger` for production builds, used internally during install-detection validation (see 4.2.1 for gating).

### Changed
- Minimum iOS deployment target raised to **iOS 15**; Swift tools version bumped to 5.5.
- `EventServerLogRequest` extended with new fields for install classification results and signals.
- `ConfigRepository` manages the new `DecisionThresholds` block from server configuration; `useInstallDetectionV2` toggle removed (v2 is now always active).
- When the config fetch fails on first launch, install classification is deferred to the next launch to avoid sending an erroneous install event.
- Install classification terminology unified: `freshInstall` renamed to `newInstall` throughout.
- Xcode version in the release workflow bumped to 16.4; `StoreKitAppTransactionReader` availability updated for iOS 18.4.

## [4.1.0] - 2026-05-15
### Added
- `configure()` now accepts an optional `wrapperVersion` parameter so wrapper SDKs (React Native, Flutter, etc.) can pass their version through to the backend.
- IDFV (`identifierForVendor`) and device model (hardware machine string) are now collected at configure time and included in every event payload.
- dSYMs are now embedded in the `AppstackSDK.xcframework` distribution, enabling crash symbolication for apps that integrate the binary framework.

### Changed
- INSTALL events triggered automatically by the SDK are now explicitly tagged `triggerType = "AUTOMATIC"`. Manually-sent INSTALL events via `sendEvent()` are tagged `"MANUAL"`, allowing the backend to filter them out.
- Removed the word "fingerprint" entirely from the SDK source.

## [4.0.6] - 2026-05-06
### Breaking
- `UserData`: dropped a public member that was only populated from the match response and never surfaced through `getAttributionParams()` or event payloads. Apps that read that member need to delete those references; match, persistence, and event behavior are otherwise unchanged.

## [4.0.5] - 2026-04-24
### Fixed
- Crash (`swift_unknownObjectRetain`) on first install affecting a small subset of users: a data race in Swift Concurrency could occur when `sendEvent` read `eventServerLogRepository` on one cooperative thread while `configureAsync` was writing it on another. The read is now performed under `stateLock` to make it atomic.
- `configure()` now ignores duplicate calls within the same process lifetime. Previously, calling it more than once could spawn concurrent `configureAsync` Tasks that simultaneously wrote repository properties, creating a second race window that also led to the same crash.
- Removed a `DispatchQueue.async { Task { } }` anti-pattern in `sendEvent`: the outer dispatch queue wrapper was a no-op because the inner `Task` immediately escaped to the Swift Concurrency cooperative thread pool regardless. Replaced with a direct `Task(priority: .utility)`.

## [4.0.4] - 2026-04-08
### Fixed
- Event sending regression introduced in 4.0.2: `WKWebView.evaluateJavaScript` on the attribution match critical path could hang indefinitely on iOS (web content process never starts for a windowless, unloaded view), which prevented the install event and `getAttributionParams()` from ever completing.

### Changed
- `X-Device-WebKit-Version` (AppleWebKit UA token) is now resolved via a fire-and-forget background task so it never blocks the match request. The bundle Info.plist version is used as a fallback on the first request; the precise UA token is included from the second request onward once the background resolution has completed.

## [4.0.3] - 2026-04-08
### Fixed
- Event sending regression introduced in 4.0.2: `WKWebView.evaluateJavaScript` on the attribution match critical path could hang indefinitely on iOS (web content process never starts for a windowless, unloaded view), which prevented the install event and `getAttributionParams()` from ever completing.

### Changed
- `X-Device-WebKit-Version` (AppleWebKit UA token) is now resolved via a fire-and-forget background task so it never blocks the match request. The bundle Info.plist version is used as a fallback on the first request; the precise UA token is included from the second request onward once the background resolution has completed.

## [4.0.2] - 2026-04-08
### Added
- Optional `matchUrl` on remote configuration so the backend can supply the attribution match endpoint; older backends without this field keep working.
- Device signal headers for match requests via `MatchDeviceSignalsProviding` / `DefaultMatchDeviceSignalsProvider` and `MatchDeviceSignals` helpers.
- `X-Device-OS-Darwin-Version` header reporting the Darwin kernel release string (e.g. `25.3.0`).
- `X-Device-WebKit-Version` now reports the precise `AppleWebKit/XXX.XX.XX` token parsed from a live WKWebView user-agent string, with a bundle Info.plist fallback.

### Changed
- User data / match HTTP requests use the configured match URL when it is present and non-empty, and fall back to the built-in base URL otherwise.
- `UserDataRequestBuilder` now merges query parameters with any query string already on the URL (builder values override duplicate keys).
- Match-related logging prints URLs without query or fragment to avoid leaking sensitive query data.

## [4.0.1] - 2026-02-10
### Changed
- **removing the Nonescapable types from the release CD.** 

## [4.0.0] - 2026-02-10
### Breaking
- **Removed** sync `getAttributionParams() -> [String: Any]?`. Use `getAttributionParams() async -> [String: Any]?` only. Call `await AppstackAttributionSdk.shared.getAttributionParams()` when you need params (e.g. after launch); it waits for the initial match to finish.
- **Added async `getAttributionParams() async`** (waits for initial match). Removed redundant `getAttributionParams(completion:)`.

## [3.6.2] - 2026-02-08
### Fixed
- Fixed compatibility with older Swift compilers (< 6.2) by disabling `NonescapableTypes` feature gate in `.swiftinterface` files. This resolves "has no member" errors when consuming the SDK from Xcode 16.0/16.1 (e.g. in React Native projects).

## [3.6.1] - 2026-02-08
### Changed
- Patch a log for ASA not meaningful anymore.

## [3.6.0] - 2026-02-04
### Changed
- Overall simplification of the code
- New changes to help to detect correctly already existing users coming back on the app, after the update containing the SDK.
- New changes to ensure the matching is sent only one time, even if the data is not available when requiring getAttributionParams.

## [3.5.1] - 2026-01-30
### Changed
- improved a bit more the code overall.
- added some more improvements at start up time.

## [3.5.0] - 2026-01-28
### Changed
- patched some crashes that could happens using the SDK.
- patched the behaviour to avoid counting updates as installs in the first days the app is running with the SDK.

## [3.4.1] - 2026-01-26
### Changed
- Rebuilt XCFramework binaries (no public API changes)

## [3.4.0] - 2026-01-26
### Added
- Added optional `customerUserId` to `configure(...)`
- Added async `getAttributionParams(completion:)` overload

### Changed
- Linked AppTrackingTransparency framework to support ATT access

## [3.3.0] - 2025-01-14
### Fixed
- Removed previous changes on how to handle automatic purchase events.


## [3.2.0] - 2025-01-05
### Added
- Initial log release of iOS SDK documentation
- Comprehensive documentation structure aligned with Android SDK

### Changed
- Updated documentation to match Android SDK structure and formatting
- Standardized README.md naming convention

### Fixed
- Documentation consistency across iOS and Android platforms
