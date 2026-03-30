import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var appLock: AppLockManager
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            if session.isAuthenticated {
                NavigationStack {
                    HomeView()
                }
                .blur(radius: appLock.isLocked ? 12 : 0)
                .disabled(appLock.isLocked)
            } else {
                NavigationStack {
                    LoginView()
                }
            }

            if session.isAuthenticated, appLock.isLocked {
                AppLockOverlayView(
                    title: "App Locked",
                    message: "Authenticate to continue.",
                    unlockAction: {
                        Task { await appLock.unlock() }
                    }
                )
                .transition(.opacity)
            }
        }
        .task {
            // Best-effort: restore a previous session from Keychain (if any).
            await session.restoreFromKeychainIfPossible()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                // Optional app lock on resume: if user already has a session, require auth.
                if session.isAuthenticated {
                    Task { await appLock.lockAndRequireAuthIfNeeded() }
                }
            case .background:
                // Lock as soon as app leaves foreground.
                if session.isAuthenticated {
                    appLock.lock()
                }
            default:
                break
            }
        }
        .animation(.easeInOut(duration: 0.2), value: appLock.isLocked)
        .animation(.easeInOut(duration: 0.2), value: session.isAuthenticated)
    }
}
