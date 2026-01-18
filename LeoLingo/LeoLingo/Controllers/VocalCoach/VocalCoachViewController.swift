import UIKit
import AVFoundation
import AVKit

// Custom view that properly handles AVPlayerLayer sizing
class VideoPlayerView: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
}

class VocalCoachViewController: UIViewController {
    
    private var videoCardView: VideoCardView?
    
    @IBOutlet var practiceCardView: UIView!
    @IBOutlet var soundCards: UICollectionView!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet weak var headingTitle: UILabel!
    @IBOutlet weak var mojoImageView: UIImageView!
    @IBOutlet weak var wordBoxImageView: UIImageView!
    @IBOutlet weak var continueButton: UIButton!
    
    let levels = DataController.shared.getAllLevels()
    var words: [Word] = []
    var word: Word!
    
    private lazy var backButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        button.backgroundColor = UIColor.white.withAlphaComponent(0.77)
        button.layer.cornerRadius = 30
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowRadius = 2
        button.layer.shadowOpacity = 0.2
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: "chevron.left", withConfiguration: symbolConfig)?
            .withTintColor(UIColor(named: "AccentColor") ?? .systemGreen, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackButton()
        
        headingTitle.layer.cornerRadius = 21
        headingTitle.layer.masksToBounds = true
        
        // Get all levels and find first unmastered word
        Task {
            do {
                guard let userId = SupabaseDataController.shared.userId else { return }
                let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                
                // Find first unmastered word across all levels
                var firstUnmasteredWord: Word?
                for level in userData.userLevels {
                    for word in level.words {
                        // Check if word is NOT mastered
                        let isMastered = word.record?.mastered ?? false
                        let hasHighAccuracy = (word.record?.accuracy?.max() ?? 0) >= 70
                        
                        if !isMastered && !hasHighAccuracy {
                            firstUnmasteredWord = word
                            break
                        }
                    }
                    if firstUnmasteredWord != nil {
                        break
                    }
                }
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    if let unmasteredWord = firstUnmasteredWord,
                       let appWord = SupabaseDataController.shared.wordData(by: unmasteredWord.id) {
                        self.wordLabel.text = appWord.wordTitle
                        print("DEBUG: VocalCoach showing first unmastered word: \(appWord.wordTitle)")
                    } else {
                        self.wordLabel.text = "All words mastered!"
                        print("DEBUG: All words are mastered!")
                    }
                }
            } catch {
                print("DEBUG: Error loading user data: \(error)")
            }
        }
        
        updatePracticeCardView()
        setupCollectionViewLayout()
        
        // Setup animated GIF (only once in viewDidLoad)
        setupAnimatedMojoGif()
        
        soundCards.delegate = self
        soundCards.dataSource = self
        soundCards.backgroundColor = .clear
        soundCards.isUserInteractionEnabled = true
        
        let firstNib = UINib(nibName: "SoundCards", bundle: nil)
        soundCards.register(firstNib, forCellWithReuseIdentifier: "First")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Video card setup removed - using animated GIF instead
    }
    
    private func setupBackButton() {
        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            backButton.widthAnchor.constraint(equalToConstant: 60),
            backButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupAnimatedMojoGif() {
        // Use animated GIF for better transparency support
        guard let gifPath = Bundle.main.path(forResource: "HeyMojo", ofType: "gif"),
              let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath)),
              let source = CGImageSourceCreateWithData(gifData as CFData, nil) else {
            print("❌ GIF file 'HeyMojo.gif' not found")
            mojoImageView.isHidden = false
            return
        }
        
        print("✅ Loading HeyMojo.gif")
        
        let imageCount = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var totalDuration: TimeInterval = 0
        
        // Extract all frames from the GIF
        for i in 0..<imageCount {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                // Get frame duration
                let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any]
                let gifProperties = properties?[kCGImagePropertyGIFDictionary as String] as? [String: Any]
                let frameDuration = gifProperties?[kCGImagePropertyGIFUnclampedDelayTime as String] as? TimeInterval
                    ?? gifProperties?[kCGImagePropertyGIFDelayTime as String] as? TimeInterval
                    ?? 0.1
                
                totalDuration += frameDuration
                images.append(UIImage(cgImage: cgImage))
            }
        }
        
        // Hide original Mojo image
        mojoImageView.isHidden = true
        
        // Create an image view for the animated GIF
        let animatedImageView = UIImageView(frame: mojoImageView.frame)
        animatedImageView.animationImages = images
        animatedImageView.animationDuration = totalDuration
        animatedImageView.animationRepeatCount = 0 // Loop forever
        animatedImageView.contentMode = .scaleAspectFit
        animatedImageView.backgroundColor = .clear
        
        // Add to practice card
        practiceCardView.addSubview(animatedImageView)
        
        // Bring UI elements to front
        practiceCardView.bringSubviewToFront(wordBoxImageView)
        practiceCardView.bringSubviewToFront(wordLabel)
        practiceCardView.bringSubviewToFront(continueButton)
        
        // Start animation
        animatedImageView.startAnimating()
        
        print("✅ Animated GIF playing with \(imageCount) frames!")
        print("📍 Animation duration: \(totalDuration)s")
    }
    
    private func navigateToPracticeScreen() {
        let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
        if let practiceVC = storyboard.instantiateViewController(withIdentifier: "PracticeScreenViewController") as? PracticeScreenViewController {
            practiceVC.levelIndex = 0
            practiceVC.currentIndex = 0
            
            if let navigationController = self.navigationController {
                navigationController.pushViewController(practiceVC, animated: true)
            } else {
                practiceVC.modalPresentationStyle = .fullScreen
                present(practiceVC, animated: true)
            }
        }
    }
    
    @objc private func backButtonTapped() {
        if let navController = self.navigationController {
            for viewController in navController.viewControllers {
                if viewController is HomePageViewController {
                    navController.popToViewController(viewController, animated: true)
                    return
                }
            }
            
            if let homeVC = storyboard?.instantiateViewController(withIdentifier: "HomePageViewController") {
                navController.setViewControllers([homeVC], animated: true)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func updatePracticeCardView() {
        practiceCardView.layer.cornerRadius = 21
        practiceCardView.layer.borderWidth = 2
        practiceCardView.layer.borderColor = UIColor(red: 161/255, green: 105/255, blue: 77/255, alpha: 1.0).cgColor
        
        practiceCardView.clipsToBounds = false
        practiceCardView.layer.shadowColor = UIColor.black.cgColor
        practiceCardView.layer.shadowOpacity = 0.62
        practiceCardView.layer.shadowOffset = CGSize(width: 0, height: 1)
        practiceCardView.layer.shadowRadius = 10
        view.bringSubviewToFront(practiceCardView)
    }
    
    func setupCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.itemSize = CGSize(width: 380, height: 260)
        soundCards.collectionViewLayout = layout
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
        if let practiceVC = storyboard.instantiateViewController(withIdentifier: "PracticeScreenViewController") as? PracticeScreenViewController {
            practiceVC.levelIndex = 0
            practiceVC.currentIndex = 0
            
            if let navigationController = self.navigationController {
                navigationController.pushViewController(practiceVC, animated: true)
            } else {
                practiceVC.modalPresentationStyle = .fullScreen
                present(practiceVC, animated: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        videoCardView?.pause()
        
        NotificationCenter.default.post(name: NSNotification.Name("VocalCoachDidBecomeInactive"), object: nil)
        
        if self.isMovingFromParent {
            if let navigationController = self.navigationController {
                if let homeVC = storyboard?.instantiateViewController(withIdentifier: "HomePageViewController") {
                    navigationController.setViewControllers([homeVC], animated: true)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoCardView?.play()
        
        // Refresh the first unmastered word when returning to this screen
        Task {
            do {
                guard let userId = SupabaseDataController.shared.userId else { return }
                let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                
                // Find first unmastered word across all levels
                var firstUnmasteredWord: Word?
                for level in userData.userLevels {
                    for word in level.words {
                        // Check if word is NOT mastered
                        let isMastered = word.record?.mastered ?? false
                        let hasHighAccuracy = (word.record?.accuracy?.max() ?? 0) >= 70
                        
                        if !isMastered && !hasHighAccuracy {
                            firstUnmasteredWord = word
                            break
                        }
                    }
                    if firstUnmasteredWord != nil {
                        break
                    }
                }
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    if let unmasteredWord = firstUnmasteredWord,
                       let appWord = SupabaseDataController.shared.wordData(by: unmasteredWord.id) {
                        self.wordLabel.text = appWord.wordTitle
                        print("DEBUG: VocalCoach updated to show: \(appWord.wordTitle)")
                    } else {
                        self.wordLabel.text = "All words mastered!"
                        print("DEBUG: All words are mastered!")
                    }
                }
            } catch {
                print("DEBUG: Error refreshing word: \(error)")
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        videoCardView = nil
    }
}

extension VocalCoachViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SampleDataController.shared.countLevelCards()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "First", for: indexPath) as! LevelCardCollectionViewCell
        cell.layer.cornerRadius = 21
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor(red: 161/255, green: 105/255, blue: 77/255, alpha: 1.0).cgColor
        cell.backgroundColor = .clear
        cell.isUserInteractionEnabled = true
        cell.contentView.isUserInteractionEnabled = true
        cell.updatelevelCard(with: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected level card at index: \(indexPath.item)")
        
        let levelCardVC = LevelCardViewController(selectedLevelIndex: indexPath.item)
        levelCardVC.title = "Level \(indexPath.item + 1)"
        
        if let navController = self.navigationController {
            navController.pushViewController(levelCardVC, animated: true)
        } else {
            let navController = UINavigationController(rootViewController: levelCardVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? LevelCardCollectionViewCell {
            cell.animateTapDown()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? LevelCardCollectionViewCell {
            cell.animateTapUp()
        }
    }
}
