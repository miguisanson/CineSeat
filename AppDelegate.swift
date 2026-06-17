import UIKit

// module 5 app launch setup
// this keeps small app flags together while filemanager handles saved json data
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppPreferences.shared.hasLaunchedBefore = true
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-resetProfileSessionForUITests") {
            AuthenticationService.shared.logOut()
        }
#endif
        return true
    }

    // module 2 scene session lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // storyboard uses this default scene configuration
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // no extra cleanup is needed for this small app yet
    }
}
