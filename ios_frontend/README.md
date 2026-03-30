# iOS Frontend (SwiftUI) — SecureSessionApp

This workspace contains a **native SwiftUI iOS app** demonstrating:

- Login → protected Home screen
- Secure session persistence (access + refresh tokens) in **Keychain**
- Automatic refresh when access token expires
- Logout + session invalidation (best-effort)
- **App lock on resume** using **LocalAuthentication** (biometrics with device passcode fallback)
- Calculator UI on the Home screen with a top bar and Logout button

> Note: Any Kotlin/Gradle Android sample code has been removed. This folder is **Swift/iOS only**.

## Location

Open the Swift app sources here:

`ios_app/SecureSessionApp/SecureSessionApp/`

## How to run

1. Open Xcode
2. Create a new project: **iOS → App → SwiftUI**
3. Name it `SecureSessionApp`
4. Replace the generated source files with the Swift files found under:
   `ios_app/SecureSessionApp/SecureSessionApp/`
5. Ensure `Info.plist` contains `NSFaceIDUsageDescription` (provided in this repo).
6. Build and run on a simulator/device.

## Using the real backend (FastAPI preview on port 3001)

This app is now wired to the real FastAPI auth endpoints:

- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `GET /me`

By default, `APIConfig.baseURL` is set to:

- `http://localhost:3001` (works in **iOS Simulator**)

Notes:
- On a **physical device**, `localhost` points to the phone, not your computer. Use your machine’s LAN IP (e.g. `http://192.168.1.10:3001`) or a tunnel URL, and update `APIConfig.baseURL` accordingly.
- The app keeps secure Keychain storage and will automatically refresh the access token when needed.
