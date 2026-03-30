import Foundation

@MainActor
final class SessionManager: ObservableObject {
    @Published private(set) var isAuthenticated: Bool = false
    @Published private(set) var accessToken: String?

    private var refreshToken: String?
    private var accessTokenExpiresAt: Date?

    private let keychain = KeychainStore.shared

    // PUBLIC_INTERFACE
    func restoreFromKeychainIfPossible() async {
        // Restore tokens from Keychain and mark session as authenticated if valid.
        //
        // If access token is expired, attempts a refresh automatically.
        do {
            let access = try keychain.getString(for: .accessToken)
            let refresh = try keychain.getString(for: .refreshToken)
            let expiryString = try keychain.getString(for: .accessTokenExpiry)

            guard let refresh else {
                await clearInMemory()
                return
            }

            self.refreshToken = refresh

            if let expiryString, let expiry = ISO8601DateFormatter().date(from: expiryString) {
                self.accessTokenExpiresAt = expiry
            } else {
                self.accessTokenExpiresAt = nil
            }

            // If we have a non-expired access token, use it, else refresh.
            if let access, let expiry = accessTokenExpiresAt, expiry > Date().addingTimeInterval(5) {
                self.accessToken = access
                self.isAuthenticated = true
                return
            }

            // Try refresh if access missing/expired.
            try await refreshIfNeeded()
            self.isAuthenticated = (self.accessToken != nil)
        } catch {
            // If Keychain fails, treat as logged out.
            await clearSession()
        }
    }

    // PUBLIC_INTERFACE
    func login(email: String, password: String) async throws {
        // Log in with email/password and persist session securely.
        let tokens = try await AuthAPI.shared.login(email: email, password: password)
        try persist(tokens: tokens)
        apply(tokens: tokens)
        isAuthenticated = true
    }

    // PUBLIC_INTERFACE
    func authorizedRequestToken() async throws -> String {
        // Return a valid access token, refreshing if needed.
        //
        // - Throws: AppError.notAuthenticated / AppError.refreshFailed
        guard isAuthenticated else {
            throw AppError.notAuthenticated
        }
        try await refreshIfNeeded()
        guard let accessToken else {
            throw AppError.notAuthenticated
        }
        return accessToken
    }

    // PUBLIC_INTERFACE
    func logout() async {
        // Logout, invalidate session (best-effort), and clear Keychain.
        let currentRefresh = refreshToken
        await AuthAPI.shared.logout(refreshToken: currentRefresh)
        await clearSession()
    }

    private func refreshIfNeeded() async throws {
        guard let refreshToken else {
            throw AppError.notAuthenticated
        }

        // If we have an expiry and it is still valid, no refresh.
        if let expiry = accessTokenExpiresAt, expiry > Date().addingTimeInterval(5), accessToken != nil {
            return
        }

        do {
            let tokens = try await AuthAPI.shared.refresh(refreshToken: refreshToken)
            try persist(tokens: tokens)
            apply(tokens: tokens)
            isAuthenticated = true
        } catch {
            await clearSession()
            throw AppError.refreshFailed
        }
    }

    private func apply(tokens: TokenPair) {
        accessToken = tokens.accessToken
        refreshToken = tokens.refreshToken
        accessTokenExpiresAt = tokens.accessTokenExpiresAt
    }

    private func persist(tokens: TokenPair) throws {
        try keychain.setString(tokens.accessToken, for: .accessToken)
        try keychain.setString(tokens.refreshToken, for: .refreshToken)
        let expiryString = ISO8601DateFormatter().string(from: tokens.accessTokenExpiresAt)
        try keychain.setString(expiryString, for: .accessTokenExpiry)
    }

    private func clearSession() async {
        do { try keychain.removeAll() } catch { /* ignore */ }
        await clearInMemory()
    }

    private func clearInMemory() async {
        accessToken = nil
        refreshToken = nil
        accessTokenExpiresAt = nil
        isAuthenticated = false
    }
}
