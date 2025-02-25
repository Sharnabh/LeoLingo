//
//  FilterOptionsView.swift
//  LeoLingo
//
//  Created by Sharnabh on 20/02/25.
//

import SwiftUI

//enum AccuracyFilter: String, CaseIterable {
//    case all = "All"
//    case accurate = "Accurate"
//    case inaccurate = "Inaccurate"
//}

struct FilterOptionsView: View {
    @State private var selectedFilter: FIlterOptions = .all
    @State private var selectedLevel: Int? = nil
    @State private var selectedSuccessRate: ClosedRange<Double> = 0...1
    @Binding var selectedWord: Word?
    @Binding var shouldReloadProgress: Bool
    
    private let dataController = DataController.shared
    
    private var allWords: [(Level, Word, AppWord)] {
        let userLevels = dataController.getAllLevels()
        return userLevels.flatMap { level in
            level.words.compactMap { word in
                if let appWord = dataController.wordData(by: word.id) {
                    return (level, word, appWord)
                }
                return nil
            }
        }
    }
    
    private func getWordsForLevel(_ level: Int) -> [(String, Double, Int)] {
        return allWords
            .filter { $0.0.id == dataController.levelData(at: level - 1).id }
            .map { (_, word, appWord) in
                (appWord.wordTitle, 
                 word.avgAccuracy,
                 word.record?.attempts ?? 0)
            }
    }
    
    private func filterByAccuracy(_ words: [(String, Double, Int)]) -> [(String, Double, Int)] {
        switch selectedFilter {
        case .accurate:
            return words.filter { $0.1 >= 70 }
        case .inaccurate:
            return words.filter { $0.1 < 70 && $0.1 > 0 }
        default:
            return words
        }
    }
    
    private func getWordsForCategory() -> [(String, Double, Int)] {
        // Just return all words from levels 1-30
        return (1...30).flatMap { level in
            getWordsForLevel(level)
        }
    }
    
    var filteredWords: [(String, Double, Int)] {
        if let level = selectedLevel {
            let levelWords = getWordsForLevel(level)
            return filterByAccuracy(levelWords)
        } else {
            return filterByAccuracy(getWordsForCategory())
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Options
            VStack(spacing: 0) {  // Add VStack with zero spacing
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Level selection menu
                        Menu {
                            ForEach(FIlterOptions.allCases, id: \.self) { filter in
                                Button(action: {
                                    if selectedFilter == filter {
                                        selectedLevel = nil
                                    }
                                    selectedFilter = filter
                                }) {
                                    HStack {
                                        Text(filter.rawValue)
                                        if selectedFilter == filter {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            FilterLabel(text: selectedFilter.rawValue)
                        }
                        
                        // Level Buttons
                        ForEach(1...30, id: \.self) { level in
                            LevelButton(
                                level: level,
                                isSelected: selectedLevel == level,
                                action: {
                                    selectedLevel = selectedLevel == level ? nil : level
                                }
                            )
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 4)
                        }

                        
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                // Add brown divider
                Rectangle()
                    .fill(Color.brown.opacity(0.5))
                    .frame(height: 0.5)
            }
            
            // Word Cards Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 1) {
                    ForEach(filteredWords, id: \.0) { word, accuracy, attempts in
                        WordCardView(
                            word: word,
                            accuracy: accuracy,
                            attempts: "\(attempts)",
                            isSelected: selectedWord != nil && allWords.first(where: { $0.1.id == selectedWord?.id })?.2.wordTitle == word
                        )
                        .onTapGesture {
                            if selectedWord?.id.uuidString == word {
                                selectedWord = nil
                            } else {
                                // Find and set the actual Word object
                                selectedWord = allWords.first(where: { $0.2.wordTitle == word })?.1
                            }
                            // Toggle the reload flag
                            shouldReloadProgress.toggle()
                        }
                    }
                }
            }
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private func updateWordsList() {
        // No need for manual update since we're using computed properties
    }
}

// Break out components into separate views
struct FilterLabel: View {
    let text: String
    
    var body: some View {
        HStack {
            Text(text)
            Image(systemName: "chevron.down")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
        .foregroundColor(Color(red: 83/255, green: 183/255, blue: 53/255))
        .cornerRadius(20)
        .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white, lineWidth: 1)
        )
    }
}

struct LevelButton: View {
    let level: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Level \(level)")
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            
                .background(isSelected ? Color(red: 225/255, green: 168/255, blue: 63/255) : Color.white)
                .foregroundColor(isSelected ? .white : Color(red: 225/255, green: 168/255, blue: 63/255))
                .cornerRadius(20)
            
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color(red: 225/255, green: 168/255, blue: 63/255) : Color.white, lineWidth: 1)
                )
//                .shadow(radius: 2)
        }
    }
}
#Preview {
    FilterOptionsView(selectedWord: .constant(nil), shouldReloadProgress: .constant(false))
}
