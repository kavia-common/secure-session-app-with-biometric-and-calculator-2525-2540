import Foundation

enum APIConfig {
    /// Base URL for the FastAPI backend preview.
    ///
    /// IMPORTANT:
    /// - iOS Simulator can reach your host machine via `http://localhost:<port>`.
    /// - A physical device cannot use `localhost`; you must point to your machine's LAN IP or a tunnel URL.
    static let baseURL: URL = URL(string: "http://localhost:3001")!
}
