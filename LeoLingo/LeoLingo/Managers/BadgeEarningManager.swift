//
//  BadgeEarningManager.swift
//  LeoLingo
//
//  Created by Badge System on 2025
//  Copyright © 2025 Sharnabh. All rights reserved.
//
//  PROPRIETARY AND CONFIDENTIAL
//  This software is protected by copyright and commercial license.
//  Unauthorized copying, distribution, modification, or reverse engineering is prohibited.
//

import Foundation
import UIKit

class BadgeEarningManager {
    static let shared = BadgeEarningManager()
    
    private init() {}
    
    // MARK: - Main Badge Checking Function
    
    /// Checks all badge earning conditions and awards badges if criteria are met
    func checkAndAwardBadges(in viewController: UIViewController) {
        guard let userId = SupabaseDataController.shared.userId else {
            print("DEBUG: BadgeEarningManager - No user ID found")
            return
        }
        
        Task {
            do {
                // Get current user data
                let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                
                // Check each badge type
                await checkBeeBadge(userData: userData, in: viewController)
                await checkTurtleBadge(userData: userData, in: viewController)
                await checkElephantBadge(userData: userData, in: viewController)
                await checkDogBadge(userData: userData, in: viewController)
                await checkBunnyBadge(userData: userData, in: viewController)
                await checkLionBadge(userData: userData, in: viewController)
                await checkLevelBadges(userData: userData, in: viewController)
                
            } catch {
                print("DEBUG: BadgeEarningManager - Error checking badges: \(error)")
            }
        }
    }
    
    // MARK: - Individual Badge Check Functions
    
    /// Bee Badge: Award after completing first word
    private func checkBeeBadge(userData: UserData, in viewController: UIViewController) async {
        // Check if badge is already earned
        guard !isBadgeAlreadyEarned("Bee", userData: userData) else { return }
        
        // Check if user has practiced at least one word
        let allWords = userData.userLevels.flatMap { $0.words }
        let practicedWords = allWords.filter { $0.isPracticed }
        
        if practicedWords.count >= 1 {
            print("DEBUG: BadgeEarningManager - Awarding Bee badge for first word completion")
            await awardBadge("Bee", in: viewController)
        }
    }
    
    /// Turtle Badge: Award for consistent practice over time
    private func checkTurtleBadge(userData: UserData, in viewController: UIViewController) async {
        // Check if badge is already earned
        guard !isBadgeAlreadyEarned("Turtle", userData: userData) else { return }
        
        // Get practice consistency metrics
        let allWords = userData.userLevels.flatMap { $0.words }
        let practicedWords = allWords.filter { $0.isPracticed }
        let practiceStreak = UserDefaults.standard.integer(forKey: "practiceStreak")
        let maxStreak = UserDefaults.standard.integer(forKey: "maxPracticeStreak")
        
        // Award turtle badge for consistent practice (any of these conditions):
        // - 15+ practiced words AND practice streak of 3+ days OR
        // - Maximum streak of 5+ days OR
        // - 20+ practiced words
        if (practicedWords.count >= 15 && practiceStreak >= 3) ||
           maxStreak >= 5 ||
           practicedWords.count >= 20 {
            print("DEBUG: BadgeEarningManager - Awarding Turtle badge for steady progress")
            print("  - Practiced words: \(practicedWords.count)")
            print("  - Current streak: \(practiceStreak) days")
            print("  - Max streak: \(maxStreak) days")
            await awardBadge("Turtle", in: viewController)
        }
    }
    
    /// Elephant Badge: Award for major milestones (completing multiple levels)
    private func checkElephantBadge(userData: UserData, in viewController: UIViewController) async {
        // Check if badge is already earned
        guard !isBadgeAlreadyEarned("Elephant", userData: userData) else { return }
        
        // Count completed levels (levels where all words have good accuracy)
        var completedLevels = 0
        
        for level in userData.userLevels {
            let totalWords = level.words.count
            let passedWords = level.words.filter { word in
                guard let record = word.record,
                      let accuracies = record.accuracy,
                      !accuracies.isEmpty else { return false }
                let avgAccuracy = accuracies.reduce(0.0, +) / Double(accuracies.count)
                return avgAccuracy >= 70.0
            }.count
            
            // Consider level completed if 80% of words are passed
            if Double(passedWords) / Double(totalWords) >= 0.8 {
                completedLevels += 1
            }
        }
        
        // Award elephant badge for completing 3+ levels
        if completedLevels >= 3 {
            print("DEBUG: BadgeEarningManager - Awarding Elephant badge for completing \(completedLevels) levels")
            await awardBadge("Elephant", in: viewController)
        }
    }
    
