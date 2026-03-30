import SwiftUI

@main
struct SecureSessionApp: App {
    @StateObject private var sessionManager = SessionManager()
    @StateObject private var appLockManager = AppLockManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(sessionManager)
                .environmentObject(appLockManager)
        }
    }
}
