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
    @State private var isLoading = false
    
    private let dataController = SupabaseDataController.shared
    
    // MARK: - Data Processing
    
    private struct WordInfo {
        let level: Level
        let word: Word
        let appWord: AppWord
    }
    
    private struct ProcessedWord {
        let title: String
        let accuracy: Double
        let attempts: Int
    }
    
    private func mapWordToInfo(_ level: Level, _ word: Word) -> WordInfo? {
        guard let appWord = dataController.wordData(by: word.id) else {
            return nil
        }
        return WordInfo(level: level, word: word, appWord: appWord)
    }
    
    private func getWordsForLevel(_ level: Level) -> [WordInfo] {
        return level.words.compactMap { word in
            mapWordToInfo(level, word)
        }
    }
    
    private var allWords: [WordInfo] {
        let userLevels = dataController.getAllLevels()
        let words = userLevels.flatMap { level in
            getWordsForLevel(level)
        }
        print("DEBUG: Found \(words.count) words")
        for word in words {
            if let record = word.word.record {
                print("DEBUG: Word: \(word.appWord.wordTitle)")
                print("  - Accuracy array: \(String(describing: record.accuracy))")
                print("  - Attempts: \(record.attempts)")
                print("  - Average accuracy: \(word.word.avgAccuracy)")
                print("  - Is practiced: \(word.word.isPracticed)")
            } else {
                print("DEBUG: Word: \(word.appWord.wordTitle) has no record")
            }
        }
        return words
    }
    
    private func processWord(_ info: WordInfo) -> ProcessedWord {
        ProcessedWord(
            title: info.appWord.wordTitle,
            accuracy: info.word.record?.avgAccuracy ?? 0.0,
            attempts: info.word.record?.attempts ?? 0
        )
    }
    
    private func filterWordsByLevel(_ words: [WordInfo], level: Int) -> [WordInfo] {
        let targetLevelId = dataController.levelData(at: level - 1).id
        return words.filter { $0.level.id == targetLevelId }
    }
    
    private func getWordsForLevel(_ level: Int) -> [ProcessedWord] {
        let filtered = filterWordsByLevel(allWords, level: level)
        return filtered.map(processWord)
    }
    
    private func filterByAccuracy(_ words: [ProcessedWord]) -> [ProcessedWord] {
        switch selectedFilter {
        case .accurate:
            return words.filter { $0.accuracy >= 70 }
        case .inaccurate:
            return words.filter { $0.accuracy < 70 && $0.accuracy > 0 }
        default:
            return words
        }
    }
    
    private func getWordsForCategory() -> [ProcessedWord] {
        return (1...30).flatMap { level in
            getWordsForLevel(level)
        }
    }
    
    private var filteredWords: [ProcessedWord] {
        if let level = selectedLevel {
            let levelWords = getWordsForLevel(level)
            return filterByAccuracy(levelWords)
        } else {
            return filterByAccuracy(getWordsForCategory())
        }
    }
    
    private func findSelectedWordInfo(_ wordTitle: String) -> Word? {
        return allWords.first(where: { $0.appWord.wordTitle == wordTitle })?.word
    }
    
    private func isWordSelected(_ wordTitle: String) -> Bool {
        guard let selectedWord = selectedWord else { return false }
        return allWords.first(where: { $0.word.id == selectedWord.id })?.appWord.wordTitle == wordTitle
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Options
            VStack(spacing: 0) {
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
                    ForEach(filteredWords, id: \.title) { word in
                        WordCardView(
                            word: word.title,
                            accuracy: word.accuracy,
                            attempts: "\(word.attempts)",
                            isSelected: isWordSelected(word.title)
                        )
                        .onTapGesture {
                            if selectedWord?.id.uuidString == word.title {
                                selectedWord = nil
                            } else {
                                selectedWord = findSelectedWordInfo(word.title)
                            }
                            shouldReloadProgress.toggle()
                        }
                    }
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .task {
            if let phoneNumber = dataController.phoneNumber {
                isLoading = true
                do {
                    _ = try await dataController.getUser(byPhone: phoneNumber)
                    shouldReloadProgress.toggle()
                } catch {
                    print("Error loading user data: \(error)")
                }
                isLoading = false
            }
        }
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
