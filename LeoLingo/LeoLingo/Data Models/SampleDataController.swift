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
