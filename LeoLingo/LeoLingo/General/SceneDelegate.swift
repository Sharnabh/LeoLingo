//
//  SceneDelegate.swift
//  LeoLingo
//
//  Created by Sharnabh on 09/01/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        // Check if user is logged in and we have their ID
        if UserDefaults.standard.isUserLoggedIn, let userIdString = UserDefaults.standard.userId, let userId = UUID(uuidString: userIdString) {
            // Set the user ID in SupabaseDataController
            SupabaseDataController.shared.restoreSession(userId: userId)
            
            // Validate badge IDs at startup to ensure consistency
            BadgeIDManager.shared.logAllBadgeIDs()
            
            // Log any stored badges from UserDefaults
            let storedBadgeIDs = UserDefaults.standard.earnedBadgeIDs
            print("DEBUG: SceneDelegate - Found \(storedBadgeIDs.count) earned badges in UserDefaults")
            for idString in storedBadgeIDs {
                print("DEBUG: SceneDelegate - Stored badge ID: \(idString)")
            }
            
            // User is logged in, go to HomePage
            let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
            if let homePageVC = storyboard.instantiateViewController(withIdentifier: "HomePageViewController") as? HomePageViewController {
                // Create a navigation controller with the home page
                let navigationController = UINavigationController(rootViewController: homePageVC)
                navigationController.setNavigationBarHidden(true, animated: false)
                window.rootViewController = navigationController
                
                // Load user data
                Task {
                    do {
                        _ = try await SupabaseDataController.shared.getUser(byId: userId)
                        // Data is now loaded and cached in SupabaseDataController
                    } catch {
                        print("Error loading user data: \(error)")
                        // Handle error - maybe show an alert or redirect to login
                        UserDefaults.standard.clearSession()
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LogInViewController {
                            window.rootViewController = loginVC
                        }
                    }
                }
            }
        } else {
            // User is not logged in or we don't have their ID, show login page
            UserDefaults.standard.clearSession() // Clear any partial session data
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LogInViewController {
                window.rootViewController = loginVC
            }
        }
        
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

