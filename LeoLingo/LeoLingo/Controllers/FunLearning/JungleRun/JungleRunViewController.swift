import UIKit
import Speech
import AVFoundation

// MARK: - Constants
private enum Constants {
    static let lionSize = CGSize(width: 150, height: 150)
    static let lionStartingX: CGFloat = 100
    static let heartSize = CGSize(width: 25, height: 25)
    static let heartSpacing: CGFloat = 30
    static let coinSize = CGSize(width: 100, height: 100)
    static let jumpHeight: CGFloat = 150
    static let jumpDuration: TimeInterval = 0.5
    static let backgroundAnimationDuration: TimeInterval = 10.0
    static let coinSpawnInterval: TimeInterval = 3.0
    static let coinAnimationDuration: TimeInterval = 5.0
    static let coinScaleAnimationDuration: TimeInterval = 0.3
    static let wordCoinDisplayDuration: TimeInterval = 5.0
    static let wordCoinExpandedSize = CGSize(width: 300, height: 300)
    static let wordLabelFont = UIFont.systemFont(ofSize: 32, weight: .bold)
    static let timerLabelFont = UIFont.systemFont(ofSize: 24, weight: .medium)
    static let overlayAlpha: CGFloat = 0.7
    static let collectSoundFileName = "collect"
    static let roarSoundFileName = "roar"
    static let popSoundFileName = "pop"
    static let themeSoundFileName = "gametheme"
    static let themeMusicVolume: Float = 0.3  // 30% volume
}

class JungleRunViewController: UIViewController {
    
    @IBOutlet var backgroundImage1: UIImageView!
    @IBOutlet var backgroundImage2: UIImageView!
    @IBOutlet var lionImageView: UIImageView!
    @IBOutlet var coinLabel: UILabel!
    @IBOutlet var diamondLabel: UILabel!
    
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    @IBOutlet var pauseMenu: UIView!
    
    
    var hearts: [UIImageView] = []
        var coins: [UIImageView] = []

        var coinValue: Int = 0
        var diamondValue: Int = 0
        var remainingHearts: Int = 5

        var wordCoinTimer: Timer?
        var wordCoin: UIImageView?
        var gameTimer: CADisplayLink?
        var isPaused: Bool = false {
            didSet {
                if isPaused {
                    gameTimer?.isPaused = true
                    wordCoinTimer?.invalidate()
                    stopBackgroundAnimation()
                } else {
                    gameTimer?.isPaused = false
                    startGameLoop()
                    startBackgroundAnimation()
                }
            }
        }
        var coinSpawnCount: Int = 0
        var gameData = JungleRun()

        private var overlayView: UIView?
        private var expandedCoinView: UIView?
        private var wordLabel: UILabel?
        private var timerLabel: UILabel?
        private var speechRecognizer: SFSpeechRecognizer?
        private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        private var recognitionTask: SFSpeechRecognitionTask?
        private var audioEngine: AVAudioEngine?
        private var countdownTimer: Timer?
        private var remainingTime: TimeInterval = Constants.wordCoinDisplayDuration

        private var collectSoundPlayer: AVAudioPlayer?
        private var roarSoundPlayer: AVAudioPlayer?
        private var popSoundPlayer: AVAudioPlayer?
        private var themeMusicPlayer: AVAudioPlayer?

        deinit {
            gameTimer?.invalidate()
            wordCoinTimer?.invalidate()
            themeMusicPlayer?.stop()
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            setupAccessibility()
            setupSpeechRecognition()
            setupSoundPlayers()
        }

        // MARK: - Pause Button Action
        @IBAction func pauseButtonTapped(_ sender: UIButton) {
            isPaused = true
            pauseMenu.isHidden = false
        }

        // MARK: - Resume Button Action
        @IBAction func resumeButtonTapped(_ sender: UIButton) {
            isPaused = false
            pauseMenu.isHidden = true
        }

        // MARK: - Restart Button Action
        @IBAction func restartButtonTapped(_ sender: UIButton) {
            pauseMenu.isHidden = true // Hide the pause menu
            resetGameState()
            startGameLoop()
            startBackgroundAnimation()
        }

