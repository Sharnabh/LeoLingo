////
////  DashboardParentModeViewController.swift
////  LeoLingo
////
////  Created by Batch - 2 on 21/01/25.
////
//


import UIKit
import WebKit

class DashboardViewController: UIViewController {
    
    private let exercises: [String : Exercise] = SampleDataController.shared.getExercisesData()
    var earnedBadges: [AppBadge] = DataController.shared.getEarnedBadges()!
    
    var minAccuracyWords: [Word]?
    var inaccurateWords: [String] = []
    
    @IBOutlet var descriptionW1: UILabel!
    @IBOutlet var descriptionW2: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet var levelView: UIView!
    
    @IBOutlet var levelBadgeImage: UIImageView!
    
    @IBOutlet var practiceTimeView: UIView!
    
    @IBOutlet var practiceTime: UILabel!
    @IBOutlet var averageAccuracyView: UIView!
    @IBOutlet var badgesEarnedView: UIView!
    @IBOutlet var mostInaccurateView: UIView!
    @IBOutlet var mojoSuggestion: UIView!
    @IBOutlet var beginnerProgressBar: UIProgressView!
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var badgesEarnedCollectionView: UICollectionView!
    
    @IBOutlet var exerciseForW1: WKWebView!
    @IBOutlet var exerciseForW2: WKWebView!
    
    @IBOutlet var averageAccuracy: UILabel!
    
    @IBOutlet var averageAccuracyLabel: UILabel!
    
    var layout: UICollectionViewFlowLayout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
        
        configureMojoSuggestionVideos()
        
        loadInaccurateWords()
        
