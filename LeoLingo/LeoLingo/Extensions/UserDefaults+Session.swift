import Foundation

extension UserDefaults {
    private enum Keys {
        static let isUserLoggedIn = "isUserLoggedIn"
        static let parentModePasscode = "parentModePasscode"
        static let userId = "userId"
        static let totalTimeSpent = "totalTimeSpent"
        static let dailyTimeSpent = "dailyTimeSpent"
        static let selectedDuration = "selectedDuration"
        static let lastResetDate = "lastResetDate"
        static let daysUsed = "daysUsed"
        static let lastPhoneNumber = "lastPhoneNumber"
        static let shouldShowOnboardingBadgeAchievement = "shouldShowOnboardingBadgeAchievement"
        static let earnedBadgeIDs = "earnedBadgeIDs"
        static let shownBadgeIDs = "shownBadgeIDs"
    }
    
    var isUserLoggedIn: Bool {
        get {
            return bool(forKey: Keys.isUserLoggedIn)
        }
        set {
            set(newValue, forKey: Keys.isUserLoggedIn)
        }
    }
    
    var userId: String? {
        get {
            return string(forKey: Keys.userId)
        }
        set {
            set(newValue, forKey: Keys.userId)
        }
    }
    
    var parentModePasscode: String? {
        get {
            return string(forKey: Keys.parentModePasscode)
        }
        set {
            set(newValue, forKey: Keys.parentModePasscode)
        }
    }
    
    var shouldShowOnboardingBadgeAchievement: Bool {
        get {
            return bool(forKey: Keys.shouldShowOnboardingBadgeAchievement)
        }
        set {
            set(newValue, forKey: Keys.shouldShowOnboardingBadgeAchievement)
        }
    }
    
    // Track earned badges by storing their UUIDs
    var earnedBadgeIDs: [String] {
        get {
            return array(forKey: Keys.earnedBadgeIDs) as? [String] ?? []
        }
        set {
            set(newValue, forKey: Keys.earnedBadgeIDs)
        }
    }
    
    // Track badges that have been shown to the user
    var shownBadgeIDs: [String] {
        get {
            return array(forKey: Keys.shownBadgeIDs) as? [String] ?? []
        }
        set {
            set(newValue, forKey: Keys.shownBadgeIDs)
        }
    }
    
    // Helper to add a newly earned badge
    func addEarnedBadge(_ badgeId: UUID) {
        var badges = earnedBadgeIDs
        let idString = badgeId.uuidString
        if !badges.contains(idString) {
            badges.append(idString)
            earnedBadgeIDs = badges
        }
    }
    
    // Helper to track which badges have been shown to the user
    func markBadgeAsShown(_ badgeId: UUID) {
        var badges = shownBadgeIDs
        let idString = badgeId.uuidString
        if !badges.contains(idString) {
            badges.append(idString)
            shownBadgeIDs = badges
        }
    }
    
    // Helper to check if a badge has been earned but not yet shown
    func hasUnshownBadge(_ badgeId: UUID) -> Bool {
        let idString = badgeId.uuidString
        return earnedBadgeIDs.contains(idString) && !shownBadgeIDs.contains(idString)
    }
    
    func contains(key: String) -> Bool {
        return object(forKey: key) != nil
    }
    
    func clearSession() {
        // Clear login-related data
        isUserLoggedIn = false
        parentModePasscode = nil
        userId = nil
        
        // Clear timer-related data
        set(0, forKey: Keys.totalTimeSpent)
        set(0, forKey: Keys.dailyTimeSpent)
        set(1800, forKey: Keys.selectedDuration) // Reset to default 30 minutes
        removeObject(forKey: Keys.lastResetDate)
        set(0, forKey: Keys.daysUsed)
        
        // Clear other user data
        removeObject(forKey: Keys.lastPhoneNumber)
        
        // Don't clear badge tracking data as we want to preserve achievements
        // across sessions even if user logs out and logs back in
        
        // Synchronize to ensure all changes are saved
        synchronize()
    }
}