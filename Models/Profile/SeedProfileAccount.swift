import Foundation

// module 5 seed account bundle
// password is separate so json profile data does not own keychain behavior
struct SeedProfileAccount {
    let profile: UserProfile
    let password: String
}
