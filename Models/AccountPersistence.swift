import Foundation
import Security

// module 5 account persistence contracts
// profiles use json while passwords use keychain through separate protocols
protocol ProfilePersisting {
    func loadProfiles() throws -> [UserProfile]
    func saveProfiles(_ profiles: [UserProfile]) throws
}

// module 5 profile file repository
// this writes profile arrays as codable json
final class ProfileFileRepository: ProfilePersisting {
    private let fileManager: FileManager
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        fileManager: FileManager = .default,
        directoryURL: URL? = nil,
        fileName: String = "profiles.json"
    ) {
        self.fileManager = fileManager
        let documentsDirectory = directoryURL ?? fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        fileURL = documentsDirectory.appendingPathComponent(fileName)

        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func loadProfiles() throws -> [UserProfile] {
        guard fileManager.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([UserProfile].self, from: data)
    }

    func saveProfiles(_ profiles: [UserProfile]) throws {
        try fileManager.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let data = try encoder.encode(profiles)
        try data.write(to: fileURL, options: .atomic)
    }
}

// module 5 password storage contract
// keychain is hidden behind a protocol so tests can use a fake store
protocol PasswordStoring {
    func savePassword(_ password: String, accountID: UUID) throws
    func password(accountID: UUID) throws -> String?
    func deletePassword(accountID: UUID) throws
}

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

// module 5 userdefaults session storage
// only the signed in profile id is stored here
final class AccountSessionStore {
    private let defaults: UserDefaults
    private let key = "signedInProfileID"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var signedInProfileID: UUID? {
        get {
            guard let value = defaults.string(forKey: key) else { return nil }
            return UUID(uuidString: value)
        }
        set {
            defaults.set(newValue?.uuidString, forKey: key)
        }
    }
}

// module 6 authentication service
// screens use this through the authenticating protocol from the domain layer
final class AuthenticationService: Authenticating {
    static let authenticationDidChange = Notification.Name("authenticationDidChange")
    static let shared = AuthenticationService(
        profileRepository: ProfileFileRepository(),
        passwordStore: KeychainPasswordStore(),
        sessionStore: AccountSessionStore(),
        seedAccounts: SampleData.profileAccounts
    )

    private let profileRepository: ProfilePersisting
    private let passwordStore: PasswordStoring
    private let sessionStore: AccountSessionStore
    private(set) var profiles: [UserProfile]

    var didChangeNotification: Notification.Name {
        Self.authenticationDidChange
    }

    init(
        profileRepository: ProfilePersisting,
        passwordStore: PasswordStoring,
        sessionStore: AccountSessionStore,
        seedAccounts: [SampleProfileAccount] = []
    ) {
        self.profileRepository = profileRepository
        self.passwordStore = passwordStore
        self.sessionStore = sessionStore
        let loadedProfiles = (try? profileRepository.loadProfiles()) ?? []
        if loadedProfiles.isEmpty && !seedAccounts.isEmpty {
            profiles = seedAccounts.map(\.profile)
            try? profileRepository.saveProfiles(profiles)
        } else {
            profiles = loadedProfiles
        }
        seedMissingPasswords(for: seedAccounts)

        if let profileID = sessionStore.signedInProfileID,
           !profiles.contains(where: { $0.id == profileID }) {
            sessionStore.signedInProfileID = nil
        }
    }

    var currentProfile: UserProfile? {
        guard let profileID = sessionStore.signedInProfileID else { return nil }
        return profiles.first { $0.id == profileID }
    }

    @discardableResult
    func createAccount(
        fullName: String,
        email: String,
        phoneNumber: String,
        password: String
    ) throws -> UserProfile {
        guard fullName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else {
            throw AuthenticationError.invalidName
        }
        guard AccountValidation.isValidEmail(email) else {
            throw AuthenticationError.invalidEmail
        }
        guard AccountValidation.isStrongPassword(password) else {
            throw AuthenticationError.weakPassword
        }

        let normalizedEmail = AccountValidation.normalizedEmail(email)
        guard !profiles.contains(where: { $0.email == normalizedEmail }) else {
            throw AuthenticationError.emailAlreadyExists
        }

        let profile = UserProfile(
            id: UUID(),
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: normalizedEmail,
            phoneNumber: phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
            joinedAt: Date()
        )

        try passwordStore.savePassword(password, accountID: profile.id)
        profiles.append(profile)
        do {
            try profileRepository.saveProfiles(profiles)
        } catch {
            profiles.removeAll { $0.id == profile.id }
            try? passwordStore.deletePassword(accountID: profile.id)
            throw AuthenticationError.storageFailed
        }

        sessionStore.signedInProfileID = profile.id
        postAuthenticationChange()
        return profile
    }

    @discardableResult
    func logIn(email: String, password: String) throws -> UserProfile {
        guard AccountValidation.isValidEmail(email) else {
            throw AuthenticationError.invalidEmail
        }

        let normalizedEmail = AccountValidation.normalizedEmail(email)
        guard let profile = profiles.first(where: { $0.email == normalizedEmail }),
              try passwordStore.password(accountID: profile.id) == password else {
            throw AuthenticationError.invalidCredentials
        }

        sessionStore.signedInProfileID = profile.id
        postAuthenticationChange()
        return profile
    }

    func logOut() {
        sessionStore.signedInProfileID = nil
        postAuthenticationChange()
    }

    @discardableResult
    func updateCurrentProfile(
        fullName: String,
        email: String,
        phoneNumber: String
    ) throws -> UserProfile {
        guard let currentProfile, let index = profiles.firstIndex(where: { $0.id == currentProfile.id }) else {
            throw AuthenticationError.noSignedInUser
        }

        let normalizedEmail = AccountValidation.normalizedEmail(email)
        guard fullName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else {
            throw AuthenticationError.invalidName
        }
        guard AccountValidation.isValidEmail(email) else {
            throw AuthenticationError.invalidEmail
        }
        guard !profiles.contains(where: { $0.id != currentProfile.id && $0.email == normalizedEmail }) else {
            throw AuthenticationError.emailAlreadyExists
        }

        profiles[index].fullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        profiles[index].email = normalizedEmail
        profiles[index].phoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            try profileRepository.saveProfiles(profiles)
        } catch {
            throw AuthenticationError.storageFailed
        }
        postAuthenticationChange()
        return profiles[index]
    }

    private func postAuthenticationChange() {
        NotificationCenter.default.post(name: Self.authenticationDidChange, object: nil)
    }

    private func seedMissingPasswords(for seedAccounts: [SampleProfileAccount]) {
        for account in seedAccounts where profiles.contains(where: { $0.id == account.profile.id }) {
            if (try? passwordStore.password(accountID: account.profile.id)) == nil {
                try? passwordStore.savePassword(account.password, accountID: account.profile.id)
            }
        }
    }
}
