# Changelog

All notable changes to the Appstack iOS SDK are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- Universal Links accept a URL directly and support optional host filtering. Branded HTTPS
  domains work by default; the shared `appstack.link` and `dev.appstack.link` hosts are rejected
  to avoid routing a link into another customer's app. Unsupported URL structures and
  non-standard multi-segment paths return nil. Expanded setup guidance covers SwiftUI,
  scene cold starts, and domain associations.
### Added
- `handleUniversalLink(_:)` handles a tapped Universal Link for an already-installed app,
  parsing `deeplinkId` and query params directly off the tapped URL with no network round
  trip. Call it from `application(_:continue:restorationHandler:)` / `scene(_:continue:)`.
  Requires adding only the branded domain provisioned for the app to its Associated Domains
  entitlement. Do not add `appstack.link` or `dev.appstack.link`. See the Universal Links
  section in the README.

## [4.6.0] - 2026-09-02
### Added
- Custom event parameters are encrypted on the device before being sent, so personal data such as an
  email or phone number leaves the app already protected. Parameter names that need to stay readable
  — for example `currency`, `revenue` and campaign fields — are excluded, and that list is
  controlled server-side, so no code change is required in your app. Requires iOS 17 or later; on
  iOS 15 and 16 the values are encrypted server-side as before. Purchase `transaction_details` and
  deeplink user data are unaffected, so revenue reporting is unchanged. A value that cannot be
  encrypted is omitted from the event, and the rest of the event still sends.

### Fixed
- A `null` in the attribution match response no longer discards the whole response. Previously one
  null query parameter could cost an install its attribution data.
- Event parameters holding `null` no longer cause the event to be silently dropped. Null values are
  now omitted from the payload (nulls inside arrays are kept), matching the Android SDK. This
  covered a nil Swift `Optional` passed as a parameter, any dictionary decoded from JSON that
  carries a null field, Dart `null` from Flutter, and nested nulls from React Native.
- `sendEvent(event:name:parameters:)` no longer crashes the app when a parameter holds a value JSON
  cannot represent — a `Date`, `URL`, `Data`, `Set`, custom object, or a `NaN`/infinite number.
  Such keys are now dropped individually and named in an error log; the event still sends with its
  remaining parameters. Send strings, finite numbers, booleans, arrays, and nested string-keyed
  dictionaries.

## [4.5.2] - 2026-09-01
### Added
- Events now carry an internal diagnostic recording whether Apple Ads attribution was enabled and
  whether the AdServices token fetch is pending, succeeded, or failed. The SDK sends an automatic
  diagnostic event when the token resolution completes, so no later app event is required.

## [4.5.1] - 2026-08-14
### Added
- Added an Apple privacy manifest declaring the SDK's required-reason API usage.

## [4.5.0] - 2026-08-11
### Added
- `setCustomerUserId(_:)` sets the customer user id after `configure()`, for when the id is only
  known once the user logs in. It applies to every event sent from that point on, including events
  already buffered but not yet delivered.
- `getAttributionParams()` now always carries an `appstack_match_status` key telling you whether the
  attribution request succeeded: `matched`, `matched_no_params`, `organic`, `skipped`, `failed` or
  `not_configured`. Only `failed` is worth re-reading later; the rest are settled answers.
- Attribution match outcomes are now visible on the `.debug` log channel.

### Changed
- `getAttributionParams()` no longer returns `nil` — where the result was previously `nil` or empty,
  it now carries the status key explaining why. Existing call sites keep compiling, but code using
  an empty result to mean "not attributed" should switch to the status key.

### Fixed
- `deleteUserData()` now also clears the stored customer user id.
- A blank customer user id is treated as absent instead of being sent as an empty string.
- A `setCustomerUserId(...)` call made immediately after `configure()` is no longer overwritten by
  the value passed to `configure()`.

## [4.4.1] - 2026-08-03
### Added
- Attribution matching now includes additional network context to improve match diagnostics.

### Fixed
- `sendEvent(event:)` now ignores `INSTALL`, which the SDK already tracks automatically. Sending it by hand previously double-counted installs; such calls are now logged and discarded.

## [4.4.0] - 2026-07-17
### Added
- Added Mac Catalyst support to the prebuilt XCFramework.