        layout = UICollectionViewFlowLayout()
        if let layout = layout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 100, height: 120)
            badgesEarnedCollectionView.collectionViewLayout = layout
            badgesEarnedCollectionView.delegate = self
            badgesEarnedCollectionView.dataSource = self
            badgesEarnedCollectionView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.44)
            badgesEarnedCollectionView.layer.cornerRadius = 21
            let badgesNib = UINib(nibName: "BadgesCollectionViewCell", bundle: nil)
            badgesEarnedCollectionView.register(badgesNib, forCellWithReuseIdentifier: BadgesCollectionViewCell.identifier)
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(WordCardHostingCell.self, forCellWithReuseIdentifier: WordCardHostingCell.identifier)
        
        configureFlowLayout()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Refresh data when view appears
        loadInaccurateWords()
        updatePracticeTime()
        refreshBadgeData()
    }
    
    private func refreshBadgeData() {
        print("DEBUG: DashboardVC - Starting badge data refresh")
        
        // Check what's in UserDefaults first
        let savedBadgeIDs = UserDefaults.standard.earnedBadgeIDs
        print("DEBUG: DashboardVC - Found \(savedBadgeIDs.count) earned badges in UserDefaults")
        
        // Debug badge IDs
        for idString in savedBadgeIDs {
            if let id = UUID(uuidString: idString) {
                // Try to find the matching app badge
                let appBadges = SampleDataController.shared.getBadgesData()
                if let match = appBadges.first(where: { $0.id == id }) {
                    print("DEBUG: DashboardVC - Found matching badge: \(match.badgeTitle) (\(match.id))")
                } else {
                    print("DEBUG: DashboardVC - No matching badge found for ID: \(id)")
                }
            }
        }
        
        // Ensure we have the latest user data and sync badges with UserDefaults
        Task {
            if let userId = SupabaseDataController.shared.userId {
                print("DEBUG: DashboardVC - Fetching user data for ID: \(userId)")
                do {
                    let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                    
                    // Count earned badges
                    let earnedBadges = userData.userBadges.filter { $0.isEarned }
                    print("DEBUG: DashboardVC - Found \(earnedBadges.count) earned badges in user data")
                    
                    // Sync earned badges with UserDefaults to ensure persistence
                    for badge in userData.userBadges where badge.isEarned {
                        print("DEBUG: DashboardVC - Adding earned badge to UserDefaults: \(badge.badgeTitle) (ID: \(badge.id))")
                        UserDefaults.standard.addEarnedBadge(badge.id)
                    }
                    
                    // Pre-load badge cache to ensure images can be found
                    let allBadges = SampleDataController.shared.getBadgesData()
                    print("DEBUG: DashboardVC - Pre-loaded \(allBadges.count) badge definitions")
                    
                    // Reload badges on main thread after fetching latest data
                    DispatchQueue.main.async {
                        self.badgesEarnedCollectionView.reloadData()
                        print("DEBUG: DashboardVC - Badge collection view reloaded")
                    }
                } catch {
                    print("ERROR: DashboardVC - Error refreshing badge data: \(error)")
                }
            } else {
                print("ERROR: DashboardVC - No user ID found, cannot fetch badge data")
                
                // Even without a user ID, try to display any badges from UserDefaults
                if !savedBadgeIDs.isEmpty {
                    DispatchQueue.main.async {
                        self.badgesEarnedCollectionView.reloadData()
                        print("DEBUG: DashboardVC - Badge collection view reloaded from UserDefaults only")
                    }
                }
            }
        }
    }
    
    private func configureMojoSuggestionVideos() {
        // Configure WebViews for video playback
        exerciseForW1.backgroundColor = .clear
        exerciseForW1.isOpaque = false
        exerciseForW1.scrollView.isScrollEnabled = false
        exerciseForW1.configuration.allowsInlineMediaPlayback = true
        exerciseForW1.configuration.mediaTypesRequiringUserActionForPlayback = []
        
        exerciseForW2.backgroundColor = .clear
        exerciseForW2.isOpaque = false
        exerciseForW2.scrollView.isScrollEnabled = false
        exerciseForW2.configuration.allowsInlineMediaPlayback = true
        exerciseForW2.configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // Load and display average practice time
        updatePracticeTime()
        
        // Set fixed frame for WebViews to maintain 16:9 ratio
        exerciseForW1.frame = CGRect(x: exerciseForW1.frame.origin.x,
                                     y: exerciseForW1.frame.origin.y,
                                     width: 250,
                                     height: 149)
        exerciseForW2.frame = CGRect(x: exerciseForW2.frame.origin.x,
                                     y: exerciseForW2.frame.origin.y,
                                     width: 250,
                                     height: 149)
        
        // Add border and corner radius to WebViews
        exerciseForW1.layer.borderWidth = 1
        exerciseForW1.layer.borderColor = UIColor.lightGray.cgColor
        exerciseForW1.layer.cornerRadius = 8
        exerciseForW1.clipsToBounds = true
        
        let height = CGFloat(mojoSuggestion.frame.height)
        exerciseForW1.heightAnchor.constraint(equalToConstant: height/6).isActive = true
        
        exerciseForW2.layer.borderWidth = 1
        exerciseForW2.layer.borderColor = UIColor.lightGray.cgColor
        exerciseForW2.layer.cornerRadius = 8
        exerciseForW2.clipsToBounds = true
        exerciseForW2.heightAnchor.constraint(equalToConstant: height/6).isActive = true
    }
    
    private func loadInaccurateWords() {
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
                    
                    // Sort by accuracy (lowest first) and take the first 2 practiced words
                    minAccuracyWords = practicedWords
                        .sorted { $0.avgAccuracy < $1.avgAccuracy }
                        .prefix(2)
                        .map { $0 }
                    
                    print("DEBUG: Selected \(minAccuracyWords?.count ?? 0) words for display")
                    if let selected = minAccuracyWords {
                        for word in selected {
                            if let appWord = DataController.shared.wordData(by: word.id) {
                                print("  Selected word: \(appWord.wordTitle)")
                                print("    Accuracy: \(word.avgAccuracy)")
                            }
                        }
                    }
                    
                    // Calculate average accuracy
                    if !practicedWords.isEmpty {
                        let avgAccuracy = practicedWords.reduce(0.0) { $0 + $1.avgAccuracy } / Double(practicedWords.count)
                        DispatchQueue.main.async {
                            self.averageAccuracyLabel.text = String(format: "%.1f%%", avgAccuracy)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.averageAccuracyLabel.text = "0.0%"
                        }
                    }
                    
                    // Reload collection view and update exercises on main thread
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                        self.updateExerciseForWords()
                    }
                } else {
                    print("DEBUG: No user ID found")
                }
            } catch {
                print("DEBUG: Error loading practices: \(error)")
            }
        }
    }
    
    private func updatePracticeTime() {
        // Get total time spent and days used from UserDefaults
        let totalTimeSpent = UserDefaults.standard.double(forKey: "totalTimeSpent")
        let daysUsed = UserDefaults.standard.integer(forKey: "daysUsed")
        
        // Calculate daily average (in seconds)
        let dailyAverage = daysUsed > 0 ? totalTimeSpent / Double(daysUsed) : totalTimeSpent
        
        // Format the average time
        let averageMinutes = Int(dailyAverage / 60)
        let hours = averageMinutes / 60
        let minutes = averageMinutes % 60
        
        // Create formatted string
        var timeText = ""
        if hours > 0 {
            timeText = "\(hours)h \(minutes)m"
        } else {
            timeText = "\(minutes)m"
        }
        
        // Update the label with average indicator
        practiceTime.text = timeText
    }
    
    func updateView() {
        levelView.layer.cornerRadius = 21
        levelView.layer.borderWidth = 3
        levelView.layer.borderColor = UIColor(red: 78/255, green: 157/255, blue: 50/255, alpha: 1.0).cgColor
        levelView.clipsToBounds = false
        
        // Drop shadow
        levelView.layer.shadowColor = UIColor.black.cgColor
        levelView.layer.shadowOpacity = 0.4
        levelView.layer.shadowOffset = CGSize(width: 0, height: 8)  //
        levelView.layer.shadowRadius = 15
        
        practiceTimeView.layer.cornerRadius = 17
        practiceTimeView.layer.borderWidth = 3
        practiceTimeView.layer.borderColor = UIColor(red: 225/255, green: 168/255, blue: 63/255, alpha: 1.0).cgColor
        practiceTimeView.clipsToBounds = false
        
        averageAccuracyView.layer.cornerRadius = 17
        averageAccuracyView.layer.borderWidth = 3
        averageAccuracyView.layer.borderColor = UIColor(red: 225/255, green: 168/255, blue: 63/255, alpha: 1.0).cgColor
        averageAccuracyView.clipsToBounds = false
        
        badgesEarnedView.layer.cornerRadius = 17
        badgesEarnedView.layer.borderWidth = 3
        badgesEarnedView.layer.borderColor = UIColor(red: 225/255, green: 168/255, blue: 63/255, alpha: 1.0).cgColor
        badgesEarnedView.clipsToBounds = false
        
        mostInaccurateView.layer.cornerRadius = 21
        mostInaccurateView.layer.borderWidth = 3
        mostInaccurateView.layer.borderColor = UIColor(red: 225/255, green: 168/255, blue: 63/255, alpha: 1.0).cgColor
        mostInaccurateView.clipsToBounds = false
        
        mojoSuggestion.layer.cornerRadius = 21
        mojoSuggestion.layer.borderWidth = 3
        mojoSuggestion.layer.borderColor = UIColor(red: 141/255, green: 91/255, blue: 66/255, alpha: 1.0).cgColor
        mojoSuggestion.clipsToBounds = false
        
        
        
    }
    @IBAction func seeAllButtonTapped(_ sender: UIButton) {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 1
        }
    }
    @IBAction func moreBadgesButtonTapped(_ sender: UIButton) {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 2
        }
    }
    func getAppWordTitle(for word: Word, appLevels: [AppLevel]) -> String? {
        
        for appLevel in appLevels {
            if let appWord = appLevel.words.first(where: { $0.id == word.id }) {
                
                return appWord.wordTitle
            }
        }
        return nil
    }
    
    func convertToEmbedURL(_ youtubeURL: String) -> String {
        // Extract video ID from YouTube URL
        if let videoID = youtubeURL.components(separatedBy: "/").last {
            // Create embed URL with custom parameters for clean player
            return "https://www.youtube.com/embed/\(videoID)?showinfo=0&controls=1&rel=0&modestbranding=1"
        }
        return youtubeURL
    }
    
    func createVideoHTML(embedURL: String) -> String {
        return """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body { margin: 0; background-color: transparent; }
                .video-container {
                    position: relative;
                    width: 100%;
                    height: 100%;
                    overflow: hidden;
                }
                iframe {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    border: 0;
                }
            </style>
        </head>
        <body>
            <div class="video-container">
                <iframe src="\(embedURL)" frameborder="0" allowfullscreen></iframe>
            </div>
        </body>
        </html>
        """
    }
    
    func updateExerciseForWords() {
        if let words = minAccuracyWords, words.count >= 2 {
            
            let appLevels = SampleDataController.shared.getLevelsData()
            
            if let word1Title = getAppWordTitle(for: words[0], appLevels: appLevels),
               let word2Title = getAppWordTitle(for: words[1], appLevels: appLevels) {
                
                let firstLetter1 = word1Title.first?.lowercased() ?? ""
                let firstLetter2 = word2Title.first?.lowercased() ?? ""
                
                if let exercise1 = exercises[firstLetter1], let exercise2 = exercises[firstLetter2] {
                    
                    descriptionW1.text = exercise1.description
                    descriptionW2.text = exercise2.description
                    
                    if let videoURL1 = exercise1.videos.first,
                       let videoURL2 = exercise2.videos.first {
                        // Convert to embed URLs
                        let embedURL1 = convertToEmbedURL(videoURL1)
                        let embedURL2 = convertToEmbedURL(videoURL2)
                        
                        // Create HTML with proper sizing
                        let html1 = createVideoHTML(embedURL: embedURL1)
                        let html2 = createVideoHTML(embedURL: embedURL2)
                        
                        // Load HTML content
                        exerciseForW1.loadHTMLString(html1, baseURL: nil)
                        exerciseForW2.loadHTMLString(html2, baseURL: nil)
                        
                        if word1Title.first == word2Title.first {
                            exerciseForW2.isHidden = true
                            descriptionW2.isHidden = true
                            descriptionLabel.isHidden = true
                            
                            // Remove any existing height constraints for exerciseForW1
                            exerciseForW1.constraints.forEach { constraint in
                                if constraint.firstAttribute == .height {
                                    exerciseForW1.removeConstraint(constraint)
                                }
                            }
                            
                            // Add new expanded height constraint
                            let expandedHeight = mojoSuggestion.frame.height/2
                            exerciseForW1.heightAnchor.constraint(equalToConstant: expandedHeight).isActive = true
                            
                            // Update layout
                            exerciseForW1.setNeedsLayout()
                            exerciseForW1.layoutIfNeeded()
                        }
                    }
                }
            }
        }
    }
}

