//
//  DataModel.swift
//  LeoLingo
//
//  Created by Batch - 2  on 13/01/25.
//

import Foundation

struct Record {
    var attempts: Int
    var accuracy: [Double]!
    var recording: [String]!
}

struct Word {
    var wordTitle: String
    var wordImage: String!
    var record: Record!
    var isPracticed: Bool
    
    var avgAccuracy: Double {
        guard let record = record,
              self.record != nil,
              record.attempts != 0 else { return 0.0 }
        
        let accuracy = record.accuracy.reduce(0.0, +) / Double(record.attempts)
        
        return (accuracy * 10).rounded() / 10
    }
    
    var isPassed: Bool {
        guard let record = record, let accuracy = record.accuracy else { return false }
        return accuracy.contains(where: { $0 > 70 })
    }
}


struct Level {
    var levelTitle: String
    var words: [Word]
    var isCompleted: Bool {
        return words.allSatisfy { $0.isPassed }
    }
}

struct Card {
    var cardTitle: String
    var words: [Word]
}

struct Badge {
    var badgeTitle: String
    var badgeImage: String
    var isAchieved: Bool
}

struct JungleRun {
    var backgroundImage: [String]
    var avatarImage: [String]
    var noOfLives: Int
    var coins: Int
    var diamonds: Int
}

struct FilterSettings {
    let isPassed: Bool
    let isPracticed: Bool
    let accuracyFilterEnabled: Bool
    let accuracyValue: Int
}
