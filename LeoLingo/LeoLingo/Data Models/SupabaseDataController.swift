import Foundation
import Supabase

class SupabaseDataController {
    static let shared = SupabaseDataController()
    
    private let supabase: SupabaseClient
    private let sampleData = SampleDataController.shared
    private var currentUser: UserData?
    
    // Add property to store current phone number
    private var currentPhoneNumber: String?
    
    // Add public getter for phone number
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
            
            // Store phone number on successful sign up
            self.currentPhoneNumber = phoneNumber
            try await initializeUserData(userId: response.id)
            return try await getUser(byPhone: phoneNumber)
        } catch {
            throw SupabaseError.databaseError(error)
        }
    }
    
    private func initializeUserData(userId: UUID) async throws {
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
                let wordData = UserWord(
                    user_id: userId,
                    word_id: word.id,
                    is_practiced: false
                )
                try await supabase
                    .from("user_words")
                    .insert(wordData)
                    .execute()
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
            
            guard !response.isEmpty else {
                throw SupabaseError.invalidCredentials
            }
            
            // Store phone number on successful sign in
            self.currentPhoneNumber = phoneNumber
            return try await getUser(byPhone: phoneNumber)
        } catch {
            throw SupabaseError.networkError(error)
        }
    }
    
    func getUser(byPhone phoneNumber: String) async throws -> UserData {
        let user: User = try await supabase
            .from("users")
            .select()
            .eq("phone_number", value: phoneNumber)
            .single()
            .execute()
            .value
        
        let wordsResponse: [UserWord] = try await supabase
            .from("user_words")
            .select()
            .eq("user_id", value: user.id)
            .execute()
            .value
        
        let recordsResponse: [WordRecord] = try await supabase
            .from("word_records")
            .select()
            .eq("user_id", value: user.id)
            .execute()
            .value
        
        let badgesResponse: [UserBadge] = try await supabase
            .from("user_badges")
            .select()
            .eq("user_id", value: user.id)
            .execute()
            .value
        
        let userLevels = constructUserLevels(
            from: wordsResponse,
            records: recordsResponse
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
    
    // MARK: - Word Progress and Recordings
    
    func updateWordProgress(wordId: UUID, accuracy: Double?, recordingPath: String? = nil) async throws {
        guard let userId = currentUser?.id else {
            throw SupabaseError.userNotLoggedIn
        }
        
        do {
            // Update word practice status
            let wordUpdate = UserWord(
                user_id: userId,
                word_id: wordId,
                is_practiced: true
            )
            
            try await supabase
                .from("user_words")
                .update(wordUpdate)
                .eq("user_id", value: userId)
                .eq("word_id", value: wordId)
                .execute()
            
            // Check for existing record
            let existingRecords: [WordRecord] = try await supabase
                .from("word_records")
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
                
                var newRecordings = existingRecord.recording ?? []
                if let recordingPath = recordingPath {
                    // Upload the recording to Supabase Storage
                    if let recordingUrl = try await uploadRecording(at: recordingPath, wordId: wordId) {
                        newRecordings.append(recordingUrl)
                    }
                }
                
                let updatedRecord = WordRecord(
                    id: existingRecord.id,
                    user_id: userId,
                    word_id: wordId,
                    attempts: existingRecord.attempts + 1,
                    accuracy: newAccuracy,
                    recording: newRecordings
                )
                
                try await supabase
                    .from("word_records")
                    .update(updatedRecord)
                    .eq("id", value: existingRecord.id)
                    .execute()
            } else {
                var recordingUrls: [String]? = nil
                if let recordingPath = recordingPath {
                    // Upload the recording to Supabase Storage
                    if let recordingUrl = try await uploadRecording(at: recordingPath, wordId: wordId) {
                        recordingUrls = [recordingUrl]
                    }
                }
                
                let newRecord = WordRecord(
                    id: UUID(),
                    user_id: userId,
                    word_id: wordId,
                    attempts: 1,
                    accuracy: accuracy.map { [$0] },
                    recording: recordingUrls
                )
                
                try await supabase
                    .from("word_records")
                    .insert(newRecord)
                    .execute()
            }
        } catch {
            throw SupabaseError.databaseError(error)
        }
    }
    
    private func uploadRecording(at path: String, wordId: UUID) async throws -> String? {
        guard let userId = currentUser?.id else {
            throw SupabaseError.userNotLoggedIn
        }
        
        do {
            let fileUrl = URL(fileURLWithPath: path)
            let fileName = "\(userId)/\(wordId)/\(Date().timeIntervalSince1970).m4a"
            
            // Upload file to Supabase Storage
            let result = try await supabase.storage
                .from("recordings")
                .upload(
                    path: fileName,
                    file: fileUrl,
                    options: FileOptions(contentType: "audio/m4a")
                )
            
            // Get public URL for the uploaded file
            let publicUrl = try await supabase.storage
                .from("recordings")
                .createSignedURL(
                    path: fileName,
                    expiresIn: 365 * 24 * 60 * 60 // 1 year in seconds
                )
            
            return publicUrl
        } catch {
            print("Error uploading recording: \(error)")
            return nil
        }
    }
    
    func getRecordings(for wordId: UUID) async throws -> [String] {
        guard let userId = currentUser?.id else {
            throw SupabaseError.userNotLoggedIn
        }
        
        let records: [WordRecord] = try await supabase
            .from("word_records")
            .select()
            .eq("user_id", value: userId)
            .eq("word_id", value: wordId)
            .execute()
            .value
        
        return records.first?.recording ?? []
    }
    
    func deleteRecording(url: String, for wordId: UUID) async throws {
        guard let userId = currentUser?.id else {
            throw SupabaseError.userNotLoggedIn
        }
        
        // Get current record
        let records: [WordRecord] = try await supabase
            .from("word_records")
            .select()
            .eq("user_id", value: userId)
            .eq("word_id", value: wordId)
            .execute()
            .value
        
        guard let record = records.first,
              var recordings = record.recording else {
            throw SupabaseError.invalidData
        }
        
        // Remove the URL from the recordings array
        recordings.removeAll { $0 == url }
        
        // Update the record
        let updatedRecord = WordRecord(
            id: record.id,
            user_id: userId,
            word_id: wordId,
            attempts: record.attempts,
            accuracy: record.accuracy,
            recording: recordings
        )
        
        try await supabase
            .from("word_records")
            .update(updatedRecord)
            .eq("id", value: record.id)
            .execute()
        
        // Delete from storage if it's a Supabase storage URL
        if let path = extractStoragePath(from: url) {
            try await supabase.storage
                .from("recordings")
                .remove(paths: [path])
        }
    }
    
    private func extractStoragePath(from url: String) -> String? {
        // Extract the path from the Supabase storage URL
        // This will need to be adjusted based on your actual URL format
        guard let components = URLComponents(string: url),
              components.host?.contains("supabase") == true,
              let path = components.path.components(separatedBy: "recordings/").last else {
            return nil
        }
        return path
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
    
    // MARK: - Helper Methods
    
    private func constructUserLevels(
        from wordsResponse: [UserWord],
        records: [WordRecord]
    ) -> [Level] {
        let appLevels = sampleData.getLevelsData()
        var userLevels: [Level] = []
        
        // Group words by their level
        for appLevel in appLevels {
            var levelWords: [Word] = []
            
            // Create Word objects for each word in the level
            for appWord in appLevel.words {
                // Find user's progress for this word
                let userWord = wordsResponse.first { $0.word_id == appWord.id }
                let wordRecord = records.first { $0.word_id == appWord.id }
                
                // Create Record if exists
                let record: Record? = wordRecord.map { response in
                    Record(
                        id: response.id,
                        attempts: response.attempts,
                        accuracy: response.accuracy,
                        recording: response.recording
                    )
                }
                
                // Create Word with user's progress
                let word = Word(
                    id: appWord.id,
                    record: record,
                    isPracticed: userWord?.is_practiced ?? false
                )
                
                levelWords.append(word)
            }
            
            // Create Level with its words
            let level = Level(
                id: appLevel.id,
                words: levelWords
            )
            
            userLevels.append(level)
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
    
    private struct UserWord: Codable {
        let id: UUID
        let user_id: UUID
        let word_id: UUID
        let is_practiced: Bool
        
        init(user_id: UUID, word_id: UUID, is_practiced: Bool) {
            self.id = UUID()
            self.user_id = user_id
            self.word_id = word_id
            self.is_practiced = is_practiced
        }
    }
    
    private struct WordRecord: Codable {
        let id: UUID
        let user_id: UUID
        let word_id: UUID
        let attempts: Int
        let accuracy: [Double]?
        let recording: [String]?
        
        init(
            id: UUID,
            user_id: UUID,
            word_id: UUID,
            attempts: Int,
            accuracy: [Double]?,
            recording: [String]?
        ) {
            self.id = id
            self.user_id = user_id
            self.word_id = word_id
            self.attempts = attempts
            self.accuracy = accuracy
            self.recording = recording
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
    
    // Add new method to update passcode
    public func updatePasscode(passcode: String) async throws {
        guard let phoneNumber = currentPhoneNumber else {
            throw SupabaseError.userNotLoggedIn
        }
        
        do {
            try await supabase
                .from("users")
                .update(["passcode": passcode])
                .eq("phone_number", value: phoneNumber)
                .execute()
        } catch {
            throw SupabaseError.databaseError(error)
        }
    }
    
    // Add sign out method
    public func signOut() {
        currentPhoneNumber = nil
        currentUser = nil
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
