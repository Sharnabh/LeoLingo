//
//  DataModel.swift
//  LeoLingo
//
//  Created by Batch - 2  on 13/01/25.
//  Copyright © 2025 Sharnabh. All rights reserved.
//
//  PROPRIETARY AND CONFIDENTIAL
//  This software is protected by copyright and commercial license.
//  Unauthorized copying, distribution, modification, or reverse engineering is prohibited.
//

import Foundation

struct UserData {
    var id: UUID = UUID()
    var name: String
    var email: String
    var password: String
    var passcode: String?
    var childName: String?
    var userLevels: [Level]
    var userEarnedBadges: [Badge]
    var userBadges: [Badge]
}

struct Level {
    var id: UUID = UUID()
    var words: [Word]
    
    var avgAccuracy: Double {
        let totalAccuracy = words.reduce(0) { sum, word in
            sum + word.avgAccuracy
        }
        
        let average = totalAccuracy / Double(words.count)
        return (average * 10).rounded() / 10
    }
    
    var isCompleted: Bool {
        return !words.contains { !$0.isPassed }
    }
}

struct Word {
    var id: UUID = UUID()
    var record: Record?
    var isPracticed: Bool = false
    
    var avgAccuracy: Double {
        guard let record = record,
              self.record != nil,
              let accuracies = record.accuracy,
              !accuracies.isEmpty else { return 0.0 }
        
        // Cap individual accuracies at 100%
        let cappedAccuracies = accuracies.map { min(100.0, max(0.0, $0)) }
        let total = cappedAccuracies.reduce(0.0, +)
        let average = total / Double(accuracies.count)
        
        return (average * 10).rounded() / 10
    }
    
    var isPassed: Bool { return record?.mastered ?? false }
}

struct Record {
    var id: UUID = UUID()
    var attempts: Int = 0
    var accuracy: [Double]?
    var recording: [String]?
    var mastered: Bool = false // NEW
    
    var avgAccuracy: Double {
        guard let accuracies = accuracy,
              !accuracies.isEmpty else {
            return 0.0
        }
        
        // Cap individual accuracies at 100%
        let cappedAccuracies = accuracies.map { min(100.0, max(0.0, $0)) }
        let total = cappedAccuracies.reduce(0.0, +)
        let average = total / Double(accuracies.count)
        
        return (average * 10).rounded() / 10
    }
}

struct Card {
    var id: UUID = UUID()
    var words: [AppWord]
}

struct LevelCard {
    var id: UUID = UUID()
    var levelTitle: String
    var levelCardImage: String
    var words: [AppWord]
    
    // Custom initializer that takes both AppLevel and a custom image
    init(from appLevel: AppLevel, levelCardImage: String) {
        self.levelTitle = appLevel.levelTitle
        self.levelCardImage = levelCardImage // Uses the provided image
        self.words = appLevel.words
    }
}

struct Badge {
    var id: UUID
    var badgeTitle: String
    var isEarned: Bool = false
    
    init(badgeTitle: String) {
        self.id = BadgeIDManager.shared.getID(for: badgeTitle)
        self.badgeTitle = badgeTitle
    }
    
    init(id: UUID, badgeTitle: String, isEarned: Bool) {
        self.id = id
        self.badgeTitle = badgeTitle
        self.isEarned = isEarned
    }
}

struct AppData {
    var id: UUID = UUID()
    var levels: [AppLevel]
    var badges: [AppBadge]
}

struct AppLevel {
    var id: UUID = UUID()
    var levelTitle: String
    var levelImage: String
    var words: [AppWord]
}

class WordIDManager {
    static let shared = WordIDManager()
    private var wordIDs: [String: String] = [:] // [wordTitle: uuidString] - cache only
    
    private init() {}
    
    /// Generates a deterministic UUID based on word title
    /// This ensures the same word always gets the same UUID across all devices
    private func generateDeterministicUUID(for title: String) -> UUID {
        let cleanTitle = title.lowercased().trimmingCharacters(in: .whitespaces)
        // Use a namespace UUID (version 5) approach - create consistent hash
        let namespace = "com.leolingo.word."
        let combined = namespace + cleanTitle
        
        // Create a deterministic UUID using MD5-like approach
        let data = combined.data(using: .utf8)!
        var hash = [UInt8](repeating: 0, count: 16)
        
        // Simple hash function to create consistent bytes
        for (index, byte) in data.enumerated() {
            hash[index % 16] ^= byte
            hash[index % 16] = hash[index % 16] &+ UInt8(index % 256)
        }
        
        // Set version (4) and variant bits for valid UUID
        hash[6] = (hash[6] & 0x0F) | 0x40  // Version 4
        hash[8] = (hash[8] & 0x3F) | 0x80  // Variant
        
        let uuidString = String(format: "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
                                hash[0], hash[1], hash[2], hash[3],
                                hash[4], hash[5], hash[6], hash[7],
                                hash[8], hash[9], hash[10], hash[11],
                                hash[12], hash[13], hash[14], hash[15])
        
        return UUID(uuidString: uuidString)!
    }
    
