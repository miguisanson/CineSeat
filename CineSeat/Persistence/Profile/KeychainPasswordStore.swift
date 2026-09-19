import Foundation
import Security

// module 5 keychain password storage
// passwords are saved outside the profile json file
final class KeychainPasswordStore: PasswordStoring {
    private let service: String

    init(service: String = "SevenSeven.CineSeat.Accounts") {
        self.service = service
    }

    func savePassword(_ password: String, accountID: UUID) throws {
        try deletePassword(accountID: accountID)
        guard let data = password.data(using: .utf8) else {
            throw AuthenticationError.storageFailed
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountID.uuidString,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecValueData as String: data
        ]
        guard SecItemAdd(query as CFDictionary, nil) == errSecSuccess else {
            throw AuthenticationError.storageFailed
        }
    }

    func password(accountID: UUID) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountID.uuidString,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess,
              let data = result as? Data,
              let password = String(data: data, encoding: .utf8) else {
            throw AuthenticationError.storageFailed
        }
        return password
    }

    func deletePassword(accountID: UUID) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountID.uuidString
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw AuthenticationError.storageFailed
        }
    }
}
