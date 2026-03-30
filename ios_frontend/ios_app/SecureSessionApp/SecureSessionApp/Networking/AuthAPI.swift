import Foundation

/// Token pair used by the app's SessionManager.
struct TokenPair: Codable {
    let accessToken: String
    let refreshToken: String
    let accessTokenExpiresAt: Date
}

/// OpenAPI: LoginRequest { username, password }
private struct LoginRequest: Codable {
    let username: String
    let password: String
}

/// OpenAPI: RefreshRequest { refresh_token }
private struct RefreshRequest: Codable {
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

/// OpenAPI: LogoutRequest { refresh_token }
private struct LogoutRequest: Codable {
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

/// OpenAPI: TokenResponse
/// { access_token, access_token_expires_in, refresh_token, refresh_token_expires_in, token_type }
private struct TokenResponse: Codable {
    let accessToken: String
    let accessTokenExpiresIn: Int
    let refreshToken: String
    let refreshTokenExpiresIn: Int
    let tokenType: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case accessTokenExpiresIn = "access_token_expires_in"
        case refreshToken = "refresh_token"
        case refreshTokenExpiresIn = "refresh_token_expires_in"
        case tokenType = "token_type"
    }
}

/// OpenAPI: MeResponse { username, session_id, access_expires_at }
struct MeResponse: Codable {
    let username: String
    let sessionId: String
    let accessExpiresAt: Int

    enum CodingKeys: String, CodingKey {
        case username
        case sessionId = "session_id"
        case accessExpiresAt = "access_expires_at"
    }
}

final class AuthAPI {
    static let shared = AuthAPI()
    private init() {}

    // PUBLIC_INTERFACE
    func login(email: String, password: String) async throws -> TokenPair {
        // Log in and return a new token pair.
        //
        // Calls FastAPI:
        // - POST /auth/login { "username": "<email>", "password": "<password>" }
        // - Returns TokenPair where `accessTokenExpiresAt = now + access_token_expires_in`.
        let url = APIConfig.baseURL.appendingPathComponent("/auth/login")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(LoginRequest(username: email, password: password))

        let (data, response) = try await URLSession.shared.data(for: request)
        let http = try requireHTTP(response)

        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 { throw AppError.invalidCredentials }
            throw AppError.networking("HTTP \(http.statusCode)")
        }

        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        return mapTokenResponseToTokenPair(tokenResponse)
    }

    // PUBLIC_INTERFACE
    func refresh(refreshToken: String) async throws -> TokenPair {
        // Refresh tokens using a refresh token.
        //
        // Calls FastAPI:
        // - POST /auth/refresh { "refresh_token": "<token>" }
        // - Returns a new access token and (rotated) refresh token.
        let url = APIConfig.baseURL.appendingPathComponent("/auth/refresh")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(RefreshRequest(refreshToken: refreshToken))

        let (data, response) = try await URLSession.shared.data(for: request)
        let http = try requireHTTP(response)

        guard (200..<300).contains(http.statusCode) else {
            throw AppError.refreshFailed
        }

        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        return mapTokenResponseToTokenPair(tokenResponse)
    }

    // PUBLIC_INTERFACE
    func logout(refreshToken: String?) async {
        // Logout and invalidate refresh token on backend (best-effort).
        //
        // Calls FastAPI:
        // - POST /auth/logout { "refresh_token": "<token>" } -> 204
        guard let refreshToken else { return }

        let url = APIConfig.baseURL.appendingPathComponent("/auth/logout")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(LogoutRequest(refreshToken: refreshToken))

        _ = try? await URLSession.shared.data(for: request)
    }

    // PUBLIC_INTERFACE
    func me(accessToken: String) async throws -> MeResponse {
        // Fetch the current user from the backend.
        //
        // Calls FastAPI:
        // - GET /me (Authorization: Bearer <access_token>)
        let url = APIConfig.baseURL.appendingPathComponent("/me")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        let http = try requireHTTP(response)

        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 { throw AppError.notAuthenticated }
            throw AppError.networking("HTTP \(http.statusCode)")
        }

        return try JSONDecoder().decode(MeResponse.self, from: data)
    }

    private func mapTokenResponseToTokenPair(_ tokenResponse: TokenResponse) -> TokenPair {
        // Backend provides "expires_in" (seconds). We persist an absolute ISO8601 timestamp in Keychain.
        return TokenPair(
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken,
            accessTokenExpiresAt: Date().addingTimeInterval(TimeInterval(tokenResponse.accessTokenExpiresIn))
        )
    }

    private func requireHTTP(_ response: URLResponse) throws -> HTTPURLResponse {
        guard let http = response as? HTTPURLResponse else {
            throw AppError.networking("Invalid response.")
        }
        return http
    }
}
