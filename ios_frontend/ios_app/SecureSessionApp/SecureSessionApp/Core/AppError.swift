import Foundation

enum AppError: LocalizedError {
    case invalidCredentials
    case notAuthenticated
    case tokenExpired
    case refreshFailed
    case networking(String)
    case keychain(String)
    case biometricUnavailable
    case biometricFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password."
        case .notAuthenticated:
            return "You are not authenticated."
        case .tokenExpired:
            return "Session expired."
        case .refreshFailed:
            return "Could not refresh the session. Please sign in again."
        case .networking(let message):
            return "Network error: \(message)"
        case .keychain(let message):
            return "Secure storage error: \(message)"
        case .biometricUnavailable:
            return "Biometric authentication is not available on this device."
        case .biometricFailed(let message):
            return "Authentication failed: \(message)"
        }
    }
}
