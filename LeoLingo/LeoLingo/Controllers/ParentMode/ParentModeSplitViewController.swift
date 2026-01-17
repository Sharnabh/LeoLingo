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
        
        // Customize the sidebar button appearance
        customizeSidebarButton()
        
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
    
    private func customizeSidebarButton() {
        // Create custom sidebar button with Vocal Coach back button style
        let sidebarButton = UIButton(type: .custom)
        sidebarButton.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        sidebarButton.backgroundColor = UIColor.white.withAlphaComponent(0.77)
        sidebarButton.layer.cornerRadius = 30
        sidebarButton.layer.shadowColor = UIColor.black.cgColor
        sidebarButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        sidebarButton.layer.shadowRadius = 2
        sidebarButton.layer.shadowOpacity = 0.2
        
        // Set the sidebar icon (keep the default system icon)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: "sidebar.left", withConfiguration: symbolConfig)?
            .withTintColor(UIColor(named: "AccentColor") ?? .systemGreen, renderingMode: .alwaysOriginal)
        sidebarButton.setImage(image, for: .normal)
        
        // Add action to toggle sidebar
        sidebarButton.addTarget(self, action: #selector(toggleSidebar), for: .touchUpInside)
        
        // Replace the default display mode button
        if let secondaryVC = viewController(for: .secondary) {
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            containerView.addSubview(sidebarButton)
            
            let barButtonItem = UIBarButtonItem(customView: containerView)
            
            // Set the button on the secondary view controller's navigation item
            if let navController = secondaryVC as? UINavigationController {
                navController.topViewController?.navigationItem.leftBarButtonItem = barButtonItem
            } else if let tabBarController = secondaryVC as? UITabBarController {
                if let selectedNav = tabBarController.selectedViewController as? UINavigationController {
                    selectedNav.topViewController?.navigationItem.leftBarButtonItem = barButtonItem
                }
            }
        }
    }
    
    @objc private func toggleSidebar() {
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
                
                // Add custom sidebar button to each navigation controller
                addCustomSidebarButton(to: navigationController)
                
                return navigationController
            }
            return tabBarController
        }
        return UIViewController() // Fallback empty controller
    }
    
    private func addCustomSidebarButton(to navigationController: UINavigationController) {
        // Create custom sidebar button with Vocal Coach back button style
        let sidebarButton = UIButton(type: .custom)
        sidebarButton.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        sidebarButton.backgroundColor = UIColor.white.withAlphaComponent(0.77)
        sidebarButton.layer.cornerRadius = 30
        sidebarButton.layer.shadowColor = UIColor.black.cgColor
        sidebarButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        sidebarButton.layer.shadowRadius = 2
        sidebarButton.layer.shadowOpacity = 0.2
        
        // Set the sidebar icon
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: "sidebar.left", withConfiguration: symbolConfig)?
            .withTintColor(UIColor(named: "AccentColor") ?? .systemGreen, renderingMode: .alwaysOriginal)
        sidebarButton.setImage(image, for: .normal)
        
        // Add action to toggle sidebar
        sidebarButton.addTarget(self, action: #selector(toggleSidebar), for: .touchUpInside)
        
        // Wrap in container to prevent navigation bar from resizing
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        containerView.addSubview(sidebarButton)
        
        let barButtonItem = UIBarButtonItem(customView: containerView)
        navigationController.topViewController?.navigationItem.leftBarButtonItem = barButtonItem
    }
} 
