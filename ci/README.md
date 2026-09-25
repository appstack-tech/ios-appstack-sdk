# Release smoke test

[`.github/workflows/smoke.yml`](../.github/workflows/smoke.yml) validates each release once it's published: it installs the SDK the way customers do and builds a consumer app against it. It runs when the `rc` branch is updated (release candidates) and when an `X.Y.Z` tag is pushed (stable releases). You can also run it by hand from the Actions tab.

| Job | What it checks |
|---|---|
| Checksum | The zip at `Package.swift`'s `url` is a release asset of this repo and its SHA-256 matches `checksum` |
| spm / embedded | `SmokeSPM` (Swift Package Manager) and `SmokeEmbedded` (XCFramework embedded directly) build for the iOS Simulator and a generic iOS device, with Xcode 16.4 (`macos-15`) and the latest stable Xcode (`macos-26`) |
| App extension | `SmokeExtension` (notification service) builds with `APPLICATION_EXTENSION_API_ONLY=YES`. Non-blocking step: the SDK binary has the `APP_EXTENSION_SAFE` flag |
| Mac Catalyst | Non-blocking: the Catalyst slice has a valid bundle layout, and both apps build for Mac Catalyst |

## Files

- `fetch-xcframework.sh`: downloads the asset and verifies the checksum. Pass a directory to unzip it there.
- `SmokeConsumer/project.yml`: XcodeGen spec. The generated `SmokeConsumer.xcodeproj` is committed. After you edit the spec, run `xcodegen generate` in `SmokeConsumer/`.

## Run locally

```bash
ci/fetch-xcframework.sh ci/SmokeConsumer/Frameworks
xcodebuild build -project ci/SmokeConsumer/SmokeConsumer.xcodeproj -scheme SmokeSPM \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO
```

## Security

The workflow uses no secrets and runs with `contents: read`, and its actions are pinned by commit SHA. Keep **Settings ▸ Actions ▸ General ▸ Fork pull request workflows** set to require approval, so fork PRs don't run without a maintainer's review.