extension DashboardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    private func configureFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 160, height: 200)  // Updated size to match WordCardView
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        collectionView.collectionViewLayout = layout
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == badgesEarnedCollectionView {
            if let badges = SupabaseDataController.shared.getEarnedBadgesData(), !badges.isEmpty {
                print("DEBUG: Found \(badges.count) earned badges for display")
                return badges.count
            } else {
                print("DEBUG: No earned badges found or empty array returned")
                return 0
            }
        }
        if collectionView == self.collectionView {
            return minAccuracyWords?.count ?? 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == badgesEarnedCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BadgesCollectionViewCell.identifier, for: indexPath) as! BadgesCollectionViewCell
            
            // Get earned badges safely
            guard let earnedBadges = SupabaseDataController.shared.getEarnedBadgesData(),
                  indexPath.row < earnedBadges.count else {
                print("DEBUG: Failed to get earned badge at index \(indexPath.row)")
                return UICollectionViewCell()
            }
            
            // Get the badge at this specific index
            let badge = earnedBadges[indexPath.row]
            
            // Log badge details for debugging
            print("DEBUG: Processing badge with ID: \(badge.id), title: \(badge.badgeTitle)")
            
            // Find the corresponding app badge to get the image
            let appBadges = SampleDataController.shared.getBadgesData()
            if let appBadge = appBadges.first(where: { $0.id == badge.id }) {
                print("DEBUG: Configuring badge cell: \(appBadge.badgeTitle) with image: \(appBadge.badgeImage)")
                cell.configure(with: "\(appBadge.badgeImage)", title: "\(appBadge.badgeTitle)")
            } else {
                // Try fuzzy matching by title if ID doesn't match
                print("DEBUG: Could not find badge by ID, trying title match for: \(badge.badgeTitle)")
                if let appBadge = appBadges.first(where: { $0.badgeTitle.lowercased() == badge.badgeTitle.lowercased() }) {
                    print("DEBUG: Found badge by title match: \(appBadge.badgeTitle) with image: \(appBadge.badgeImage)")
                    // Update UserDefaults with the correct ID for future reference
                    UserDefaults.standard.addEarnedBadge(appBadge.id)
                    cell.configure(with: "\(appBadge.badgeImage)", title: "\(appBadge.badgeTitle)")
                } else {
                    print("DEBUG: Could not find app badge matching ID: \(badge.id) or title: \(badge.badgeTitle)")
                    // Fallback configuration
                    cell.configure(with: "star", title: badge.badgeTitle)
                }
            }
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WordCardHostingCell.identifier, for: indexPath) as! WordCardHostingCell
        
        guard let words = minAccuracyWords else { return cell }
        cell.configure(with: words[indexPath.item])
        return cell
    }
    
}

