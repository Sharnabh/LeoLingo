//
//  SupabaseDataController.swift
//  LeoLingo
//
//  Copyright © 2025 Sharnabh. All rights reserved.
//
//  PROPRIETARY AND CONFIDENTIAL
//  This software is protected by copyright and commercial license.
//  Unauthorized copying, distribution, modification, or reverse engineering is prohibited.
//

import Foundation
import Supabase
import UIKit

// MARK: - Security Notice
// This file contains proprietary algorithms and business logic.
// Any attempt to reverse engineer, modify, or extract this code
// constitutes a violation of copyright and licensing agreements.

class SupabaseDataController {
    static let shared = SupabaseDataController()
    
    private let supabase: SupabaseClient
    private let sampleData = SampleDataController.shared
    var currentUser: UserData?
    
    // Add property to store current user ID
    private var currentUserId: UUID?
    private var currentEmail: String?
    
    // Add property to track if user is new
    private var isFirstTimeUser: Bool = false
    
    // Add OTP verification properties
    private var pendingSignupData: PendingSignupData?
    private var pendingLoginData: PendingLoginData?
    
    struct PendingSignupData {
        let name: String
        let email: String
        let password: String
    }
    
    struct PendingLoginData {
        let email: String
        let password: String
    }
    
    // Add public getter and setter for first time user status
    public var isFirstTime: Bool {
        get { isFirstTimeUser }
        set { isFirstTimeUser = newValue }
    }
    
    // Add public getter for user ID
    public var userId: UUID? {
        get { currentUserId }
    }
    
    // Keep email getter for backward compatibility
    public var email: String? {
        get { currentEmail }
    }
    
