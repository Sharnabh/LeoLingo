import UIKit

class ParentModeSidebarViewController: UITableViewController {
    
    enum MenuItem: Int, CaseIterable {
        case dashboard
        case wordReport
        case badges
        
        var title: String {
            switch self {
            case .dashboard: return "Dashboard"
            case .wordReport: return "Word Report"
            case .badges: return "Badges"
            }
        }
        
        var image: UIImage? {
            switch self {
            case .dashboard: return UIImage(systemName: "house.fill")
            case .wordReport: return UIImage(systemName: "doc.text.fill")
            case .badges: return UIImage(systemName: "star.fill")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure table view
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MenuCell")
        tableView.backgroundColor = .systemGroupedBackground
        
        // Set title
        title = "Menu"
        
        // Configure navigation bar appearance
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add switch to kids mode button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Kids Mode",
            image: UIImage(systemName: "person.circle.fill"),
            primaryAction: UIAction { [weak self] _ in
                self?.switchToKidsMode()
            }
        )
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Main menu section and Sign out section
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? MenuItem.allCases.count : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        
        if indexPath.section == 0 {
            guard let menuItem = MenuItem(rawValue: indexPath.row) else { return cell }
            content.text = menuItem.title
            content.image = menuItem.image
        } else {
            content.text = "Sign Out"
            content.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
            content.textProperties.color = .systemRed
            content.imageProperties.tintColor = .systemRed
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Navigation" : nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard let menuItem = MenuItem(rawValue: indexPath.row),
                  let splitViewController = splitViewController,
                  let tabBarController = (splitViewController.viewController(for: .secondary) as? UITabBarController) else {
                return
            }
            
            // Switch to the corresponding tab
            switch menuItem {
            case .dashboard:
                tabBarController.selectedIndex = 0
            case .wordReport:
                tabBarController.selectedIndex = 1
            case .badges:
                tabBarController.selectedIndex = 2
            }
            
            // Collapse the sidebar on selection for compact size classes
            if splitViewController.displayMode == .primaryOverlay {
                splitViewController.show(.secondary)
            }
        } else {
            // Handle sign out
            let alertController = UIAlertController(
                title: "Sign Out",
                message: "Are you sure you want to sign out?",
                preferredStyle: .alert
            )
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
                self?.signOut()
            })
            
            present(alertController, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func switchToKidsMode() {
        let alertVC = UIAlertController(title: "Do you want to exit Parent mode?", message: nil, preferredStyle: .alert)
        
        alertVC.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
            if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomePageViewController") as? HomePageViewController {
                homeVC.modalPresentationStyle = .fullScreen
                self?.present(homeVC, animated: true, completion: nil)
            }
        }))
        
        alertVC.addAction(UIAlertAction(title: "No", style: .cancel))
        
        present(alertVC, animated: true)
    }
    
    private func signOut() {
        // Clear user session
        UserDefaults.standard.clearSession()
        
        // Navigate to login screen
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LogInViewController {
            loginVC.modalPresentationStyle = .fullScreen
            
            // Set the window's root view controller to ensure proper navigation stack
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = loginVC
                sceneDelegate.window?.makeKeyAndVisible()
            }
        }
    }
} 
