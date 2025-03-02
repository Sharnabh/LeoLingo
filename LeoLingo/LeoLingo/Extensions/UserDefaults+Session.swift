import Foundation

extension UserDefaults {
    private enum Keys {
        static let isUserLoggedIn = "isUserLoggedIn"
        static let parentModePasscode = "parentModePasscode"
        static let userId = "userId"
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
    
    func clearSession() {
        isUserLoggedIn = false
        parentModePasscode = nil
        userId = nil
    }
} 