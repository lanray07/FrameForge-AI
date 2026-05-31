# GitHub Xcode Release Workflow

This repo can build FrameForge AI through GitHub Actions on macOS.

## Workflows

- `.github/workflows/xcode-simulator-build.yml` builds the app for iOS Simulator on pushes, pull requests, or manual runs. It does not need Apple signing secrets.
- `.github/workflows/xcode-app-store-archive.yml` creates a signed App Store archive and exports an IPA with Xcode automatic signing. It can optionally upload that IPA to App Store Connect.

## Required GitHub Secrets

Add these in GitHub at `Settings > Secrets and variables > Actions > Secrets`:

- `APPLE_TEAM_ID`: Apple Developer team ID.
- `APP_STORE_CONNECT_API_KEY_ID`: API key ID.
- `APP_STORE_CONNECT_API_ISSUER_ID`: issuer ID.
- `APP_STORE_CONNECT_API_PRIVATE_KEY`: raw `AuthKey_XXXXXXXXXX.p8` private key contents.

The workflow also supports `APP_STORE_CONNECT_API_KEY_BASE64` instead of `APP_STORE_CONNECT_API_PRIVATE_KEY` when the `.p8` file is stored base64-encoded.

## Optional GitHub Variable

Add this at `Settings > Secrets and variables > Actions > Variables` if the bundle ID differs:

- `BUNDLE_ID`: defaults to `com.frameforgeai.app`.

## How To Run

1. Push this repo to GitHub.
2. Open the GitHub repository.
3. Go to `Actions`.
4. Run `Xcode Simulator Build` first.
5. Add the automatic signing and App Store Connect API secrets.
6. Run `Xcode App Store Archive`.
7. Leave `upload_to_app_store_connect` as `false` for the first run, then set it to `true` once the archive succeeds.

The release workflow creates an unsigned archive, uses Xcode cloud signing with `-allowProvisioningUpdates` and an App Store Connect API key during export, then uploads with `xcrun altool` and the same key.
