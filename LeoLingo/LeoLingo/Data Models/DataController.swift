//
//  DataController.swift
//  LeoLingo
//
//  Created by Batch - 2  on 23/01/25.
//

import Foundation

class DataController {
    
    private var user: [UserData] = []
    
    static var shared = DataController()
    
    private init() {
        
    }
    // Users
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
        if user.contains(where: {$0.phoneNumber == phoneNumber && $0.password == password}) {
            return user.first
        } else {
            return nil
        }
    }
    
    // Levels
    func getAllLevels() -> [Level] {
        return user[0].userLevels
    }
    
    func updateLevels(_ levels: [Level]) {
        user[0].userLevels = levels
    }
    
    func levelData(at index: Int) -> Level {
        return user[0].userLevels[index]
    }
    
    func updateWordPraticeStatus(at index: Int, wordIndex: Int, accuracy: Double?) {
        user[0].userLevels[index].words[wordIndex].isPracticed = true
        updateWordRecord(at: index, wordIndex: wordIndex, accuracy: accuracy)
    }
    
    func updateWordRecord(at index: Int, wordIndex: Int, accuracy: Double?) {
        user[0].userLevels[index].words[wordIndex].record?.attempts += 1
        if let accuracy = accuracy {
            user[0].userLevels[index].words[wordIndex].record?.accuracy?.append(accuracy)
        }
    }
    
    // Badges
    func getBadges() -> [Badge] {
        return user[0].userBadges
    }
    
    func countBadges() -> Int {
        return user[0].userBadges.count
    }
    
    func getEarnedBadges() -> [Badge] {
        return user[0].userEarnedBadges
    }
    
    func appendEarnedBadge(_ badge: Badge) {
        user[0].userEarnedBadges.append(badge)
    }
    
    func countEarnedBadges() -> Int {
        return user[0].userEarnedBadges.count
    }
    
    func updateBadgeStatus(_ badge: Badge) {
        var index = 0
        for i in user[0].userBadges {
            index += 1
            if i.badgeTitle == badge.badgeTitle {
                user[0].userBadges[index].isEarned = true
            }
        }
        user[0].userEarnedBadges.append(badge)
    }
    
}
