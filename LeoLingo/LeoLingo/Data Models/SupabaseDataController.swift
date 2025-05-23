import Foundation
import Supabase
import UIKit

class SupabaseDataController {
    static let shared = SupabaseDataController()
    
    private let supabase: SupabaseClient
    private let sampleData = SampleDataController.shared
    private var currentUser: UserData?
    
    // Add property to store current user ID
    private var currentUserId: UUID?
    private var currentPhoneNumber: String?
    
    // Add property to track if user is new
    private var isFirstTimeUser: Bool = false
    
    // Add public getter and setter for first time user status
    public var isFirstTime: Bool {
        get { isFirstTimeUser }
        set { isFirstTimeUser = newValue }
    }
    
    // Add public getter for user ID
    public var userId: UUID? {
        get { currentUserId }
    }
    
    // Keep phone number getter for backward compatibility
    public var phoneNumber: String? {
        get { currentPhoneNumber }
    }
    
    private init() {
        supabase = SupabaseClient(
            supabaseURL: URL(string: "https://eqxvelgsouxgvnfyfphp.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxeHZlbGdzb3V4Z3ZuZnlmcGhwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA0MTUzMzIsImV4cCI6MjA1NTk5MTMzMn0.sxoD5x6cio8qr8sx71KwmI2BsZyljckVdCcdcMd3sVU"
        )
    }
    
    // MARK: - User Management
    
    func signUp(name: String, phoneNumber: String, password: String) async throws -> UserData {
        do {
            let userData = User(
                name: name,
                phone_number: phoneNumber,
                password: password
            )
            
            let response: User = try await supabase
                .from("users")
                .insert(userData)
                .select()
                .single()
                .execute()
                .value
            
            print("DEBUG: ====== SIGNUP ======")
            print("DEBUG: Created new user with ID: \(response.id)")
            print("DEBUG: ===================")
            
            // Store both user ID and phone number on successful sign up
            self.currentUserId = response.id
            self.currentPhoneNumber = phoneNumber
            self.isFirstTimeUser = true
            
            // Save user ID to UserDefaults
            UserDefaults.standard.userId = response.id.uuidString
            UserDefaults.standard.isUserLoggedIn = true
            
            await initializeUserDataWithBadgeAchievement(userId: response.id)
            return try await getUser(byId: response.id)
        } catch {
            throw SupabaseError.databaseError(error)
        }
    }
    
    private func initializeUserData(userId: UUID) async throws {
        print("DEBUG: Initializing user data for ID: \(userId)")
        
        // Check for existing word records
        let existingRecords: [UserWordRecord] = try await supabase
            .from("user_word_records")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        print("DEBUG: Found \(existingRecords.count) existing word records")
        
        // Print word ID mappings before initialization
        print("DEBUG: Current word ID mappings:")
        WordIDManager.shared.printCurrentMappings()
        
        if existingRecords.isEmpty {
            print("DEBUG: Creating new word records for user")
            let badges = sampleData.getBadgesData()
            
            // Initialize badges - set NewLeo badge as earned by default
            for badge in badges {
                let isEarned = badge.badgeTitle == "NewLeo"
                let badgeData = UserBadge(
                    user_id: userId,
                    badge_id: badge.id,
                    is_earned: isEarned,
                    earned_at: isEarned ? Date() : nil
                )
                
                // Insert badge data and handle any errors
                do {
                    try await supabase
                        .from("user_badges")
                        .insert(badgeData)
                        .execute()
                    print("DEBUG: Successfully initialized badge: \(badge.badgeTitle)")
                } catch {
                    print("DEBUG: Error initializing badge \(badge.badgeTitle): \(error)")
                }
            }
            
            // Initialize word records
            let levels = sampleData.getLevelsData()
            for level in levels {
                print("DEBUG: Creating records for level \(level.levelTitle)")
                for word in level.words {
                    print("DEBUG: Creating record for word: \(word.wordTitle), ID: \(word.id)")
                    let wordData = UserWordRecord(
                        user_id: userId,
                        word_id: word.id,
                        is_practiced: false
                    )
                    try await supabase
                        .from("user_word_records")
                        .insert(wordData)
                        .execute()
                }
            }
            print("DEBUG: Finished creating word records")
        } else {
            print("DEBUG: User already has word records, checking consistency")
            for record in existingRecords {
                if let word = wordData(by: record.word_id) {
                    print("DEBUG: Found word '\(word.wordTitle)' for record ID: \(record.word_id)")
                } else {
                    print("DEBUG: No word found for record ID: \(record.word_id)")
                }
            }
        }
    }
    
    func signIn(phoneNumber: String, password: String) async throws -> UserData {
        do {
            print("DEBUG: Attempting sign in for phone: \(phoneNumber)")
            let response: [User] = try await supabase
                .from("users")
                .select()
                .eq("phone_number", value: phoneNumber)
                .eq("password", value: password)
                .execute()
                .value
            
            guard let user = response.first else {
                throw SupabaseError.invalidCredentials
            }
            
            print("DEBUG: ====== LOGIN ======")
            print("DEBUG: Found user with ID: \(user.id)")
            print("DEBUG: ==================")
            
            // Store both user ID and phone number on successful sign in
            self.currentUserId = user.id
            self.currentPhoneNumber = phoneNumber
            self.isFirstTimeUser = false
            
            // Save user ID to UserDefaults
            UserDefaults.standard.userId = user.id.uuidString
            UserDefaults.standard.isUserLoggedIn = true
            
            // Ensure user data exists
            try await initializeUserData(userId: user.id)
            return try await getUser(byId: user.id)
        } catch {
            print("DEBUG: Sign in error: \(error)")
            throw SupabaseError.networkError(error)
        }
    }
    
    // Add new method to get user by ID
    func getUser(byId userId: UUID) async throws -> UserData {
        print("DEBUG: Getting user data for ID: \(userId)")
        let user: User = try await supabase
            .from("users")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
        
        // Get all word records in a single query
        let wordsResponse: [UserWordRecord] = try await supabase
            .from("user_word_records")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
            
        print("DEBUG: Found \(wordsResponse.count) word records in database")
        print("DEBUG: Word records details:")
        for record in wordsResponse {
            print("  Word ID: \(record.word_id)")
            print("    Practiced: \(record.is_practiced)")
            print("    Attempts: \(record.attempts)")
            print("    Accuracy: \(record.accuracy ?? [])")
        }
        
        // Get all badge records in a single query
        let badgesResponse: [UserBadge] = try await supabase
            .from("user_badges")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        let userLevels = constructUserLevels(
            from: wordsResponse,
            records: wordsResponse // Use the same response since it contains all needed data
        )
        
        let userBadges = constructUserBadges(from: badgesResponse)
        let earnedBadges = userBadges.filter { $0.isEarned }
        
        let userData = UserData(
            id: user.id,
            name: user.name,
            phoneNumber: user.phone_number,
            password: user.password,
            passcode: user.passcode,
            childName: user.child_name,
            userLevels: userLevels,
            userEarnedBadges: earnedBadges,
            userBadges: userBadges
        )
        
        currentUser = userData
        return userData
    }
    
    // Keep the phone number method for backward compatibility
    func getUser(byPhone phoneNumber: String) async throws -> UserData {
        let user: User = try await supabase
            .from("users")
            .select()
            .eq("phone_number", value: phoneNumber)
            .single()
            .execute()
            .value
        
        return try await getUser(byId: user.id)
    }
    
    // MARK: - Word Progress and Recordings
    
    // Add database model for words
    private struct DBWord: Codable {
        let id: UUID
        let title: String
        
        private enum CodingKeys: String, CodingKey {
            case id
            case title = "word_title"
        }
    }
    
    func updateWordProgress(wordId: UUID, accuracy: Double?, recordingPath: String? = nil) async throws {
        guard let userId = currentUser?.id else {
            throw SupabaseError.userNotLoggedIn
        }
        
        print("DEBUG: Updating word progress for wordId: \(wordId)")
        print("DEBUG: Accuracy value: \(String(describing: accuracy))")
        print("DEBUG: Recording path: \(String(describing: recordingPath))")
        
        // Verify the word exists in our local data
        guard wordData(by: wordId) != nil else {
            throw SupabaseError.invalidData
        }
        
        do {
            // Get existing record if any
            let existingRecords: [UserWordRecord] = try await supabase
                .from("user_word_records")
                .select()
                .eq("user_id", value: userId)
                .eq("word_id", value: wordId)
                .execute()
                .value
            
            print("DEBUG: Found \(existingRecords.count) existing records")
            
            if let existingRecord = existingRecords.first {
                print("DEBUG: Existing record:")
                print("  - Attempts: \(existingRecord.attempts)")
                print("  - Current accuracy array: \(String(describing: existingRecord.accuracy))")
                print("  - Current recordings: \(String(describing: existingRecord.recordings))")
                
                var newAccuracy = existingRecord.accuracy ?? []
                if let accuracy = accuracy {
                    newAccuracy.append(accuracy)
                }
                
                var newRecordings = existingRecord.recordings ?? []
                if let recordingPath = recordingPath {
                    // Upload the recording and get the stored filename
                    if let storedFilename = try await uploadRecording(at: recordingPath, wordId: wordId) {
                        newRecordings.append(storedFilename)
                        print("DEBUG: Added new recording filename: \(storedFilename)")
                        print("DEBUG: Updated recordings array: \(newRecordings)")
                    }
                }
                
                let updatedRecord = UserWordRecord(
                    user_id: userId,
                    word_id: wordId,
                    is_practiced: true,
                    attempts: existingRecord.attempts + 1,
                    accuracy: newAccuracy,
                    recordings: newRecordings.isEmpty ? nil : newRecordings
                )
                
                print("DEBUG: Updated record:")
                print("  - Attempts: \(updatedRecord.attempts)")
                print("  - New accuracy array: \(String(describing: updatedRecord.accuracy))")
                print("  - New recordings array: \(String(describing: updatedRecord.recordings))")
                print("  - Average accuracy: \(updatedRecord.avgAccuracy)")
                
                try await supabase
                    .from("user_word_records")
                    .update(updatedRecord)
                    .eq("id", value: existingRecord.id)
                    .execute()
                
                // Refresh current user data to ensure we have the latest records
                currentUser = try await getUser(byId: userId)
            } else {
                print("DEBUG: Creating new record")
                
                var newRecordings: [String]? = nil
                if let recordingPath = recordingPath {
                    // Upload the recording and get the stored filename
                    if let storedFilename = try await uploadRecording(at: recordingPath, wordId: wordId) {
                        newRecordings = [storedFilename]
                        print("DEBUG: Added new recording filename: \(storedFilename)")
                    }
                }
                
                let newRecord = UserWordRecord(
                    user_id: userId,
                    word_id: wordId,
                    is_practiced: true,
                    attempts: 1,
                    accuracy: accuracy.map { [$0] },
                    recordings: newRecordings
                )
                
                print("DEBUG: New record:")
                print("  - Attempts: \(newRecord.attempts)")
                print("  - Accuracy array: \(String(describing: newRecord.accuracy))")
                print("  - Recordings array: \(String(describing: newRecord.recordings))")
                print("  - Average accuracy: \(newRecord.avgAccuracy)")
                
                try await supabase
                    .from("user_word_records")
                    .insert(newRecord)
                    .execute()
                
                // Refresh current user data to ensure we have the latest records
                currentUser = try await getUser(byId: userId)
            }
        } catch {
            print("Error updating word progress: \(error)")
            throw SupabaseError.databaseError(error)
        }
    }
    
    private func uploadRecording(at path: String, wordId: UUID) async throws -> String? {
        guard let userId = currentUser?.id else {
            throw SupabaseError.userNotLoggedIn
        }
        
        // Create a unique filename for the recording that includes userId for uniqueness
        let timestamp = Date().timeIntervalSince1970
        let uniqueFileName = "recording_\(userId)_\(wordId)_\(Int(timestamp)).m4a"
        
        // Get the app's documents directory
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("DEBUG: Could not get documents directory")
            return nil
        }
        
        // Create a Recordings directory if it doesn't exist
        let recordingsDirectory = documentsPath.appendingPathComponent("Recordings", isDirectory: true)
        try? FileManager.default.createDirectory(at: recordingsDirectory, withIntermediateDirectories: true)
        
        // Create the destination path with the unique filename
        let destinationPath = recordingsDirectory.appendingPathComponent(uniqueFileName)
        
        do {
            // Convert source path string to URL
            let sourceURL = URL(fileURLWithPath: path)
            
            print("DEBUG: Copying recording from \(sourceURL.path) to \(destinationPath.path)")
            
            // Copy the file from the temporary location to our app's storage
            if FileManager.default.fileExists(atPath: destinationPath.path) {
                try FileManager.default.removeItem(at: destinationPath)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destinationPath)
            
            print("DEBUG: Successfully copied recording to \(destinationPath.path)")
            
            // Return the full path - this will be stored in Supabase
            return destinationPath.path
        } catch {
            print("Error copying recording: \(error)")
            return nil
        }
    }
    
