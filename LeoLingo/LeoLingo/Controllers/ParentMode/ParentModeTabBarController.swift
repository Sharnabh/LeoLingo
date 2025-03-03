import UIKit

class ParentModeTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create sidebar toggle button
        let sidebarButton = UIBarButtonItem(
            image: UIImage(systemName: "sidebar.left"),
            style: .plain,
            target: self,
            action: #selector(toggleSidebar)
        )
        
        // Add button to all view controllers in the tab bar
        viewControllers?.forEach { viewController in
            viewController.navigationItem.leftBarButtonItem = sidebarButton
        }
    }
    
    @objc private func toggleSidebar() {
        if let splitViewController = splitViewController {
            splitViewController.show(.primary)
        }
    }
} 