import UIKit

class ParentModeSplitViewController: UISplitViewController {
    
    init() {
        super.init(style: .doubleColumn)
    }
    
    required init?(coder: NSCoder) {
        super.init(style: .doubleColumn)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure split view settings
        preferredDisplayMode = .oneBesideSecondary
        preferredSplitBehavior = .overlay
        
        // Hide the default system sidebar button
        displayModeButtonVisibility = .never
        
        // Set minimum widths for primary and secondary views
        minimumPrimaryColumnWidth = 220
        maximumPrimaryColumnWidth = 300
        
        // Enable collapse and expand gestures
        presentsWithGesture = true
        
        // Set primary and secondary view controllers if not already set
        if viewControllers.isEmpty {
            let sidebarVC = ParentModeSidebarViewController(style: .insetGrouped)
            let mainVC = createMainViewController()
            
            setViewController(sidebarVC, for: .primary)
            setViewController(mainVC, for: .secondary)
        }
    }
    
    @objc private func handleSidebarToggle(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            if self.displayMode == .secondaryOnly || self.displayMode == .oneOverSecondary {
                self.show(.primary)
            } else {
                self.show(.secondary)
            }
        }
    }
    
    private func createMainViewController() -> UIViewController {
        // Get the main tab bar controller from storyboard
        let storyboard = UIStoryboard(name: "ParentMode", bundle: nil)
        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "parentModeTabBar") as? UITabBarController {
            // Wrap each view controller in a navigation controller
            tabBarController.viewControllers = tabBarController.viewControllers?.map { viewController in
                let navigationController = UINavigationController(rootViewController: viewController)
                navigationController.navigationBar.prefersLargeTitles = true
                navigationController.tabBarItem = viewController.tabBarItem

                return navigationController
            }
            return tabBarController
        }
        return UIViewController() // Fallback empty controller
    }
} 