    func getRecordings(for wordId: UUID) async throws -> [String] {
        guard let userId = currentUser?.id else {
            throw SupabaseError.userNotLoggedIn
        }
        
        let records: [UserWordRecord] = try await supabase
            .from("user_word_records")
            .select()
            .eq("user_id", value: userId)
            .eq("word_id", value: wordId)
            .execute()
            .value
        
        // If we have recordings, ensure they all have valid paths
        if let recordings = records.first?.recordings {
            // Filter out any invalid paths
            return recordings.filter { FileManager.default.fileExists(atPath: $0) }
        }
        
        return []
    }
    
    func deleteRecording(url: String, for wordId: UUID) async throws {
        guard let userId = currentUser?.id else {
            throw SupabaseError.userNotLoggedIn
        }
        
        let records: [UserWordRecord] = try await supabase
            .from("user_word_records")
            .select()
            .eq("user_id", value: userId)
            .eq("word_id", value: wordId)
            .execute()
            .value
        
        guard let record = records.first,
              var recordings = record.recordings else {
            throw SupabaseError.invalidData
        }
        
        // Remove the URL from the recordings array
        recordings.removeAll { $0 == url }
        
        // Delete the file if it exists
        if FileManager.default.fileExists(atPath: url) {
            try FileManager.default.removeItem(atPath: url)
            print("DEBUG: Successfully deleted recording file at \(url)")
        }
        
        // Update the record
        let updatedRecord = UserWordRecord(
            user_id: userId,
            word_id: wordId,
            is_practiced: record.is_practiced,
            attempts: record.attempts,
            accuracy: record.accuracy,
            recordings: recordings.isEmpty ? nil : recordings
        )
        
        try await supabase
            .from("user_word_records")
            .update(updatedRecord)
            .eq("id", value: record.id)
            .execute()
    }
    