    /// Dog Badge: Award for regular practice habits
    private func checkDogBadge(userData: UserData, in viewController: UIViewController) async {
        // Check if badge is already earned
        guard !isBadgeAlreadyEarned("Dog", userData: userData) else { return }
        
        // Check total practice time and word count
        let allWords = userData.userLevels.flatMap { $0.words }
        let practicedWords = allWords.filter { $0.isPracticed }
        
        // Check for multiple practice attempts (showing regular use)
        let totalAttempts = allWords.compactMap { $0.record?.attempts }.reduce(0, +)
        
        // Get daily practice time from UserDefaults
        let dailyTimeSpent = UserDefaults.standard.double(forKey: "dailyTimeSpent")
        
        // Award dog badge for regular practice (any of these conditions):
        // - 50+ total attempts OR
        // - 25+ practiced words OR 
        // - 30+ minutes of daily practice time
        if totalAttempts >= 50 || practicedWords.count >= 25 || dailyTimeSpent >= 1800 {
            print("DEBUG: BadgeEarningManager - Awarding Dog badge for regular practice")
            print("  - Total attempts: \(totalAttempts)")
            print("  - Practiced words: \(practicedWords.count)")
            print("  - Daily time: \(dailyTimeSpent/60) minutes")
            await awardBadge("Dog", in: viewController)
        }
    }
    
    /// Bunny Badge: Award for rapid improvement in accuracy
    private func checkBunnyBadge(userData: UserData, in viewController: UIViewController) async {
        // Check if badge is already earned
        guard !isBadgeAlreadyEarned("Bunny", userData: userData) else { return }
        
        // Check for rapid improvement
        let allWords = userData.userLevels.flatMap { $0.words }
        var improvementCount = 0
        
        for word in allWords {
            guard let record = word.record,
                  let accuracies = record.accuracy,
                  accuracies.count >= 2 else { continue }
            
            // Check if accuracy improved significantly
            let firstAccuracy = accuracies.first ?? 0
            let lastAccuracy = accuracies.last ?? 0
            
            if lastAccuracy - firstAccuracy >= 30.0 { // 30% improvement
                improvementCount += 1
            }
        }
        
        // Award bunny badge for improving on 5+ words rapidly
        if improvementCount >= 5 {
            print("DEBUG: BadgeEarningManager - Awarding Bunny badge for rapid improvement")
            await awardBadge("Bunny", in: viewController)
        }
    }
    
    /// Lion Badge: Award for sustained excellence
    private func checkLionBadge(userData: UserData, in viewController: UIViewController) async {
        // Check if badge is already earned
        guard !isBadgeAlreadyEarned("Lion", userData: userData) else { return }
        
        // Check for high performance consistency
        let allWords = userData.userLevels.flatMap { $0.words }
        let highAccuracyWords = allWords.filter { word in
            guard let record = word.record,
                  let accuracies = record.accuracy,
                  !accuracies.isEmpty else { return false }
            let avgAccuracy = accuracies.reduce(0.0, +) / Double(accuracies.count)
            return avgAccuracy >= 85.0 // High accuracy threshold
        }
        
        // Award lion badge for achieving high accuracy on 20+ words
        if highAccuracyWords.count >= 20 {
            print("DEBUG: BadgeEarningManager - Awarding Lion badge for excellence")
            await awardBadge("Lion", in: viewController)
        }
    }
    
