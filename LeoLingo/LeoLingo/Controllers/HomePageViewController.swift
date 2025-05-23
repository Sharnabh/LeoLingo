//
//  HomePageViewController.swift
//  LeoLingo
//
//  Created by Tarun   on 15/01/25.
//

import UIKit
import SwiftUI

class HomePageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var levelImageView: UIImageView!
    
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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func loadPersistedData() {
        // Load total time spent
        totalTimeSpent = UserDefaults.standard.double(forKey: "totalTimeSpent")
        dailyTimeSpent = UserDefaults.standard.double(forKey: "dailyTimeSpent")
        selectedDuration = UserDefaults.standard.double(forKey: "selectedDuration")
        
        // Initialize days used if not set
        if !UserDefaults.standard.contains(key: "daysUsed") {
            UserDefaults.standard.set(1, forKey: "daysUsed")
        }
        
        // Load last reset date
        if let lastResetTimeStamp = UserDefaults.standard.object(forKey: "lastResetDate") as? Date {
            lastResetDate = lastResetTimeStamp
            
            // Check if we need to reset (if we've passed midnight since last reset)
            if shouldResetTimer() {
                resetTimer()
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
    
    private func resetTimer() {
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
        // Save timer state
        pausedDate = Date()
        if let startTime = startTime {
            elapsedTimeBeforePause = Date().timeIntervalSince(startTime)
            // Save to UserDefaults
            UserDefaults.standard.set(totalTimeSpent, forKey: "totalTimeSpent")
            UserDefaults.standard.set(dailyTimeSpent, forKey: "dailyTimeSpent")
            UserDefaults.standard.set(selectedDuration, forKey: "selectedDuration")
            UserDefaults.standard.set(lastResetDate, forKey: "lastResetDate")
            UserDefaults.standard.synchronize()
        }
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func appDidBecomeActive() {
        // Check if we need to reset the timer
        if shouldResetTimer() {
            resetTimer()
        }
        restoreTimerState()
    }
    
    @objc private func vocalCoachDidBecomeActive() {
        isVocalCoachActive = true
    }
    
    @objc private func vocalCoachDidBecomeInactive() {
        isVocalCoachActive = false
    }
    
    private func restoreTimerState() {
        // Load total time spent
        totalTimeSpent = UserDefaults.standard.double(forKey: "totalTimeSpent")
        startTimer()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("DEBUG: HomeVC - View did appear")
        
        // Check if we should show the badge achievement popup after onboarding
        if UserDefaults.standard.shouldShowOnboardingBadgeAchievement {
            print("DEBUG: HomeVC - Should show onboarding badge achievement")
            // Reset the flag so it doesn't show again
            UserDefaults.standard.shouldShowOnboardingBadgeAchievement = false
            
            // Delay showing the popup for a better UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showOnboardingBadgeAchievement()
            }
        } else {
            print("DEBUG: HomeVC - Checking for unshown badges")
            // Check for any earned badges that haven't been shown yet
            // This handles the case where the app was closed and reopened
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                BadgeAchievementManager.shared.checkAndShowUnshownBadges(in: self)
            }
        }
        
        // Refresh practices and badges when view appears
        loadRecentPractices()
        refreshBadgeData()
    }
    
    private func refreshBadgeData() {
        print("DEBUG: HomePageVC - Starting badge data refresh")
        
        // Check what's in UserDefaults first
        let savedBadgeIDs = UserDefaults.standard.earnedBadgeIDs
        print("DEBUG: HomePageVC - Found \(savedBadgeIDs.count) earned badges in UserDefaults")
        
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
                print("DEBUG: HomePageVC - Fetching user data for ID: \(userId)")
                do {
                    let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                    
                    // Count earned badges
                    let earnedBadges = userData.userBadges.filter { $0.isEarned }
                    print("DEBUG: HomePageVC - Found \(earnedBadges.count) earned badges in user data")
                    
                    // Sync earned badges with UserDefaults to ensure persistence
                    for badge in userData.userBadges where badge.isEarned {
                        print("DEBUG: HomePageVC - Adding earned badge to UserDefaults: \(badge.badgeTitle) (ID: \(badge.id))")
                        UserDefaults.standard.addEarnedBadge(badge.id)
                    }
                    
                    // Pre-load badge cache to ensure images can be found
                    let allBadges = SampleDataController.shared.getBadgesData()
                    print("DEBUG: HomePageVC - Pre-loaded \(allBadges.count) badge definitions")
                    
                    // Reload badges on main thread after fetching latest data
                    DispatchQueue.main.async {
                        self.badgesEarnedCollectionView.reloadData()
                        print("DEBUG: HomePageVC - Badge collection view reloaded")
                    }
                } catch {
                    print("ERROR: HomePageVC - Error refreshing badge data: \(error)")
                }
            } else {
                print("ERROR: HomePageVC - No user ID found, cannot fetch badge data")
                
                // Even without a user ID, try to display any badges from UserDefaults
                if !savedBadgeIDs.isEmpty {
                    DispatchQueue.main.async {
                        self.badgesEarnedCollectionView.reloadData()
                        print("DEBUG: HomePageVC - Badge collection view reloaded from UserDefaults only")
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
                guard let phoneNumber = SupabaseDataController.shared.phoneNumber else { return }
                
                // Fetch user data from Supabase
                let userData = try await SupabaseDataController.shared.getUser(byPhone: phoneNumber)
                let levels = userData.userLevels
                var currentLevel: Level? = nil
                
                // Find the first incomplete level
                for level in levels {
                    let totalWords = level.words.count
                    let completedWords = level.words.filter { word in
                        // A word is considered completed if it has been practiced with good accuracy
                        if let record = word.record,
                           let accuracies = record.accuracy,
                           !accuracies.isEmpty {
                            let avgAccuracy = accuracies.reduce(0.0, +) / Double(accuracies.count)
                            return avgAccuracy >= 70.0 // Consider word completed if average accuracy is 70% or higher
                        }
                        return false
                    }.count
                    
                    if completedWords < totalWords {
                        currentLevel = level
                        
                        // Calculate and update progress for this level
                        let progress = Float(completedWords) / Float(totalWords)
                        
                        // Update UI on main thread
                        DispatchQueue.main.async {
                            self.levelProgress.progress = progress
                            
                            // Get AppLevel using the level ID
                            if let appLevel = DataController.shared.getLevel(by: level.id) {
                                self.levelImageView.image = UIImage(named: appLevel.levelImage)
                            }
                        }
                        break
                    }
                }
                
                // If no current level found (all levels completed)
                if currentLevel == nil && !levels.isEmpty {
                    DispatchQueue.main.async {
                        // Show the last level's image with full progress
                        if let lastLevel = levels.last,
                           let lastAppLevel = DataController.shared.getLevel(by: lastLevel.id) {
                            self.levelImageView.image = UIImage(named: lastAppLevel.levelImage)
                            self.levelProgress.progress = 1.0
                        }
                    }
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
        let durations = ["30 minutes", "45 minutes", "60 minutes"]
        cell.textLabel?.text = durations[indexPath.row]
        cell.textLabel?.textColor = UIColor(red: 78/255, green: 157/255, blue: 50/255, alpha: 1.0)
        cell.backgroundColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let durations: [TimeInterval] = [1800, 2700, 3600] // 30, 45, 60 minutes in seconds
        selectedDuration = durations[indexPath.row]
        // Save selected duration
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
                self.resetTimer()
            }
            self.updateTimeDisplay()
        }
    }
    
    func updateTimeDisplay() {
        guard let startTime = startTime else { return }
        let currentElapsedTime = Date().timeIntervalSince(startTime)
        
        // Only update time if vocal coach is active
        if isVocalCoachActive {
            dailyTimeSpent += 1 // Add one second
            totalTimeSpent += 1
            
            // Save total time immediately for real-time updates in dashboard
            UserDefaults.standard.set(totalTimeSpent, forKey: "totalTimeSpent")
            UserDefaults.standard.synchronize()
        }
        
        // Format daily time
        let remainingSeconds = max(selectedDuration - dailyTimeSpent, 0)
        let remainingMinutes = Int(ceil(remainingSeconds / 60))
        
        // Update UI with remaining time
        if remainingSeconds > 0 {
            timeLeft.text = "\(remainingMinutes)m left"
        } else {
            timeLeft.text = "Daily limit reached!"
        }
        
        // Update progress bar
        if isVocalCoachActive {
            timeLeftBar.progress = min(Float(dailyTimeSpent) / Float(selectedDuration), 1.0)
        }
        
        // Save daily state
        UserDefaults.standard.set(dailyTimeSpent, forKey: "dailyTimeSpent")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == badgesEarnedCollectionView {
            guard let badges = SupabaseDataController.shared.getEarnedBadgesData() else {
                print("DEBUG: No earned badges found")
                return 0
            }
            print("DEBUG: Found \(badges.count) earned badges")
            return badges.count
        }
        return sortedWords?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == badgesEarnedCollectionView {
            let cell = badgesEarnedCollectionView.dequeueReusableCell(withReuseIdentifier: BadgesEarnedCollectionViewCell.identifier, for: indexPath) as! BadgesEarnedCollectionViewCell
            
            guard let earnedBadges = SupabaseDataController.shared.getEarnedBadgesData(),
                  indexPath.row < earnedBadges.count else {
                print("DEBUG: Failed to get earned badge at index \(indexPath.row)")
                return UICollectionViewCell()
            }
            
            // Get the badge at this specific index
            let badge = earnedBadges[indexPath.row]
            print("DEBUG: HomePageVC - Processing badge with ID: \(badge.id), title: \(badge.badgeTitle)")
            
            // Find the corresponding app badge to get the image
            let appBadges = SampleDataController.shared.getBadgesData()
            if let appBadge = appBadges.first(where: { $0.id == badge.id }) {
                print("DEBUG: HomePageVC - Found matching badge: \(appBadge.badgeTitle) with image: \(appBadge.badgeImage)")
                cell.configure(with: appBadge.badgeImage)
            } else {
                // Try fuzzy matching by title if ID doesn't match
                if let appBadge = appBadges.first(where: { $0.badgeTitle.lowercased() == badge.badgeTitle.lowercased() }) {
                    print("DEBUG: HomePageVC - Found badge by title match: \(appBadge.badgeTitle) with image: \(appBadge.badgeImage)")
                    // Update UserDefaults with the correct ID for future reference
                    UserDefaults.standard.addEarnedBadge(appBadge.id)
                    cell.configure(with: appBadge.badgeImage)
                } else {
                    print("DEBUG: HomePageVC - Could not find app badge matching ID: \(badge.id) or title: \(badge.badgeTitle)")
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
        levelView.clipsToBounds = false
        
        // Drop shadow
        levelView.layer.shadowColor = UIColor.black.cgColor
        levelView.layer.shadowOpacity = 0.6
        levelView.layer.shadowOffset = CGSize(width: 0, height: 10)  //
        levelView.layer.shadowRadius = 20
        
        
        // Level progress
        levelProgress.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
        
        // remaining time
        remainingTimeView.layer.cornerRadius = 25
        remainingTimeView.layer.borderWidth = 3
        remainingTimeView.layer.borderColor = UIColor(red: 222/255, green: 168/255, blue: 62/255, alpha: 1.0).cgColor
        timeLeftBar.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
        
        // badges
        badgesView.layer.cornerRadius = 21
        badgesView.layer.borderWidth = 3
        badgesView.layer.borderColor = UIColor(red: 75/255, green: 142/255, blue: 79/255, alpha: 1.0).cgColor
        badgesView.clipsToBounds = false
        
        badgesView.layer.shadowColor = UIColor.black.cgColor
        badgesView.layer.shadowOpacity = 0.4
        badgesView.layer.shadowOffset = CGSize(width: 0, height: 1)
        badgesView.layer.shadowRadius = 5
        
        //recent practices
        practicesView.layer.cornerRadius = 21  // Rounded corners
        practicesView.layer.borderWidth = 3    // Border thickness
        practicesView.layer.borderColor = UIColor(red: 75/255, green: 142/255, blue: 79/255, alpha: 1.0).cgColor
        practicesView.clipsToBounds = false  // Clips content to rounded corners
        
        practicesView.layer.shadowColor = UIColor.black.cgColor
        practicesView.layer.shadowOpacity = 0.4  // 62% opacity
        practicesView.layer.shadowOffset = CGSize(width: 0, height: 1)  // Offset of 16pt downward
        practicesView.layer.shadowRadius = 5  // Blur radius of 43pt
        
        
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
                    print("DEBUG: Loading practices for user ID: \(userId)")
                    // Fetch latest user data from Supabase using ID
                    let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                    let words = userData.userLevels.flatMap { $0.words }
                    print("DEBUG: Total words loaded: \(words.count)")
                    
                    // Filter words that have been practiced
                    let practicedWords = words.filter { word in
                        print("DEBUG: Checking word \(word.id):")
                        print("  - Is practiced: \(word.isPracticed)")
                        print("  - Has record: \(word.record != nil)")
                        print("  - Attempts: \(word.record?.attempts ?? 0)")
                        print("  - Accuracy: \(word.record?.accuracy ?? [])")
                        return word.isPracticed
                    }
                    
                    print("DEBUG: Found \(practicedWords.count) practiced words")
                    
                    if practicedWords.isEmpty {
                        print("DEBUG: No practiced words found")
                    } else {
                        print("DEBUG: Practiced words details:")
                        for word in practicedWords {
                            if let appWord = DataController.shared.wordData(by: word.id) {
                                print("  Word: \(appWord.wordTitle)")
                                print("    Accuracy: \(word.avgAccuracy)")
                                print("    Attempts: \(word.record?.attempts ?? 0)")
                                print("    Practiced: \(word.isPracticed)")
                                print("    Record exists: \(word.record != nil)")
                            }
                        }
                    }
                    
                    // Sort by accuracy (highest first) and take only the last 2 practiced words
                    sortedWords = practicedWords
                        .sorted { $0.avgAccuracy > $1.avgAccuracy }
                        .prefix(2)
                        .map { $0 }
                    
                    print("DEBUG: Selected \(sortedWords?.count ?? 0) words for display")
                    if let selected = sortedWords {
                        for word in selected {
                            if let appWord = DataController.shared.wordData(by: word.id) {
                                print("  Selected word: \(appWord.wordTitle)")
                                print("    Accuracy: \(word.avgAccuracy)")
                            }
                        }
                    }
                    
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
        print("DEBUG: HomeVC - Showing onboarding badge achievement")
        
        guard let userId = UserDefaults.standard.userId, 
              let id = UUID(uuidString: userId) else {
            print("ERROR: HomeVC - Cannot show badge, no user ID found")
            return
        }
        
        Task {
            do {
                // Get all badges data
                let badges = SupabaseDataController.shared.getBadgesData()
                print("DEBUG: HomeVC - Got \(badges.count) total badges")
                
                // Find the NewLeo badge
                if let newLeoBadge = badges.first(where: { $0.badgeTitle == "NewLeo" }) {
                    print("DEBUG: HomeVC - Found NewLeo badge with ID: \(newLeoBadge.id)")
                    
                    // Track this badge as earned in UserDefaults
                    UserDefaults.standard.addEarnedBadge(newLeoBadge.id)
                    
                    // Get the current user data to ensure badges are loaded
                    let userData = try await SupabaseDataController.shared.getUser(byId: id)
                    
                    // First try to find the badge in user's data
                    if let badge = userData.userBadges.first(where: { $0.id == newLeoBadge.id }) {
                        print("DEBUG: HomeVC - Found badge in user data, showing achievement popup")
                        // Show the achievement popup
                        DispatchQueue.main.async {
                            BadgeAchievementManager.shared.showBadgeAchievement(for: badge, in: self)
                        }
                    } else {
                        // If not found in user data, create a badge object from the app badge
                        print("DEBUG: HomePageVC - Creating badge from app badge data")
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