    // MARK: - Badges
    
    func updateBadgeStatus(badgeId: UUID, isEarned: Bool, showPopup: Bool = true) async throws {
        guard let userId = currentUser?.id else {
            throw SupabaseError.userNotLoggedIn
        }
        
        let badgeUpdate = UserBadge(
            user_id: userId,
            badge_id: badgeId,
            is_earned: isEarned,
            earned_at: isEarned ? Date() : nil
        )
        
        try await supabase
            .from("user_badges")
            .update(badgeUpdate)
            .eq("user_id", value: userId)
            .eq("badge_id", value: badgeId)
            .execute()
            
        // Track badge achievement in UserDefaults if earned
        if isEarned {
            UserDefaults.standard.addEarnedBadge(badgeId)
        }
        
        // Show badge achievement popup if a badge is newly earned
        if isEarned && showPopup {
            // Get updated user data to refresh badge status
            _ = try await getUser(byId: userId)
            
            // Get the earned badge
            if let badge = getUserBadgesData().first(where: { $0.id == badgeId }) {
                // Show achievement popup on the main thread
                DispatchQueue.main.async {
                    // Find the top-most view controller
                    if let topVC = UIApplication.shared.getTopViewController() {
                        BadgeAchievementManager.shared.showBadgeAchievement(for: badge, in: topVC)
                    }
                }
            }
        }
    }
    
