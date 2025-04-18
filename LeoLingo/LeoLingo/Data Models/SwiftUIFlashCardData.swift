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
            color: Color(red: 0.7, green: 0.5, blue: 0.8),
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
            color: Color(red: 0.9, green: 0.7, blue: 0.3),
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
            color: Color(red: 0.4, green: 0.8, blue: 0.4),
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
            color: Color(red: 0.5, green: 0.7, blue: 0.9),
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
            name: "Occupations", 
            image: "occupations",
            color: Color(red: 0.8, green: 0.4, blue: 0.6),
            cards: [
                FlashCard(word: "Doctor", image: "doctor"),
                FlashCard(word: "Teacher", image: "teacher"),
                FlashCard(word: "Astronaut", image: "astronaut"),
                FlashCard(word: "Firefighter", image: "firefighter"),
                FlashCard(word: "Chef", image: "chef"),
                FlashCard(word: "Pilot", image: "pilot")
            ],
            backgroundImage: "occupations_bg"
        ),
        FlashCardCategory(
            name: "Sports", 
            image: "sports",
            color: Color(red: 0.4, green: 0.6, blue: 0.8),
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
        FlashCardCategory(
            name: "Insects", 
            image: "insects",
            color: Color(red: 0.8, green: 0.8, blue: 0.4),
            cards: [
                FlashCard(word: "Butterfly", image: "butterfly"),
                FlashCard(word: "Ladybug", image: "ladybug"),
                FlashCard(word: "Dragonfly", image: "dragonfly"),
                FlashCard(word: "Grasshopper", image: "grasshopper"),
                FlashCard(word: "Beetle", image: "beetle"),
                FlashCard(word: "Firefly", image: "firefly")
            ],
            backgroundImage: "insects_bg"
        ),
        
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
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        synthesizer.speak(utterance)
    }
} 