        // MARK: - Quit Button Action
        @IBAction func quitButtonTapped(_ sender: UIButton) {
            let homePageVC = JungleRunHomeViewController()
            homePageVC.updateScore(coin: gameData.coins, diamond: gameData.diamonds)
            
            // Stop theme music before dismissing
            themeMusicPlayer?.stop()
            self.dismiss(animated: true)
        }

        // MARK: - Background Setup
        func setupBackground() {
            backgroundImage1 = UIImageView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
            backgroundImage1.image = UIImage(named: "JungleRunBackground1")
            backgroundImage1.contentMode = .scaleAspectFill
            view.addSubview(backgroundImage1)

            backgroundImage2 = UIImageView(frame: CGRect(x: view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height))
            backgroundImage2.image = UIImage(named: "JungleRunBackground2")
            backgroundImage2.contentMode = .scaleAspectFill
            view.addSubview(backgroundImage2)
            
            // Ensure backgrounds are behind other elements
            view.sendSubviewToBack(backgroundImage2)
            view.sendSubviewToBack(backgroundImage1)
        }

        func startBackgroundAnimation() {
            // Remove any existing animations first
            backgroundImage1.layer.removeAllAnimations()
            backgroundImage2.layer.removeAllAnimations()
            
            // Reset positions before starting new animation
            backgroundImage1.frame.origin.x = 0
            backgroundImage2.frame.origin.x = view.bounds.width
            
            UIView.animate(withDuration: Constants.backgroundAnimationDuration, delay: 0, options: [.repeat, .curveLinear], animations: {
                self.backgroundImage1.frame.origin.x -= self.view.bounds.width
                self.backgroundImage2.frame.origin.x -= self.view.bounds.width
            }, completion: nil)
        }

        func stopBackgroundAnimation() {
            // Stop the background animation by removing animations and resetting positions
            backgroundImage1.layer.removeAllAnimations()
            backgroundImage2.layer.removeAllAnimations()
            backgroundImage1.frame.origin.x = 0
            backgroundImage2.frame.origin.x = self.view.bounds.width
        }

        // MARK: - Lion Setup
        func setupLion() {
            let lionSize = Constants.lionSize
            let lionY = view.bounds.height - 250  // Position lion 250 points from bottom
            lionImageView = UIImageView(frame: CGRect(x: Constants.lionStartingX, y: lionY, width: lionSize.width, height: lionSize.height))
            lionImageView.image = UIImage(named: "JungleLion")
            lionImageView.contentMode = .scaleAspectFit
            view.addSubview(lionImageView)
        }

        // MARK: - UI Setup
        func setupLabels() {
            coinLabel.text = "💰 0"
            coinLabel.textColor = .systemBrown
            view.addSubview(coinLabel)
            diamondLabel.text = "💎 0"
            diamondLabel.textColor = .systemBrown
            view.addSubview(diamondLabel)
        }

        func setupHearts() {
            for i in 0..<5 {
                let heart = UIImageView(frame: CGRect(x: 20 + CGFloat(i * Int(Constants.heartSpacing)), y: 90, width: Constants.heartSize.width, height: Constants.heartSize.height))
                heart.image = UIImage(named: "heart")
                view.addSubview(heart)
                hearts.append(heart)
            }
        }