    func getEarnedBadgesData() -> [Badge]? {
        // First check if we have earned badges in the current user data
        if let earnedBadges = currentUser?.userEarnedBadges, !earnedBadges.isEmpty {
            return earnedBadges
        }
        
        // If there are no earned badges in currentUser or if currentUser is nil,
        // construct badges from UserDefaults persistence
        let earnedBadgeIDs = UserDefaults.standard.earnedBadgeIDs
        if !earnedBadgeIDs.isEmpty {
            var persistedBadges: [Badge] = []
            
            // Get all available badges
            let allBadges = getBadgesData()
            
            // Create Badge objects for each ID stored in UserDefaults
            for idString in earnedBadgeIDs {
                if let id = UUID(uuidString: idString),
                   let appBadge = allBadges.first(where: { $0.id == id }) {
                    let badge = Badge(
                        id: appBadge.id,
                        badgeTitle: appBadge.badgeTitle,
                        isEarned: true
                    )
                    persistedBadges.append(badge)
                }
            }
            
            return persistedBadges
        }
        
        return nil
    }
    
    // MARK: - App Content
    
    func getLevelsData() -> [AppLevel] {
        return sampleData.getLevelsData()
    }
    
    func getBadgesData() -> [AppBadge] {
        return sampleData.getBadgesData()
    }
    
