import Foundation

// module 5 password storage contract
// keychain is hidden behind a protocol so tests can use a fake store
protocol PasswordStoring {
    func savePassword(_ password: String, accountID: UUID) throws
    func password(accountID: UUID) throws -> String?
    func deletePassword(accountID: UUID) throws
}
