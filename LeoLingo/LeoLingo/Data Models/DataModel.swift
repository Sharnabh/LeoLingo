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
              record.attempts != 0 else { return 0.0 }
        
        let accuracy = record.accuracy!.reduce(0.0, +) / Double(record.attempts)
        
        return (accuracy * 10).rounded() / 10
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
}

struct Card {
    var id: UUID = UUID()
    var words: [AppWord]
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

struct AppWord {
    var id: UUID = UUID()
    var wordTitle: String
    var wordImage: String
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
