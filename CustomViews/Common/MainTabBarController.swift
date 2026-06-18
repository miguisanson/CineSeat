import UIKit

// module 2 tab bar controller
// storyboard owns the tabs while this sets the visual style
final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = CineSeatTheme.border
        appearance.stackedLayoutAppearance.selected.iconColor = CineSeatTheme.primaryText
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: CineSeatTheme.primaryText]
        appearance.stackedLayoutAppearance.normal.iconColor = CineSeatTheme.mutedText
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: CineSeatTheme.mutedText]
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
