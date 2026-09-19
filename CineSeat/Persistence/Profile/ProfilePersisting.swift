import Foundation

// module 5 account persistence contract
// profile json storage hides the filemanager details
protocol ProfilePersisting {
    func loadProfiles() throws -> [UserProfile]
    func saveProfiles(_ profiles: [UserProfile]) throws
}
