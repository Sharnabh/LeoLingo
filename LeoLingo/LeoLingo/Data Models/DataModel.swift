//
//  DataModel.swift
//  LeoLingo
//
//  Created by Batch - 2  on 13/01/25.
//

import Foundation

struct UserData {
    var id: UUID = UUID()
    var name: String
    var phoneNumber: String
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
    
    var isPassed: Bool {
        guard let record = record, let accuracy = record.accuracy else { return false }
        return accuracy.contains(where: { $0 > 70 })
    }
}

struct Record {
    var id: UUID = UUID()
    var attempts: Int = 0
    var accuracy: [Double]?
    var recording: [String]?
    
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
    var id: UUID = UUID()
    var isEarned: Bool = false
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
    private let plistName = "WordIDs.plist"
    private var wordIDs: [String: String] = [:] // [wordTitle: uuidString]
    
    private init() {
        loadWordIDs()
        printCurrentMappings()
    }
    
    private var plistURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(plistName)
    }
    
    private func loadWordIDs() {
        guard let url = plistURL,
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String] else {
            print("DEBUG: No existing word ID mappings found or failed to load")
            return
        }
        wordIDs = dict
        print("DEBUG: Loaded \(dict.count) word ID mappings from plist")
    }
    
    private func saveWordIDs() {
        guard let url = plistURL,
              let data = try? PropertyListSerialization.data(fromPropertyList: wordIDs, format: .xml, options: 0) else {
            print("DEBUG: Failed to save word ID mappings")
            return
        }
        try? data.write(to: url)
        print("DEBUG: Saved \(wordIDs.count) word ID mappings to plist")
    }
    
    func getID(for wordTitle: String) -> UUID {
        let cleanTitle = wordTitle.lowercased().trimmingCharacters(in: .whitespaces)
        
        if let existingIDString = wordIDs[cleanTitle],
           let existingID = UUID(uuidString: existingIDString) {
            print("DEBUG: Found existing ID for word '\(cleanTitle)': \(existingID)")
            return existingID
        }
        
        let newID = UUID()
        wordIDs[cleanTitle] = newID.uuidString
        print("DEBUG: Generated new ID for word '\(cleanTitle)': \(newID)")
        saveWordIDs()
        return newID
    }
    
    func printCurrentMappings() {
        print("DEBUG: Current word ID mappings:")
        for (word, id) in wordIDs {
            print("  \(word): \(id)")
        }
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
    var id: UUID = UUID()
    var badgeTitle: String
    var badgeDescription: String
    var badgeImage: String
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
