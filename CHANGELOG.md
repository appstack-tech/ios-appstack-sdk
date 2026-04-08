# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
