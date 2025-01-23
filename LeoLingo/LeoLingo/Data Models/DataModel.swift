//
//  DataModel.swift
//  LeoLingo
//
//  Created by Batch - 2  on 13/01/25.
//

import Foundation

struct UserData {
    var name: String
    var phoneNumber: String
    var password: String
    var passcode: String
}

struct Record {
    var attempts: Int = 0
    var accuracy: [Double]?
    var recording: [String]?
}

struct Word {
    var wordTitle: String
    var wordImage: String?
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


struct Level {
    var levelTitle: String
    var levelImage: String
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

enum FIlterOptions: String, CaseIterable {
    case all = "All"
    case accurate = "Accurate"
    case inaccurate = "Inaccurate"
}

struct Card {
    var cardTitle: String
    var words: [Word]
}

struct Badge {
    var badgeTitle: String
    var badgeDescription: String
    var badgeImage: String
    var isEarned: Bool = false
}

struct JungleRun {
    var coins: Int = 0
    var diamonds: Int = 0
    var word: String?
    var isAccurate: Bool = false
}

struct FilterSettings {
    let isPassed: Bool
    let isPracticed: Bool
    let accuracyFilterEnabled: Bool
    let accuracyValue: Int
}
