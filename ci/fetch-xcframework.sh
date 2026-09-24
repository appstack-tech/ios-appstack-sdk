#!/usr/bin/env bash
# Downloads the XCFramework zip that the repo-root Package.swift points at and
# checks that its SHA-256 matches the declared checksum, the same check SPM
# runs on a customer's machine.
#
# Usage: ci/fetch-xcframework.sh [unzip-dir]
#
# Environment:
#   EXPECTED_URL_PREFIX  fail unless the manifest url starts with this
#   WAIT_SECONDS         keep retrying a 404 for up to this long (default 0).
#                        A stable release pushes its tag before it creates the
#                        GitHub Release, so the asset can lag behind the push.
set -euo pipefail

cd "$(dirname "$0")/.."

url=$(sed -n 's/^[[:space:]]*url:[[:space:]]*"\([^"]*\)".*/\1/p' Package.swift)
checksum=$(sed -n 's/^[[:space:]]*checksum:[[:space:]]*"\([^"]*\)".*/\1/p' Package.swift)

if [[ $(wc -l <<<"$url") -ne 1 || -z "$url" || $(wc -l <<<"$checksum") -ne 1 || -z "$checksum" ]]; then
  echo "::error file=Package.swift::Expected exactly one binaryTarget url and checksum in Package.swift"
  exit 1
fi
if [[ ! "$checksum" =~ ^[0-9a-f]{64}$ ]]; then
  echo "::error file=Package.swift::checksum is not a SHA-256 hex digest: $checksum"
  exit 1
fi
if [[ -n "${EXPECTED_URL_PREFIX:-}" && "$url" != "$EXPECTED_URL_PREFIX"* ]]; then
  echo "::error file=Package.swift::url must start with $EXPECTED_URL_PREFIX, got $url"
  exit 1
fi

echo "url:      $url"
echo "checksum: $checksum"

zip="${RUNNER_TEMP:-${TMPDIR:-/tmp}}/AppstackSDK.xcframework.zip"
deadline=$(( $(date +%s) + ${WAIT_SECONDS:-0} ))
while true; do
  status=$(curl -sSL --retry 3 -o "$zip" -w '%{http_code}' "$url" || true)
  [[ "$status" == 200 ]] && break
  if [[ "$status" == 404 && $(date +%s) -lt $deadline ]]; then
    echo "Asset not published yet (HTTP 404), retrying in 30s..."
    sleep 30
    continue
  fi
  echo "::error::Download of $url failed with HTTP $status"
  exit 1
done

actual=$(shasum -a 256 "$zip" | awk '{print $1}')
if [[ "$actual" != "$checksum" ]]; then
  echo "::error file=Package.swift::Checksum mismatch: Package.swift declares $checksum, asset is $actual"
  exit 1
fi
echo "Checksum OK"

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    echo "| | |"
    echo "|---|---|"
    echo "| url | \`$url\` |"
    echo "| checksum | \`$checksum\` ✅ |"
  } >> "$GITHUB_STEP_SUMMARY"
fi

if [[ $# -ge 1 ]]; then
  rm -rf "$1/AppstackSDK.xcframework"
  mkdir -p "$1"
  unzip -q "$zip" -d "$1"
  test -f "$1/AppstackSDK.xcframework/Info.plist"
  echo "Unzipped to $1/AppstackSDK.xcframework"
fi