    /// Level Badges: Award for completing individual levels
    private func checkLevelBadges(userData: UserData, in viewController: UIViewController) async {
        for (index, level) in userData.userLevels.enumerated() {
            let levelNumber = index + 1
            let levelBadgeName = "Level \(levelNumber)"
            
            // Check if this level badge is already earned
            guard !isBadgeAlreadyEarned(levelBadgeName, userData: userData) else { continue }
            
            // Check if level is completed
            let totalWords = level.words.count
            let passedWords = level.words.filter { word in
                guard let record = word.record,
                      let accuracies = record.accuracy,
                      !accuracies.isEmpty else { return false }
                let avgAccuracy = accuracies.reduce(0.0, +) / Double(accuracies.count)
                return avgAccuracy >= 70.0
            }.count
            
            // Award level badge if all words are passed
            if passedWords == totalWords && totalWords > 0 {
                print("DEBUG: BadgeEarningManager - Awarding \(levelBadgeName) badge")
                await awardBadge(levelBadgeName, in: viewController)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    /// Check if a badge is already earned
    private func isBadgeAlreadyEarned(_ badgeTitle: String, userData: UserData) -> Bool {
        return userData.userBadges.contains { $0.badgeTitle == badgeTitle && $0.isEarned }
    }
    
    /// Award a badge and show the achievement popup
    private func awardBadge(_ badgeTitle: String, in viewController: UIViewController) async {
        do {
            // Get the badge from sample data
            let allBadges = SupabaseDataController.shared.getBadgesData()
            guard let appBadge = allBadges.first(where: { $0.badgeTitle == badgeTitle }) else {
                print("DEBUG: BadgeEarningManager - Could not find badge: \(badgeTitle)")
                return
            }
            
            // Update badge status in database
            try await SupabaseDataController.shared.updateBadgeStatus(
                badgeId: appBadge.id,
                isEarned: true,
                showPopup: false // We'll handle the popup ourselves
            )
            
            // Create badge object for popup
            let badge = Badge(
                id: appBadge.id,
                badgeTitle: appBadge.badgeTitle,
                isEarned: true
            )
            
            // Show achievement popup on main thread
            DispatchQueue.main.async {
                BadgeAchievementManager.shared.showBadgeAchievement(for: badge, in: viewController)
            }
            
            print("DEBUG: BadgeEarningManager - Successfully awarded \(badgeTitle) badge")
            
        } catch {
            print("DEBUG: BadgeEarningManager - Error awarding \(badgeTitle) badge: \(error)")
        }
    }
}

// MARK: - Convenient Badge Checking Extensions

extension BadgeEarningManager {
    
    /// Call this after a user completes a word with accuracy
    func checkBadgesAfterWordCompletion(accuracy: Double, in viewController: UIViewController) {
        // Check badges that might be earned after word completion
        checkAndAwardBadges(in: viewController)
    }
    
    /// Call this after a user completes a level
    func checkBadgesAfterLevelCompletion(levelIndex: Int, in viewController: UIViewController) {
        // Check specifically for level badges and milestone badges
        checkAndAwardBadges(in: viewController)
    }
    
    /// Call this periodically to check progress-based badges
    func checkProgressBadges(in viewController: UIViewController) {
        // Check badges based on overall progress (turtle, dog, etc.)
        checkAndAwardBadges(in: viewController)
    }
}

// MARK: - Practice Session Tracking

extension BadgeEarningManager {
    
    /// Call this when a practice session starts
    func startPracticeSession() {
        let currentDate = Date()
        UserDefaults.standard.set(currentDate, forKey: "lastPracticeSessionStart")
        
        // Increment daily session count
        let today = Calendar.current.startOfDay(for: currentDate)
        let lastSessionDate = UserDefaults.standard.object(forKey: "lastSessionCountDate") as? Date ?? Date.distantPast
        
        if Calendar.current.startOfDay(for: lastSessionDate) != today {
            // Reset daily session count for new day
            UserDefaults.standard.set(1, forKey: "dailySessionCount")
            UserDefaults.standard.set(today, forKey: "lastSessionCountDate")
        } else {
            // Increment session count for current day
            let sessionCount = UserDefaults.standard.integer(forKey: "dailySessionCount")
            UserDefaults.standard.set(sessionCount + 1, forKey: "dailySessionCount")
        }
    }
    
    /// Call this when a practice session ends
    func endPracticeSession() {
        guard let startTime = UserDefaults.standard.object(forKey: "lastPracticeSessionStart") as? Date else { return }
        
        let sessionDuration = Date().timeIntervalSince(startTime)
        
        // Add to total daily practice time
        let currentDailyTime = UserDefaults.standard.double(forKey: "dailyTimeSpent")
        UserDefaults.standard.set(currentDailyTime + sessionDuration, forKey: "dailyTimeSpent")
        
        // Track total practice time across all days
        let totalPracticeTime = UserDefaults.standard.double(forKey: "totalPracticeTime")
        UserDefaults.standard.set(totalPracticeTime + sessionDuration, forKey: "totalPracticeTime")
        
        // Update practice streak
        updatePracticeStreak()
    }
    
    /// Update practice streak for consistent practice tracking
    private func updatePracticeStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastPracticeDate = UserDefaults.standard.object(forKey: "lastPracticeDate") as? Date ?? Date.distantPast
        let lastPracticeDayStart = Calendar.current.startOfDay(for: lastPracticeDate)
        
        let daysBetween = Calendar.current.dateComponents([.day], from: lastPracticeDayStart, to: today).day ?? 0
        
        var currentStreak = UserDefaults.standard.integer(forKey: "practiceStreak")
        
        if daysBetween == 0 {
            // Same day, no change to streak
        } else if daysBetween == 1 {
            // Consecutive day, increment streak
            currentStreak += 1
        } else {
            // Streak broken, reset to 1
            currentStreak = 1
        }
        
        UserDefaults.standard.set(currentStreak, forKey: "practiceStreak")
        UserDefaults.standard.set(Date(), forKey: "lastPracticeDate")
        
        // Update max streak if current is higher
        let maxStreak = UserDefaults.standard.integer(forKey: "maxPracticeStreak")
        if currentStreak > maxStreak {
            UserDefaults.standard.set(currentStreak, forKey: "maxPracticeStreak")
        }
    }
}
