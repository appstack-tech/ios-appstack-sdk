# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
