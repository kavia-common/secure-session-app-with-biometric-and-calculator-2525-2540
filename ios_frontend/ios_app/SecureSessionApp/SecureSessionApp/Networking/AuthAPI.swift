import Foundation

struct TokenPair: Codable {
    let accessToken: String
    let refreshToken: String
    let accessTokenExpiresAt: Date
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RefreshRequest: Codable {
    let refreshToken: String
}

final class AuthAPI {
    static let shared = AuthAPI()
    private init() {}

    // PUBLIC_INTERFACE
    func login(email: String, password: String) async throws -> TokenPair {
        """Log in and return a new token pair.
        
        Uses URLSession to call a backend if `APIConfig.baseURL` is configured; otherwise uses a local mock.
        """
        if APIConfig.baseURL == nil {
            return try await mockLogin(email: email, password: password)
        }

        // Example real endpoint design:
        // POST /auth/login { email, password } -> { accessToken, refreshToken, accessTokenExpiresAt }
        let url = APIConfig.baseURL!.appendingPathComponent("/auth/login")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try JSONEncoder().encode(LoginRequest(email: email, password: password))

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw AppError.networking("Invalid response.")
        }
        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 { throw AppError.invalidCredentials }
            throw AppError.networking("HTTP \(http.statusCode)")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(TokenPair.self, from: data)
    }

    // PUBLIC_INTERFACE
    func refresh(refreshToken: String) async throws -> TokenPair {
        """Refresh tokens using a refresh token.
        
        Uses URLSession to call a backend if configured; otherwise uses a local mock.
        """
        if APIConfig.baseURL == nil {
            return try await mockRefresh(refreshToken: refreshToken)
        }

        // Example real endpoint design:
        // POST /auth/refresh { refreshToken } -> { accessToken, refreshToken, accessTokenExpiresAt }
        let url = APIConfig.baseURL!.appendingPathComponent("/auth/refresh")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(RefreshRequest(refreshToken: refreshToken))

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw AppError.networking("Invalid response.")
        }
        guard (200..<300).contains(http.statusCode) else {
            throw AppError.refreshFailed
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(TokenPair.self, from: data)
    }

    // PUBLIC_INTERFACE
    func logout(accessToken: String?) async {
        """Logout and invalidate session on backend if available.
        
        In mock mode this is a no-op.
        """
        guard let baseURL = APIConfig.baseURL else { return }
        let url = baseURL.appendingPathComponent("/auth/logout")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        _ = try? await URLSession.shared.data(for: request)
    }

    // MARK: - Mock backend

    private func mockLogin(email: String, password: String) async throws -> TokenPair {
        try await Task.sleep(nanoseconds: 450_000_000)

        // Very simple demo logic.
        guard !email.isEmpty, password == "password" else {
            throw AppError.invalidCredentials
        }

        return TokenPair(
            accessToken: "access_\(UUID().uuidString)",
            refreshToken: "refresh_\(UUID().uuidString)",
            accessTokenExpiresAt: Date().addingTimeInterval(60) // expires quickly to demonstrate refresh
        )
    }

    private func mockRefresh(refreshToken: String) async throws -> TokenPair {
        try await Task.sleep(nanoseconds: 250_000_000)

        guard refreshToken.hasPrefix("refresh_") else {
            throw AppError.refreshFailed
        }

        return TokenPair(
            accessToken: "access_\(UUID().uuidString)",
            refreshToken: refreshToken, // keep same refresh token in mock
            accessTokenExpiresAt: Date().addingTimeInterval(60)
        )
    }
}
