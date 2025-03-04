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
        
        // Synchronize to ensure all changes are saved
        synchronize()
    }
} 