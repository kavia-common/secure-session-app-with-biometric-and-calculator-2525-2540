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
