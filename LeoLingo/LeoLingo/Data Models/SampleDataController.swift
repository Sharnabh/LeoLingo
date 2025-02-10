//
//  BadgesDataController.swift
//  LeoLingo
//
//  Created by Batch - 2  on 23/01/25.
//

import Foundation

class SampleDataController {
    
    private var badges: [Badge] = []
    private var levels: [Level] = []
    private var cards: [Card] = []
    private var earnedBadges: [Badge] = []
    private var exercises: [String: Exercise] = [:]

    
    static var shared = SampleDataController()
    
    private init() {
        loadData()
    }
    
    func loadData() {
        levels = [
            Level(levelTitle: "Level 1", levelImage: "1", words: [
                Word(wordTitle: "A", wordImage: "a"),
                Word(wordTitle: "Alarm", wordImage: "alarm"),
                Word(wordTitle: "Army", wordImage: "army"),
                Word(wordTitle: "Art", wordImage: "art"),
                Word(wordTitle: "Apple", wordImage: "apple"),
                Word(wordTitle: "Ant", wordImage: "ant")
                ]),
            Level(levelTitle: "Level 2", levelImage: "2", words: [
                Word(wordTitle: "B", wordImage: "b"),
                Word(wordTitle: "Black", wordImage: "black"),
                Word(wordTitle: "Bread", wordImage: "bread"),
                Word(wordTitle: "Broom", wordImage: "broom"),
                Word(wordTitle: "Brick", wordImage: "brick"),
                Word(wordTitle: "Brother", wordImage: "brother")
                ]),
            Level(levelTitle: "Level 3", levelImage: "3", words: [
                Word(wordTitle: "R", wordImage: "r"),
                Word(wordTitle: "Ring", wordImage: "ring"),
                Word(wordTitle: "Rice", wordImage: "rice"),
                Word(wordTitle: "Red", wordImage: "red"),
                Word(wordTitle: "Read", wordImage: "read"),
                Word(wordTitle: "Run", wordImage: "run")
                ]),
            Level(levelTitle: "Level 4", levelImage: "4", words: [
                Word(wordTitle: "Fire", wordImage: "fire"),
                Word(wordTitle: "Frog", wordImage: "frog"),
                Word(wordTitle: "Fruit", wordImage: "fruits"),
                Word(wordTitle: "Frame", wordImage: "frame"),
                Word(wordTitle: "Flute", wordImage: "flute"),
                Word(wordTitle: "Flower", wordImage: "flower")
                ]),
            Level(levelTitle: "Level 5", levelImage: "5", words: [
                Word(wordTitle: "Lunch", wordImage: "lunch"),
                Word(wordTitle: "Lips", wordImage: "lips"),
                Word(wordTitle: "Lamp", wordImage: "lamp"),
                Word(wordTitle: "Laugh", wordImage: "laugh"),
                Word(wordTitle: "Lamp", wordImage: "lamp"),
                Word(wordTitle: "Leaf", wordImage: "leaf")
                ]),
            Level(levelTitle: "Level 6", levelImage: "6", words: [
                Word(wordTitle: "Lion", wordImage: "JungleLion"),
                Word(wordTitle: "Wire", wordImage: "wire"),
                Word(wordTitle: "Wrist", wordImage: "wrist"),
                Word(wordTitle: "Watch", wordImage: "watch"),
                Word(wordTitle: "Wall", wordImage: "wall"),
                Word(wordTitle: "Market", wordImage: "market")
                ]),
            Level(levelTitle: "Level 7", levelImage: "7", words: [
                Word(wordTitle: "City", wordImage: "city"),
                Word(wordTitle: "Ear", wordImage: "ear"),
                Word(wordTitle: "Eye", wordImage: "eye"),
                Word(wordTitle: "Book", wordImage: "book"),
                Word(wordTitle: "Pen", wordImage: "pen"),
                Word(wordTitle: "Sun", wordImage: "sun")
                ]),
            Level(levelTitle: "Level 8", levelImage: "8", words: [
                Word(wordTitle: "Sand", wordImage: "sand"),
                Word(wordTitle: "Snow", wordImage: "snow"),
                Word(wordTitle: "Sky", wordImage: "sky"),
                Word(wordTitle: "Snake", wordImage: "snake"),
                Word(wordTitle: "Sing", wordImage: "sing"),
                Word(wordTitle: "Superhero", wordImage: "superhero")
                ]),
            Level(levelTitle: "Level 9", levelImage: "9", words: [
                Word(wordTitle: "School", wordImage: "school"),
                Word(wordTitle: "Sweater", wordImage: "sweater"),
                Word(wordTitle: "Swim", wordImage: "swim"),
                Word(wordTitle: "Star", wordImage: "star"),
                Word(wordTitle: "Soup", wordImage: "soup"),
                Word(wordTitle: "Swan", wordImage: "swan")
                ])
        ]
        badges = [
            Badge(badgeTitle: "Bee", badgeDescription: "Busy Bee(You have taken the first step)", badgeImage: "bee", isEarned: false),
            Badge(badgeTitle: "Turtle", badgeDescription: "Persistent Achiever(Steady Progress Over Time", badgeImage: "turtle", isEarned: false),
            Badge(badgeTitle: "Elephant", badgeDescription: "Master of Speech(Major Milestones Reached)", badgeImage: "elephant", isEarned: false),
            Badge(badgeTitle: "Dog", badgeDescription: "Loyal Learner(Regular Practice)", badgeImage: "dog", isEarned: false),
            Badge(badgeTitle: "Bunny", badgeDescription: "Quick Learner(Fast Improvement)", badgeImage: "bunny", isEarned: false),
            Badge(badgeTitle: "Lion", badgeDescription: "Learner(Fast Improvements)", badgeImage: "lion", isEarned: false)
        ]
        earnedBadges = [
            Badge(badgeTitle: "Beginner", badgeDescription: " ", badgeImage: "bronze-medal", isEarned: true),
            Badge(badgeTitle: "Lion", badgeDescription: "Learner(Fast Improvements)", badgeImage: "lion", isEarned: true)
        ]
        cards = [
            Card(cardTitle: "Earlywords", cardImage: "EarlyWords", words: []),
            Card(cardTitle: "BodyParts", cardImage: "BodyParts", words: [
                Word(wordTitle: "Wrist", wordImage: "wrist"),
                Word(wordTitle: "Lips", wordImage: "lips"),
                Word(wordTitle: "Eye", wordImage: "eye"),
                Word(wordTitle: "Ear", wordImage: "ear"),
                Word(wordTitle: "Thumb", wordImage: "thumb"),
                Word(wordTitle: "Nose", wordImage: "nose"),
                Word(wordTitle: "Palm", wordImage: "palm")
            ]),
            Card(cardTitle: "Lsounds", cardImage: "Lsounds", words: []),
            Card(cardTitle: "Rsounds", cardImage: "Rsounds", words: []),
            Card(cardTitle: "Ssounds", cardImage: "Ssounds", words: []),
            Card(cardTitle: "Vsounds", cardImage: "Vsounds", words: []),
            Card(cardTitle: "Earlywords", cardImage: "EarlyWords", words: []),
            Card(cardTitle: "BodyParts", cardImage: "BodyParts", words: []),
            Card(cardTitle: "Lsounds", cardImage: "Lsounds", words: []),
            Card(cardTitle: "Rsounds", cardImage: "Rsounds", words: []),
            Card(cardTitle: "Ssounds", cardImage: "Ssounds", words: []),
            Card(cardTitle: "Vsounds", cardImage: "Vsounds", words: []),
            Card(cardTitle: "EarlyWords", cardImage: "EarlyWords", words: [])
        ]
        
        exercises = [
            "b": Exercise(
                description: "Make the 'B' sound by pressing your lips together and releasing air while voicing: 'buh'. Try saying 'ball' or 'bat'.",
                videos: ["https://youtu.be/746Aq0ndZy0"]
            ),
            "c": Exercise(
                description: "For the 'C' or 'K' sound, raise the back of your tongue to touch the roof of your mouth, then release with a burst of air: 'kuh'. Try 'cat' or 'kite'.",
                videos: ["https://youtu.be/0z80Zt66RcU"]
            ),
            "d": Exercise(
                description: "Place your tongue behind your upper front teeth and release quickly while voicing: 'duh'. Try saying 'dog' or 'door'.",
                videos: ["https://youtu.be/61xe97Nf8J4"]
            ),
            "f": Exercise(
                description: "Gently place your top teeth on your lower lip and blow air out to make the 'F' sound: 'fff'. Try 'fish' or 'fun'.",
                videos: ["https://youtu.be/xA61MYdspgM"]
            ),
            "g": Exercise(
                description: "The 'G' sound is made by lifting the back of your tongue to touch the soft part of the roof of your mouth: 'guh'. Try 'goat' or 'game'.",
                videos: ["https://youtu.be/bSlb9yscpbw"]
            ),
            "h": Exercise(
                description: "For the 'H' sound, breathe out softly from your throat without using your voice: 'huh'. Try 'hat' or 'happy'.",
                videos: ["https://youtu.be/3-qJF9ZstLQ"]
            ),
            "j": Exercise(
                description: "The 'J' sound is made by touching your tongue to the roof of your mouth and releasing with a voiced sound: 'juh'. Try 'jump' or 'juice'.",
                videos: ["https://youtu.be/xETjN3Y24cQ"]
            ),
            "k": Exercise(
                description: "Like the 'C' sound, make the 'K' by pressing the back of your tongue against the roof of your mouth: 'kuh'. Try 'kite' or 'kick'.",
                videos: ["https://youtu.be/JwKKfHIpOX8"]
            ),
            "l": Exercise(
                description: "To say 'L', lift the tip of your tongue to touch just behind your upper front teeth and let the air flow around it: 'lll'. Try 'lion' or 'light'.",
                videos: ["https://youtu.be/_IAEg3igJVI"]
            ),
            "m": Exercise(
                description: "Close your lips and hum through your nose to make the 'M' sound: 'mmm'. Try 'monkey' or 'moon'.",
                videos: ["https://youtu.be/0VCeITL8P4E"]
            ),
            "n": Exercise(
                description: "For 'N', place your tongue behind your top teeth and let air pass through your nose: 'nnn'. Try 'nose' or 'net'.",
                videos: ["https://youtu.be/oun0cGPMHZQ"]
            ),
            "p": Exercise(
                description: "Press your lips together, then release a small burst of air without using your voice: 'puh'. Try 'penguin' or 'pie'.",
                videos: ["https://youtu.be/yJK2UZ2YkwA"]
            ),
            "r": Exercise(
                description: "Curl your tongue slightly and let air pass over it to make the 'R' sound: 'rrr'. Try 'rabbit' or 'run'.",
                videos: ["https://youtu.be/dgAwcWO72z0"]
            ),
            "s": Exercise(
                description: "Smile slightly and let air pass through your teeth to create the 'S' sound: 'sss'. Try 'sun' or 'sock'.",
                videos: ["https://youtu.be/KRbxUiF2dkw"]
            ),
            "t": Exercise(
                description: "Place your tongue behind your upper front teeth and release quickly: 'tuh'. Try 'tiger' or 'tree'.",
                videos: ["https://youtu.be/j1ia8QFUIyg"]
            ),
            "w": Exercise(
                description: "Round your lips and push them forward slightly while voicing: 'wuh'. Try 'water' or 'wagon'.",
                videos: ["https://youtu.be/WHP9rOFibd4"]
            )
        ]
    }
    
    func getLevelsData() -> [Level] {
        return levels
    }
    
    func getBadgesData() -> [Badge] {
        return badges
    }
    
    func getEarnedBadgesData() -> [Badge] {
        return earnedBadges
    }
    
    func getCardsData() -> [Card] {
        return cards
    }
    
    func countCards() -> Int {
        return cards.count
    }
    func getExercisesData() -> [String : Exercise] {
        return exercises
    }
}
