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

## Mock login

By default, `APIConfig.baseURL` is `nil`, and the app uses an in-memory mock backend:

- Email: anything (non-empty)
- Password: `password`

The mock access token expires quickly (60 seconds) so you can observe refresh behavior.

## Using a real backend

If you have real endpoints, set `APIConfig.baseURL` to your backend base URL and implement endpoints matching the sample paths in `AuthAPI`:

- `POST /auth/login` → `TokenPair`
- `POST /auth/refresh` → `TokenPair`
- `POST /auth/logout` (best-effort)

> Note: The included backend OpenAPI in this workspace currently only shows `/` health check, so the iOS app ships with a mock auth service by default.