### Changed
- Improved install detection and attribution reliability.
- Improved Swift Package Manager resolution: installations now download the prebuilt XCFramework
  directly from the GitHub release asset instead of cloning the complete source repository.
- Deprecated `isDebug` and `endpointBaseUrl`; both arguments are now ignored and will be removed
  in a future version. Integrations should migrate to `configure(apiKey:logLevel:customerUserId:)`.

### Fixed
- Improved SDK behavior during initialization and temporary connectivity failures.

### Removed
- Removed the test-only `AppstackAttributionSdk.setInstallDateForTesting(_:)` API.

## [4.3.1] - 2026-06-24
### Added
- `getAppstackId()` now returns a stable ID even when called before `configure()`.

### Changed
- `logLevel` now controls only the SDK's console output:
  - `.off` — no SDK logs.
  - `.error` — actionable errors only (e.g. invalid API key, incorrect SDK usage).
  - `.info` — errors plus high-level lifecycle confirmations.
  - `.debug` — info plus integration troubleshooting details.

### Reliability
- More resilient install tracking under poor or intermittent connectivity.
- Events sent before `configure()` are buffered and delivered once the SDK is ready.
- Hardened against crashes under concurrent access.

## [4.2.0] - 2026-06-04
### Added
- Improved install detection: fresh installs, reinstalls, and updates are now
  distinguished more accurately.

### Changed
- Minimum supported version raised to **iOS 15**.

## [4.1.0] - 2026-05-15
### Added
- `configure()` accepts an optional `wrapperVersion` so wrapper SDKs
  (React Native, Flutter, etc.) can report their version.
- Additional device signals are now collected to improve attribution accuracy.
- Crash reports from the SDK are now symbolicated (dSYMs ship with the framework).

### Changed
- Automatically-triggered and manually-sent INSTALL events are now tagged so they
  can be told apart.

## [4.0.6] - 2026-05-06
### Breaking
- `UserData`: removed a public member that was never populated in attribution
  params or event payloads. Delete any references to it; all other behavior is
  unchanged.

## [4.0.5] - 2026-04-24

### Fixed
- Fixed a rare crash on first install caused by a data race.
- `configure()` now ignores duplicate calls within the same app session.

## [4.0.4] - 2026-04-08

### Fixed
- Fixed a regression where the install event and `getAttributionParams()` could
  hang and never complete.

## [4.0.3] - 2026-04-08

### Fixed
- Fixed a regression where the install event and `getAttributionParams()` could
  hang and never complete.

## [4.0.2] - 2026-04-08
### Changed
- Internal improvements to attribution matching and request handling.

## [4.0.1] - 2026-02-10

### Fixed
- Build and compatibility fixes for the released framework.

## [4.0.0] - 2026-02-10
### Breaking
- Removed the synchronous `getAttributionParams() -> [String: Any]?`. Use the
  async version instead: `await AppstackAttributionSdk.shared.getAttributionParams()`,
  which waits for the initial match to complete.

## [3.6.2] - 2026-02-08

### Fixed
- Fixed compatibility with older Swift compilers (Xcode 16.0 / 16.1), resolving
  "has no member" errors when consuming the SDK (e.g. in React Native projects).

## [3.6.0] - 2026-02-04
### Changed
- Better detection of existing users returning to the app after updating to a
  version that includes the SDK.
- The attribution match is now sent only once, even when attribution data isn't
  yet available at the time `getAttributionParams()` is called.

## [3.5.1] - 2026-01-30
### Changed
- Startup-time improvements.

## [3.5.0] - 2026-01-28

### Fixed
- Fixed some crashes that could occur while using the SDK.
- Updates are no longer counted as installs during the app's first days running
  with the SDK.

## [3.4.1] - 2026-01-26
### Changed
- Rebuilt XCFramework binaries (no public API changes).

## [3.4.0] - 2026-01-26
### Added
- Optional `customerUserId` on `configure(...)`.
- Async `getAttributionParams(completion:)` overload.

### Changed
- Linked the AppTrackingTransparency framework to support ATT access.

## [3.3.0] - 2025-01-14

### Fixed
- Reverted earlier changes to automatic purchase-event handling.

## [3.2.0] - 2025-01-05
### Added
- Initial iOS SDK documentation.
