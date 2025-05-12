//
//  HomePageViewController.swift
//  LeoLingo
//
//  Created by Tarun   on 15/01/25.
//

import UIKit

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
        setupRemainingTimeView()
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
        // Refresh practices and badges when view appears
        loadRecentPractices()
        badgesEarnedCollectionView.reloadData()
        
        // Ensure we have the latest user data
        Task {
            if let userId = SupabaseDataController.shared.userId {
                do {
                    _ = try await SupabaseDataController.shared.getUser(byId: userId)
                    // Reload badges on main thread after fetching latest data
                    DispatchQueue.main.async {
                        self.badgesEarnedCollectionView.reloadData()
                    }
                } catch {
                    print("Error refreshing user data: \(error)")
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
                self.resetTimer()
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
    
    private func setupRemainingTimeView() {
        // Set background color
        remainingTimeView.backgroundColor = UIColor(red: 222/255, green: 168/255, blue: 62/255, alpha: 0.8)
        
        // Customize progress bar appearance
        timeLeftBar.progressTintColor = .white
        timeLeftBar.trackTintColor = UIColor.white.withAlphaComponent(0.3)
        timeLeftBar.layer.cornerRadius = 4
        timeLeftBar.clipsToBounds = true
        
        // Update time label appearance
        timeLeft.font = .systemFont(ofSize: 18, weight: .bold)
        timeLeft.textColor = .white
    }
    
    private func updateTimeDisplay() {
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
            timeLeft.textColor = .white
        } else {
            timeLeft.text = "Daily limit reached!"
            timeLeft.textColor = .white
        }
        
        // Update progress bar with smooth animation
        UIView.animate(withDuration: 0.3) {
            self.timeLeftBar.progress = min(Float(self.dailyTimeSpent) / Float(self.selectedDuration), 1.0)
        }
        
        // Save daily state
        UserDefaults.standard.set(dailyTimeSpent, forKey: "dailyTimeSpent")
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
            
            guard let badges = SupabaseDataController.shared.getEarnedBadgesData() else {
                print("DEBUG: Failed to get earned badges while configuring cell")
                return UICollectionViewCell()
            }
            
            print("DEBUG: Configuring badge cell at index \(indexPath.row)")
            
            for badge in SampleDataController.shared.getBadgesData() {
                if badge.id == badges[indexPath.row].id {
                    print("DEBUG: Found matching badge: \(badge.badgeTitle)")
                    cell.configure(with: badge.badgeImage)
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
        let storyboard = UIStoryboard(name: "ParentMode", bundle: nil)
        if let parentHomeVC = storyboard.instantiateViewController(withIdentifier: "ParentModeLockScreen") as? LockScreenViewController {
            parentHomeVC.modalPresentationStyle = .fullScreen
            self.present(parentHomeVC, animated: true, completion: nil)
            
        }
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
}
extension HomePageViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
