import Foundation

@MainActor
final class AppLockManager: ObservableObject {
    @Published private(set) var isLocked: Bool = false

    /// Toggle to disable app lock behavior if needed.
    var isAppLockEnabled: Bool = true

    // PUBLIC_INTERFACE
    func lock() {
        """Lock the app UI until the user authenticates."""
        isLocked = true
    }

    // PUBLIC_INTERFACE
    func unlockWithoutPrompt() {
        """Unlock the app UI without prompting for biometrics.
        
        Used after logout when protected content is no longer visible.
        """
        isLocked = false
    }

    // PUBLIC_INTERFACE
    func unlock() async {
        """Attempt to unlock using biometrics/passcode."""
        guard isLocked else { return }
        do {
            try await BiometricAuthManager.shared.authenticate(reason: "Unlock to continue.")
            isLocked = false
        } catch {
            // Keep locked on failure (user cancelled / failed auth).
            isLocked = true
        }
    }

    // PUBLIC_INTERFACE
    func lockAndRequireAuthIfNeeded() async {
        """Lock and then request authentication if app-lock is enabled.
        
        Called when returning to foreground.
        """
        guard isAppLockEnabled else {
            isLocked = false
            return
        }
        isLocked = true
        await unlock()
    }
}
