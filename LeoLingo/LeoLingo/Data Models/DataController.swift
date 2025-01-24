//
//  DataController.swift
//  LeoLingo
//
//  Created by Batch - 2  on 23/01/25.
//

import Foundation

class DataController {
    private var levels: [Level] = []
    private var user: [UserData] = [UserData(name: "Joy", phoneNumber: "1234567890", password: "123", passcode: "2580")]
    
    static var shared = DataController()
    
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
                Word(wordTitle: "Lunch", wordImage: "luch"),
                Word(wordTitle: "Lips", wordImage: "lips"),
                Word(wordTitle: "Lamp", wordImage: "lamp"),
                Word(wordTitle: "Laugh", wordImage: "laugh"),
                Word(wordTitle: "Lamp", wordImage: "lamp"),
                Word(wordTitle: "Leaf", wordImage: "leaf")
                ]),
            Level(levelTitle: "Level 6", levelImage: "6", words: [
                Word(wordTitle: "Lion", wordImage: "lion"),
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

    }
    
    func createUser(user: UserData) {
        self.user.append(user)
    }
    
    func allUsers() -> [UserData] {
        return user
    }
    
    func updatePasscode(_ passcode: String) {
        
        self.user[0].passcode = passcode
    }
    
    func allLevels() -> [Level] {
        return levels
    }
    
    func updateLevels(_ levels: [Level]) {
        self.levels = levels
    }
    
    func levelData(at index: Int) -> Level {
        return levels[index]
    }
    
    func updateWordPraticeStatus(at index: Int, wordIndex: Int, accuracy: Double?) {
        levels[index].words[wordIndex].isPracticed = true
        updateWordRecord(at: index, wordIndex: wordIndex, accuracy: accuracy)
    }
    
    func updateWordRecord(at index: Int, wordIndex: Int, accuracy: Double?) {
        levels[index].words[wordIndex].record?.attempts += 1
        if let accuracy = accuracy {
            levels[index].words[wordIndex].record?.accuracy?.append(accuracy)
        }
    }
    
    func findUser(byPhone phoneNumber: String) -> UserData? {
        
        if user.contains(where: { $0.phoneNumber == phoneNumber }) {
            return user.first(where: { $0.phoneNumber == phoneNumber })
        } else {
            return nil
        }
    }
    
}