        // MARK: - Game Logic
        func startGameLoop() {
            guard !isPaused else { return }
            
            gameTimer = CADisplayLink(target: self, selector: #selector(updateGame))
            gameTimer?.add(to: .main, forMode: .default)
            spawnCoins()
        }

        @objc func updateGame() {
            detectCollisions()
        }

        func generateRandomWord() -> String {
            let words = ["Cat", "Dog", "Lion", "Tree", "Car"]
            guard let word = words.randomElement() else {
                // Log error and return default word
                print("Error: No words available in the words array")
                return "Word"
            }
            return word
        }

        func spawnCoins() {
            wordCoinTimer?.invalidate() // Ensure no duplicate timers

            wordCoinTimer = Timer.scheduledTimer(withTimeInterval: Constants.coinSpawnInterval, repeats: true) { timer in
                if self.isPaused { timer.invalidate(); return } // Stop spawning when paused

                self.coinSpawnCount += 1
                let isWordCoin = self.coinSpawnCount % 5 == 0 // Spawn a word coin every 5th coin instead of every 2nd
                let coinImageName = isWordCoin ? "wordCoin" : "valueCoin"
                let coin = UIImageView(image: UIImage(named: coinImageName))

                if isWordCoin {
                    self.gameData.word = self.generateRandomWord()
                }

                let randomY = self.view.bounds.height - CGFloat.random(in: 300...400)
                coin.frame = CGRect(x: self.view.bounds.width, y: randomY, width: Constants.coinSize.width, height: Constants.coinSize.height)
                self.view.addSubview(coin)
                self.coins.append(coin)

                UIView.animate(withDuration: Constants.coinAnimationDuration, delay: 0, options: .curveLinear, animations: {
                    coin.frame.origin.x = -50
                }, completion: { _ in
                    if let index = self.coins.firstIndex(of: coin) {
                        self.coins.remove(at: index)
                    }
                    coin.removeFromSuperview()
                })
            }
        }

        func detectCollisions() {
            guard let lionFrame = lionImageView.layer.presentation()?.frame else { return }
            
            // Use Set for O(1) lookups
            let coinsToRemove = Set(coins.filter { coin in
                guard let coinFrame = coin.layer.presentation()?.frame else { return false }
                return lionFrame.intersects(coinFrame)
            })
            
            for coin in coinsToRemove {
                handleCoinCollision(coin)
            }
        }
        
        private func handleCoinCollision(_ coin: UIImageView) {
            if coin.image == UIImage(named: "valueCoin") {
                gameData.coins += 100
                updateCoinLabel()
                playCollectSound()
            } else if let coinImage = coin.image, coinImage == UIImage(named: "wordCoin") {
                handleWordCoin(coin)
            }
            coin.removeFromSuperview()
            if let index = coins.firstIndex(of: coin) {
                coins.remove(at: index)
            }
        }

        func handleWordCoin(_ coin: UIImageView) {
            if let word = gameData.word {
                showWordCoinChallenge(with: word, coinView: coin)
            } else {
                // Fallback to a default word if none is available
                showWordCoinChallenge(with: "Word", coinView: coin)
            }
            coin.removeFromSuperview()
            if let index = coins.firstIndex(of: coin) {
                coins.remove(at: index)
            }
        }

        func updateCoinLabel() {
            coinLabel.text = "🪙 \(gameData.coins)"
        }

        func updateDiamondLabel() {
            diamondLabel.text = "💎 \(gameData.diamonds)"
        }

        func loseHeart() {
            if remainingHearts > 0 {
                remainingHearts -= 1
                hearts[remainingHearts].isHidden = true
            }
            if remainingHearts == 0 {
                gameOver()
            }
        }

        func gameOver() {
            gameTimer?.invalidate()
            wordCoinTimer?.invalidate()
            stopBackgroundAnimation()

            let alert = UIAlertController(title: "Game Over", message: "Your Score:\nCoins: \(gameData.coins)\nDiamonds: \(gameData.diamonds)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Play Again", style: .default, handler: { _ in
                self.resetGameState()
                self.startGameLoop()
                self.startBackgroundAnimation()
            }))
            present(alert, animated: true, completion: nil)
        }

        // MARK: - Reset Game State
        func resetGameState() {
            gameData = JungleRun()
            for heart in hearts {
                heart.isHidden = false
            }
            updateCoinLabel()
            updateDiamondLabel()
            remainingHearts = 5
            
            // Clear all coins and their animations
            coins.forEach { coin in
                coin.layer.removeAllAnimations()
                coin.removeFromSuperview()
            }
            coins.removeAll()
            
            // Reset background position
            stopBackgroundAnimation()
            startBackgroundAnimation()
            
            // Restart theme music if it's not playing
            if themeMusicPlayer?.isPlaying == false {
                themeMusicPlayer?.play()
            }
        }