    func getUserBadgesData() -> [Badge] {
        // First try to get badges from current user data
        if let userBadges = currentUser?.userBadges, !userBadges.isEmpty {
            return userBadges
        }
        
        // If no badges in currentUser or if currentUser is nil,
        // construct badges from UserDefaults persistence and all available badges
        let earnedBadgeIDs = UserDefaults.standard.earnedBadgeIDs
        let allBadges = getBadgesData()
        var persistedBadges: [Badge] = []
        
        // Create Badge objects for all available badges, marking earned ones
        for appBadge in allBadges {
            let isEarned = earnedBadgeIDs.contains(appBadge.id.uuidString)
            let badge = Badge(
                id: appBadge.id,
                badgeTitle: appBadge.badgeTitle,
                isEarned: isEarned
            )
            persistedBadges.append(badge)
        }
        
        return persistedBadges
    }
    
    func getCardsData() -> [AppCard] {
        return sampleData.getCardsData()
    }
    
    func getLevelCards() -> [LevelCard] {
        return sampleData.getLevelCards()
    }
    
    func getExercisesData() -> [String: Exercise] {
        return sampleData.getExercisesData()
    }
    
    // Add method to get all levels
    func getAllLevels() -> [Level] {
        guard let currentUser = currentUser else { return [] }
        return currentUser.userLevels
    }
    
    // Add method to get level data by index
    func levelData(at index: Int) -> AppLevel {
        let levels = sampleData.getLevelsData()
        guard index >= 0 && index < levels.count else {
            // Return first level as fallback if index is out of bounds
            return levels[0]
        }
        return levels[index]
    }
    
    // Add method to get word data by ID
    func wordData(by id: UUID) -> AppWord? {
        print("DEBUG: Looking up word with ID: \(id)")
        
        // Print current word ID mappings
        WordIDManager.shared.printCurrentMappings()
        
        let levels = sampleData.getLevelsData()
        for level in levels {
            if let word = level.words.first(where: { $0.id == id }) {
                print("DEBUG: Found word '\(word.wordTitle)' for ID: \(id)")
                return word
            }
        }
        print("DEBUG: No word found for ID: \(id)")
        return nil
    }
    
    // MARK: - Helper Methods
    
