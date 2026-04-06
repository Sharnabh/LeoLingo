//
//  HomePageViewController.swift
//  LeoLingo
//
//  Created by Tarun   on 15/01/25.
//  Copyright © 2025 Sharnabh. All rights reserved.
//
//  PROPRIETARY AND CONFIDENTIAL
//  This software is protected by copyright and commercial license.
//  Unauthorized copying, distribution, modification, or reverse engineering is prohibited.
//

import UIKit
import SwiftUI

class HomePageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var levelImageView: UIImageView!
    @IBOutlet var levelLabel: UILabel!
    
    @IBOutlet var remainingTimeView: UIView!
    @IBOutlet var timeLeft: UILabel!
    @IBOutlet var timeLeftBar: UIProgressView!
    
    @IBOutlet var practicesView: UIView!
    @IBOutlet var badgesView: UIView!
    @IBOutlet var levelProgress: UIProgressView!
    @IBOutlet var levelView: UIView!
    
    @IBOutlet weak var badgesEarnedCollectionView: UICollectionView!
    @IBOutlet weak var recentPracticesCollectionView: UICollectionView!
    
    var badgesLayout: UICollectionViewFlowLayout?
    var practicesLayout: UICollectionViewFlowLayout?
    var sortedWords: [Word]?
    
    var timer: Timer?
    var selectedDuration: TimeInterval = 1800 // Default 30 minutes
    var startTime: Date?
    
    // Add properties for persisting timer state
    private var pausedDate: Date?
    private var elapsedTimeBeforePause: TimeInterval = 0
    private var totalTimeSpent: TimeInterval = 0
    private var isVocalCoachActive: Bool = false
    private var lastResetDate: Date? // Track when we last reset the timer
    private var dailyTimeSpent: TimeInterval = 0 // Track daily time spent
    
    private let emptyBadgesLabel: UILabel = {
        let label = UILabel()
        label.text = "Start practicing\nto earn badges! 🏆"
        label.textColor = UIColor(red: 75/255, green: 142/255, blue: 79/255, alpha: 1.0)
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyPracticesLabel: UILabel = {
        let label = UILabel()
        label.text = "Complete exercises\nto see your progress! 🎯"
        label.textColor = UIColor(red: 75/255, green: 142/255, blue: 79/255, alpha: 1.0)
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLevelView()
        generateCollectionViewLayout()
        loadRecentPractices()
        setupTimeView()
        updateLevelImage()
        
        // Add observers for app lifecycle and vocal coach
        NotificationCenter.default.addObserver(self,
                                            selector: #selector(appWillResignActive),
                                            name: UIApplication.didEnterBackgroundNotification,
                                            object: nil)
        NotificationCenter.default.addObserver(self,
                                            selector: #selector(appDidBecomeActive),
                                            name: UIApplication.didBecomeActiveNotification,
                                            object: nil)
        NotificationCenter.default.addObserver(self,
                                            selector: #selector(vocalCoachDidBecomeActive),
                                            name: NSNotification.Name("VocalCoachDidBecomeActive"),
                                            object: nil)
        NotificationCenter.default.addObserver(self,
                                            selector: #selector(vocalCoachDidBecomeInactive),
                                            name: NSNotification.Name("VocalCoachDidBecomeInactive"),
                                            object: nil)
        
        // Load persisted data
        loadPersistedData()
        
        // Start timer immediately
        startTimer()
        
        setupEmptyStateViews()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func loadPersistedData() {
        // Load total time spent (cumulative across all sessions)
        totalTimeSpent = UserDefaults.standard.double(forKey: "totalTimeSpent")
        dailyTimeSpent = UserDefaults.standard.double(forKey: "dailyTimeSpent")
        selectedDuration = UserDefaults.standard.double(forKey: "selectedDuration")
        
        // Set default duration if not set
        if selectedDuration == 0 {
            selectedDuration = 1800 // Default 30 minutes
            UserDefaults.standard.set(selectedDuration, forKey: "selectedDuration")
        }
        
        // Initialize days used if not set
        if UserDefaults.standard.object(forKey: "daysUsed") == nil {
            UserDefaults.standard.set(1, forKey: "daysUsed")
        }
        
        // Load last reset date
        if let lastResetTimeStamp = UserDefaults.standard.object(forKey: "lastResetDate") as? Date {
            lastResetDate = lastResetTimeStamp
            
            // Check if we need to reset daily time (if we've passed midnight since last reset)
            if shouldResetTimer() {
                resetDailyTimer()
            }
        } else {
            // First time running app, set initial reset date
            lastResetDate = Date()
            UserDefaults.standard.set(lastResetDate, forKey: "lastResetDate")
        }
        
    }
    
    private func shouldResetTimer() -> Bool {
        guard let lastReset = lastResetDate else { return true }
        
        // Get calendar and components
        let calendar = Calendar.current
        let now = Date()
        
        // Check if the current date is a different day than the last reset
        // and we've passed midnight
        return !calendar.isDate(lastReset, inSameDayAs: now)
    }
    
    private func resetDailyTimer() {
        // Only reset daily time, NOT total time
        dailyTimeSpent = 0
        lastResetDate = Date()
        
        // Increment days used counter when a new day starts
        let daysUsed = UserDefaults.standard.integer(forKey: "daysUsed")
        UserDefaults.standard.set(daysUsed + 1, forKey: "daysUsed")
        
        // Save the new state
        UserDefaults.standard.set(dailyTimeSpent, forKey: "dailyTimeSpent")
        UserDefaults.standard.set(lastResetDate, forKey: "lastResetDate")
        UserDefaults.standard.synchronize()
        
        // Update UI
        updateTimeDisplay()
    }
    
    @objc private func appWillResignActive() {
        // Save timer state when app goes to background
        pausedDate = Date()
        
        // Save all time data
        UserDefaults.standard.set(totalTimeSpent, forKey: "totalTimeSpent")
        UserDefaults.standard.set(dailyTimeSpent, forKey: "dailyTimeSpent")
        UserDefaults.standard.set(selectedDuration, forKey: "selectedDuration")
        UserDefaults.standard.set(lastResetDate, forKey: "lastResetDate")
        UserDefaults.standard.synchronize()
        
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func appDidBecomeActive() {
        // Reload persisted data
        totalTimeSpent = UserDefaults.standard.double(forKey: "totalTimeSpent")
        dailyTimeSpent = UserDefaults.standard.double(forKey: "dailyTimeSpent")
        
        // Check if we need to reset the daily timer
        if shouldResetTimer() {
            resetDailyTimer()
        }
        
        restoreTimerState()
    }
    
    @objc private func vocalCoachDidBecomeActive() {
        isVocalCoachActive = true
        UserDefaults.standard.set(true, forKey: "isVocalCoachActive")
    }
    
    @objc private func vocalCoachDidBecomeInactive() {
        isVocalCoachActive = false
        UserDefaults.standard.set(false, forKey: "isVocalCoachActive")
    }
    
    private func restoreTimerState() {
        // Load total time spent
        totalTimeSpent = UserDefaults.standard.double(forKey: "totalTimeSpent")
        startTimer()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        // Check if we should show the badge achievement popup after onboarding
        if UserDefaults.standard.shouldShowOnboardingBadgeAchievement {
            // Reset the flag so it doesn't show again
            UserDefaults.standard.shouldShowOnboardingBadgeAchievement = false
            
            // Delay showing the popup for a better UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showOnboardingBadgeAchievement()
            }
        }
        
        // Check for any newly earned badges that haven't been shown yet
        checkForNewlyEarnedBadges()
        
        // Refresh practices and badges when view appears
        loadRecentPractices()
        refreshBadgeData()
    }
    
    private func checkForNewlyEarnedBadges() {
        Task {
            do {
                guard let userId = SupabaseDataController.shared.userId else { return }
                
                // First, check and award any progress badges the user has earned
                await BadgeEarningManager.shared.checkAndAwardProgressBadges()
                
                // Get user data from Supabase
                let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                
                // Get list of badges shown before
                let shownBadgeIDs = UserDefaults.standard.array(forKey: "shownBadgeAchievements") as? [String] ?? []
                
                // Find any earned badge that hasn't been shown yet
                for badge in userData.userBadges where badge.isEarned {
                    let badgeIDString = badge.id.uuidString
                    if !shownBadgeIDs.contains(badgeIDString) {
                        // This is a newly earned badge - show achievement popup
                        
                        DispatchQueue.main.async {
                            BadgeAchievementManager.shared.showBadgeAchievement(for: badge, in: self)
                        }
                        
                        // Mark this badge as shown
                        var updatedShownBadges = shownBadgeIDs
                        updatedShownBadges.append(badgeIDString)
                        UserDefaults.standard.set(updatedShownBadges, forKey: "shownBadgeAchievements")
                        
                        // Only show one badge at a time
                        break
                    }
                }
            } catch {
                print("DEBUG: Error checking for newly earned badges: \(error)")
            }
        }
    }
    
    private func refreshBadgeData() {
        
        // Check what's in UserDefaults first
        let savedBadgeIDs = UserDefaults.standard.earnedBadgeIDs
        
        // Debug badge IDs
        for idString in savedBadgeIDs {
            if let id = UUID(uuidString: idString) {
                // Try to find the matching app badge
                let appBadges = SampleDataController.shared.getBadgesData()
                if let match = appBadges.first(where: { $0.id == id }) {
                    print("DEBUG: HomePageVC - Found matching badge: \(match.badgeTitle) (\(match.id))")
                } else {
                    print("DEBUG: HomePageVC - No matching badge found for ID: \(id)")
                }
            }
        }
        
        // Ensure we have the latest user data and sync badges with UserDefaults
        Task {
            if let userId = SupabaseDataController.shared.userId {
                do {
                    let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                    
                    // Count earned badges
                    let earnedBadges = userData.userBadges.filter { $0.isEarned }
                    
                    // Sync earned badges with UserDefaults to ensure persistence
                    for badge in userData.userBadges where badge.isEarned {
                        UserDefaults.standard.addEarnedBadge(badge.id)
                    }
                    
                    // Pre-load badge cache to ensure images can be found
                    let allBadges = SampleDataController.shared.getBadgesData()
                    
                    // Reload badges on main thread after fetching latest data
                    DispatchQueue.main.async {
                        self.badgesEarnedCollectionView.reloadData()
                    }
                } catch {
                    print("ERROR: HomePageVC - Error refreshing badge data: \(error)")
                }
            } else {
                
                // Even without a user ID, try to display any badges from UserDefaults
                if !savedBadgeIDs.isEmpty {
                    DispatchQueue.main.async {
                        self.badgesEarnedCollectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func updateBadgeStatus(badgeId: UUID) {
        Task {
            if UserDefaults.standard.isUserLoggedIn {
                do {
                    try? await SupabaseDataController.shared.updateBadgeStatus(badgeId: badgeId, isEarned: true)
                } catch {
                    print()
                }
            }
        }
    }
    
    func updateLevelImage() {
        Task {
            do {
                guard let userId = SupabaseDataController.shared.userId else { return }
                
                // Fetch user data from Supabase
                let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                let allAppLevels = SupabaseDataController.shared.getLevelsData()
                
                // Count total completed levels (levels where all words are mastered)
                var completedLevelCount = 0
                var currentLevelProgress: Float = 0.0
                var isAllLevelsComplete = true
                
                for (index, userLevel) in userData.userLevels.enumerated() {
                    let totalWords = userLevel.words.count
                    let completedWords = userLevel.words.filter { word in
                        // Check accuracy - word is mastered if any accuracy >= 70%
                        if let record = word.record,
                           let accuracies = record.accuracy,
                           !accuracies.isEmpty {
                            let maxAccuracy = accuracies.max() ?? 0
                            return maxAccuracy >= 70.0
                        }
                        return false
                    }.count
                    
                    if completedWords == totalWords {
                        // Level fully completed
                        completedLevelCount += 1
                    } else {
                        // This is the current level in progress
                        currentLevelProgress = Float(completedWords) / Float(totalWords)
                        isAllLevelsComplete = false
                        break
                    }
                }
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    // Find the level badge for the latest completed level
                    let displayLevelIndex = min(completedLevelCount, allAppLevels.count - 1)
                    let displayLevel = allAppLevels[displayLevelIndex]
                    
                    // Update level image to show the latest completed/current level badge
                    self.levelImageView.image = UIImage(named: displayLevel.levelImage)
                    
                    // Update progress bar to show current level progress
                    self.levelProgress.progress = min(currentLevelProgress, 1.0)
                    
                    // Update the level label to show tier based on current level
                    let currentDisplayLevel = completedLevelCount + 1 // Display starts from level 1
                    let tierLabel: String
                    
                    if currentDisplayLevel <= 10 {
                        // Beginner tier (Levels 1-10)
                        tierLabel = "Beginner"
                    } else if currentDisplayLevel <= 20 {
                        // Intermediate tier (Levels 11-20)
                        tierLabel = "Intermediate"
                    } else {
                        // Advanced tier (Levels 21-30)
                        tierLabel = "Advanced"
                    }
                    
                    // Update the existing level label from storyboard
                    self.levelLabel.text = tierLabel
                }
            } catch {
                print("Error updating level image: \(error)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Update level image when view appears
        updateLevelImage()
        loadRecentPractices()
    }
    
    func setupTimeView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showDurationPicker))
        remainingTimeView.addGestureRecognizer(tapGesture)
        remainingTimeView.isUserInteractionEnabled = true
        startTimer()
    }
    
    @objc func showDurationPicker() {
        let popoverVC = UIViewController()
        popoverVC.preferredContentSize = CGSize(width: 250, height: 180)
        
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DurationCell")
        
        popoverVC.view = tableView
        
        popoverVC.modalPresentationStyle = .popover
        if let presentationController = popoverVC.popoverPresentationController {
            presentationController.sourceView = remainingTimeView
            presentationController.sourceRect = remainingTimeView.bounds
            presentationController.permittedArrowDirections = .any
            presentationController.delegate = self
        }
        
        present(popoverVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DurationCell", for: indexPath)
        let durations = ["8 minutes", "15 minutes", "30 minutes"]
        cell.textLabel?.text = durations[indexPath.row]
        cell.textLabel?.textColor = UIColor(red: 78/255, green: 157/255, blue: 50/255, alpha: 1.0)
        cell.backgroundColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let durations: [TimeInterval] = [480, 900, 1800] // 8, 15, 30 minutes in seconds
        selectedDuration = durations[indexPath.row]
        UserDefaults.standard.set(selectedDuration, forKey: "selectedDuration")
        UserDefaults.standard.synchronize()
        startTimer()
        dismiss(animated: true)
    }
    
    func startTimer() {
        timer?.invalidate()
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Check for midnight reset before updating display
            if self.shouldResetTimer() {
                self.resetDailyTimer()
            }
            self.updateTimeDisplay()
        }
    }
    
    private func setupEmptyStateViews() {
        // Add empty state labels
        badgesView.addSubview(emptyBadgesLabel)
        practicesView.addSubview(emptyPracticesLabel)
        
        NSLayoutConstraint.activate([
            emptyBadgesLabel.centerXAnchor.constraint(equalTo: badgesView.centerXAnchor),
            emptyBadgesLabel.centerYAnchor.constraint(equalTo: badgesView.centerYAnchor),
            emptyBadgesLabel.leadingAnchor.constraint(equalTo: badgesView.leadingAnchor, constant: 16),
            emptyBadgesLabel.trailingAnchor.constraint(equalTo: badgesView.trailingAnchor, constant: -16),
            
            emptyPracticesLabel.centerXAnchor.constraint(equalTo: practicesView.centerXAnchor),
            emptyPracticesLabel.centerYAnchor.constraint(equalTo: practicesView.centerYAnchor),
            emptyPracticesLabel.leadingAnchor.constraint(equalTo: practicesView.leadingAnchor, constant: 16),
            emptyPracticesLabel.trailingAnchor.constraint(equalTo: practicesView.trailingAnchor, constant: -16)
        ])
    }
    
    private func updateTimeDisplay() {
        guard startTime != nil else { return }
        
        // Check if vocal coach is active from UserDefaults
        let isVocalCoachActive = UserDefaults.standard.bool(forKey: "isVocalCoachActive")
        
        // Only update time if vocal coach is active
        if isVocalCoachActive {
            dailyTimeSpent += 1 // Add one second
            totalTimeSpent += 1
            
            // Save time data for persistence
            UserDefaults.standard.set(totalTimeSpent, forKey: "totalTimeSpent")
            UserDefaults.standard.set(dailyTimeSpent, forKey: "dailyTimeSpent")
        }
        
        // Format daily time - show remaining time for today's goal
        let remainingSeconds = max(selectedDuration - dailyTimeSpent, 0)
        let hours = Int(remainingSeconds) / 3600
        let minutes = Int(remainingSeconds) / 60 % 60
        let seconds = Int(remainingSeconds) % 60
        
        // Update UI with remaining time
        if remainingSeconds > 0 {
            if hours > 0 {
                timeLeft.text = String(format: "%dh %dm left", hours, minutes)
            } else if minutes > 0 {
                timeLeft.text = String(format: "%dm %ds left", minutes, seconds)
            } else {
                timeLeft.text = String(format: "%ds left", seconds)
            }
            timeLeft.textColor = .black
        } else {
            timeLeft.text = "Daily goal reached! 🎉"
            timeLeft.textColor = UIColor(red: 75/255, green: 142/255, blue: 79/255, alpha: 1.0)
        }
        
        // Update progress bar with smooth animation
        UIView.animate(withDuration: 0.3) {
            self.timeLeftBar.progress = min(Float(self.dailyTimeSpent) / Float(self.selectedDuration), 1.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == badgesEarnedCollectionView {
            guard let badges = SupabaseDataController.shared.getEarnedBadgesData() else {
                emptyBadgesLabel.isHidden = false
                badgesEarnedCollectionView.isHidden = true
                return 0
            }
            emptyBadgesLabel.isHidden = badges.count > 0
            badgesEarnedCollectionView.isHidden = badges.count == 0
            return badges.count
        }
        
        let practiceCount = sortedWords?.count ?? 0
        emptyPracticesLabel.isHidden = practiceCount > 0
        recentPracticesCollectionView.isHidden = practiceCount == 0
        return practiceCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == badgesEarnedCollectionView {
            let cell = badgesEarnedCollectionView.dequeueReusableCell(withReuseIdentifier: BadgesEarnedCollectionViewCell.identifier, for: indexPath) as! BadgesEarnedCollectionViewCell
            
            guard let earnedBadges = SupabaseDataController.shared.getEarnedBadgesData(),
                  indexPath.row < earnedBadges.count else {
                return UICollectionViewCell()
            }
            
            // Get the badge at this specific index
            let badge = earnedBadges[indexPath.row]
            
            // Find the corresponding app badge to get the image
            let appBadges = SampleDataController.shared.getBadgesData()
            if let appBadge = appBadges.first(where: { $0.id == badge.id }) {
                cell.configure(with: appBadge.badgeImage)
            } else {
                // Try fuzzy matching by title if ID doesn't match
                if let appBadge = appBadges.first(where: { $0.badgeTitle.lowercased() == badge.badgeTitle.lowercased() }) {
                    // Update UserDefaults with the correct ID for future reference
                    UserDefaults.standard.addEarnedBadge(appBadge.id)
                    cell.configure(with: appBadge.badgeImage)
                } else {
                    // Fallback configuration
                    cell.configure(with: "star")
                }
            }
            
            return cell
        }
        let cell = recentPracticesCollectionView.dequeueReusableCell(withReuseIdentifier: RecentPracticesCollectionViewCell.identifier, for: indexPath) as! RecentPracticesCollectionViewCell
        
        guard let words = sortedWords else { return cell }
        let word = words[indexPath.item]
        cell.updateLabel(with: word)
        
        return cell
    }
    
    func generateCollectionViewLayout() {
        badgesLayout = UICollectionViewFlowLayout()
        if let layout = badgesLayout {
            layout.itemSize = CGSize(width: 90, height: 90)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.scrollDirection = .horizontal
            badgesEarnedCollectionView.collectionViewLayout = layout
            badgesEarnedCollectionView.delegate = self
            badgesEarnedCollectionView.dataSource = self
            badgesEarnedCollectionView.layer.cornerRadius = 21
            
            let nib = UINib(nibName: "BadgesEarnedCollectionViewCell", bundle: nil)
            badgesEarnedCollectionView.register(nib, forCellWithReuseIdentifier: BadgesEarnedCollectionViewCell.identifier)
        }
        
        practicesLayout = UICollectionViewFlowLayout()
        if let layout = practicesLayout {
            layout.itemSize = CGSize(width: 90, height: 90)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 0
            
            recentPracticesCollectionView.collectionViewLayout = layout
            recentPracticesCollectionView.delegate = self
            recentPracticesCollectionView.dataSource = self
            recentPracticesCollectionView.layer.cornerRadius = 21
            
            let nib = UINib(nibName: "RecentPracticesCollectionViewCell", bundle: nil)
            recentPracticesCollectionView.register(nib, forCellWithReuseIdentifier: RecentPracticesCollectionViewCell.identifier)
        }
    }
    
    
    func updateLevelView() {
        // Corner radius and border
        levelView.layer.cornerRadius = 21
        levelView.layer.borderWidth = 3
        levelView.layer.borderColor = UIColor(red: 75/255, green: 142/255, blue: 79/255, alpha: 1.0).cgColor
        levelView.clipsToBounds = true // Changed to true to ensure proper corner radius
        
        // Drop shadow for the entire view
        levelView.layer.shadowColor = UIColor.black.cgColor
        levelView.layer.shadowOpacity = 0.2
        levelView.layer.shadowOffset = CGSize(width: 0, height: 4)
        levelView.layer.shadowRadius = 8
        levelView.layer.masksToBounds = false
        
        // Level progress customization
        levelProgress.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
        levelProgress.progressTintColor = UIColor(red: 75/255, green: 142/255, blue: 79/255, alpha: 1.0)
        levelProgress.trackTintColor = UIColor(red: 75/255, green: 142/255, blue: 79/255, alpha: 0.2)
        levelProgress.layer.cornerRadius = 4
        levelProgress.clipsToBounds = true
        
        // Add subtle animation for progress updates
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.levelProgress.layoutIfNeeded()
        }
        
        // Ensure proper shadow rendering
        levelView.layer.shouldRasterize = true
        levelView.layer.rasterizationScale = UIScreen.main.scale
        
        // remaining time view styling
        remainingTimeView.layer.cornerRadius = 25
        remainingTimeView.layer.borderWidth = 3
        remainingTimeView.layer.borderColor = UIColor(red: 222/255, green: 168/255, blue: 62/255, alpha: 1.0).cgColor
        timeLeftBar.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
        
        // badges view styling
        badgesView.layer.cornerRadius = 21
        badgesView.layer.borderWidth = 3
        badgesView.layer.borderColor = UIColor(red: 75/255, green: 142/255, blue: 79/255, alpha: 1.0).cgColor
        badgesView.clipsToBounds = true
        
        badgesView.layer.shadowColor = UIColor.black.cgColor
        badgesView.layer.shadowOpacity = 0.2
        badgesView.layer.shadowOffset = CGSize(width: 0, height: 4)
        badgesView.layer.shadowRadius = 8
        badgesView.layer.masksToBounds = false
        
        // recent practices view styling
        practicesView.layer.cornerRadius = 21
        practicesView.layer.borderWidth = 3
        practicesView.layer.borderColor = UIColor(red: 75/255, green: 142/255, blue: 79/255, alpha: 1.0).cgColor
        practicesView.clipsToBounds = true
        
        practicesView.layer.shadowColor = UIColor.black.cgColor
        practicesView.layer.shadowOpacity = 0.2
        practicesView.layer.shadowOffset = CGSize(width: 0, height: 4)
        practicesView.layer.shadowRadius = 8
        practicesView.layer.masksToBounds = false
        
        // Ensure proper shadow rendering for all views
        badgesView.layer.shouldRasterize = true
        badgesView.layer.rasterizationScale = UIScreen.main.scale
        practicesView.layer.shouldRasterize = true
        practicesView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    @IBAction func kidsModeButtonTapped(_ sender: UIButton) {
        let lockScreenView = UIHostingController(rootView: ParentModeLockScreenView())
        lockScreenView.modalPresentationStyle = .fullScreen
        self.present(lockScreenView, animated: true)
    }
    @IBAction func vocalCoachButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
        
        if SupabaseDataController.shared.isFirstTime {
            // Show greeting for first-time users
            if let greetVC = storyboard.instantiateViewController(withIdentifier: "VocalCoachGreeting") as? GreetViewController {
                greetVC.modalPresentationStyle = .fullScreen
                // Post notification when vocal coach becomes active
                NotificationCenter.default.post(name: NSNotification.Name("VocalCoachDidBecomeActive"), object: nil)
                present(greetVC, animated: true)
                // Reset the first time status after showing greeting
                SupabaseDataController.shared.isFirstTime = false
            }
        } else {
            // Directly show VocalCoach for returning users
            if let vocalCoachVC = storyboard.instantiateViewController(withIdentifier: "VocalCoachViewController") as? VocalCoachViewController {
                vocalCoachVC.modalPresentationStyle = .fullScreen
                // Post notification when vocal coach becomes active
                NotificationCenter.default.post(name: NSNotification.Name("VocalCoachDidBecomeActive"), object: nil)
                present(vocalCoachVC, animated: true, completion: nil)
            }
        }
    }
    @IBAction func funLearningButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "FunLearning", bundle: nil)
        if let funLearningVC = storyboard.instantiateViewController(withIdentifier: "FunLearningNavBar") as? UINavigationController {
            funLearningVC.modalPresentationStyle = .fullScreen
            present(funLearningVC, animated: true)
        }
    }
    
    private func loadRecentPractices() {
        Task {
            do {
                if let userId = SupabaseDataController.shared.userId {
                    // Fetch latest user data from Supabase using ID
                    let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                    let words = userData.userLevels.flatMap { $0.words }
                    
                    // Filter words that have been practiced
                    let practicedWords = words.filter { word in
                        return word.isPracticed
                    }
                    
                    // Sort by accuracy (highest first) and take only the last 2 practiced words
                    sortedWords = practicedWords
                        .sorted { $0.avgAccuracy > $1.avgAccuracy }
                        .prefix(2)
                        .map { $0 }
                    
                    // Reload collection view on main thread
                    DispatchQueue.main.async {
                        self.recentPracticesCollectionView.reloadData()
                    }
                } else {
                    print("DEBUG: No user ID found")
                }
            } catch {
                print("DEBUG: Error loading recent practices: \(error)")
            }
        }
    }
    
    private func showOnboardingBadgeAchievement() {
        
        guard let userId = UserDefaults.standard.userId, 
              let id = UUID(uuidString: userId) else {
            return
        }
        
        Task {
            do {
                // Get all badges data
                let badges = SupabaseDataController.shared.getBadgesData()
                
                // Find the NewLeo badge
                if let newLeoBadge = badges.first(where: { $0.badgeTitle == "NewLeo" }) {
                    
                    // Track this badge as earned in UserDefaults
                    UserDefaults.standard.addEarnedBadge(newLeoBadge.id)
                    
                    // Get the current user data to ensure badges are loaded
                    let userData = try await SupabaseDataController.shared.getUser(byId: id)
                    
                    // First try to find the badge in user's data
                    if let badge = userData.userBadges.first(where: { $0.id == newLeoBadge.id }) {
                        // Show the achievement popup
                        DispatchQueue.main.async {
                            BadgeAchievementManager.shared.showBadgeAchievement(for: badge, in: self)
                        }
                    } else {
                        // If not found in user data, create a badge object from the app badge
                        let badge = Badge(
                            id: newLeoBadge.id,
                            badgeTitle: newLeoBadge.badgeTitle,
                            isEarned: true
                        )
                        
                        DispatchQueue.main.async {
                            BadgeAchievementManager.shared.showBadgeAchievement(for: badge, in: self)
                        }
                    }
                }
            } catch {
                print("Error showing onboarding badge: \(error)")
            }
        }
    }
}
extension HomePageViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
