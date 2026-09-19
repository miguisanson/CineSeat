import Foundation

// module 6 authentication service
// screens use this through the authenticating protocol from the domain layer
final class AuthenticationService: Authenticating {
    static let authenticationDidChange = Notification.Name("authenticationDidChange")
    static let shared = AuthenticationService(
        profileRepository: ProfileFileRepository(),
        passwordStore: KeychainPasswordStore(),
        sessionStore: AccountSessionStore()
    )

    private let profileRepository: ProfilePersisting
    private let passwordStore: PasswordStoring
    private let sessionStore: AccountSessionStore
    private(set) var profiles: [UserProfile]
    private static let legacyGeneratedProfileIDs: Set<UUID> = Set((1...20).compactMap {
        UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", $0))
    })

    var didChangeNotification: Notification.Name {
        Self.authenticationDidChange
    }

    init(
        profileRepository: ProfilePersisting,
        passwordStore: PasswordStoring,
        sessionStore: AccountSessionStore
    ) {
        self.profileRepository = profileRepository
        self.passwordStore = passwordStore
        self.sessionStore = sessionStore
        let loadedProfiles = (try? profileRepository.loadProfiles()) ?? []
        profiles = Self.cleanedProfiles(from: loadedProfiles)
        let removedProfileIDs = Set(loadedProfiles.map(\.id)).subtracting(profiles.map(\.id))
        for profileID in removedProfileIDs {
            try? passwordStore.deletePassword(accountID: profileID)
        }
        if profiles.count != loadedProfiles.count {
            try? profileRepository.saveProfiles(profiles)
        }

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

    func profile(matchingEmail email: String) -> UserProfile? {
        let normalizedEmail = AccountValidation.normalizedEmail(email)
        return profiles.first { $0.email == normalizedEmail }
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

    private static func cleanedProfiles(from profiles: [UserProfile]) -> [UserProfile] {
        profiles.filter { !legacyGeneratedProfileIDs.contains($0.id) }
    }

}
