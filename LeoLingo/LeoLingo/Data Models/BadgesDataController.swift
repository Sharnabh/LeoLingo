//
//  BadgesDataController.swift
//  LeoLingo
//
//  Created by Batch - 2  on 23/01/25.
//

import Foundation

class BadgesDataController {
    private var badges: [Badge] = []
    private var earnedBadges: [Badge] = []
    
    static var shared = BadgesDataController()
    
    private init() {
        loadBadgesData()
    }
    
    func loadBadgesData() {
        badges = [
            Badge(badgeTitle: "Bee", badgeDescription: "Busy Bee(You have taken the first step)", badgeImage: "bee", isEarned: true),
            Badge(badgeTitle: "Turtle", badgeDescription: "Persistent Achiever(Steady Progress Over Time", badgeImage: "turtle", isEarned: false),
            Badge(badgeTitle: "Elephant", badgeDescription: "Master of Speech(Major Milestones Reached)", badgeImage: "elephant", isEarned: false),
            Badge(badgeTitle: "Dog", badgeDescription: "Loyal Learner(Regular Practice)", badgeImage: "dog", isEarned: true),
            Badge(badgeTitle: "Bunny", badgeDescription: "Quick Learner(Fast Improvement)", badgeImage: "bunny", isEarned: false),
            Badge(badgeTitle: "Lion", badgeDescription: "Learner(Fast Improvements)", badgeImage: "lion", isEarned: false)
        ]
        earnedBadges = [
            Badge(badgeTitle: "Beginner", badgeDescription: " ", badgeImage: "bronze-medal", isEarned: true)
        ]
    }
    
    func getBadges() -> [Badge] {
        return badges
    }
    
    func countBadges() -> Int {
        return badges.count
    }
    
    func getEarnedBadges() -> [Badge] {
        return earnedBadges
    }
    
    func appendEarnedBadge(_ badge: Badge) {
        earnedBadges.append(badge)
    }
    
    func countEarnedBadges() -> Int {
        return earnedBadges.count
    }
    
}
