import Foundation
import Supabase

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
            
            // Store both user ID and phone number on successful sign up
            self.currentUserId = response.id
            self.currentPhoneNumber = phoneNumber
            self.isFirstTimeUser = true
            try await initializeUserData(userId: response.id)
            return try await getUser(byId: response.id)
        } catch {
            throw SupabaseError.databaseError(error)
        }
    }
    
    private func initializeUserData(userId: UUID) async throws {
        
        // Check for existing word records
        let existingRecords: [UserWordRecord] = try await supabase
            .from("user_word_records")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        
        // Print word ID mappings before initialization
        WordIDManager.shared.printCurrentMappings()
        
        if existingRecords.isEmpty {
            let badges = sampleData.getBadgesData()
            for badge in badges {
                let badgeData = UserBadge(
                    user_id: userId,
                    badge_id: badge.id,
                    is_earned: false
                )
                try await supabase
                    .from("user_badges")
                    .insert(badgeData)
                    .execute()
            }
            
            let levels = sampleData.getLevelsData()
            for level in levels {
                for word in level.words {
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
            
            
            if let existingRecord = existingRecords.first {
                
                var newAccuracy = existingRecord.accuracy ?? []
                if let accuracy = accuracy {
                    newAccuracy.append(accuracy)
                }
                
                var newRecordings = existingRecord.recordings ?? []
                if let recordingPath = recordingPath {
                    // Upload the recording and get the stored filename
                    if let storedFilename = try await uploadRecording(at: recordingPath, wordId: wordId) {
                        newRecordings.append(storedFilename)
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
                
                try await supabase
                    .from("user_word_records")
                    .update(updatedRecord)
                    .eq("id", value: existingRecord.id)
                    .execute()
                
                // Refresh current user data to ensure we have the latest records
                currentUser = try await getUser(byId: userId)
            } else {
                var newRecordings: [String]? = nil
                if let recordingPath = recordingPath {
                    // Upload the recording and get the stored filename
                    if let storedFilename = try await uploadRecording(at: recordingPath, wordId: wordId) {
                        newRecordings = [storedFilename]
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
            
            // Copy the file from the temporary location to our app's storage
            if FileManager.default.fileExists(atPath: destinationPath.path) {
                try FileManager.default.removeItem(at: destinationPath)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destinationPath)
            
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
    
    func updateBadgeStatus(badgeId: UUID, isEarned: Bool) async throws {
        guard let userId = currentUser?.id else {
            throw SupabaseError.userNotLoggedIn
        }
        
        let badgeUpdate = UserBadge(
            user_id: userId,
            badge_id: badgeId,
            is_earned: isEarned
        )
        
        try await supabase
            .from("user_badges")
            .update(badgeUpdate)
            .eq("user_id", value: userId)
            .eq("badge_id", value: badgeId)
            .execute()
    }
    
    // MARK: - App Content
    
    func getLevelsData() -> [AppLevel] {
        return sampleData.getLevelsData()
    }
    
    func getBadgesData() -> [AppBadge] {
        return sampleData.getBadgesData()
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
        
        // Print current word ID mappings
        WordIDManager.shared.printCurrentMappings()
        
        let levels = sampleData.getLevelsData()
        for level in levels {
            if let word = level.words.first(where: { $0.id == id }) {
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
        
        public init(name: String, phone_number: String, password: String) {
            self.id = UUID()
            self.name = name
            self.phone_number = phone_number
            self.password = password
            self.passcode = nil
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
        
        init(user_id: UUID, badge_id: UUID, is_earned: Bool) {
            self.id = UUID()
            self.user_id = user_id
            self.badge_id = badge_id
            self.is_earned = is_earned
            self.earned_at = nil
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
    public func updateChildName(_ childName: String) async throws {
        guard let userId = currentUserId else {
            throw SupabaseError.userNotLoggedIn
        }
        
        do {
            try await supabase
                .from("users")
                .update(["child_name": childName])
                .eq("id", value: userId)
                .execute()
        } catch {
            throw SupabaseError.databaseError(error)
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