    private func constructUserLevels(
        from wordsResponse: [UserWordRecord],
        records: [UserWordRecord]
    ) -> [Level] {
        print("DEBUG: Constructing user levels from \(wordsResponse.count) word records")
        print("DEBUG: Word records in database:")
        for record in wordsResponse where record.is_practiced {
            print("  - Word ID: \(record.word_id) (Practiced: \(record.is_practiced), Attempts: \(record.attempts))")
        }
        
        let appLevels = sampleData.getLevelsData()
        var userLevels: [Level] = []
        var foundPracticedWords = 0
        
        // Group words by their level
        for appLevel in appLevels {
            var levelWords: [Word] = []
            
            // Create Word objects for each word in the level
            for appWord in appLevel.words {
                // Find user's progress for this word
                if let record = wordsResponse.first(where: { $0.word_id == appWord.id }) {
                    print("DEBUG: Found record for word \(appWord.wordTitle):")
                    print("  - Word ID: \(record.word_id)")
                    print("  - Attempts: \(record.attempts)")
                    print("  - Accuracy: \(record.accuracy ?? [])")
                    print("  - Is practiced: \(record.is_practiced)")
                    
                    if record.is_practiced {
                        foundPracticedWords += 1
                    }
                    
                    // Create Record if exists
                    let wordRecord = Record(
                        id: record.id,
                        attempts: record.attempts,
                        accuracy: record.accuracy,
                        recording: record.recordings
                    )
                    
                    // Create Word with user's progress
                    let word = Word(
                        id: appWord.id,
                        record: wordRecord,
                        isPracticed: record.is_practiced
                    )
                    levelWords.append(word)
                } else {
                    print("DEBUG: No record found for word \(appWord.wordTitle)")
                    // Create Word with no progress
                    let word = Word(
                        id: appWord.id,
                        record: nil,
                        isPracticed: false
                    )
                    levelWords.append(word)
                }
            }
            
            // Create Level with its words
            let level = Level(
                id: appLevel.id,
                words: levelWords
            )
            
            userLevels.append(level)
        }
        
        // Print summary of practiced words
        let allWords = userLevels.flatMap { $0.words }
        let practicedWords = allWords.filter { $0.isPracticed }
        print("DEBUG: Found \(practicedWords.count) practiced words out of \(allWords.count) total words")
        print("DEBUG: Database shows \(foundPracticedWords) practiced words")
        
        if practicedWords.count != foundPracticedWords {
            print("DEBUG: WARNING - Mismatch between database practiced words (\(foundPracticedWords)) and constructed practiced words (\(practicedWords.count))")
        }
        
        for word in practicedWords {
            if let appWord = wordData(by: word.id) {
                print("DEBUG: Practiced word: \(appWord.wordTitle)")
                print("  - Attempts: \(word.record?.attempts ?? 0)")
                print("  - Accuracy: \(word.record?.accuracy ?? [])")
            }
        }
        
        return userLevels
    }
    
    private func constructUserBadges(
        from badgesResponse: [UserBadge]
    ) -> [Badge] {
        let appBadges = sampleData.getBadgesData()
        var userBadges: [Badge] = []
        
        // Create Badge objects with user's earned status
        for appBadge in appBadges {
            let userBadge = badgesResponse.first { $0.badge_id == appBadge.id }
            
            let badge = Badge(
                id: appBadge.id,
                badgeTitle: appBadge.badgeTitle,
                isEarned: userBadge?.is_earned ?? false
            )
            
            userBadges.append(badge)
        }
        
        return userBadges
    }
    
    // MARK: - Database Models
    
    public struct User: Codable {
        public let id: UUID
        public let name: String
        public let phone_number: String
        public let password: String
        public let passcode: String?
        public let child_name: String?
        
        public init(name: String, phone_number: String, password: String) {
            self.id = UUID()
            self.name = name
            self.phone_number = phone_number
            self.password = password
            self.passcode = nil
            self.child_name = nil
        }
    }
    
    private struct UserWordRecord: Codable {
        let id: UUID
        let user_id: UUID
        let word_id: UUID      // References local word
        let is_practiced: Bool
        let attempts: Int
        let accuracy: [Double]?
        let recordings: [String]?
        
        // Add computed property for average accuracy
        var avgAccuracy: Double {
            guard let accuracies = accuracy,
                  !accuracies.isEmpty else {
                return 0.0
            }
            
            // Cap individual accuracies at 100%
            let cappedAccuracies = accuracies.map { min(100.0, max(0.0, $0)) }
            let total = cappedAccuracies.reduce(0.0, +)
            let average = total / Double(accuracies.count)
            
            return (average * 10).rounded() / 10
        }
        
        // Add computed property to check if word is passed
        var isPassed: Bool {
            guard let accuracies = accuracy else { return false }
            return accuracies.contains(where: { $0 > 70 })
        }
        
        init(
            user_id: UUID,
            word_id: UUID,
            is_practiced: Bool,
            attempts: Int = 0,
            accuracy: [Double]? = nil,
            recordings: [String]? = nil
        ) {
            self.id = UUID()
            self.user_id = user_id
            self.word_id = word_id
            self.is_practiced = is_practiced
            self.attempts = attempts
            self.accuracy = accuracy
            self.recordings = recordings
        }
    }
    