    func getID(for wordTitle: String) -> UUID {
        let cleanTitle = wordTitle.lowercased().trimmingCharacters(in: .whitespaces)
        
        // Check cache first
        if let existingIDString = wordIDs[cleanTitle],
           let existingID = UUID(uuidString: existingIDString) {
            return existingID
        }
        
        // Generate deterministic UUID - same on all devices
        let deterministicID = generateDeterministicUUID(for: cleanTitle)
        wordIDs[cleanTitle] = deterministicID.uuidString
        return deterministicID
    }
        
    func getAllMappings() -> [String: UUID] {
        var mappings: [String: UUID] = [:]
        for (word, idString) in wordIDs {
            if let uuid = UUID(uuidString: idString) {
                mappings[word] = uuid
            }
        }
        return mappings
    }
}

class BadgeIDManager {
    static let shared = BadgeIDManager()
    private var badgeIDs: [String: String] = [:] // [badgeTitle: uuidString] - cache only
    
    private init() {}
    
    /// Generates a deterministic UUID based on badge title
    /// This ensures the same badge always gets the same UUID across all devices
    private func generateDeterministicUUID(for title: String) -> UUID {
        let cleanTitle = title.lowercased().trimmingCharacters(in: .whitespaces)
        // Use a namespace UUID approach - create consistent hash
        let namespace = "com.leolingo.badge."
        let combined = namespace + cleanTitle
        
        // Create a deterministic UUID using hash approach
        let data = combined.data(using: .utf8)!
        var hash = [UInt8](repeating: 0, count: 16)
        
        // Simple hash function to create consistent bytes
        for (index, byte) in data.enumerated() {
            hash[index % 16] ^= byte
            hash[index % 16] = hash[index % 16] &+ UInt8(index % 256)
        }
        
        // Set version (4) and variant bits for valid UUID
        hash[6] = (hash[6] & 0x0F) | 0x40  // Version 4
        hash[8] = (hash[8] & 0x3F) | 0x80  // Variant
        
        let uuidString = String(format: "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
                                hash[0], hash[1], hash[2], hash[3],
                                hash[4], hash[5], hash[6], hash[7],
                                hash[8], hash[9], hash[10], hash[11],
                                hash[12], hash[13], hash[14], hash[15])
        
        return UUID(uuidString: uuidString)!
    }
    
    func getID(for badgeTitle: String) -> UUID {
        let cleanTitle = badgeTitle.lowercased().trimmingCharacters(in: .whitespaces)
        
        // Check cache first
        if let existingIDString = badgeIDs[cleanTitle],
           let existingID = UUID(uuidString: existingIDString) {
            return existingID
        }
        
        // Generate deterministic UUID - same on all devices
        let deterministicID = generateDeterministicUUID(for: cleanTitle)
        badgeIDs[cleanTitle] = deterministicID.uuidString
        return deterministicID
    }
    
    
    func getAllMappings() -> [String: UUID] {
        var mappings: [String: UUID] = [:]
        for (word, idString) in badgeIDs {
            if let uuid = UUID(uuidString: idString) {
                mappings[word] = uuid
            }
        }
        return mappings
    }
}

struct AppWord {
    var id: UUID
    var wordTitle: String
    var wordImage: String
    
    init(wordTitle: String, wordImage: String) {
        self.id = WordIDManager.shared.getID(for: wordTitle)
        self.wordTitle = wordTitle
        self.wordImage = wordImage
    }
}

// Category
struct AppCategory {
    var id: UUID = UUID()
    var categoryTitle: String
    var categoryImage: String
    var words: [AppWord]
}

struct CategoryCard {
    var id: UUID = UUID()
    var categoryTitle: String
    var categoryCardImage: String
    var words: [AppWord]
    
    // Custom initializer that takes both AppLevel and a custom image
    init(from appCategory: AppCategory, categoryCardImage: String) {
        self.categoryTitle = appCategory.categoryTitle
        self.categoryCardImage = categoryCardImage // Uses the provided image
        self.words = appCategory.words
    }
}

struct AppBadge {
    var id: UUID
    var badgeTitle: String
    var badgeDescription: String
    var badgeImage: String
    
    init(badgeTitle: String, badgeDescription: String, badgeImage: String) {
        self.id = BadgeIDManager.shared.getID(for: badgeTitle)
        self.badgeTitle = badgeTitle
        self.badgeDescription = badgeDescription
        self.badgeImage = badgeImage
    }
}

struct AppCard {
    var id: UUID = UUID()
    var cardTitle: String
    var cardImage: String
    var words: [AppWord]
}

struct JungleRun {
    var coins: Int = 0
    var diamonds: Int = 0
    var word: String?
    var isAccurate: Bool = false
}

enum FIlterOptions: String, CaseIterable {
    case all = "All"
    case accurate = "Accurate"
    case inaccurate = "Inaccurate"
}

struct FilterSettings {
    let isPassed: Bool
    let isPracticed: Bool
    let accuracyFilterEnabled: Bool
    let accuracyValue: Int
}

struct Exercise {
    let description: String
    let videos: [String]
}
