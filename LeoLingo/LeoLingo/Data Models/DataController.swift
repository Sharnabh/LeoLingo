//
//  DataController.swift
//  LeoLingo
//
//  Created by Batch - 2  on 23/01/25.
//

import Foundation

class DataController {
    
    private var user: [UserData] = []
    private var app: AppData = AppData(levels: SampleDataController.shared.getLevelsData(), badges: SampleDataController.shared.getBadgesData())
    static var shared = DataController()
    
    private init() {
        // Add sample user during initialization
        createSampleUser()
    }
    
    private func createSampleUser() {
        // Create sample user with levels and badges
        let sampleLevels = getUserLevelsData()
        let sampleBadges = getUserBadgesData()
        
        // Create earned badges (at least 2 for the dashboard)
        var earnedBadges = [Badge]()
        for badge in sampleBadges.prefix(2) {
            var earnedBadge = badge
            earnedBadge.isEarned = true
            earnedBadges.append(earnedBadge)
        }
        
        let sampleUser = UserData(
            name: "Sample User",
            phoneNumber: "123",
            password: "123",
            passcode: "0000",
            userLevels: sampleLevels,
            userEarnedBadges: earnedBadges,
            userBadges: sampleBadges
        )
        
        createUser(user: sampleUser)
    }
    
    // Users
    func getUserLevelsData() -> [Level] {
        var levels: [Level] = []
        for level in app.levels {
            var words: [Word] = []
            for word in level.words {
                words.append(Word(id: word.id))
            }
            levels.append(Level(id: level.id, words: words))
        }
        return levels
    }
    
    func getUserBadgesData() -> [Badge] {
        var badges: [Badge] = []
        for badge in app.badges {
            badges.append(Badge(id: badge.id, isEarned: true))
        }
        return badges
    }
    
    func getUserEarnedBadges() -> [Badge] {
        var badges: [Badge] = getUserBadgesData()
        var earnedBadges: [Badge] = []
        for badge in badges {
            if badge.isEarned {
                earnedBadges.append(badge)
            }
        }
        return earnedBadges
    }
    
    func createUser(user: UserData) {
        self.user.append(user)
    }
    
    func getallUsers() -> [UserData] {
        return user
    }
    
    func updatePasscode(_ passcode: String) {
        
        self.user[0].passcode = passcode
    }
    
    func findUser(byPhone phoneNumber: String) -> UserData? {
        
        if user.contains(where: { $0.phoneNumber == phoneNumber }) {
            return user.first(where: { $0.phoneNumber == phoneNumber })
        } else {
            return nil
        }
    }
    
    func validateUser(phoneNumber: String, password: String) -> UserData? {
        return user.first(where: { $0.phoneNumber == phoneNumber && $0.password == password })
    }
    
    // Levels
    func getAllLevels() -> [Level] {
        guard !user.isEmpty else { return [] }
        return user[0].userLevels
    }
    
    func getLevel(by id: UUID) -> AppLevel? {
        for level in app.levels {
            if level.id == id {
                return level
            }
        }
        return nil
    }
    
    func updateLevels(_ levels: [Level]) {
        guard !user.isEmpty else { return }
        user[0].userLevels = levels
    }
    
    func levelData(at index: Int) -> Level {
        guard !user.isEmpty,
              index < user[0].userLevels.count else { 
            // Return an empty level instead of nil
            return Level(id: UUID(), words: [])
        }
        return user[0].userLevels[index]
    }
    
    func updateWordPraticeStatus(at index: Int, wordIndex: Int, accuracy: Double?) {
        guard !user.isEmpty,
              index < user[0].userLevels.count,
              wordIndex < user[0].userLevels[index].words.count else { return }
        
        user[0].userLevels[index].words[wordIndex].isPracticed = true
        updateWordRecord(at: index, wordIndex: wordIndex, accuracy: accuracy)
    }
    
    func updateWordRecord(at index: Int, wordIndex: Int, accuracy: Double?) {
        guard !user.isEmpty,
              index < user[0].userLevels.count,
              wordIndex < user[0].userLevels[index].words.count else { return }
        
        user[0].userLevels[index].words[wordIndex].record?.attempts += 1
        if let accuracy = accuracy {
            user[0].userLevels[index].words[wordIndex].record?.accuracy?.append(accuracy)
        }
    }
    
    func wordData(by id: UUID) -> AppWord? {
        var words = app.levels.flatMap { $0.words }
        for word in words {
            if word.id == id {
                return word
            }
        }
        return nil
    }
    
    // Badges
    func getBadges() -> [AppBadge] {
        return app.badges
    }
    
    func getBadgesStatus(_ badge: AppBadge) -> Bool {
        for i in user[0].userBadges {
            if i.id == badge.id {
                return i.isEarned
            }
        }
        return false
    }
    
    func countBadges() -> Int {
        return app.badges.count
    }
    
    func getEarnedBadges() -> [AppBadge] {
        var earnedBadges: [AppBadge] = []
        for badge in user[0].userBadges {
            if badge.isEarned {
                for i in app.badges {
                    if badge.id == i.id {
                        earnedBadges.append(i)
                    }
                }
            }
        }
        return earnedBadges
    }
    
    func appendEarnedBadge(_ badge: Badge) {
        user[0].userEarnedBadges.append(badge)
    }
    
    func countEarnedBadges() -> Int {
        var count: Int = 0
        for badges in user[0].userBadges {
            if badges.isEarned {
                count += 1
            }
        }
        return count
    }
    
    func addEarnedBadges() {
        for badge in app.badges {
            var badges: Badge = Badge(id: badge.id, isEarned: true)
            if badges.isEarned {
                user[0].userEarnedBadges.append(badges)
            }
        }
    }
    
    func updateBadgeStatus(_ badge: Badge) {
        var index = 0
        for i in user[0].userBadges {
            index += 1
            if i.id == badge.id {
                user[0].userBadges[index].isEarned = true
            }
        }
        user[0].userEarnedBadges.append(badge)
    }
    
}