        // MARK: - Gesture Handling
        func setupTapGesture() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            view.addGestureRecognizer(tapGesture)
        }

        @objc func handleTap() {
            UIView.animate(withDuration: Constants.jumpDuration / 2, animations: {
                self.lionImageView.frame.origin.y -= Constants.jumpHeight
            }, completion: { _ in
                UIView.animate(withDuration: Constants.jumpDuration / 2, animations: {
                    self.lionImageView.frame.origin.y += Constants.jumpHeight
                })
            })
        }

        // MARK: - UI Setup
        func setupUI() {
            setupBackground()
            setupLion()
            setupLabels()
            setupHearts()
            setupTapGesture()
            setupPauseMenu()
            
            startBackgroundAnimation()
            startGameLoop()
        }
        
        func setupPauseMenu() {
            pauseMenu.layer.borderWidth = 5
            pauseMenu.layer.cornerRadius = 21
            pauseMenu.layer.borderColor = UIColor(red: 36/255, green: 61/255, blue: 35/255, alpha: 1).cgColor
            pauseMenu.isHidden = true
            
            view.bringSubviewToFront(pauseButton)
            view.bringSubviewToFront(pauseMenu)
        }

        // MARK: - Accessibility
        func setupAccessibility() {
            lionImageView.isAccessibilityElement = true
            lionImageView.accessibilityLabel = "Lion character"
            lionImageView.accessibilityHint = "Tap to make the lion jump"
            
            coinLabel.isAccessibilityElement = true
            coinLabel.accessibilityLabel = "Coins collected"
            
            diamondLabel.isAccessibilityElement = true
            diamondLabel.accessibilityLabel = "Diamonds collected"
            
            pauseButton.isAccessibilityElement = true
            pauseButton.accessibilityLabel = "Pause game"
            
            // Add accessibility for hearts
            for (index, heart) in hearts.enumerated() {
                heart.isAccessibilityElement = true
                heart.accessibilityLabel = "Heart \(index + 1)"
            }
        }

        private func setupSpeechRecognition() {
            speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
            
            SFSpeechRecognizer.requestAuthorization { authStatus in
                DispatchQueue.main.async {
                    switch authStatus {
                    case .authorized:
                        print("Speech recognition authorized")
                    case .denied:
                        print("User denied speech recognition authorization")
                    case .restricted:
                        print("Speech recognition restricted on this device")
                    case .notDetermined:
                        print("Speech recognition not yet authorized")
                    @unknown default:
                        print("Unknown authorization status")
                    }
                }
            }
        }
        
        private func setupSoundPlayers() {
            // Configure audio session for sound effects
            do {
                try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to set up audio session: \(error)")
            }
            
            // Setup theme music
            if let soundURL = Bundle.main.url(forResource: Constants.themeSoundFileName, withExtension: "mp3") {
                themeMusicPlayer = try? AVAudioPlayer(contentsOf: soundURL)
                themeMusicPlayer?.volume = Constants.themeMusicVolume
                themeMusicPlayer?.numberOfLoops = -1  // Infinite loop
                themeMusicPlayer?.prepareToPlay()
                themeMusicPlayer?.play()
            }
            
            // Setup collect sound
            if let soundURL = Bundle.main.url(forResource: Constants.collectSoundFileName, withExtension: "mp3") {
                collectSoundPlayer = try? AVAudioPlayer(contentsOf: soundURL)
                collectSoundPlayer?.prepareToPlay()
            }
            
            // Setup roar sound
            if let soundURL = Bundle.main.url(forResource: Constants.roarSoundFileName, withExtension: "mp3") {
                roarSoundPlayer = try? AVAudioPlayer(contentsOf: soundURL)
                roarSoundPlayer?.prepareToPlay()
            }
            
            // Setup pop sound
            if let soundURL = Bundle.main.url(forResource: Constants.popSoundFileName, withExtension: "mp3") {
                popSoundPlayer = try? AVAudioPlayer(contentsOf: soundURL)
                popSoundPlayer?.prepareToPlay()
            }
        }
        
        private func playCollectSound() {
            collectSoundPlayer?.currentTime = 0
            collectSoundPlayer?.play()
        }
        
        private func playRoarSound() {
            roarSoundPlayer?.currentTime = 0
            roarSoundPlayer?.play()
        }
        
        private func playPopSound() {
            popSoundPlayer?.currentTime = 0
            popSoundPlayer?.play()
        }
        
        private func showWordCoinChallenge(with word: String, coinView: UIImageView) {
            // Stop all animations first
            isPaused = true
            stopBackgroundAnimation()
            coins.forEach { $0.layer.removeAllAnimations() }
            
            // Create overlay
            let overlay = UIView(frame: view.bounds)
            overlay.backgroundColor = UIColor.black.withAlphaComponent(Constants.overlayAlpha)
            view.addSubview(overlay)
            self.overlayView = overlay
            
            // Create expanded coin view with initial position at coin's location
            let expandedView = UIView(frame: CGRect(origin: .zero, size: coinView.bounds.size))
            expandedView.center = coinView.center
            expandedView.backgroundColor = .clear
            
            // Add the coin image
            let coinImageView = UIImageView(frame: expandedView.bounds)
            coinImageView.image = UIImage(named: "wordCoin")
            coinImageView.contentMode = .scaleAspectFit
            expandedView.addSubview(coinImageView)
            
            // Add word label
            let label = UILabel(frame: expandedView.bounds)
            label.text = word
            label.textAlignment = .center
            label.font = Constants.wordLabelFont
            label.textColor = .white
            expandedView.addSubview(label)
            self.wordLabel = label
            
            // Add timer label
            let timerLabel = UILabel(frame: CGRect(x: 0, y: -40, width: expandedView.bounds.width, height: 30))
            timerLabel.textAlignment = .center
            timerLabel.font = Constants.timerLabelFont
            timerLabel.textColor = .white
            expandedView.addSubview(timerLabel)
            self.timerLabel = timerLabel
            
            view.addSubview(expandedView)
            self.expandedCoinView = expandedView
            
            // Animate the expansion from coin's position to center
            expandedView.transform = CGAffineTransform(scaleX: 1, y: 1)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                expandedView.transform = CGAffineTransform(scaleX: Constants.wordCoinExpandedSize.width / Constants.coinSize.width,
                                                         y: Constants.wordCoinExpandedSize.height / Constants.coinSize.height)
                expandedView.center = self.view.center
            }) { _ in
                self.startSpeechRecognition(for: word)
                self.startCountdownTimer()
            }
        }
        
        private func startCountdownTimer() {
            remainingTime = Constants.wordCoinDisplayDuration
            updateTimerLabel()
            
            countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.remainingTime -= 1
                self.updateTimerLabel()
                
                if self.remainingTime <= 0 {
                    self.handleWordCoinTimeout()
                }
            }
        }
        
        private func updateTimerLabel() {
            timerLabel?.text = String(format: "%.0f", remainingTime)
        }
        
        private func startSpeechRecognition(for targetWord: String) {
            guard let recognizer = speechRecognizer, recognizer.isAvailable else { return }
            
            audioEngine = AVAudioEngine()
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            guard let recognitionRequest = recognitionRequest else { return }
            
            recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                
                if let result = result {
                    let spokenText = result.bestTranscription.formattedString.lowercased()
                    if spokenText.contains(targetWord.lowercased()) {
                        self.handleCorrectPronunciation()
                    }
                }
            }
            
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers, .allowBluetooth])
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                print("Failed to set up audio session for speech recognition: \(error)")
            }
            
            let inputNode = audioEngine?.inputNode
            let recordingFormat = inputNode?.outputFormat(forBus: 0)
            
            inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine?.prepare()
            try? audioEngine?.start()
        }
        
        private func handleCorrectPronunciation() {
            cleanupWordCoinChallenge()
            gameData.diamonds += 1
            updateDiamondLabel()
            
            // Reset audio session for sound effects
            do {
                try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to reset audio session: \(error)")
            }
            
            playRoarSound()
            resumeGame()
        }
        
        private func handleWordCoinTimeout() {
            cleanupWordCoinChallenge()
            
            // Reset audio session for sound effects
            do {
                try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to reset audio session: \(error)")
            }
            
            // Play pop sound and handle heart loss
            playPopSound()
            loseHeart()
            resumeGame()
        }
        
        private func cleanupWordCoinChallenge() {
            countdownTimer?.invalidate()
            countdownTimer = nil
            
            audioEngine?.stop()
            audioEngine?.inputNode.removeTap(onBus: 0)
            recognitionRequest?.endAudio()
            recognitionTask?.cancel()
            
            // Reset audio session before cleanup
            do {
                try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to reset audio session during cleanup: \(error)")
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                self.overlayView?.alpha = 0
                self.expandedCoinView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }) { _ in
                self.overlayView?.removeFromSuperview()
                self.expandedCoinView?.removeFromSuperview()
                self.overlayView = nil
                self.expandedCoinView = nil
            }
        }
        
        private func resumeGame() {
            isPaused = false
            startBackgroundAnimation()
            spawnCoins() // Restart coin spawning
        }
    }
