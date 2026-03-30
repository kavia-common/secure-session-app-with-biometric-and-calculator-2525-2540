import Foundation
import Security

final class KeychainStore {
    static let shared = KeychainStore()

    private init() {}

    private let service = "org.example.securesession"

    enum Key: String {
        case accessToken
        case refreshToken
        case accessTokenExpiry // stored as ISO8601 string
    }

    // PUBLIC_INTERFACE
    func setString(_ value: String, for key: Key) throws {
        // Store a string securely in Keychain.
        //
        // - Parameters:
        //   - value: String to store.
        //   - key: Key identifier.
        // - Throws: AppError.keychain on failure.
        guard let data = value.data(using: .utf8) else {
            throw AppError.keychain("Failed to encode string.")
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]

        SecItemDelete(query as CFDictionary)

        let attributes: [String: Any] = query.merging([
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]) { $1 }

        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw AppError.keychain("SecItemAdd failed with status \(status).")
        }
    }

    // PUBLIC_INTERFACE
    func getString(for key: Key) throws -> String? {
        // Retrieve a string from Keychain.
        //
        // - Parameter key: Key identifier.
        // - Returns: Stored string or nil if not found.
        // - Throws: AppError.keychain on unexpected Keychain failures.
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw AppError.keychain("SecItemCopyMatching failed with status \(status).")
        }

        guard let data = item as? Data else {
            throw AppError.keychain("Unexpected item type.")
        }
        return String(data: data, encoding: .utf8)
    }

    // PUBLIC_INTERFACE
    func remove(_ key: Key) throws {
        // Remove an entry from Keychain.
        //
        // - Parameter key: Key identifier.
        // - Throws: AppError.keychain on failure.
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw AppError.keychain("SecItemDelete failed with status \(status).")
        }
    }

    // PUBLIC_INTERFACE
    func removeAll() throws {
        // Remove all app entries from Keychain for this service.
        for key in [Key.accessToken, .refreshToken, .accessTokenExpiry] {
            try remove(key)
        }
    }
}