    private struct UserBadge: Codable {
        let id: UUID
        let user_id: UUID
        let badge_id: UUID
        let is_earned: Bool
        let earned_at: Date?
        
        init(user_id: UUID, badge_id: UUID, is_earned: Bool, earned_at: Date? = nil) {
            self.id = UUID()
            self.user_id = user_id
            self.badge_id = badge_id
            self.is_earned = is_earned
            self.earned_at = earned_at
        }
    }
    
    // Add this new method
    public func getAllUsers() async throws -> [User] {
        do {
            let response: [User] = try await supabase
                .from("users")
                .select()
                .execute()
                .value
            return response
        } catch {
            throw SupabaseError.databaseError(error)
        }
    }
    
    // Update passcode method to use ID
    public func updatePasscode(passcode: String) async throws {
        guard let userId = currentUserId else {
            throw SupabaseError.userNotLoggedIn
        }
        
        do {
            try await supabase
                .from("users")
                .update(["passcode": passcode])
                .eq("id", value: userId)
                .execute()
            
            // Save passcode to UserDefaults
            UserDefaults.standard.parentModePasscode = passcode
        } catch {
            throw SupabaseError.databaseError(error)
        }
    }
    
    // Add method to restore session
    public func restoreSession(userId: UUID) {
        self.currentUserId = userId
        
        // Try to get the phone number from UserDefaults if needed
        // This is optional since we mainly use the userId now
        if let phone = UserDefaults.standard.string(forKey: "lastPhoneNumber") {
            self.currentPhoneNumber = phone
        }
        
        self.isFirstTimeUser = false
    }
    
    // Update sign out method to clear UserDefaults
    public func signOut() {
        UserDefaults.standard.clearSession()
        currentUserId = nil
        currentPhoneNumber = nil
        currentUser = nil
        isFirstTimeUser = false
    }
    
    // Add method to update child's name
    public func updateChildName(userId: UUID, childName: String) async throws {
        print("DEBUG: Starting child name update for user \(userId)")
        print("DEBUG: New child name: \(childName)")
        
        do {
            let response = try await supabase
                .from("users")
                .update(["child_name": childName])
                .eq("id", value: userId)
                .execute()
            
            print("DEBUG: Update response received")
            print("DEBUG: Response: \(response)")
            
            // Verify the update was successful
            let updatedUser: User = try await supabase
                .from("users")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            
            print("DEBUG: Verification - Updated user data:")
            print("DEBUG: User ID: \(updatedUser.id)")
            print("DEBUG: Child name: \(String(describing: updatedUser.child_name))")
            
            if updatedUser.child_name == nil {
                print("DEBUG: WARNING - Child name is still nil after update")
            }
        } catch {
            print("DEBUG: Error in updateChildName: \(error)")
            throw SupabaseError.databaseError(error)
        }
    }
    
    private func initializeUserDataWithBadgeAchievement(userId: UUID) async {
        do {
            // Initialize user data
            try await initializeUserData(userId: userId)
            
            // Get all badges to find the NewLeo badge
            let badges = sampleData.getBadgesData()
            if let newLeoBadge = badges.first(where: { $0.badgeTitle == "NewLeo" }) {
                // Get the current user data to get the Badge object
                let userData = try await getUser(byId: userId)
                
                // Track the badge as earned in UserDefaults
                UserDefaults.standard.addEarnedBadge(newLeoBadge.id)
                
                // Note: Badge achievement popup is now handled in HomePageViewController
                // via the shouldShowOnboardingBadgeAchievement UserDefaults flag
            }
        } catch {
            print("DEBUG: Error initializing user data with badge achievement: \(error)")
        }
    }
}

// MARK: - Error Types

public enum SupabaseError: LocalizedError {
    case userNotFound
    case invalidCredentials
    case networkError(Error)
    case databaseError(Error)
    case unauthorized
    case invalidData
    case userNotLoggedIn
    
    public var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found"
        case .invalidCredentials:
            return "Invalid phone number or password"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .databaseError(let error):
            return "Database error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized access"
        case .invalidData:
            return "Invalid data received from server"
        case .userNotLoggedIn:
            return "No user is currently logged in"
        }
    }
}
