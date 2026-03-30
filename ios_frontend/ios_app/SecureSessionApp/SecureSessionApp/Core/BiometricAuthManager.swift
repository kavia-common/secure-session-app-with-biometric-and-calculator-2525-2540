import Foundation
import LocalAuthentication

final class BiometricAuthManager {
    static let shared = BiometricAuthManager()

    private init() {}

    // PUBLIC_INTERFACE
    func authenticate(reason: String) async throws {
        """Authenticate the user with biometrics, falling back to device passcode if needed.
        
        Uses `LAContext` with `.deviceOwnerAuthentication` so the system can fall back to passcode.
        
        - Parameter reason: The localized reason shown in the system prompt.
        - Throws: AppError.biometricUnavailable or AppError.biometricFailed.
        """
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            throw AppError.biometricUnavailable
        }

        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
            if !success {
                throw AppError.biometricFailed("Unknown failure.")
            }
        } catch {
            throw AppError.biometricFailed(error.localizedDescription)
        }
    }
}