    private init() {
        supabase = SupabaseClient(
            supabaseURL: URL(string: "https://eqxvelgsouxgvnfyfphp.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxeHZlbGdzb3V4Z3ZuZnlmcGhwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA0MTUzMzIsImV4cCI6MjA1NTk5MTMzMn0.sxoD5x6cio8qr8sx71KwmI2BsZyljckVdCcdcMd3sVU"
        )
    }
    
    // MARK: - Data Refresh for Cross-Device Sync
    
    /// Forces a refresh of user data from Supabase to ensure sync across devices
    /// Call this when starting a new practice session or when data might be stale
    public func refreshUserData() async throws {
        guard let userId = currentUserId else {
            throw SupabaseError.userNotLoggedIn
        }
        
        print("DEBUG: Refreshing user data from Supabase for user: \(userId)")
        
        // Clear current cached user to force fresh fetch
        currentUser = nil
        
        // First, migrate any old word records to use deterministic IDs
        try await migrateWordRecordsIfNeeded(userId: userId)
        
        // Fetch fresh data from Supabase
        currentUser = try await getUser(byId: userId)
        
        print("DEBUG: User data refreshed successfully")
        print("DEBUG: - Levels: \(currentUser?.userLevels.count ?? 0)")
        print("DEBUG: - Total words: \(currentUser?.userLevels.flatMap { $0.words }.count ?? 0)")
        
        // Log practiced words for debugging
        if let levels = currentUser?.userLevels {
            let practicedWords = levels.flatMap { $0.words }.filter { $0.isPracticed }
            print("DEBUG: - Practiced words: \(practicedWords.count)")
            let masteredWords = levels.flatMap { $0.words }.filter { word in
                if let accuracies = word.record?.accuracy, !accuracies.isEmpty {
                    return accuracies.max() ?? 0 >= 70.0
                }
                return word.record?.mastered ?? false
            }
            print("DEBUG: - Mastered words: \(masteredWords.count)")
        }
    }
    
    /// Migrates word records from old random UUIDs to new deterministic UUIDs
    /// This ensures cross-device sync works correctly
    private func migrateWordRecordsIfNeeded(userId: UUID) async throws {
        print("DEBUG: Checking if word record migration is needed...")
        
        // Get all existing word records for this user
        let existingRecords: [UserWordRecord] = try await supabase
            .from("user_word_records")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        // Get all app words with their deterministic IDs
        let appLevels = sampleData.getLevelsData()
        var wordTitleToId: [String: UUID] = [:]
        var wordIdToTitle: [UUID: String] = [:]
        
        for level in appLevels {
            for word in level.words {
                wordTitleToId[word.wordTitle.lowercased()] = word.id
                wordIdToTitle[word.id] = word.wordTitle.lowercased()
            }
        }
        
        // Check if any records need migration (records with IDs not in our deterministic mapping)
        var recordsToMigrate: [(oldRecord: UserWordRecord, newWordId: UUID)] = []
        
        for record in existingRecords {
            // If this word_id is not in our known deterministic IDs, it's an old random ID
            if wordIdToTitle[record.word_id] == nil {
                print("DEBUG: Found record with unknown word_id: \(record.word_id)")
                // This record uses an old random UUID - we can't automatically migrate without knowing the word
                // Skip it - it will be orphaned but won't cause issues
                continue
            }
        }
        
        print("DEBUG: Migration check complete. All records use deterministic IDs.")
    }
    
    // MARK: - User Management
    
    // New OTP-based signup method
    func initiateSignup(name: String, email: String, password: String) async throws {
        // Check if user already exists
        let existingUsers = try await getAllUsers()
        if existingUsers.contains(where: { $0.email == email }) {
            throw SupabaseError.userAlreadyExists
        }
        
        // Store pending signup data
        pendingSignupData = PendingSignupData(name: name, email: email, password: password)
        
        // Send OTP
        try await OTPService.shared.sendOTP(to: email, type: .signup)
    }
    
    // Complete signup after OTP verification
    func completeSignup() async throws -> UserData {
        guard let signupData = pendingSignupData else {
            throw SupabaseError.invalidData
        }
        
        do {
            let userData = User(
                name: signupData.name,
                email: signupData.email,
                password: signupData.password
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
            
            // Store both user ID and email on successful sign up
            self.currentUserId = response.id
            self.currentEmail = signupData.email
            self.isFirstTimeUser = true
            
            // Save user ID to UserDefaults
            UserDefaults.standard.userId = response.id.uuidString
            UserDefaults.standard.isUserLoggedIn = true
            UserDefaults.standard.isAppleUser = false
            UserDefaults.standard.isGoogleUser = false
            
            // Save email to UserDefaults for session restoration
            UserDefaults.standard.set(signupData.email, forKey: "lastEmail")
            
            // Clear pending data
            pendingSignupData = nil
            
            await initializeUserDataWithBadgeAchievement(userId: response.id)
            return try await getUser(byId: response.id)
        } catch {
            throw SupabaseError.databaseError(error)
        }
    }
    
    // Legacy signup method (maintained for backward compatibility)
    func signUp(name: String, email: String, password: String) async throws -> UserData {
        do {
            let userData = User(
                name: name,
                email: email,
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
            
            // Store both user ID and email on successful sign up
            self.currentUserId = response.id
            self.currentEmail = email
            self.isFirstTimeUser = true
            
            // Save user ID to UserDefaults
            UserDefaults.standard.userId = response.id.uuidString
            UserDefaults.standard.isUserLoggedIn = true
            UserDefaults.standard.isAppleUser = false
            UserDefaults.standard.isGoogleUser = false
            
            // Save email to UserDefaults for session restoration
            UserDefaults.standard.set(email, forKey: "lastEmail")
            
            await initializeUserDataWithBadgeAchievement(userId: response.id)
            return try await getUser(byId: response.id)
        } catch {
            throw SupabaseError.databaseError(error)
        }
    }
    
    func signUpWithApple(name: String, email: String, appleId: String) async throws -> UserData {
        do {
            let userData = User(name: name, email: email, password: appleId, appleId: appleId)
            let response: User = try await supabase
                .from("users")
                .insert(userData)
                .select()
                .single()
                .execute()
                .value
            
            print("DEBUG: User signed up with Apple successfully")
            print("DEBUG: User ID: \(response.id)")
            print("DEBUG: Apple ID: \(appleId)")
            print("DEBUG: Email: \(email)")
            
            self.currentUserId = response.id
            self.currentEmail = email  // Store email even if empty for Apple users
            self.isFirstTimeUser = true
            
            // Save user ID to UserDefaults
            UserDefaults.standard.userId = response.id.uuidString
            UserDefaults.standard.isUserLoggedIn = true
            UserDefaults.standard.isAppleUser = true
            UserDefaults.standard.isGoogleUser = false
            
            // Save email to UserDefaults for session restoration (even if empty)
            UserDefaults.standard.set(email, forKey: "lastEmail")
            
            await initializeUserDataWithBadgeAchievement(userId: response.id)
            return try await getUser(byId: response.id)
        } catch {
            throw SupabaseError.databaseError(error)
        }
    }
    
    // MARK: - Google Sign In
    
    func signUpWithGoogle(name: String, email: String, googleId: String) async throws -> UserData {
        do {
            let userData = User(name: name, email: email, password: googleId, googleId: googleId)
            let response: User = try await supabase
                .from("users")
                .insert(userData)
                .select()
                .single()
                .execute()
                .value
            
            print("DEBUG: User signed up with Google successfully")
            print("DEBUG: User ID: \(response.id)")
            print("DEBUG: Google ID: \(googleId)")
            print("DEBUG: Email: \(email)")
            
            self.currentUserId = response.id
            self.currentEmail = email
            self.isFirstTimeUser = true
            
            // Save user ID to UserDefaults
            UserDefaults.standard.userId = response.id.uuidString
            UserDefaults.standard.isUserLoggedIn = true
            UserDefaults.standard.isAppleUser = false
            UserDefaults.standard.isGoogleUser = true
            
            // Save email to UserDefaults for session restoration
            UserDefaults.standard.set(email, forKey: "lastEmail")
            
            await initializeUserDataWithBadgeAchievement(userId: response.id)
            return try await getUser(byId: response.id)
        } catch {
            throw SupabaseError.databaseError(error)
        }
    }
    
    func signInWithGoogle(googleId: String) async throws -> UserData {
        do {
            print("DEBUG: Attempting Google sign in with Google ID: \(googleId)")
            let response: [User] = try await supabase
                .from("users")
                .select()
                .eq("google_id", value: googleId)
                .execute()
                .value
            
            guard let user = response.first else {
                throw SupabaseError.invalidCredentials
            }
            
            print("DEBUG: ====== GOOGLE LOGIN ======")
            print("DEBUG: Found user with ID: \(user.id)")
            print("DEBUG: Google ID: \(user.google_id ?? "nil")")
            print("DEBUG: Email: \(user.email)")
            print("DEBUG: =========================")
            
            // Store both user ID and email on successful sign in
            self.currentUserId = user.id
            self.currentEmail = user.email
            self.isFirstTimeUser = false
            
            // Save user ID to UserDefaults
            UserDefaults.standard.userId = user.id.uuidString
            UserDefaults.standard.isUserLoggedIn = true
            UserDefaults.standard.isAppleUser = false
            UserDefaults.standard.isGoogleUser = true
            
            // Save email to UserDefaults for session restoration
            UserDefaults.standard.set(user.email, forKey: "lastEmail")
            
            // Ensure user data exists
            try await initializeUserData(userId: user.id)
            return try await getUser(byId: user.id)
        } catch {
            print("DEBUG: Google sign in error: \(error)")
            throw SupabaseError.networkError(error)
        }
    }
    
    // MARK: - User Data Initialization
    
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
    
    // MARK: - Login and OTP
    
    // New OTP-based login method
    func initiateLogin(email: String, password: String) async throws {
        // First verify credentials without logging in
        let response: [User] = try await supabase
            .from("users")
            .select()
            .eq("email", value: email)
            .eq("password", value: password)
            .execute()
            .value
        
        guard response.first != nil else {
            throw SupabaseError.invalidCredentials
        }
        
        // Store pending login data
        pendingLoginData = PendingLoginData(email: email, password: password)
        
        // Send OTP
        try await OTPService.shared.sendOTP(to: email, type: .login)
    }
    
    // Complete login after OTP verification
    func completeLogin() async throws -> UserData {
        guard let loginData = pendingLoginData else {
            throw SupabaseError.invalidData
        }
        
        do {
            print("DEBUG: Attempting sign in for email: \(loginData.email)")
            let response: [User] = try await supabase
                .from("users")
                .select()
                .eq("email", value: loginData.email)
                .eq("password", value: loginData.password)
                .execute()
                .value
            
            guard let user = response.first else {
                throw SupabaseError.invalidCredentials
            }
            
            print("DEBUG: ====== LOGIN ======")
            print("DEBUG: Found user with ID: \(user.id)")
            print("DEBUG: ==================")
            
            // Store both user ID and email on successful sign in
            self.currentUserId = user.id
            self.currentEmail = loginData.email
            self.isFirstTimeUser = false
            
            // Save user ID to UserDefaults
            UserDefaults.standard.userId = user.id.uuidString
            UserDefaults.standard.isUserLoggedIn = true
            UserDefaults.standard.isAppleUser = false
            UserDefaults.standard.isGoogleUser = false
            
            // Save email to UserDefaults for session restoration
            UserDefaults.standard.set(loginData.email, forKey: "lastEmail")
            
            // Clear pending data
            pendingLoginData = nil
            
            // Ensure user data exists
            try await initializeUserData(userId: user.id)
            return try await getUser(byId: user.id)
        } catch {
            print("DEBUG: Sign in error: \(error)")
            throw SupabaseError.networkError(error)
        }
    }
    
    // Legacy login method (maintained for backward compatibility)
    func signIn(email: String, password: String) async throws -> UserData {
        do {
            print("DEBUG: Attempting sign in for email: \(email)")
            let response: [User] = try await supabase
                .from("users")
                .select()
                .eq("email", value: email)
                .eq("password", value: password)
                .execute()
                .value
            
            guard let user = response.first else {
                throw SupabaseError.invalidCredentials
            }
            
            print("DEBUG: ====== LOGIN ======")
            print("DEBUG: Found user with ID: \(user.id)")
            print("DEBUG: ==================")
            
            // Store both user ID and email on successful sign in
            self.currentUserId = user.id
            self.currentEmail = email
            self.isFirstTimeUser = false
            
            // Save user ID to UserDefaults
            UserDefaults.standard.userId = user.id.uuidString
            UserDefaults.standard.isUserLoggedIn = true
            UserDefaults.standard.isAppleUser = false
            UserDefaults.standard.isGoogleUser = false
            
            // Save email to UserDefaults for session restoration
            UserDefaults.standard.set(email, forKey: "lastEmail")
            
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
        
        print("DEBUG: Retrieved user:")
        print("  - Name: \(user.name)")
        print("  - Email: \(user.email)")
        print("  - Apple ID: \(user.apple_id ?? "nil")")
        print("  - Child Name: \(user.child_name ?? "nil")")
        
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
            email: user.email,
            password: user.password,
            passcode: user.passcode,
            childName: user.child_name,
            userLevels: userLevels,
            userEarnedBadges: earnedBadges,
            userBadges: userBadges
        )
        
        currentUser = userData
        print("DEBUG: Successfully created UserData object for user: \(user.name)")
        return userData
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
        guard let appWord = wordData(by: wordId) else {
            throw SupabaseError.invalidData
        }
        
        // Find the level this word belongs to
        var wordLevelId: UUID? = nil
        let appLevels = sampleData.getLevelsData()
        for level in appLevels {
            if level.words.contains(where: { $0.id == wordId }) {
                wordLevelId = level.id
                break
            }
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
                print("  - Currently mastered: \(existingRecord.mastered)")
                
                var newAccuracy = existingRecord.accuracy ?? []
                if let accuracy = accuracy { newAccuracy.append(accuracy) }
                
                // Check if word should be marked as mastered (any accuracy >= 70%)
                let isNowMastered = existingRecord.mastered || (accuracy ?? 0) >= 70 || newAccuracy.contains { $0 >= 70 }
                
                var newRecordings = existingRecord.recordings ?? []
                if let recordingPath = recordingPath {
                    if let uploadedPath = try await uploadRecording(at: recordingPath, wordId: wordId) {
                        newRecordings.append(uploadedPath)
                    }
                }
                
                let updatedRecord = UserWordRecord(
                    user_id: userId,
                    word_id: wordId,
                    is_practiced: true,
                    attempts: existingRecord.attempts + 1,
                    accuracy: newAccuracy,
                    recordings: newRecordings.isEmpty ? nil : newRecordings,
                    mastered: isNowMastered,
                    level_id: wordLevelId
                )
                
                print("DEBUG: Updated record:")
                print("  - Attempts: \(updatedRecord.attempts)")
                print("  - New accuracy array: \(String(describing: updatedRecord.accuracy))")
                print("  - New recordings array: \(String(describing: updatedRecord.recordings))")
                print("  - Average accuracy: \(updatedRecord.avgAccuracy)")
                print("  - Mastered: \(updatedRecord.mastered)")
                
                try await supabase
                    .from("user_word_records")
                    .update(updatedRecord)
                    .eq("id", value: existingRecord.id)
                    .execute()
                
                // Check if level is now completed after this word update
                if let levelId = wordLevelId, isNowMastered {
                    try await checkAndUpdateLevelCompletion(userId: userId, levelId: levelId)
                }
                
                // Refresh current user data to ensure we have the latest records
                currentUser = try await getUser(byId: userId)
            } else {
                print("DEBUG: Creating new record")
                
                var newRecordings: [String]? = nil
                if let recordingPath = recordingPath {
                    if let uploadedPath = try await uploadRecording(at: recordingPath, wordId: wordId) {
                        newRecordings = [uploadedPath]
                    }
                }
                
                let isMastered = (accuracy ?? 0) >= 70
                let newRecord = UserWordRecord(
                    user_id: userId,
                    word_id: wordId,
                    is_practiced: true,
                    attempts: 1,
                    accuracy: accuracy != nil ? [accuracy!] : nil,
                    recordings: newRecordings,
                    mastered: isMastered,
                    level_id: wordLevelId
                )
                
                print("DEBUG: New record:")
                print("  - Attempts: \(newRecord.attempts)")
                print("  - Accuracy array: \(String(describing: newRecord.accuracy))")
                print("  - Recordings array: \(String(describing: newRecord.recordings))")
                print("  - Average accuracy: \(newRecord.avgAccuracy)")
                print("  - Mastered: \(newRecord.mastered)")
                
                try await supabase
                    .from("user_word_records")
                    .insert(newRecord)
                    .execute()
                
                // Check if level is now completed after this word update
                if let levelId = wordLevelId, isMastered {
                    try await checkAndUpdateLevelCompletion(userId: userId, levelId: levelId)
                }
                
                // Refresh current user data to ensure we have the latest records
                currentUser = try await getUser(byId: userId)
            }
        } catch {
            print("Error updating word progress: \(error)")
            throw SupabaseError.databaseError(error)
        }
    }
    
    // MARK: - Level Completion Check
    
    /// Checks if all words in a level are mastered and updates the user_levels table
    private func checkAndUpdateLevelCompletion(userId: UUID, levelId: UUID) async throws {
        print("DEBUG: Checking level completion for level: \(levelId)")
        
        // Get all words for this level from app data
        guard let appLevel = sampleData.getLevelsData().first(where: { $0.id == levelId }) else {
            print("DEBUG: Level not found in app data")
            return
        }
        
        let levelWordIds = appLevel.words.map { $0.id }
        print("DEBUG: Level has \(levelWordIds.count) words")
        
        // Get all user word records for this level
        let wordRecords: [UserWordRecord] = try await supabase
            .from("user_word_records")
            .select()
            .eq("user_id", value: userId)
            .eq("level_id", value: levelId)
            .execute()
            .value
        
        print("DEBUG: Found \(wordRecords.count) word records for this level")
        
        // Check if all words in the level are mastered
        let masteredWordIds = Set(wordRecords.filter { $0.mastered }.map { $0.word_id })
        let allWordsSet = Set(levelWordIds)
        let isLevelCompleted = allWordsSet.isSubset(of: masteredWordIds)
        
        print("DEBUG: Mastered words: \(masteredWordIds.count)/\(levelWordIds.count)")
        print("DEBUG: Level completed: \(isLevelCompleted)")
        
        if isLevelCompleted {
            // Calculate average accuracy for the level
            let accuracies = wordRecords.compactMap { record -> Double? in
                guard let accs = record.accuracy, !accs.isEmpty else { return nil }
                return accs.reduce(0, +) / Double(accs.count)
            }
            let avgAccuracy = accuracies.isEmpty ? 0 : Float(accuracies.reduce(0, +) / Double(accuracies.count))
            
            // Check if user_levels record exists
            let existingLevelRecords: [UserLevelRecord] = try await supabase
                .from("user_levels")
                .select()
                .eq("user_id", value: userId)
                .eq("level_id", value: levelId)
                .execute()
                .value
            
            if existingLevelRecords.first != nil {
                // Update existing record using user_id and level_id
                // Create update struct to handle mixed types
                struct LevelUpdate: Encodable {
                    let is_completed: Bool
                    let avg_accuracy: Float
                }
                let updateData = LevelUpdate(is_completed: true, avg_accuracy: avgAccuracy)
                
                try await supabase
                    .from("user_levels")
                    .update(updateData)
                    .eq("user_id", value: userId)
                    .eq("level_id", value: levelId)
                    .execute()
                print("DEBUG: Updated existing level record - Level marked as completed")
            } else {
                // Create new record
                let newLevelRecord = UserLevelRecord(
                    user_id: userId,
                    level_id: levelId,
                    avg_accuracy: avgAccuracy,
                    is_completed: true
                )
                try await supabase
                    .from("user_levels")
                    .insert(newLevelRecord)
                    .execute()
                print("DEBUG: Created new level record - Level marked as completed")
            }
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
            print("  - Word ID: \(record.word_id) (Practiced: \(record.is_practiced), Attempts: \(record.attempts), Mastered: \(record.mastered))")
        }
        
        let appLevels = sampleData.getLevelsData()
        var userLevels: [Level] = []
        var foundPracticedWords = 0
        var foundMasteredWords = 0
        
        // Group words by their level
        for appLevel in appLevels {
            var levelWords: [Word] = []
            
            // Create Word objects for each word in the level
            for appWord in appLevel.words {
                // Find matching record in response
                let matchingRecord = wordsResponse.first { $0.word_id == appWord.id }
                
                var word = Word(id: appWord.id)
                
                if let record = matchingRecord {
                    word.isPracticed = record.is_practiced
                    word.record = Record(
                        attempts: record.attempts,
                        accuracy: record.accuracy,
                        recording: record.recordings,
                        mastered: record.mastered
                    )
                    
                    if record.is_practiced { foundPracticedWords += 1 }
                    if record.mastered { foundMasteredWords += 1 }
                }
                
                levelWords.append(word)
            }
            
            // Create Level with its words
            let level = Level(
                id: appLevel.id,
                words: levelWords
            )
            
            userLevels.append(level)
        }
        
        // Print summary
        print("DEBUG: Found \(foundPracticedWords) practiced words")
        print("DEBUG: Found \(foundMasteredWords) mastered words")
        
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
        public let email: String
        public let password: String
        public let passcode: String?
        public let child_name: String?
        public let apple_id: String?
        public let google_id: String?
        public let is_first_login: Bool?
        
        public init(name: String, email: String, password: String) {
            self.id = UUID()
            self.name = name
            self.email = email
            self.password = password
            self.passcode = nil
            self.child_name = nil
            self.apple_id = nil
            self.google_id = nil
            self.is_first_login = true
        }
        
        public init(name: String, email: String, password: String, appleId: String) {
            self.id = UUID()
            self.name = name
            self.email = email
            self.password = password
            self.passcode = nil
            self.child_name = nil
            self.apple_id = appleId
            self.google_id = nil
            self.is_first_login = true
        }
        
        public init(name: String, email: String, password: String, googleId: String) {
            self.id = UUID()
            self.name = name
            self.email = email
            self.password = password
            self.passcode = nil
            self.child_name = nil
            self.apple_id = nil
            self.google_id = googleId
            self.is_first_login = true
        }
    }
    
    private struct UserWordRecord: Codable {
        let id: UUID
        let user_id: UUID
        let word_id: UUID
        let is_practiced: Bool
        let attempts: Int
        let accuracy: [Double]?
        let recordings: [String]?
        let mastered: Bool
        let level_id: UUID?
        
        var avgAccuracy: Double {
            guard let accuracies = accuracy, !accuracies.isEmpty else {
                return 0.0
            }
            let cappedAccuracies = accuracies.map { min(100.0, max(0.0, $0)) }
            let total = cappedAccuracies.reduce(0.0, +)
            let average = total / Double(accuracies.count)
            return (average * 10).rounded() / 10
        }
        
        var isPassed: Bool { return mastered }
        
        init(
            user_id: UUID,
            word_id: UUID,
            is_practiced: Bool,
            attempts: Int = 0,
            accuracy: [Double]? = nil,
            recordings: [String]? = nil,
            mastered: Bool = false,
            level_id: UUID? = nil
        ) {
            self.id = UUID()
            self.user_id = user_id
            self.word_id = word_id
            self.is_practiced = is_practiced
            self.attempts = attempts
            self.accuracy = accuracy
            self.recordings = recordings
            self.mastered = mastered
            self.level_id = level_id
        }
    }
    
    private struct UserLevelRecord: Codable {
        let id: Int64?
        let user_id: UUID
        let level_id: UUID
        let avg_accuracy: Float?
        let is_completed: Bool
        
        init(user_id: UUID, level_id: UUID, avg_accuracy: Float? = nil, is_completed: Bool = false) {
            self.id = nil
            self.user_id = user_id
            self.level_id = level_id
            self.avg_accuracy = avg_accuracy
            self.is_completed = is_completed
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
        
        // Check if this is an Apple user or Google user from UserDefaults
        let isAppleUser = UserDefaults.standard.isAppleUser
        let isGoogleUser = UserDefaults.standard.isGoogleUser
        
        if isAppleUser {
            print("DEBUG: Restoring session for Apple user with ID: \(userId)")
        } else if isGoogleUser {
            print("DEBUG: Restoring session for Google user with ID: \(userId)")
        } else {
            print("DEBUG: Restoring session for regular user with ID: \(userId)")
        }
        
        // Try to get the email from UserDefaults for session restoration
        // For Apple users, this might be empty, but we store it anyway
        if let email = UserDefaults.standard.string(forKey: "lastEmail") {
            self.currentEmail = email
            if isAppleUser {
                print("DEBUG: Restored Apple user session with email: \(email.isEmpty ? "(empty)" : email)")
            } else if isGoogleUser {
                print("DEBUG: Restored Google user session with email: \(email)")
            } else {
                print("DEBUG: Restored regular user session with email: \(email)")
            }
        } else {
            print("DEBUG: No stored email found in UserDefaults")
        }
        
        self.isFirstTimeUser = false
    }
    
    // Update sign out method to clear UserDefaults
    public func signOut() {
        UserDefaults.standard.clearSession()
        // Also clear the lastEmail specifically
        UserDefaults.standard.removeObject(forKey: "lastEmail")
        
        currentUserId = nil
        currentEmail = nil
        currentUser = nil
        isFirstTimeUser = false
        
        print("DEBUG: User signed out and all session data cleared")
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
    
    // Add method to update user's Apple ID
    public func updateUserAppleId(userId: UUID, appleId: String) async throws {
        print("DEBUG: Starting Apple ID update for user \(userId)")
        print("DEBUG: New Apple ID: \(appleId)")
        
        do {
            let response = try await supabase
                .from("users")
                .update(["apple_id": appleId])
                .eq("id", value: userId)
                .execute()
            
            print("DEBUG: Apple ID update response received")
            print("DEBUG: Response: \(response)")
            
            // Mark user as Apple user in UserDefaults
            UserDefaults.standard.isAppleUser = true
            
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
            print("DEBUG: Apple ID: \(String(describing: updatedUser.apple_id))")
            
            if updatedUser.apple_id == nil {
                print("DEBUG: WARNING - Apple ID is still nil after update")
            }
        } catch {
            print("DEBUG: Error in updateUserAppleId: \(error)")
            throw SupabaseError.databaseError(error)
        }
    }
    
    // Add method to mark questionnaire completion
    public func markQuestionnaireCompleted(userId: UUID) async throws {
        print("DEBUG: Marking questionnaire completed for user \(userId)")
        
        do {
            let response = try await supabase
                .from("users")
                .update(["is_first_login": false])
                .eq("id", value: userId)
                .execute()
            
            print("DEBUG: Questionnaire completion update response received")
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
            print("DEBUG: Is first login: \(String(describing: updatedUser.is_first_login))")
            
            if updatedUser.is_first_login != false {
                print("DEBUG: WARNING - is_first_login is still not false after update")
            }
        } catch {
            print("DEBUG: Error in markQuestionnaireCompleted: \(error)")
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
    
    // MARK: - Apple Sign In
    
    func signInWithApple(appleId: String) async throws -> UserData {
        do {
            print("DEBUG: Attempting Apple sign in with Apple ID: \(appleId)")
            let response: [User] = try await supabase
                .from("users")
                .select()
                .eq("apple_id", value: appleId)
                .execute()
                .value
            
            guard let user = response.first else {
                throw SupabaseError.invalidCredentials
            }
            
            print("DEBUG: ====== APPLE LOGIN ======")
            print("DEBUG: Found user with ID: \(user.id)")
            print("DEBUG: Apple ID: \(user.apple_id ?? "nil")")
            print("DEBUG: Email: \(user.email)")
            print("DEBUG: ========================")
            
            // Store both user ID and email on successful sign in
            self.currentUserId = user.id
            self.currentEmail = user.email  // This might be empty for Apple users
            self.isFirstTimeUser = false
            
            // Save user ID to UserDefaults
            UserDefaults.standard.userId = user.id.uuidString
            UserDefaults.standard.isUserLoggedIn = true
            UserDefaults.standard.isAppleUser = true
            UserDefaults.standard.isGoogleUser = false
            
            // Save email to UserDefaults for session restoration (even if empty)
            UserDefaults.standard.set(user.email, forKey: "lastEmail")
            
            // Ensure user data exists
            try await initializeUserData(userId: user.id)
            return try await getUser(byId: user.id)
        } catch {
            print("DEBUG: Apple sign in error: \(error)")
            throw SupabaseError.networkError(error)
        }
    }
    
    // Add method to update user's Google ID
    public func updateUserGoogleId(userId: UUID, googleId: String) async throws {
        print("DEBUG: Starting Google ID update for user \(userId)")
        print("DEBUG: New Google ID: \(googleId)")
        
        do {
            let response = try await supabase
                .from("users")
                .update(["google_id": googleId])
                .eq("id", value: userId)
                .execute()
            
            print("DEBUG: Google ID update response received")
            print("DEBUG: Response: \(response)")
            
            // Mark user as Google user in UserDefaults
            UserDefaults.standard.isGoogleUser = true
            UserDefaults.standard.isAppleUser = false
            
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
            print("DEBUG: Google ID: \(String(describing: updatedUser.google_id))")
            
            if updatedUser.google_id == nil {
                print("DEBUG: WARNING - Google ID is still nil after update")
            }
        } catch {
            print("DEBUG: Error in updateUserGoogleId: \(error)")
            throw SupabaseError.databaseError(error)
        }
    }
    
    // Add method to check if a user is a Google user
    private func isGoogleUser(userId: UUID) async -> Bool {
        do {
            let user: User = try await supabase
                .from("users")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            
            return user.google_id != nil && !user.google_id!.isEmpty
        } catch {
            print("DEBUG: Error checking if user is Google user: \(error)")
            return false
        }
    }

    private func isAppleUser(userId: UUID) async -> Bool {
        do {
            let user: User = try await supabase
                .from("users")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value

            return user.apple_id != nil && !user.apple_id!.isEmpty
        } catch {
            print("DEBUG: Error checking if user is Apple user: \(error)")
            return false
        }
    }
}

// MARK: - Error Types

public enum SupabaseError: LocalizedError {
    case userNotFound
    case invalidCredentials
    case userAlreadyExists
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
            return "Invalid email or password"
        case .userAlreadyExists:
            return "User with this email already exists"
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
