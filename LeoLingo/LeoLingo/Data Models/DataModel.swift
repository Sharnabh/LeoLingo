//
//  DataModel.swift
//  LeoLingo
//
//  Created by Batch - 2  on 13/01/25.
//

import Foundation

struct WordReport {
    var attempts: Int
    var accuracy: Double
    var recording: [String]
}

struct Word {
    var wordTitle: String
    var wordImage: String
    var wordReports: [WordReport]
    var isPracticed: Bool
}

struct Level {
    var levelTitle: String
    var levelDescription: String
    var words: [Word]
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
