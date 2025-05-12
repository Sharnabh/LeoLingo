import Foundation
import SwiftUI
import AVFoundation

// Main model for categories
struct FlashCardCategory: Identifiable {
    let id = UUID()
    let name: String
    let image: String
    let color: Color
    let cards: [FlashCard]
    let backgroundImage: String
}

// Model for individual flashcards
struct FlashCard: Identifiable {
    let id = UUID()
    let word: String
    let image: String
}

// Singleton to manage our flashcard data
class SwiftUIFlashCardDataManager {
    static let shared = SwiftUIFlashCardDataManager()
    private let synthesizer = AVSpeechSynthesizer()
    
    private init() {}
    
    // Categories with unique words to avoid redeclarations
    let categories: [FlashCardCategory] = [
        FlashCardCategory(
            name: "Body Parts",
            image: "body_parts",
            color: Color(red: 0.85, green: 0.45, blue: 0.85), // Brighter purple
            cards: [
                FlashCard(word: "Ear", image: "ear"),
                FlashCard(word: "Palm", image: "palm"),
                FlashCard(word: "Lips", image: "lips"),
                FlashCard(word: "Eye", image: "eye"),
                FlashCard(word: "Nose", image: "nose"),
                FlashCard(word: "Thumb", image: "thumb")
            ],
            backgroundImage: "body_bg"
        ),
        FlashCardCategory(
            name: "Animals",
            image: "wild_animals",
            color: Color(red: 1.0, green: 0.75, blue: 0.2), // Vibrant yellow
            cards: [
                FlashCard(word: "Elephant", image: "elephant"),
                FlashCard(word: "Giraffe", image: "giraffe"),
                FlashCard(word: "Zebra", image: "zebra"),
                FlashCard(word: "Rhinoceros", image: "rhinoceros"),
                FlashCard(word: "Cheetah", image: "cheetah"),
                FlashCard(word: "Gorilla", image: "gorilla")
            ],
            backgroundImage: "jungle_bg"
        ),
        FlashCardCategory(
            name: "Vegetables",
            image: "vegetables",
            color: Color(red: 0.35, green: 0.85, blue: 0.35), // Bright green
            cards: [
                FlashCard(word: "Broccoli", image: "broccoli"),
                FlashCard(word: "Carrot", image: "carrot"),
                FlashCard(word: "Cucumber", image: "cucumber"),
                FlashCard(word: "Spinach", image: "spinach"),
                FlashCard(word: "Potato", image: "potato"),
                FlashCard(word: "Cabbage", image: "cabbage")
            ],
            backgroundImage: "vegetables_bg"
        ),
        FlashCardCategory(
            name: "Weather", 
            image: "weather",
            color: Color(red: 0.4, green: 0.7, blue: 1.0), // Sky blue
            cards: [
                FlashCard(word: "Sunny", image: "sunny"),
                FlashCard(word: "Rainy", image: "rainy"),
                FlashCard(word: "Snowy", image: "snowy"),
                FlashCard(word: "Windy", image: "windy"),
                FlashCard(word: "Stormy", image: "stormy"),
                FlashCard(word: "Foggy", image: "foggy")
            ],
            backgroundImage: "weather_bg"
        ),
        FlashCardCategory(
            name: "Sports", 
            image: "sports",
            color: Color(red: 0.95, green: 0.85, blue: 0.2), // Bright yellow
            cards: [
                FlashCard(word: "Soccer", image: "soccer"),
                FlashCard(word: "Basketball", image: "basketball"),
                FlashCard(word: "Tennis", image: "tennis"),
                FlashCard(word: "Swimming", image: "swimming"),
                FlashCard(word: "Cycling", image: "cycling"),
                FlashCard(word: "Gymnastics", image: "gymnastics")
            ],
            backgroundImage: "sports_bg"
        ),
        // New category: Vehicles
        FlashCardCategory(
            name: "Vehicles",
            image: "vehicles",
            color: Color(red: 0.85, green: 0.3, blue: 0.95), // Vibrant violet
            cards: [
                FlashCard(word: "Car", image: "car"),
                FlashCard(word: "Bus", image: "bus"),
                FlashCard(word: "Train", image: "train"),
                FlashCard(word: "Airplane", image: "airplane"),
                FlashCard(word: "Bicycle", image: "bicycle"),
                FlashCard(word: "Boat", image: "boat")
            ],
            backgroundImage: "vehicles_bg"
        ),
        // New category: Clothes
        FlashCardCategory(
            name: "Clothes",
            image: "clothes",
            color: Color(red: 0.95, green: 0.5, blue: 0.5), // Coral pink
            cards: [
                FlashCard(word: "Shirt", image: "shirt"),
                FlashCard(word: "Pants", image: "pants"),
                FlashCard(word: "Shoes", image: "shoes"),
                FlashCard(word: "Hat", image: "hat"),
                FlashCard(word: "Socks", image: "socks"),
                FlashCard(word: "Jacket", image: "jacket")
            ],
            backgroundImage: "clothes_bg"
        ),
        // New category: Actions
        FlashCardCategory(
            name: "Actions",
            image: "actions",
            color: Color(red: 0.2, green: 0.6, blue: 0.95), // Bright blue
            cards: [
                FlashCard(word: "Jump", image: "jump"),
                FlashCard(word: "Run", image: "run"),
                FlashCard(word: "Sleep", image: "sleep"),
                FlashCard(word: "Eat", image: "eat"),
                FlashCard(word: "Write", image: "write"),
                FlashCard(word: "Read", image: "read")
            ],
            backgroundImage: "actions_bg"
        ),
        // New category: Stationery
        FlashCardCategory(
            name: "Stationery",
            image: "stationery",
            color: Color(red: 0.6, green: 0.6, blue: 0.75), // Lavender gray
            cards: [
                FlashCard(word: "Pencil", image: "pencil"),
                FlashCard(word: "Eraser", image: "eraser"),
                FlashCard(word: "Ruler", image: "ruler"),
                FlashCard(word: "Notebook", image: "notebook"),
                FlashCard(word: "Scissors", image: "scissors"),
                FlashCard(word: "Glue", image: "glue")
            ],
            backgroundImage: "stationery_bg"
        ),
        // New category: Toys
        FlashCardCategory(
            name: "Toys",
            image: "toys",
            color: Color(red: 1.0, green: 0.6, blue: 0.3), // Bright orange
            cards: [
                FlashCard(word: "Doll", image: "doll"),
                FlashCard(word: "Ball", image: "ball"),
                FlashCard(word: "Robot", image: "robot"),
                FlashCard(word: "Teddy", image: "teddy"),
                FlashCard(word: "Blocks", image: "blocks"),
                FlashCard(word: "Kite", image: "kite")
            ],
            backgroundImage: "toys_bg"
        )
    ]
    
    // Function to get all categories
    func getAllCategories() -> [FlashCardCategory] {
        return categories
    }
    
    // Function to speak a word
    func speakWord(_ word: String) {
        let utterance = AVSpeechUtterance(string: word)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.2
        utterance.volume = 1.0
        utterance.voice = AVSpeechSynthesisVoice(language: "en-IN")
        
        synthesizer.speak(utterance)
    }
}
