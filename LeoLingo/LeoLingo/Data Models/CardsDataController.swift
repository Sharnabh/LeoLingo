//
//  CardsDataController.swift
//  LeoLingo
//
//  Created by Batch - 2  on 24/01/25.
//

import Foundation

class CardsDataController {
    
    private var cards: [Card] = []
    
    static var shared = CardsDataController()
    
    private init() {
        loadData()
    }
    
    func loadData() {
        cards = [
            Card(cardTitle: "Earlywords", cardImage: "EarlyWords", words: []),
            Card(cardTitle: "BodyParts", cardImage: "BodyParts", words: []),
            Card(cardTitle: "Earlywords", cardImage: "EarlyWords", words: []),
            Card(cardTitle: "BodyParts", cardImage: "BodyParts", words: []),
            Card(cardTitle: "Earlywords", cardImage: "EarlyWords", words: []),
            Card(cardTitle: "BodyParts", cardImage: "BodyParts", words: []),
            Card(cardTitle: "Earlywords", cardImage: "EarlyWords", words: []),
            Card(cardTitle: "BodyParts", cardImage: "BodyParts", words: []),
            Card(cardTitle: "Earlywords", cardImage: "EarlyWords", words: []),
            Card(cardTitle: "BodyParts", cardImage: "BodyParts", words: []),
            Card(cardTitle: "Earlywords", cardImage: "EarlyWords", words: []),
            Card(cardTitle: "BodyParts", cardImage: "BodyParts", words: [])
        ]
    }
    
    func getCards() -> [Card] {
        return cards
    }
    
    func countCards() -> Int {
        return cards.count
    }
    
}
