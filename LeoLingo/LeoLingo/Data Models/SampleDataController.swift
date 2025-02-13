//
//  BadgesDataController.swift
//  LeoLingo
//
//  Created by Batch - 2  on 23/01/25.
//

import Foundation

class SampleDataController {
    
    private var badges: [AppBadge] = []
    private var levels: [AppLevel] = []
    private var cards: [AppCard] = []
    private var exercises: [String: Exercise] = [:]
    
    static var shared = SampleDataController()
    
    private init() {
        loadData()
    }
    
    func loadData() {
        levels = [
            AppLevel(levelTitle: "Level 1", levelImage: "1", words: [
                AppWord(wordTitle: "A", wordImage: "a"),
                AppWord(wordTitle: "Alarm", wordImage: "alarm"),
                AppWord(wordTitle: "Army", wordImage: "army"),
                AppWord(wordTitle: "Art", wordImage: "art"),
                AppWord(wordTitle: "Apple", wordImage: "apple"),
                AppWord(wordTitle: "Ant", wordImage: "ant")
                ]),
            AppLevel(levelTitle: "Level 2", levelImage: "2", words: [
                AppWord(wordTitle: "B", wordImage: "b"),
                AppWord(wordTitle: "Black", wordImage: "black"),
                AppWord(wordTitle: "Bread", wordImage: "bread"),
                AppWord(wordTitle: "Broom", wordImage: "broom"),
                AppWord(wordTitle: "Brick", wordImage: "brick"),
                AppWord(wordTitle: "Brother", wordImage: "brother")
                ]),
            AppLevel(levelTitle: "Level 3", levelImage: "3", words: [
                AppWord(wordTitle: "R", wordImage: "r"),
                AppWord(wordTitle: "Ring", wordImage: "ring"),
                AppWord(wordTitle: "Rice", wordImage: "rice"),
                AppWord(wordTitle: "Red", wordImage: "red"),
                AppWord(wordTitle: "Read", wordImage: "read"),
                AppWord(wordTitle: "Run", wordImage: "run")
                ]),
            AppLevel(levelTitle: "Level 4", levelImage: "4", words: [
                AppWord(wordTitle: "Fire", wordImage: "fire"),
                AppWord(wordTitle: "Frog", wordImage: "frog"),
                AppWord(wordTitle: "Fruit", wordImage: "fruits"),
                AppWord(wordTitle: "Frame", wordImage: "frame"),
                AppWord(wordTitle: "Flute", wordImage: "flute"),
                AppWord(wordTitle: "Flower", wordImage: "flower")
                ]),
            AppLevel(levelTitle: "Level 5", levelImage: "5", words: [
                AppWord(wordTitle: "Lunch", wordImage: "lunch"),
                AppWord(wordTitle: "Lips", wordImage: "lips"),
                AppWord(wordTitle: "Lamp", wordImage: "lamp"),
                AppWord(wordTitle: "Laugh", wordImage: "laugh"),
                AppWord(wordTitle: "Lamp", wordImage: "lamp"),
                AppWord(wordTitle: "Leaf", wordImage: "leaf")
                ]),
            AppLevel(levelTitle: "Level 6", levelImage: "6", words: [
                AppWord(wordTitle: "Lion", wordImage: "JungleLion"),
                AppWord(wordTitle: "Wire", wordImage: "wire"),
                AppWord(wordTitle: "Wrist", wordImage: "wrist"),
                AppWord(wordTitle: "Watch", wordImage: "watch"),
                AppWord(wordTitle: "Wall", wordImage: "wall"),
                AppWord(wordTitle: "Market", wordImage: "market")
                ]),
            AppLevel(levelTitle: "Level 7", levelImage: "7", words: [
                AppWord(wordTitle: "City", wordImage: "city"),
                AppWord(wordTitle: "Ear", wordImage: "ear"),
                AppWord(wordTitle: "Eye", wordImage: "eye"),
                AppWord(wordTitle: "Book", wordImage: "book"),
                AppWord(wordTitle: "Pen", wordImage: "pen"),
                AppWord(wordTitle: "Sun", wordImage: "sun")
                ]),
            AppLevel(levelTitle: "Level 8", levelImage: "8", words: [
                AppWord(wordTitle: "Sand", wordImage: "sand"),
                AppWord(wordTitle: "Snow", wordImage: "snow"),
                AppWord(wordTitle: "Sky", wordImage: "sky"),
                AppWord(wordTitle: "Snake", wordImage: "snake"),
                AppWord(wordTitle: "Sing", wordImage: "sing"),
                AppWord(wordTitle: "Superhero", wordImage: "superhero")
                ]),
            AppLevel(levelTitle: "Level 9", levelImage: "9", words: [
                AppWord(wordTitle: "School", wordImage: "school"),
                AppWord(wordTitle: "Sweater", wordImage: "sweater"),
                AppWord(wordTitle: "Swim", wordImage: "swim"),
                AppWord(wordTitle: "Star", wordImage: "star"),
                AppWord(wordTitle: "Soup", wordImage: "soup"),
                AppWord(wordTitle: "Swan", wordImage: "swan")
                ])
        ]
        badges = [
            AppBadge(badgeTitle: "Bee", badgeDescription: "Busy Bee(You have taken the first step)", badgeImage: "bee"),
            AppBadge(badgeTitle: "Turtle", badgeDescription: "Persistent Achiever(Steady Progress Over Time", badgeImage: "turtle"),
            AppBadge(badgeTitle: "Elephant", badgeDescription: "Master of Speech(Major Milestones Reached)", badgeImage: "elephant"),
            AppBadge(badgeTitle: "Dog", badgeDescription: "Loyal Learner(Regular Practice)", badgeImage: "dog"),
            AppBadge(badgeTitle: "Bunny", badgeDescription: "Quick Learner(Fast Improvement)", badgeImage: "bunny"),
            AppBadge(badgeTitle: "Lion", badgeDescription: "Learner(Fast Improvements)", badgeImage: "lion")
        ]
        cards = [
            AppCard(cardTitle: "Earlywords", cardImage: "EarlyWords", words: []),
            AppCard(cardTitle: "BodyParts", cardImage: "BodyParts", words: [
                AppWord(wordTitle: "Wrist", wordImage: "wrist"),
                AppWord(wordTitle: "Lips", wordImage: "lips"),
                AppWord(wordTitle: "Eye", wordImage: "eye"),
                AppWord(wordTitle: "Ear", wordImage: "ear"),
                AppWord(wordTitle: "Thumb", wordImage: "thumb"),
                AppWord(wordTitle: "Nose", wordImage: "nose"),
                AppWord(wordTitle: "Palm", wordImage: "palm")
            ]),
            AppCard(cardTitle: "Lsounds", cardImage: "Lsounds", words: []),
            AppCard(cardTitle: "Rsounds", cardImage: "Rsounds", words: []),
            AppCard(cardTitle: "Ssounds", cardImage: "Ssounds", words: []),
            AppCard(cardTitle: "Vsounds", cardImage: "Vsounds", words: []),
            AppCard(cardTitle: "Earlywords", cardImage: "EarlyWords", words: []),
            AppCard(cardTitle: "BodyParts", cardImage: "BodyParts", words: []),
            AppCard(cardTitle: "Lsounds", cardImage: "Lsounds", words: []),
            AppCard(cardTitle: "Rsounds", cardImage: "Rsounds", words: []),
            AppCard(cardTitle: "Ssounds", cardImage: "Ssounds", words: []),
            AppCard(cardTitle: "Vsounds", cardImage: "Vsounds", words: []),
            AppCard(cardTitle: "EarlyWords", cardImage: "EarlyWords", words: [])
        ]
        
        exercises = [
            "b": Exercise(
                description: "Your child is doing good. Try the suggested exercise to help him.",
                videos: ["https://youtu.be/746Aq0ndZy0"]
            ),
            "c": Exercise(
                description: "Your child is doing good. Try the suggested exercise to help him.",
                videos: ["https://youtu.be/0z80Zt66RcU"]
            ),
            "d": Exercise(
                description: "Your child is doing good. Try the suggested exercise to help him.",
                videos: ["https://youtu.be/61xe97Nf8J4"]
            ),
            "f": Exercise(
                description: "Your child is doing good. Try the suggested exercise to help him.",
                videos: ["https://youtu.be/xA61MYdspgM"]
            ),
            "g": Exercise(
                description: "Your child is doing good. Try the suggested exercise to help him.",
                videos: ["https://youtu.be/bSlb9yscpbw"]
            ),
            "h": Exercise(
                description: "Your child is doing good. Try the suggested exercise to help him.",
                videos: ["https://youtu.be/3-qJF9ZstLQ"]
            ),
            "j": Exercise(
                description: "Your child is doing good. Try the suggested exercise to help him.",
                videos: ["https://youtu.be/xETjN3Y24cQ"]
            ),
            "k": Exercise(
                description: "Your child is doing good. Try the suggested exercise to help him.",
                videos: ["https://youtu.be/JwKKfHIpOX8"]
            ),
            "l": Exercise(
                description: "Your child is doing good. Try the suggested exercise to help him.",
                videos: ["https://youtu.be/_IAEg3igJVI"]
            ),
            "m": Exercise(
                description: "Your child is doing good. Try the suggested exercise to help him.",
                videos: ["https://youtu.be/0VCeITL8P4E"]
            ),
            "n": Exercise(
                description: "Your child is doing good. Try the suggested exercise to help him.",
                videos: ["https://youtu.be/oun0cGPMHZQ"]
            ),
            "p": Exercise(
                description: "Your child is doing good. Try the suggested exercise to help him.",
                videos: ["https://youtu.be/yJK2UZ2YkwA"]
            ),
            "r": Exercise(
                description: "Your child is doing good. Try the suggested exercise to help him.",
                videos: ["https://youtu.be/dgAwcWO72z0"]
            ),
            "s": Exercise(
                description: "Your child is doing good. Try the suggested exercise to help him.",
                videos: ["https://youtu.be/KRbxUiF2dkw"]
            ),
            "t": Exercise(
                description: "Your child is doing good. Try the suggested exercise to help him.",
                videos: ["https://youtu.be/j1ia8QFUIyg"]
            ),
            "w": Exercise(
                description: "Your child is doing good. Try the suggested exercise to help him.",
                videos: ["https://youtu.be/WHP9rOFibd4"]
            )
        ]
    }
    
    func getLevelsData() -> [AppLevel] {
        return levels
    }
    
    func getBadgesData() -> [AppBadge] {
        return badges
    }
    
    func getBadges(by id: UUID) -> AppBadge? {
        for badge in badges {
            if badge.id == id {
                return badge
            }
        }
        return nil
    }
    
    func getCardsData() -> [AppCard] {
        return cards
    }
    
    func countCards() -> Int {
        return cards.count
    }
    func getExercisesData() -> [String : Exercise] {
        return exercises
    }
}
