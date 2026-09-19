import UIKit

// module 2 scene lifecycle
// storyboard creates the first window and connects the tab bar screens
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // the storyboard handles the window so there is no manual setup here
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // no scene specific resources yet
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // app is active again
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // app is about to pause
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // app is coming back to the front
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // module 5 saved json files are written by the repositories when changes happen
    }
}
