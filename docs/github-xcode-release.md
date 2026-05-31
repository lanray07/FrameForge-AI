# GitHub Xcode Release Workflow

This repo can build FrameForge AI through GitHub Actions on macOS.

## Workflows

- `.github/workflows/xcode-simulator-build.yml` builds the app for iOS Simulator on pushes, pull requests, or manual runs. It does not need Apple signing secrets.
- `.github/workflows/xcode-app-store-archive.yml` creates a signed App Store archive and exports an IPA. It can optionally upload that IPA to App Store Connect.

## Required GitHub Secrets

Add these in GitHub at `Settings > Secrets and variables > Actions > Secrets`:

- `APPLE_TEAM_ID`: Apple Developer team ID.
- `BUILD_CERTIFICATE_BASE64`: Base64-encoded Apple Distribution `.p12` certificate.
- `P12_PASSWORD`: Password for the `.p12` certificate.
- `BUILD_PROVISION_PROFILE_BASE64`: Base64-encoded App Store `.mobileprovision` profile for the app bundle ID.
- `KEYCHAIN_PASSWORD`: Any strong temporary keychain password for the runner.

For automatic upload to App Store Connect, also add:

- `APP_STORE_CONNECT_API_KEY_ID`: API key ID.
- `APP_STORE_CONNECT_API_ISSUER_ID`: issuer ID.
- `APP_STORE_CONNECT_API_KEY_BASE64`: Base64-encoded `AuthKey_XXXXXXXXXX.p8` file.

## Optional GitHub Variable

Add this at `Settings > Secrets and variables > Actions > Variables` if the bundle ID differs:

- `BUNDLE_ID`: defaults to `com.frameforge.ai`.

## How To Run

1. Push this repo to GitHub.
2. Open the GitHub repository.
3. Go to `Actions`.
4. Run `Xcode Simulator Build` first.
5. Add signing secrets.
6. Run `Xcode App Store Archive`.
7. Leave `upload_to_app_store_connect` as `false` for the first run, then set it to `true` once the archive succeeds.

The release workflow uses Xcode's command-line tools to archive/export the app and `xcrun altool` with an App Store Connect API key for upload.
