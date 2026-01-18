////
////  DashboardParentModeViewController.swift
////  LeoLingo
////
////  Created by Batch - 2 on 21/01/25.
////
//


import UIKit
import WebKit
import ImageIO

class DashboardViewController: UIViewController, WKNavigationDelegate {
    
    private let exercises: [String : Exercise] = SampleDataController.shared.getExercisesData()
    var earnedBadges: [AppBadge] = DataController.shared.getEarnedBadges()!
    
    var minAccuracyWords: [Word]?
    var inaccurateWords: [String] = []
    
    // Store video URLs for tap handling
    private var videoURL1: String?
    private var videoURL2: String?
    
    // HeyMojo GIF properties
    private var heyMojoImageView: UIImageView?
    private var heyMojoImages: [UIImage] = []
    private var heyMojoDuration: TimeInterval = 0
    
    @IBOutlet var descriptionW1: UILabel!
    @IBOutlet var descriptionW2: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet var levelView: UIView!
    
    @IBOutlet var levelBadgeImage: UIImageView!
    @IBOutlet weak var levelTierLabel: UILabel?
    
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
        
        // Setup HeyMojo GIF
        setupHeyMojoGif()
        
        loadInaccurateWords()
        
        // Update level badge section
        updateLevelBadge()
        
        // Show default exercises initially (will be updated when data loads)
        showDefaultExercises()
        
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
        updatePracticeTime()  // Refresh practice time from UserDefaults
        refreshBadgeData()
        updateLevelBadge()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Also update practice time when view is about to appear
        updatePracticeTime()
    }
    
    // MARK: - Level Badge Update
    
    private func updateLevelBadge() {
        Task {
            do {
                guard let userId = SupabaseDataController.shared.userId else { return }
                
                // Fetch user data from Supabase
                let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                let allAppLevels = SupabaseDataController.shared.getLevelsData()
                
                // Count total completed levels (levels where all words are mastered)
                var completedLevelCount = 0
                var currentLevelProgress: Float = 0.0
                
                for userLevel in userData.userLevels {
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
                    
                    if completedWords == totalWords && totalWords > 0 {
                        // Level fully completed
                        completedLevelCount += 1
                    } else {
                        // This is the current level in progress
                        if totalWords > 0 {
                            currentLevelProgress = Float(completedWords) / Float(totalWords)
                        }
                        break
                    }
                }
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    // Find the level badge for the current/latest level
                    let displayLevelIndex = min(completedLevelCount, allAppLevels.count - 1)
                    let displayLevel = allAppLevels[displayLevelIndex]
                    
                    // Update level badge image
                    self.levelBadgeImage?.image = UIImage(named: displayLevel.levelImage)
                    
                    // Update progress bar
                    self.beginnerProgressBar?.progress = min(currentLevelProgress, 1.0)
                    
                    // Update the tier label based on current level
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
                    
                    // Update the tier label if connected
                    self.levelTierLabel?.text = tierLabel
                    
                    print("DEBUG: Dashboard - Level badge updated:")
                    print("  - Current level: \(currentDisplayLevel)")
                    print("  - Tier: \(tierLabel)")
                    print("  - Progress: \(currentLevelProgress * 100)%")
                    print("  - Badge image: \(displayLevel.levelImage)")
                }
            } catch {
                print("Error updating level badge in dashboard: \(error)")
            }
        }
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
        exerciseForW1.backgroundColor = .black
        exerciseForW1.isOpaque = true
        exerciseForW1.scrollView.isScrollEnabled = false
        exerciseForW1.scrollView.bounces = false
        exerciseForW1.configuration.allowsInlineMediaPlayback = true
        exerciseForW1.configuration.mediaTypesRequiringUserActionForPlayback = []
        exerciseForW1.configuration.preferences.javaScriptEnabled = true
        exerciseForW1.navigationDelegate = self
        
        exerciseForW2.backgroundColor = .black
        exerciseForW2.isOpaque = true
        exerciseForW2.scrollView.isScrollEnabled = false
        exerciseForW2.scrollView.bounces = false
        exerciseForW2.configuration.allowsInlineMediaPlayback = true
        exerciseForW2.configuration.mediaTypesRequiringUserActionForPlayback = []
        exerciseForW2.configuration.preferences.javaScriptEnabled = true
        exerciseForW2.navigationDelegate = self
        
        // Load and display average practice time
        updatePracticeTime()
        
        // Add border and corner radius to WebViews - make them bigger
        exerciseForW1.layer.cornerRadius = 12
        exerciseForW1.clipsToBounds = true
        exerciseForW1.layer.borderWidth = 0
        
        exerciseForW2.layer.cornerRadius = 12
        exerciseForW2.clipsToBounds = true
        exerciseForW2.layer.borderWidth = 0
        
        // Set larger size constraints for better visibility
        exerciseForW1.translatesAutoresizingMaskIntoConstraints = false
        exerciseForW2.translatesAutoresizingMaskIntoConstraints = false
        
        // Remove existing height constraints
        for constraint in exerciseForW1.constraints where constraint.firstAttribute == .height {
            exerciseForW1.removeConstraint(constraint)
        }
        for constraint in exerciseForW2.constraints where constraint.firstAttribute == .height {
            exerciseForW2.removeConstraint(constraint)
        }
        
        // Add new larger height constraints (16:9 aspect ratio friendly)
        exerciseForW1.heightAnchor.constraint(equalToConstant: 180).isActive = true
        exerciseForW1.widthAnchor.constraint(equalToConstant: 320).isActive = true
        
        exerciseForW2.heightAnchor.constraint(equalToConstant: 180).isActive = true
        exerciseForW2.widthAnchor.constraint(equalToConstant: 320).isActive = true
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Check if this is a YouTube link click
        if let url = navigationAction.request.url,
           (url.absoluteString.contains("youtube.com") || url.absoluteString.contains("youtu.be")) {
            // Open in Safari/YouTube app
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
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
        let daysUsed = max(UserDefaults.standard.integer(forKey: "daysUsed"), 1)
        
        print("DEBUG: Dashboard - Practice time calculation:")
        print("  - Total time spent: \(totalTimeSpent) seconds")
        print("  - Days used: \(daysUsed)")
        
        // Calculate daily average (in seconds)
        let dailyAverage = totalTimeSpent / Double(daysUsed)
        
        print("  - Daily average: \(dailyAverage) seconds")
        
        // Format the average time
        let totalSeconds = Int(dailyAverage)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        // Create formatted string
        var timeText = ""
        if hours > 0 {
            timeText = "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            timeText = "\(minutes)m \(seconds)s"
        } else if seconds > 0 {
            timeText = "\(seconds)s"
        } else {
            timeText = "0m"
        }
        
        // Update the label with average indicator
        practiceTime?.text = timeText
        
        print("  - Display text: \(timeText)")
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
    
    // MARK: - HeyMojo GIF Setup
    private func setupHeyMojoGif() {
        guard let gifPath = Bundle.main.path(forResource: "HeyMojo", ofType: "gif"),
              let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath)),
              let source = CGImageSourceCreateWithData(gifData as CFData, nil) else {
            print("❌ GIF file 'HeyMojo.gif' not found in Dashboard")
            return
        }
        
        print("✅ Loading HeyMojo.gif for Dashboard")
        let imageCount = CGImageSourceGetCount(source)
        var totalDuration: TimeInterval = 0
        
        for i in 0..<imageCount {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any]
                let gifProperties = properties?[kCGImagePropertyGIFDictionary as String] as? [String: Any]
                let frameDuration = gifProperties?[kCGImagePropertyGIFUnclampedDelayTime as String] as? TimeInterval
                    ?? gifProperties?[kCGImagePropertyGIFDelayTime as String] as? TimeInterval
                    ?? 0.1
                totalDuration += frameDuration
                heyMojoImages.append(UIImage(cgImage: cgImage))
            }
        }
        
        guard !heyMojoImages.isEmpty else {
            print("❌ Could not extract frames from HeyMojo.gif")
            return
        }
        
        heyMojoDuration = max(totalDuration, 0.5)
        
        // Hide any existing static Mojo image in mojoSuggestion
        for subview in mojoSuggestion.subviews {
            if let imageView = subview as? UIImageView {
                imageView.isHidden = true
                imageView.alpha = 0
            }
        }
        
        // Create animated image view
        heyMojoImageView = UIImageView()
        heyMojoImageView?.animationImages = heyMojoImages
        heyMojoImageView?.animationDuration = heyMojoDuration
        heyMojoImageView?.animationRepeatCount = 0 // Loop forever
        heyMojoImageView?.contentMode = .scaleAspectFit
        heyMojoImageView?.backgroundColor = .clear
        heyMojoImageView?.image = heyMojoImages.first
        
        if let heyMojoImageView = heyMojoImageView {
            mojoSuggestion.addSubview(heyMojoImageView)
            heyMojoImageView.translatesAutoresizingMaskIntoConstraints = false
            
            // Position at the right side of mojoSuggestion view
            NSLayoutConstraint.activate([
                heyMojoImageView.trailingAnchor.constraint(equalTo: mojoSuggestion.trailingAnchor, constant: 0),
                heyMojoImageView.topAnchor.constraint(equalTo: mojoSuggestion.topAnchor, constant: -20),
                heyMojoImageView.bottomAnchor.constraint(equalTo: mojoSuggestion.bottomAnchor, constant: 20),
                heyMojoImageView.widthAnchor.constraint(equalToConstant: 300)
            ])
            
            heyMojoImageView.startAnimating()
            print("✅ HeyMojo GIF loaded with \(imageCount) frames, duration: \(heyMojoDuration)s")
        }
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
        // Extract video ID from various YouTube URL formats
        var videoID: String?
        
        if youtubeURL.contains("youtu.be/") {
            // Short URL format: https://youtu.be/VIDEO_ID
            videoID = youtubeURL.components(separatedBy: "youtu.be/").last?.components(separatedBy: "?").first
        } else if youtubeURL.contains("youtube.com/watch?v=") {
            // Standard URL format: https://www.youtube.com/watch?v=VIDEO_ID
            if let range = youtubeURL.range(of: "v=") {
                let startIndex = range.upperBound
                let endIndex = youtubeURL[startIndex...].firstIndex(of: "&") ?? youtubeURL.endIndex
                videoID = String(youtubeURL[startIndex..<endIndex])
            }
        } else if youtubeURL.contains("youtube.com/embed/") {
            // Already embed format
            videoID = youtubeURL.components(separatedBy: "embed/").last?.components(separatedBy: "?").first
        }
        
        guard let id = videoID, !id.isEmpty else {
            print("DEBUG: Could not extract video ID from URL: \(youtubeURL)")
            return youtubeURL
        }
        
        return id
    }
    
    func getVideoThumbnailURL(_ videoID: String) -> String {
        // YouTube provides thumbnail images at these URLs
        return "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg"
    }
    
    func createThumbnailHTML(videoID: String, videoURL: String) -> String {
        let thumbnailURL = getVideoThumbnailURL(videoID)
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                html, body {
                    width: 100%;
                    height: 100%;
                    overflow: hidden;
                    background-color: #000;
                }
                .thumbnail-container {
                    position: relative;
                    width: 100%;
                    height: 100%;
                    cursor: pointer;
                }
                .thumbnail {
                    width: 100%;
                    height: 100%;
                    object-fit: cover;
                    border-radius: 12px;
                }
                .play-button {
                    position: absolute;
                    top: 50%;
                    left: 50%;
                    transform: translate(-50%, -50%);
                    width: 68px;
                    height: 48px;
                    background-color: rgba(255, 0, 0, 0.9);
                    border-radius: 12px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                }
                .play-button::after {
                    content: '';
                    border-style: solid;
                    border-width: 10px 0 10px 18px;
                    border-color: transparent transparent transparent white;
                    margin-left: 4px;
                }
                .thumbnail-container:hover .play-button {
                    background-color: rgba(255, 0, 0, 1);
                }
            </style>
        </head>
        <body>
            <div class="thumbnail-container" onclick="window.location.href='\(videoURL)'">
                <img class="thumbnail" src="\(thumbnailURL)" alt="Video Thumbnail" onerror="this.src='https://via.placeholder.com/320x180/333/fff?text=Video'"/>
                <div class="play-button"></div>
            </div>
        </body>
        </html>
        """
    }
    
    func createVideoHTML(embedURL: String) -> String {
        // This is now used as a fallback - prefer createThumbnailHTML
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                html, body {
                    width: 100%;
                    height: 100%;
                    background-color: #000;
                    overflow: hidden;
                }
                .video-container {
                    position: relative;
                    width: 100%;
                    height: 100%;
                }
                iframe {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    border: none;
                    border-radius: 12px;
                }
            </style>
        </head>
        <body>
            <div class="video-container">
                <iframe 
                    src="\(embedURL)" 
                    frameborder="0" 
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                    allowfullscreen>
                </iframe>
            </div>
        </body>
        </html>
        """
    }
    
    func updateExerciseForWords() {
        let appLevels = SampleDataController.shared.getLevelsData()
        
        // Handle case with no practiced words - show default exercises
        guard let words = minAccuracyWords, !words.isEmpty else {
            print("DEBUG: No inaccurate words found, showing default exercises")
            showDefaultExercises()
            return
        }
        
        // Get word titles for the inaccurate words
        var wordTitles: [String] = []
        for word in words {
            if let title = getAppWordTitle(for: word, appLevels: appLevels) {
                wordTitles.append(title)
            }
        }
        
        guard !wordTitles.isEmpty else {
            print("DEBUG: Could not find word titles, showing default exercises")
            showDefaultExercises()
            return
        }
        
        // Get first letters for exercise lookup
        let firstLetter1 = wordTitles[0].first?.lowercased() ?? "a"
        let firstLetter2 = wordTitles.count > 1 ? (wordTitles[1].first?.lowercased() ?? firstLetter1) : firstLetter1
        
        print("DEBUG: Looking up exercises for letters: \(firstLetter1), \(firstLetter2)")
        
        // Get exercises for the weak letters
        let exercise1 = exercises[firstLetter1] ?? exercises["a"]!
        let exercise2 = exercises[firstLetter2] ?? exercises["a"]!
        
        // Update descriptions with word-specific feedback
        descriptionW1?.text = "Your child needs practice with '\(wordTitles[0])'. \(exercise1.description)"
        
        if wordTitles.count > 1 && firstLetter1 != firstLetter2 {
            descriptionW2?.text = "Your child needs practice with '\(wordTitles[1])'. \(exercise2.description)"
            descriptionW2?.isHidden = false
            descriptionLabel?.isHidden = false
            exerciseForW2?.isHidden = false
        } else {
            // Same letter or only one word - hide second exercise
            descriptionW2?.isHidden = true
            descriptionLabel?.isHidden = true
            exerciseForW2?.isHidden = true
        }
        
        // Load video thumbnails
        if let videoURL1 = exercise1.videos.first {
            let videoID = convertToEmbedURL(videoURL1)
            self.videoURL1 = videoURL1
            let html1 = createThumbnailHTML(videoID: videoID, videoURL: videoURL1)
            exerciseForW1?.loadHTMLString(html1, baseURL: nil)
            print("DEBUG: Loaded exercise thumbnail 1 for letter '\(firstLetter1)' with ID: \(videoID)")
        }
        
        if wordTitles.count > 1 && firstLetter1 != firstLetter2, let videoURL2 = exercise2.videos.first {
            let videoID = convertToEmbedURL(videoURL2)
            self.videoURL2 = videoURL2
            let html2 = createThumbnailHTML(videoID: videoID, videoURL: videoURL2)
            exerciseForW2?.loadHTMLString(html2, baseURL: nil)
            print("DEBUG: Loaded exercise thumbnail 2 for letter '\(firstLetter2)' with ID: \(videoID)")
        }
    }
    
    private func showDefaultExercises() {
        // Show general speech exercises when no specific weaknesses detected
        descriptionW1?.text = "Start practicing to get personalized exercise recommendations!"
        descriptionW2?.isHidden = true
        descriptionLabel?.isHidden = true
        exerciseForW2?.isHidden = true
        
        // Load a default helpful video thumbnail
        if let defaultExercise = exercises["l"] {
            if let videoURL = defaultExercise.videos.first {
                let videoID = convertToEmbedURL(videoURL)
                self.videoURL1 = videoURL
                let html = createThumbnailHTML(videoID: videoID, videoURL: videoURL)
                exerciseForW1?.loadHTMLString(html, baseURL: nil)
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

