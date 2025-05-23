import UIKit
import SwiftUI
import AVFoundation

class BadgeAchievementManager {
    // Singleton instance
    static let shared = BadgeAchievementManager()
    
    // Private initializer
    private init() {}
    
    // Variable to store the current hosting controller
    private var currentPopupController: UIHostingController<BadgeAchievementPopupView>?
    
    // Audio player for celebration sound
    private var audioPlayer: AVAudioPlayer?
    
    // Method to show the badge achievement popup
    func showBadgeAchievement(for badge: Badge, in viewController: UIViewController) {
        // Create the SwiftUI view for the badge achievement
        let badgeImage = loadBadgeImage(for: badge)
        let badgePopupView = BadgeAchievementPopupView(
            badgeTitle: badge.badgeTitle,
            badgeImage: badgeImage
        )
        
        // Create a hosting controller
        let hostingController = UIHostingController(rootView: badgePopupView)
        hostingController.modalPresentationStyle = .overFullScreen
        hostingController.modalTransitionStyle = .crossDissolve
        hostingController.view.backgroundColor = .clear
        
        // Store reference
        self.currentPopupController = hostingController
        
        // Track this badge as earned and shown in UserDefaults
        UserDefaults.standard.addEarnedBadge(badge.id)
        UserDefaults.standard.markBadgeAsShown(badge.id)
        
        // Play celebration sound
        playCelebrationSound()
        
        // Register for dismiss notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dismissPopup),
            name: NSNotification.Name("DismissBadgeAchievement"),
            object: nil
        )
        
        // Present the popup
        viewController.present(hostingController, animated: true)
        
        // Provide haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // Method to check and show any unshown badges
    func checkAndShowUnshownBadges(in viewController: UIViewController) {
        guard let userId = UserDefaults.standard.userId,
              let id = UUID(uuidString: userId) else { return }
        
        Task {
            do {
                // Get all badges data
                let badges = SupabaseDataController.shared.getBadgesData()
                
                // Get the current user data to ensure badges are loaded
                let userData = try await SupabaseDataController.shared.getUser(byId: id)
                
                // Find any earned badges that haven't been shown yet
                for badge in userData.userBadges.filter({ $0.isEarned }) {
                    // Check if this badge has been earned but not shown
                    if UserDefaults.standard.hasUnshownBadge(badge.id) {
                        // Show achievement popup on the main thread
                        DispatchQueue.main.async {
                            self.showBadgeAchievement(for: badge, in: viewController)
                            // Only show one badge at a time to avoid overwhelming the user
                            return
                        }
                        break
                    }
                    // Track existing earned badges
                    else if badge.isEarned {
                        UserDefaults.standard.addEarnedBadge(badge.id)
                    }
                }
            } catch {
                print("Error checking for unshown badges: \(error)")
            }
        }
    }
    
    @objc private func dismissPopup() {
        // Dismiss popup when notification is received
        currentPopupController?.dismiss(animated: true) {
            self.currentPopupController = nil
        }
        
        // Remove observer
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name("DismissBadgeAchievement"),
            object: nil
        )
    }
    
    // Helper method to load the badge image
    private func loadBadgeImage(for badge: Badge) -> UIImage? {
        // Get all badges data
        let badgesData = SupabaseDataController.shared.getBadgesData()
        
        // Find the app badge with the matching ID
        if let appBadge = badgesData.first(where: { $0.id == badge.id }) {
            // Try to load the image directly
            if let image = UIImage(named: appBadge.badgeImage) {
                return image
            }
            
            // If the direct image load fails, try checking in BadgesAnimalImage folder
            if let image = UIImage(named: "BadgesAnimalImage/\(appBadge.badgeImage)") {
                return image
            }
        }
        
        // If we still don't have an image, use a fallback system image
        return UIImage(systemName: "star.circle.fill")
    }
    
    // Play celebration sound
    private func playCelebrationSound() {
        guard let url = Bundle.main.url(forResource: "celebration", withExtension: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error playing celebration sound: \(error)")
        }
    }
}
