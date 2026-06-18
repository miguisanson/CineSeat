import Foundation

// module 5 sample account bundle
// password is separate so json profile data does not own keychain behavior
struct SampleProfileAccount {
    let profile: UserProfile
    let password: String
}
