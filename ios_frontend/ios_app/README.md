# SecureSessionApp (iOS SwiftUI)

This folder contains an **idiomatic SwiftUI** implementation of:

- Login screen → protected Home screen
- Secure session persistence (access + refresh tokens) in **Keychain**
- Automatic refresh when access token expires
- Logout + session invalidation (best-effort)
- **App lock on resume** using **LocalAuthentication** (biometrics with device passcode fallback)
- A basic calculator UI on the Home screen with a top app bar and Logout button

## How to run

This repository’s `ios_frontend/` originally contains an Android sample project.  
To run the iOS app:

1. Open Xcode
2. Create a new project: **iOS → App → SwiftUI**
3. Name it `SecureSessionApp`
4. Replace the generated source files with the Swift files found under:
   `ios_app/SecureSessionApp/SecureSessionApp/`
5. Ensure `Info.plist` contains `NSFaceIDUsageDescription` (provided here).
6. Build and run on a simulator/device.

## Using the real backend (FastAPI preview on port 3001)

This app is wired to the real FastAPI auth endpoints:

- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `GET /me`

By default, `APIConfig.baseURL` is set to:

- `http://localhost:3001` (works in **iOS Simulator**)

Notes:
- On a **physical device**, `localhost` points to the phone. Use your machine’s LAN IP or a tunnel URL and update `APIConfig.baseURL`.
- The app keeps secure Keychain storage and performs automatic token refresh when the access token expires.
