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
    
    private var practiceSessionActive = false
    
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
        practiceSessionActive = false
    }
    
    // MARK: - Progress Badge Checking
    
    /// Check and award progress-based badges based on user achievements
    func checkAndAwardProgressBadges() async {
        guard let userId = SupabaseDataController.shared.userId else { return }
        
        do {
            let userData = try await SupabaseDataController.shared.getUser(byId: userId)
            let allBadges = SupabaseDataController.shared.getBadgesData()
            
            // Get all words across all levels
            let allWords = userData.userLevels.flatMap { $0.words }
            let practicedWords = allWords.filter { $0.isPracticed }
            let masteredWords = allWords.filter { word in
                if let accuracies = word.record?.accuracy, !accuracies.isEmpty {
                    return accuracies.max() ?? 0 >= 70.0
                }
                return false
            }
            
            // Calculate statistics
            let totalPracticeDays = UserDefaults.standard.integer(forKey: "daysUsed")
            let totalTimeSpent = UserDefaults.standard.double(forKey: "totalTimeSpent")
            let completedLevels = userData.userLevels.filter { level in
                let totalWords = level.words.count
                let completedWords = level.words.filter { word in
                    if let accuracies = word.record?.accuracy, !accuracies.isEmpty {
                        return accuracies.max() ?? 0 >= 70.0
                    }
                    return false
                }.count
                return completedWords == totalWords
            }.count
            
            // Check each badge condition
            await checkBeeBadge(practicedWords: practicedWords, allBadges: allBadges)
            await checkTurtleBadge(totalDays: totalPracticeDays, allBadges: allBadges)
            await checkElephantBadge(completedLevels: completedLevels, masteredWords: masteredWords.count, allBadges: allBadges)
            await checkDogBadge(totalDays: totalPracticeDays, allBadges: allBadges)
            await checkBunnyBadge(practicedWords: practicedWords, timeSpent: totalTimeSpent, allBadges: allBadges)
            await checkLionBadge(completedLevels: completedLevels, masteredWords: masteredWords.count, allBadges: allBadges)
            
        } catch {
            print("DEBUG: Error checking progress badges: \(error)")
        }
    }
    
    // MARK: - Individual Badge Checks
    
    /// Bee Badge: Vocalized first word
    private func checkBeeBadge(practicedWords: [Word], allBadges: [AppBadge]) async {
        guard practicedWords.count >= 1,
              let beeBadge = allBadges.first(where: { $0.badgeTitle == "Bee" }),
              !UserDefaults.standard.earnedBadgeIDs.contains(beeBadge.id.uuidString) else { return }
        
        do {
            try await SupabaseDataController.shared.updateBadgeStatus(badgeId: beeBadge.id, isEarned: true, showPopup: true)
            print("DEBUG: ✅ Awarded Bee badge - First word vocalized!")
        } catch {
            print("DEBUG: Error awarding Bee badge: \(error)")
        }
    }
    
    /// Turtle Badge: Steady progress over time (7+ days of practice)
    private func checkTurtleBadge(totalDays: Int, allBadges: [AppBadge]) async {
        guard totalDays >= 7,
              let turtleBadge = allBadges.first(where: { $0.badgeTitle == "Turtle" }),
              !UserDefaults.standard.earnedBadgeIDs.contains(turtleBadge.id.uuidString) else { return }
        
        do {
            try await SupabaseDataController.shared.updateBadgeStatus(badgeId: turtleBadge.id, isEarned: true, showPopup: true)
            print("DEBUG: ✅ Awarded Turtle badge - 7 days of steady practice!")
        } catch {
            print("DEBUG: Error awarding Turtle badge: \(error)")
        }
    }
    
    /// Elephant Badge: Major milestones (10+ levels completed OR 50+ words mastered)
    private func checkElephantBadge(completedLevels: Int, masteredWords: Int, allBadges: [AppBadge]) async {
        guard (completedLevels >= 10 || masteredWords >= 50),
              let elephantBadge = allBadges.first(where: { $0.badgeTitle == "Elephant" }),
              !UserDefaults.standard.earnedBadgeIDs.contains(elephantBadge.id.uuidString) else { return }
        
        do {
            try await SupabaseDataController.shared.updateBadgeStatus(badgeId: elephantBadge.id, isEarned: true, showPopup: true)
            print("DEBUG: ✅ Awarded Elephant badge - Major milestone reached!")
        } catch {
            print("DEBUG: Error awarding Elephant badge: \(error)")
        }
    }
    
    /// Dog Badge: Loyal learner (14+ consecutive days OR total 30+ days)
    private func checkDogBadge(totalDays: Int, allBadges: [AppBadge]) async {
        guard totalDays >= 14,
              let dogBadge = allBadges.first(where: { $0.badgeTitle == "Dog" }),
              !UserDefaults.standard.earnedBadgeIDs.contains(dogBadge.id.uuidString) else { return }
        
        do {
            try await SupabaseDataController.shared.updateBadgeStatus(badgeId: dogBadge.id, isEarned: true, showPopup: true)
            print("DEBUG: ✅ Awarded Dog badge - Loyal learner!")
        } catch {
            print("DEBUG: Error awarding Dog badge: \(error)")
        }
    }
    
    /// Bunny Badge: Quick learner (20+ words practiced in first 3 days OR 10+ words in 1 day)
    private func checkBunnyBadge(practicedWords: [Word], timeSpent: TimeInterval, allBadges: [AppBadge]) async {
        let totalDays = UserDefaults.standard.integer(forKey: "daysUsed")
        
        // Quick learner: 20+ words in first 3 days OR currently has 10+ practiced words
        let isQuickLearner = (totalDays <= 3 && practicedWords.count >= 20) || (practicedWords.count >= 10)
        
        guard isQuickLearner,
              let bunnyBadge = allBadges.first(where: { $0.badgeTitle == "Bunny" }),
              !UserDefaults.standard.earnedBadgeIDs.contains(bunnyBadge.id.uuidString) else { return }
        
        do {
            try await SupabaseDataController.shared.updateBadgeStatus(badgeId: bunnyBadge.id, isEarned: true, showPopup: true)
            print("DEBUG: ✅ Awarded Bunny badge - Quick learner!")
        } catch {
            print("DEBUG: Error awarding Bunny badge: \(error)")
        }
    }
    
    /// Lion Badge: Master learner (20+ levels completed OR 100+ words mastered)
    private func checkLionBadge(completedLevels: Int, masteredWords: Int, allBadges: [AppBadge]) async {
        guard (completedLevels >= 20 || masteredWords >= 100),
              let lionBadge = allBadges.first(where: { $0.badgeTitle == "Lion" }),
              !UserDefaults.standard.earnedBadgeIDs.contains(lionBadge.id.uuidString) else { return }
        
        do {
            try await SupabaseDataController.shared.updateBadgeStatus(badgeId: lionBadge.id, isEarned: true, showPopup: true)
            print("DEBUG: ✅ Awarded Lion badge - Master learner!")
        } catch {
            print("DEBUG: Error awarding Lion badge: \(error)")
        }
    }
}
