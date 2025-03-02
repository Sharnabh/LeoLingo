import Foundation

extension UserDefaults {
    private enum Keys {
        static let isUserLoggedIn = "isUserLoggedIn"
        static let parentModePasscode = "parentModePasscode"
    }
    
    var isUserLoggedIn: Bool {
        get {
            return bool(forKey: Keys.isUserLoggedIn)
        }
        set {
            set(newValue, forKey: Keys.isUserLoggedIn)
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
    }
} 