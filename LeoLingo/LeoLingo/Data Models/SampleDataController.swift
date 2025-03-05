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
    private var levelCards : [LevelCard] = []
    private var exercises: [String: Exercise] = [:]
    private var categories: [AppCategory] = []
    private var categoryCards : [CategoryCard] = []
    
    static var shared = SampleDataController()
    
    private init() {
        loadData()
    }
    
    func loadData() {
        // Initialize WordIDManager
        let wordManager = WordIDManager.shared
        
        // Helper function to create AppWord with consistent ID
        func createWord(title: String, image: String) -> AppWord {
            return AppWord(wordTitle: title, wordImage: image)
        }
        
        levels = [
            AppLevel(levelTitle: "Level 1", levelImage: "1", words: [
                createWord(title: "A", image: "a"),
                createWord(title: "Alarm", image: "alarm"),
                createWord(title: "Army", image: "army"),
                createWord(title: "Art", image: "art"),
                createWord(title: "Apple", image: "apple"),
                createWord(title: "Ant", image: "ant")
            ]),
            AppLevel(levelTitle: "Level 2", levelImage: "2", words: [
                createWord(title: "B", image: "b"),
                createWord(title: "Black", image: "black"),
                createWord(title: "Bread", image: "bread"),
                createWord(title: "Broom", image: "broom"),
                createWord(title: "Brick", image: "brick"),
                createWord(title: "Brother", image: "brother")
            ]),
            AppLevel(levelTitle: "Level 3", levelImage: "3", words: [
                createWord(title: "R", image: "r"),
                createWord(title: "Ring", image: "ring"),
                createWord(title: "Rice", image: "rice"),
                createWord(title: "Red", image: "red"),
                createWord(title: "Read", image: "read"),
                createWord(title: "Run", image: "run")
            ]),
            AppLevel(levelTitle: "Level 4", levelImage: "4", words: [
                createWord(title: "Fire", image: "fire"),
                createWord(title: "Frog", image: "frog"),
                createWord(title: "Fruit", image: "fruits"),
                createWord(title: "Frame", image: "frame"),
                createWord(title: "Flute", image: "flute"),
                createWord(title: "Flower", image: "flower")
            ]),
            AppLevel(levelTitle: "Level 5", levelImage: "5", words: [
                createWord(title: "Lunch", image: "lunch"),
                createWord(title: "Lips", image: "lips"),
                createWord(title: "Lamp", image: "lamp"),
                createWord(title: "Laugh", image: "laugh"),
                createWord(title: "Lamp", image: "lamp"),
                createWord(title: "Leaf", image: "leaf")
            ]),
            AppLevel(levelTitle: "Level 6", levelImage: "6", words: [
                createWord(title: "Lion", image: "JungleLion"),
                createWord(title: "Wire", image: "wire"),
                createWord(title: "Wrist", image: "wrist"),
                createWord(title: "Watch", image: "watch"),
                createWord(title: "Wall", image: "wall"),
                createWord(title: "Market", image: "market")
            ]),
            AppLevel(levelTitle: "Level 7", levelImage: "7", words: [
                createWord(title: "City", image: "city"),
                createWord(title: "Ear", image: "ear"),
                createWord(title: "Eye", image: "eye"),
                createWord(title: "Book", image: "book"),
                createWord(title: "Pen", image: "pen"),
                createWord(title: "Sun", image: "sun")
            ]),
            AppLevel(levelTitle: "Level 8", levelImage: "8", words: [
                createWord(title: "Sand", image: "sand"),
                createWord(title: "Snow", image: "snow"),
                createWord(title: "Sky", image: "sky"),
                createWord(title: "Snake", image: "snake"),
                createWord(title: "Sing", image: "sing"),
                createWord(title: "Superhero", image: "superhero")
            ]),
            AppLevel(levelTitle: "Level 9", levelImage: "9", words: [
                createWord(title: "School", image: "school"),
                createWord(title: "Sweater", image: "sweater"),
                createWord(title: "Swim", image: "swim"),
                createWord(title: "Star", image: "star"),
                createWord(title: "Soup", image: "soup"),
                createWord(title: "Swan", image: "swan")
            ]),
            AppLevel(levelTitle: "Level 10", levelImage: "10", words: [
                createWord(title: "School", image: "school"),
                createWord(title: "Sweater", image: "sweater"),
                createWord(title: "Swim", image: "swim"),
                createWord(title: "Star", image: "star"),
                createWord(title: "Soup", image: "soup"),
                createWord(title: "Swan", image: "swan")
            ])
        ]
        categories = [
            AppCategory(categoryTitle: "Body Parts", categoryImage: "BodyParts", words: [
                AppWord(wordTitle: "Eye", wordImage: "eye"),
                AppWord(wordTitle: "Thumb", wordImage: "thumb"),
                AppWord(wordTitle: "Palm", wordImage: "palm"),
                AppWord(wordTitle: "Nose", wordImage: "nose"),
                AppWord(wordTitle: "Lips", wordImage: "lips"),
                AppWord(wordTitle: "Ear", wordImage: "ear")
                ]),
            AppCategory(categoryTitle: "Fruits", categoryImage: "Fruits", words: [
                AppWord(wordTitle: "Apple", wordImage: "apple"),
                AppWord(wordTitle: "Banana", wordImage: "banana")
                ]),
            AppCategory(categoryTitle: "Vehicles", categoryImage: "Vehicles", words: [
                AppWord(wordTitle: "Car", wordImage: "car"),
                AppWord(wordTitle: "Bus", wordImage: "bus")
                ]),
            AppCategory(categoryTitle: "Food", categoryImage: "Vehicles", words: []),
            AppCategory(categoryTitle: "Animals", categoryImage: "Vehicles", words: []),
            AppCategory(categoryTitle: "Clothes", categoryImage: "Vehicles", words: []),
            AppCategory(categoryTitle: "Places", categoryImage: "Vehicles", words: []),
            AppCategory(categoryTitle: "Time", categoryImage: "Vehicles", words: []),
            AppCategory(categoryTitle: "Actions", categoryImage: "Vehicles", words: []),
            AppCategory(categoryTitle: "Relations", categoryImage: "Vehicles", words: []),

            
        ]
        badges = [
            AppBadge(badgeTitle: "Bee", badgeDescription: "Busy Bee(You have taken the first step)", badgeImage: "bee"),
            AppBadge(badgeTitle: "Turtle", badgeDescription: "Persistent Achiever(Steady Progress Over Time", badgeImage: "turtle"),
            AppBadge(badgeTitle: "Elephant", badgeDescription: "Master of Speech(Major Milestones Reached)", badgeImage: "elephant"),
            AppBadge(badgeTitle: "Dog", badgeDescription: "Loyal Learner(Regular Practice)", badgeImage: "dog"),
            AppBadge(badgeTitle: "Bunny", badgeDescription: "Quick Learner(Fast Improvement)", badgeImage: "bunny"),
            AppBadge(badgeTitle: "Lion", badgeDescription: "Learner(Fast Improvements)", badgeImage: "lion"),
            AppBadge(badgeTitle: "Level 1", badgeDescription: "This is Level 1", badgeImage: "1"),
            AppBadge(badgeTitle: "Level 2", badgeDescription: "This is Level 2", badgeImage: "2"),
            AppBadge(badgeTitle: "Level 3", badgeDescription: "This is Level 3", badgeImage: "3"),
            AppBadge(badgeTitle: "Level 4", badgeDescription: "This is Level 4", badgeImage: "4"),
            AppBadge(badgeTitle: "Level 5", badgeDescription: "This is Level 5", badgeImage: "5"),
            AppBadge(badgeTitle: "Level 6", badgeDescription: "This is Level 6", badgeImage: "6"),
            AppBadge(badgeTitle: "Level 7", badgeDescription: "This is Level 7", badgeImage: "7"),
            AppBadge(badgeTitle: "Level 8", badgeDescription: "This is Level 8", badgeImage: "8"),
            AppBadge(badgeTitle: "Level 9", badgeDescription: "This is Level 9", badgeImage: "9"),
            AppBadge(badgeTitle: "Level 10", badgeDescription: "This is Level 10", badgeImage: "10"),
            AppBadge(badgeTitle: "Level 11", badgeDescription: "This is Level 11", badgeImage: "11"),
            AppBadge(badgeTitle: "Level 12", badgeDescription: "This is Level 12", badgeImage: "12"),
            AppBadge(badgeTitle: "Level 13", badgeDescription: "This is Level 13", badgeImage: "13"),
            AppBadge(badgeTitle: "Level 14", badgeDescription: "This is Level 14", badgeImage: "14"),
            AppBadge(badgeTitle: "Level 15", badgeDescription: "This is Level 15", badgeImage: "15"),
            AppBadge(badgeTitle: "Level 16", badgeDescription: "This is Level 16", badgeImage: "16"),
            AppBadge(badgeTitle: "Level 17", badgeDescription: "This is Level 17", badgeImage: "17"),
            AppBadge(badgeTitle: "Level 18", badgeDescription: "This is Level 18", badgeImage: "18"),
            AppBadge(badgeTitle: "Level 19", badgeDescription: "This is Level 19", badgeImage: "19"),
            AppBadge(badgeTitle: "Level 20", badgeDescription: "This is Level 20", badgeImage: "20"),
            AppBadge(badgeTitle: "Level 21", badgeDescription: "This is Level 21", badgeImage: "21"),
            AppBadge(badgeTitle: "Level 22", badgeDescription: "This is Level 22", badgeImage: "22"),
            AppBadge(badgeTitle: "Level 23", badgeDescription: "This is Level 23", badgeImage: "23"),
            AppBadge(badgeTitle: "Level 24", badgeDescription: "This is Level 24", badgeImage: "24"),
            AppBadge(badgeTitle: "Level 25", badgeDescription: "This is Level 25", badgeImage: "25"),
            AppBadge(badgeTitle: "Level 26", badgeDescription: "This is Level 26", badgeImage: "26"),
            AppBadge(badgeTitle: "Level 27", badgeDescription: "This is Level 27", badgeImage: "27"),
            AppBadge(badgeTitle: "Level 28", badgeDescription: "This is Level 28", badgeImage: "28"),
            AppBadge(badgeTitle: "Level 29", badgeDescription: "This is Level 29", badgeImage: "29"),
            AppBadge(badgeTitle: "Level 30", badgeDescription: "This is Level 30", badgeImage: "30")
        ]
        cards = [
            AppCard(cardTitle: "Earlywords", cardImage: "EarlyWords", words: []),
            AppCard(cardTitle: "BodyParts", cardImage: "BodyParts", words: [
                createWord(title: "Wrist", image: "wrist"),
                createWord(title: "Lips", image: "lips"),
                createWord(title: "Eye", image: "eye"),
                createWord(title: "Ear", image: "ear"),
                createWord(title: "Thumb", image: "thumb"),
                createWord(title: "Nose", image: "nose"),
                createWord(title: "Palm", image: "palm")
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
            "a": Exercise(
                description: "Your child is doing good. Try the suggested exercise for A words.",
                videos: ["https://youtu.be/4SNO61r4Nz8?si=RLnQ3s69xJEYPyLS"]
            ),
            "b": Exercise(
                description: "Your child is doing good. Try the suggested exercise for B words.",
                videos: ["https://youtu.be/746Aq0ndZy0"]
            ),
            "c": Exercise(
                description: "Your child is doing good. Try the suggested exercise for C words.",
                videos: ["https://youtu.be/0z80Zt66RcU"]
            ),
            "d": Exercise(
                description: "Your child is doing good. Try the suggested exercise for D words.",
                videos: ["https://youtu.be/61xe97Nf8J4"]
            ),
            "e": Exercise(
                description: "Your child is doing good. Try the suggested exercise for E words.",
                videos: ["https://youtu.be/61xe97Nf8J4"]
            ),
            "f": Exercise(
                description: "Your child is doing good. Try the suggested exercise for F words.",
                videos: ["https://youtu.be/xA61MYdspgM"]
            ),
            "g": Exercise(
                description: "Your child is doing good. Try the suggested exercise for G words.",
                videos: ["https://youtu.be/bSlb9yscpbw"]
            ),
            "h": Exercise(
                description: "Your child is doing good. Try the suggested exercise for H words.",
                videos: ["https://youtu.be/3-qJF9ZstLQ"]
            ),
            "i": Exercise(
                description: "Your child is doing good. Try the suggested exercise for I words.",
                videos: ["https://youtu.be/61xe97Nf8J4"]
            ),
            "j": Exercise(
                description: "Your child is doing good. Try the suggested exercise for J words.",
                videos: ["https://youtu.be/xETjN3Y24cQ"]
            ),
            "k": Exercise(
                description: "Your child is doing good. Try the suggested exercise for K words.",
                videos: ["https://youtu.be/JwKKfHIpOX8"]
            ),
            "l": Exercise(
                description: "Your child is doing good. Try the suggested exercise for L words.",
                videos: ["https://youtu.be/_IAEg3igJVI"]
            ),
            "m": Exercise(
                description: "Your child is doing good. Try the suggested exercise for M words.",
                videos: ["https://youtu.be/0VCeITL8P4E"]
            ),
            "n": Exercise(
                description: "Your child is doing good. Try the suggested exercise for N words.",
                videos: ["https://youtu.be/oun0cGPMHZQ"]
            ),
            "o": Exercise(
                description: "Your child is doing good. Try the suggested exercise for O words.",
                videos: ["https://youtu.be/61xe97Nf8J4"]
            ),
            "p": Exercise(
                description: "Your child is doing good. Try the suggested exercise for P words.",
                videos: ["https://youtu.be/yJK2UZ2YkwA"]
            ),
            "r": Exercise(
                description: "Your child is doing good. Try the suggested exercise for R words.",
                videos: ["https://youtu.be/dgAwcWO72z0"]
            ),
            "s": Exercise(
                description: "Your child is doing good. Try the suggested exercise for S words.",
                videos: ["https://youtu.be/KRbxUiF2dkw"]
            ),
            "t": Exercise(
                description: "Your child is doing good. Try the suggested exercise for T words.",
                videos: ["https://youtu.be/j1ia8QFUIyg"]
            ),
            "u": Exercise(
                description: "Your child is doing good. Try the suggested exercise for U words.",
                videos: ["https://youtu.be/61xe97Nf8J4"]
            ),
            "v": Exercise(
                description: "Your child is doing good. Try the suggested exercise for V words.",
                videos: ["https://youtu.be/61xe97Nf8J4"]
            ),
            "w": Exercise(
                description: "Your child is doing good. Try the suggested exercise for W words.",
                videos: ["https://youtu.be/WHP9rOFibd4"]
            ),
            "x": Exercise(
                description: "Your child is doing good. Try the suggested exercise for X words.",
                videos: ["https://youtu.be/61xe97Nf8J4"]
            ),
            "y": Exercise(
                description: "Your child is doing good. Try the suggested exercise for Y words.",
                videos: ["https://youtu.be/61xe97Nf8J4"]
            )
        ]
        let levelCardImages = ["Level1","Level2","Level3","Level4","Level5","Level6","Level7","Level8","Level9","Level10"]
       
        levelCards = zip(levels, levelCardImages).map { LevelCard(from: $0.0, levelCardImage: $0.1) }
        
        let categoryCardImages = ["BodyParts","Fruits","Vegitables","Animals","Colors","Shapes","Numbers","Letters","Actions"]
        
        categoryCards = zip(categories, categoryCardImages).map { CategoryCard(from: $0.0, categoryCardImage: $0.1) }
    }
    
    func getLevelsData() -> [AppLevel] {
        return levels
    }
    
    func getCategoriesData() -> [AppCategory] {
        return categories
    }
    func countWordsInCategory(at index: Int) -> Int {
        let categories = SampleDataController.shared.getCategoriesData()
        
        guard index < categories.count else {
            return 0
        }
        
        return categories[index].words.count
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
    func getLevelCards() -> [LevelCard] {
        return levelCards
    }
    func countLevelCards() -> Int {
        return levelCards.count
    }
    func getCategoryCards() -> [CategoryCard] {
        return categoryCards
    }
    func countCategoryCards() -> Int {
        return categoryCards.count
    }
}
