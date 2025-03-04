import UIKit
import AVFoundation
import Speech
import Combine

class WaveformView: UIView {
    private var barLayers: [CALayer] = []
    private var displayLink: CADisplayLink?
    private let numberOfBars: Int = 40 // Increased number of bars for smoother look
    private let waveformColor = UIColor(red: 79/255, green: 144/255, blue: 76/255, alpha: 1.0) // #4F904C
    private var phase: CGFloat = 0
    private var animationStartTime: CFTimeInterval = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBars()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBars()
    }
    
    private func setupBars() {
        // Remove existing bars
        barLayers.forEach { $0.removeFromSuperlayer() }
        barLayers.removeAll()
        
        let barWidth: CGFloat = 2 // Thinner bars
        let spacing: CGFloat = 4 // More spacing between bars
        let totalWidth = CGFloat(numberOfBars) * (barWidth + spacing)
        let startX = (bounds.width - totalWidth) / 2
        
        for i in 0..<numberOfBars {
            let bar = CALayer()
            bar.backgroundColor = waveformColor.cgColor
            let x = startX + CGFloat(i) * (barWidth + spacing)
            // Set initial height
            let initialHeight: CGFloat = 20 + CGFloat(arc4random_uniform(20))
            bar.frame = CGRect(x: x, y: bounds.height/2 - initialHeight/2, width: barWidth, height: initialHeight)
            bar.cornerRadius = barWidth/2
            
            // Add initial animation
            let animation = CABasicAnimation(keyPath: "bounds.size.height")
            animation.duration = 0.5
            animation.repeatCount = .infinity
            animation.autoreverses = true
            bar.add(animation, forKey: "height")
            
            layer.addSublayer(bar)
            barLayers.append(bar)
        }
    }
    
    func startAnimation() {
        isHidden = false
        alpha = 1
        
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateBars))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 60, preferred: 60)
        displayLink?.add(to: .main, forMode: .common)
        
        animationStartTime = CACurrentMediaTime()
        phase = 0
        
        // Ensure bars are visible with initial animation
        barLayers.forEach { bar in
            bar.opacity = 1.0
            let initialHeight: CGFloat = 20 + CGFloat(arc4random_uniform(20))
            bar.frame = CGRect(x: bar.frame.origin.x,
                             y: bounds.height/2 - initialHeight/2,
                             width: bar.frame.width,
                             height: initialHeight)
        }
    }
    
    func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        
        // Smooth fade out animation
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        barLayers.forEach { bar in
            let finalHeight: CGFloat = 20
            bar.frame = CGRect(x: bar.frame.origin.x,
                             y: bounds.height/2 - finalHeight/2,
                             width: bar.frame.width,
                             height: finalHeight)
        }
        CATransaction.commit()
    }
    
    @objc private func updateBars() {
        let currentTime = CACurrentMediaTime()
        let elapsedTime = currentTime - animationStartTime
        phase += 0.05 // Slower phase change for smoother animation
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        for (index, bar) in barLayers.enumerated() {
            // Create more complex wave patterns
            let normalizedIndex = CGFloat(index) / CGFloat(numberOfBars)
            let primaryWave = sin(phase + normalizedIndex * 4.0) // Primary wave
            let secondaryWave = sin(phase * 1.5 + normalizedIndex * 2.0) * 0.5 // Secondary wave
            let fastWave = sin(phase * 3.0 + normalizedIndex) * 0.3 // Fast wave
            
            // Add some random noise for natural variation
            let noise = CGFloat(arc4random_uniform(10)) / 100.0
            
            // Combine all waves
            let combinedWave = primaryWave + secondaryWave + fastWave + noise
            
            // Calculate height with more variation
            let minHeight: CGFloat = 20
            let maxHeight: CGFloat = 80
            let heightRange = maxHeight - minHeight
            let waveHeight = minHeight + (heightRange * abs(combinedWave))
            
            // Update bar position and height with smooth transition
            let yPosition = bounds.height/2 - waveHeight/2
            bar.frame = CGRect(x: bar.frame.origin.x,
                             y: yPosition,
                             width: bar.frame.width,
                             height: waveHeight)
        }
        
        CATransaction.commit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupBars()
    }
}

class PracticeScreenViewController: UIViewController {
    
    var levels: [Level] = []
    private let synthesizer = AVSpeechSynthesizer()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var noiseTimer: Timer?
    private let speechProcessor = SpeechProcessor()
    private var speechSubscription: AnyCancellable?
    private var countdownTimer: Timer?
    
    private lazy var waveformView: WaveformView = {
        let view = WaveformView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.alpha = 0
        return view
    }()
    
    private var isListening = false {
        didSet {
            updateCountdownLabel()
            if isListening {
                waveformView.alpha = 1
                waveformView.startAnimation()
            } else {
                waveformView.stopAnimation()
                UIView.animate(withDuration: 0.3) {
                    self.waveformView.alpha = 0
                }
            }
        }
    }
    
    private lazy var countdownLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.textColor = .systemGreen
        label.alpha = 0
        return label
    }()
    
    private lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemRed
        label.alpha = 0
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        button.backgroundColor = .white
        button.layer.cornerRadius = 30
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.2
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)
        let image = UIImage(systemName: "chevron.left", withConfiguration: symbolConfig)?
            .withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @IBOutlet var directionLabel: UILabel!
    @IBOutlet var mojoImage: UIImageView!
    @IBOutlet var wordImage: UIImageView!
    

    @IBOutlet var levelProgress: UIProgressView!
    
    @IBOutlet var levelLabel: UILabel!
    
    var mojoImageData = ["mojo2", "mojoHearing"]
    
    var levelIndex = 0
    var currentIndex = 0
    var consecutiveWrongWords = 0
    var currentWordAttempts = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Clear any persisted data
        clearUserDefaults()
        directionLabel.adjustsFontSizeToFitWidth = true
        
        // Load levels from Supabase
        Task {
            do {
                guard let userId = SupabaseDataController.shared.userId else {
                    print("No user ID found")
                    return
                }
                
                let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                // Keep all words, including practiced ones
                self.levels = userData.userLevels
                
                if self.levels.isEmpty {
                    // Show completion message if no words available
                    showCompletionMessage()
                } else {
                    // Always start from the first available level
                    self.levelIndex = 0
                    self.currentIndex = 0
                    updateUI()
                }
            } catch {
                handleError(error)
            }
        }
        
        setupBackButton()
        setupCountdownLabel()
        setupWarningLabel()
        requestSpeechAuthorization()
        startNoiseMonitoring()
        
        // Add speech processor setup
        speechProcessor.requestSpeechRecognitionPermission()
        
        levelLabel.layer.cornerRadius = 21
        levelLabel.layer.masksToBounds = true
        
        // Add tap gesture to wordImage
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(wordImageTapped))
        wordImage.isUserInteractionEnabled = true
        wordImage.addGestureRecognizer(tapGesture)
        
        // Hide the default back button
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopNoiseMonitoring()
    }
    
    private func setupCountdownLabel() {
        view.addSubview(countdownLabel)
        view.addSubview(waveformView)
        
        NSLayoutConstraint.activate([
            countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            countdownLabel.heightAnchor.constraint(equalToConstant: 60),
            countdownLabel.widthAnchor.constraint(equalToConstant: 60),
            
            waveformView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            waveformView.centerYAnchor.constraint(equalTo: countdownLabel.centerYAnchor),
            waveformView.widthAnchor.constraint(equalToConstant: 200),
            waveformView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Ensure countdown label is above waveform
        view.bringSubviewToFront(countdownLabel)
    }
    
    private func updateCountdownLabel() {
        if isListening {
            countdownLabel.alpha = 0
        }
    }
    
    private func startCountdown() {
        var count = 3
        countdownLabel.alpha = 1
        countdownLabel.text = "\(count)"
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            count -= 1
            if count > 0 {
                self.countdownLabel.text = "\(count)"
            } else {
                timer.invalidate()
                self.countdownLabel.alpha = 0
                self.startSpeechRecognition()
            }
        }
    }
    
    private func setupWarningLabel() {
        view.addSubview(warningLabel)
        
        NSLayoutConstraint.activate([
            warningLabel.bottomAnchor.constraint(equalTo: countdownLabel.topAnchor, constant: -8),
            warningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            warningLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            warningLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                default:
                    self?.handleError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Speech recognition not authorized"]))
                }
            }
        }
    }
    
    private func startListening() {
        // Check noise level before starting
        if warningLabel.alpha == 1.0 {
            // Show alert for noisy environment
            let alert = UIAlertController(
                title: "Noisy Environment",
                message: "The background noise level is high. Please move to a quieter place.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                // Restart the countdown after user acknowledges
                self?.startCountdown()
            })
            
            present(alert, animated: true)
        } else {
            startSpeechRecognition()
        }
    }
    
    private func startSpeechRecognition() {
        // Cancel any existing subscription
        speechSubscription?.cancel()
        
        let currentWord = getCurrentWord()
        let currentAttempt = levels[levelIndex].words[currentIndex].record?.attempts ?? 0
        
        // Start recording with current word and attempt number
        speechProcessor.startRecording(word: currentWord, wordId: levels[levelIndex].words[currentIndex].id, attemptNumber: currentAttempt + 1)
        isListening = true
        
        // Handle speech recognition results
        speechSubscription = speechProcessor.$userSpokenText
            .filter { !$0.isEmpty }
            .sink { [weak self] spokenText in
                guard let self = self else { return }
                
                let distance = self.speechProcessor.levenshteinDistance(spokenText.lowercased(), currentWord.lowercased())
                let maxLength = max(spokenText.count, currentWord.count)
                let accuracy = max(0, 100.0 - (Double(distance) / Double(maxLength)) * 100.0)
                
                // Record the accuracy and recording path
                self.recordAccuracy(accuracy)
                
                if accuracy >= 70.0 {
                    self.handleCorrectPronunciation()
                } else {
                    self.handleIncorrectPronunciation()
                }
                
                self.stopListening()
            }
            
        // Set a timeout for speech recognition
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            guard let self = self else { return }
            if self.isListening {
                self.stopListening()
                self.handleIncorrectPronunciation()
            }
        }
    }
    
    private func stopListening() {
        speechSubscription?.cancel()
        speechProcessor.stopRecording()
        isListening = false
    }
    
    private func getCurrentWord() -> String {
        let currentData = levels[levelIndex].words[currentIndex]
        if let wordData = SupabaseDataController.shared.wordData(by: currentData.id) {
            return wordData.wordTitle
        }
        return ""
    }
    
    private func handleIncorrectPronunciation() {
        currentWordAttempts += 1
        
        if currentWordAttempts >= 2 {
            // Reset attempts for next word
            currentWordAttempts = 0
            consecutiveWrongWords += 1
            
            if consecutiveWrongWords >= 3 {
                // Reset counter and show fun learning
                consecutiveWrongWords = 0
                showFunLearningPopOver()
            } else {
                // Show incorrect popup and move to next word after dismissal
                showPopover(isCorrect: false, levelChange: false) {
                    // Move to next word and start its utterance after popover dismissal
                    self.moveToNextWord()
                }
            }
        } else {
            // First attempt was wrong, give another try
            showPopover(isCorrect: false, levelChange: false) {
                // Get the current word and direction after popover dismissal
                let currentWord = self.getCurrentWord()
                let direction = "This is \(currentWord). Say \(currentWord)."
                
                // Update the direction label and pronounce it
                self.directionLabel.text = direction
                self.pronounceDirection(direction)
                
                // Start countdown after direction is spoken
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.startCountdown()
                }
            }
        }
        
        // Record the attempt in the database
        Task {
            do {
                let currentWord = levels[levelIndex].words[currentIndex]
                let spokenText = speechProcessor.userSpokenText
                let wordTitle = getCurrentWord()
                let distance = speechProcessor.levenshteinDistance(spokenText.lowercased(), wordTitle.lowercased())
                let maxLength = max(spokenText.count, wordTitle.count)
                let accuracy = max(0, 100.0 - (Double(distance) / Double(maxLength)) * 100.0)
                
                try await SupabaseDataController.shared.updateWordProgress(
                    wordId: currentWord.id,
                    accuracy: accuracy,
                    recordingPath: speechProcessor.getRecordingURL()?.path
                )
            } catch {
                print("Error updating word progress: \(error)")
            }
        }
    }
    
    private func handleCorrectPronunciation() {
        // Reset counters on correct pronunciation
        consecutiveWrongWords = 0
        
        // Mark current word as practiced in database
        Task {
            do {
                let currentWord = levels[levelIndex].words[currentIndex]
                let spokenText = speechProcessor.userSpokenText
                let wordTitle = getCurrentWord()
                let distance = speechProcessor.levenshteinDistance(spokenText.lowercased(), wordTitle.lowercased())
                let maxLength = max(spokenText.count, wordTitle.count)
                let accuracy = max(0, 100.0 - (Double(distance) / Double(maxLength)) * 100.0)
                
                try await SupabaseDataController.shared.updateWordProgress(
                    wordId: currentWord.id,
                    accuracy: accuracy,
                    recordingPath: speechProcessor.getRecordingURL()?.path
                )
                
                // Refresh data using userId
                guard let userId = SupabaseDataController.shared.userId else {
                    print("No user ID found")
                    return
                }
                let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                self.levels = userData.userLevels
                
                // Show success feedback and move to next word on main thread
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let isLastWordInLevel = currentIndex == levels[levelIndex].words.count - 1
                    
                    // Show the success popup first
                    self.showPopover(isCorrect: true, levelChange: isLastWordInLevel) {
                        if self.currentIndex >= self.levels[self.levelIndex].words.count - 1 {
                            if self.levelIndex < self.levels.count - 1 {
                                // Move to next level if available
                                self.levelIndex += 1
                                self.currentIndex = 0
                                self.showLevelChangePopover()
                                self.showConfettiEffect()
                            } else {
                                // At the last word of the last level
                                self.levelIndex = 0
                                self.currentIndex = 0
                                self.updateUIAfterPopover()
                            }
                        } else {
                            // Move to next word in current level
                            self.currentIndex += 1
                            self.updateUIAfterPopover()
                        }
                    }
                }
            } catch {
                print("Error in handleCorrectPronunciation: \(error)")
            }
        }
    }
    
    @objc private func wordImageTapped() {
        let currentData = levels[levelIndex].words[currentIndex]
        if let word = DataController.shared.wordData(by: currentData.id) {
            // Only pronounce the word itself, not the full direction
            pronounceWord(word.wordTitle)
        }
    }
    
    private func pronounceWord(_ word: String) {
        // Stop any ongoing speech
        synthesizer.stopSpeaking(at: .immediate)
        
        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    private func pronounceDirection(_ direction: String) {
        // Stop any ongoing speech
        synthesizer.stopSpeaking(at: .immediate)
        
        let utterance = AVSpeechUtterance(string: direction)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4  // Slightly slower for better clarity
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    func getDirection(for index: Int, at levelIndex: Int) -> String {
        let appLevels = SupabaseDataController.shared.getLevelsData()
        let currentWord = levels[levelIndex].words[index]
        
        for level in appLevels {
            if let word = level.words.first(where: { $0.id == currentWord.id }) {
                return "This is \(word.wordTitle). Say \(word.wordTitle)."
            }
        }
        return ""
    }
    
    func updateUI() {
        // Validate indices before updating UI
        guard !levels.isEmpty,
              levelIndex < levels.count,
              currentIndex < levels[levelIndex].words.count else {
            showCompletionMessage()
            return
        }
        
        let currentData = levels[levelIndex].words[currentIndex]
        directionLabel.text = ""
        
        // Get word data from app levels
        let appLevels = SupabaseDataController.shared.getLevelsData()
        var wordImage: String?
        var wordTitle: String?
        var levelTitle: String?
        
        // Update level label with current level
        if let currentLevel = appLevels.first(where: { $0.id == levels[levelIndex].id }) {
            levelTitle = currentLevel.levelTitle
            levelLabel.text = levelTitle
        }
        
        // Update progress bar based on current word index
        let totalWordsInLevel = levels[levelIndex].words.count
        let currentProgress = Float(currentIndex + 1) / Float(totalWordsInLevel)
        levelProgress.progress = currentProgress
        
        for level in appLevels {
            if let word = level.words.first(where: { $0.id == currentData.id }) {
                wordImage = word.wordImage
                wordTitle = word.wordTitle
                break
            }
        }
        
        if let wordImage = wordImage {
            self.wordImage.image = UIImage(named: wordImage)
        }
        self.mojoImage.image = UIImage(named: "mojo2")
        
        if let wordTitle = wordTitle {
            let direction = "This is \(wordTitle). Say \(wordTitle)."
            
            // Sequence the animations
            animateWordImage()
            
            // Update direction label and start utterance after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                guard let self = self else { return }
                self.directionLabel.text = direction
                self.pronounceDirection(direction)
                
                // Start countdown after direction is spoken
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.startCountdown()
                }
            }
        }
    }
    
    //MARK: - Animation
    func animateWordImage() {
        wordImage.transform = CGAffineTransform(translationX: 0, y: -500)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.wordImage.transform = .identity
        }, completion: nil)
    }
    
    func typeEffect(text: String, label: UILabel?) {
        guard let label = label else { return }
        label.text = ""
        var characterIndex = 0.0
        for letter in text {
            Timer.scheduledTimer(withTimeInterval: 0.05 * characterIndex, repeats: false) { _ in
                label.text?.append(letter)
            }
            characterIndex += 1
        }
    }
    
    func moveToNextWord() {
        Task {
            do {
                // Use userId consistently for fetching data
                guard let userId = SupabaseDataController.shared.userId else {
                    print("No user ID found")
                    return
                }
                
                // Refresh data from Supabase using userId
                let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                self.levels = userData.userLevels
                
                // Move to next word
                currentIndex += 1
                
                // If we've reached the end of current level's words
                if currentIndex >= levels[levelIndex].words.count {
                    // Try to move to next level
                    levelIndex += 1
                    currentIndex = 0
                    
                    // If we've reached the end of all levels
                    if levelIndex >= levels.count {
                        showCompletionMessage()
                        return
                    }
                    
                    showLevelChangePopover()
                    showConfettiEffect()
                } else {
                    // Update UI with the next word
                    updateUI()
                }
            } catch {
                print("Error in moveToNextWord: \(error)")
                // Handle the error gracefully without disrupting the user experience
                DispatchQueue.main.async {
                    self.handleError(error)
                }
            }
        }
    }
    
    func showFunLearningPopOver() {
        let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
        if let popoverVC = storyboard.instantiateViewController(withIdentifier: "PopoverViewController") as? PopoverViewController {
            // Change to full screen presentation
            popoverVC.modalPresentationStyle = .fullScreen
            popoverVC.modalTransitionStyle = .crossDissolve
            
            popoverVC.configurePopover(message: "Lets Play Some Games!", image: "mojo2")
            
            // Present the popover and ensure navigation happens after dismissal
            present(popoverVC, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    guard let self = self else { return }
                    // Ensure we're on the main thread for UI updates
                    DispatchQueue.main.async {
                        popoverVC.dismiss(animated: true) { [weak self] in
                            guard let self = self else { return }
                            // Load FunLearning storyboard
                            let storyboard = UIStoryboard(name: "FunLearning", bundle: nil)
                            if let funLearningVC = storyboard.instantiateViewController(withIdentifier: "FunLearningVC") as? FunLearningViewController {
                                // Push to navigation stack
                                self.navigationController?.pushViewController(funLearningVC, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func showLevelChangePopover() {
        let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
        if let popoverVC = storyboard.instantiateViewController(withIdentifier: "PopoverViewController") as? PopoverViewController {
            // Change to full screen presentation
            popoverVC.modalPresentationStyle = .fullScreen
            popoverVC.modalTransitionStyle = .crossDissolve
            
            let appLevels = SupabaseDataController.shared.getLevelsData()
            if let level = appLevels.first(where: { $0.id == levels[levelIndex].id }) {
                popoverVC.configurePopover(message: "Congratulations!! You have completed this level. Would you like to proceed to the next level? ", image: level.levelImage)
                
                // Present the popover and dismiss after 2 seconds
                present(popoverVC, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                        guard let self = self else { return }
                        popoverVC.dismiss(animated: true) {
                            self.updateUIAfterPopover()
                        }
                    }
                }
            }
        }
    }
    
    func showPopover(isCorrect: Bool, levelChange: Bool, completion: (() -> Void)? = nil) {
        let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
        if let popoverVC = storyboard.instantiateViewController(withIdentifier: "PopoverViewController") as? PopoverViewController {
            // Change to full screen presentation
            popoverVC.modalPresentationStyle = .fullScreen
            popoverVC.modalTransitionStyle = .crossDissolve
            
            // Update messages to reflect pronunciation accuracy
            if isCorrect && !levelChange {
                popoverVC.configurePopover(message: "Great pronunciation!", image: "mojo2")
                
                // Present the popover
                present(popoverVC, animated: true) {
                    // Automatically dismiss after 2 seconds and execute the next action
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                        guard let self = self else { return }
                        popoverVC.dismiss(animated: true) {
                            // Progress to next word or level
                            if self.currentIndex >= self.levels[self.levelIndex].words.count - 1 {
                                // If we're at the last word of the level
                                if self.levelIndex < self.levels.count - 1 {
                                    // Move to next level if available
                                    self.levelIndex += 1
                                    self.currentIndex = 0
                                    self.showLevelChangePopover()
                                    self.showConfettiEffect()
                                } else {
                                    // At the last word of the last level, loop back to first level
                                    self.levelIndex = 0
                                    self.currentIndex = 0
                                    self.updateUIAfterPopover()
                                }
                            } else {
                                // Move to next word in current level
                                self.currentIndex += 1
                                self.updateUIAfterPopover()
                            }
                        }
                    }
                }
            } else if isCorrect && levelChange {
                showLevelChangePopover()
                return
            } else {
                popoverVC.configurePopover(message: "Let's try that pronunciation again.", image: "SadMojo")
                // Present the popover and dismiss after 2 seconds
                present(popoverVC, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        popoverVC.dismiss(animated: true) {
                            completion?()
                        }
                    }
                }
            }
        }
    }
    
    // New function to handle UI updates after popover dismissal
    private func updateUIAfterPopover() {
        // Validate indices before updating UI
        guard !levels.isEmpty,
              levelIndex < levels.count,
              currentIndex < levels[levelIndex].words.count else {
            showCompletionMessage()
            return
        }
        
        let currentData = levels[levelIndex].words[currentIndex]
        directionLabel.text = ""
        
        // Get word data from app levels
        let appLevels = SupabaseDataController.shared.getLevelsData()
        var wordImage: String?
        var wordTitle: String?
        
        for level in appLevels {
            if let word = level.words.first(where: { $0.id == currentData.id }) {
                wordImage = word.wordImage
                wordTitle = word.wordTitle
                break
            }
        }
        
        if let wordImage = wordImage {
            self.wordImage.image = UIImage(named: wordImage)
        }
        self.mojoImage.image = UIImage(named: "mojo2")
        
        if let wordTitle = wordTitle {
            let direction = "This is \(wordTitle). Say \(wordTitle)."
            
            // Sequence the animations
            animateWordImage()
            
            // Update direction label and start utterance after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                guard let self = self else { return }
                self.directionLabel.text = direction
                self.pronounceDirection(direction)
                
                // Start countdown after direction is spoken
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.startCountdown()
                }
            }
        }
    }
    
    func navigateToFunLearning() {
        let storyboard = UIStoryboard(name: "FunLearning", bundle: nil)
        if let funLearningVC = storyboard.instantiateViewController(withIdentifier: "FunLearningVC") as? FunLearningViewController {
            self.navigationController?.pushViewController(funLearningVC, animated: true)
        }
    }
    
    func showConfettiEffect() {
        let confettiLayer = CAEmitterLayer()
        confettiLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -10)
        confettiLayer.emitterShape = .line
        confettiLayer.emitterSize = CGSize(width: view.bounds.width, height: 1)
        
        let colors: [UIColor] = [.red, .green, .blue, .yellow, .purple, .orange]
        let shapes: [UIImage] = [UIImage(named: "confetti1")!, UIImage(named: "confetti2")!, UIImage(named: "confetti3")!]
        
        var cells: [CAEmitterCell] = []
        for color in colors {
            for shape in shapes {
                let cell = CAEmitterCell()
                cell.birthRate = 6
                cell.lifetime = 5.0
                cell.velocity = CGFloat.random(in: 150...200)
                cell.velocityRange = 50
                cell.emissionLongitude = .pi
                cell.emissionRange = .pi / 4
                cell.spin = 2
                cell.spinRange = 3
                cell.scale = 0.1
                cell.scaleRange = 0.2
                cell.contents = shape.cgImage
                cell.color = color.cgColor
                cells.append(cell)
            }
        }
        confettiLayer.emitterCells = cells
        view.layer.addSublayer(confettiLayer)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            confettiLayer.removeFromSuperlayer()
        }
    }
    
    private func recordAccuracy(_ accuracy: Double) {
        let currentWord = levels[levelIndex].words[currentIndex]
        
        Task {
            do {
                // Get recording path from speech processor if available
                let recordingPath = speechProcessor.getRecordingURL()?.path
                
                // Update word progress in Supabase
                try await SupabaseDataController.shared.updateWordProgress(
                    wordId: currentWord.id,
                    accuracy: accuracy,
                    recordingPath: recordingPath
                )
                
                // Refresh local data using userId
                guard let userId = SupabaseDataController.shared.userId else {
                    print("No user ID found")
                    return
                }
                let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                self.levels = userData.userLevels
                
            } catch {
                print("Error in recordAccuracy: \(error)")
            }
        }
    }
    
    private func updateLevelProgress(_ accuracy: Double) {
        let currentLevel = levels[levelIndex]
        
        // Calculate overall level progress and update UI
        updateProgressUI()
    }
    
    private func updateProgressUI() {
        let currentLevel = levels[levelIndex]
        
        // Calculate progress
        let totalWords = currentLevel.words.count
        let practicedWords = currentLevel.words.filter { $0.isPracticed }.count
        let progress = Float(practicedWords) / Float(totalWords)
        
        // Calculate accuracy
        let accuracies = currentLevel.words.compactMap { word -> Double? in
            if let record = word.record, let accuracies = record.accuracy, !accuracies.isEmpty {
                return accuracies.reduce(0.0, +) / Double(accuracies.count)
            }
            return nil
        }
        let accuracy = accuracies.isEmpty ? 0.0 : accuracies.reduce(0.0, +) / Double(accuracies.count)
        
        // Update progress bar if it exists
        if let progressBar = view.viewWithTag(100) as? UIProgressView {
            progressBar.progress = progress
        }
        
        // Update accuracy label if it exists
        if let accuracyLabel = view.viewWithTag(101) as? UILabel {
            accuracyLabel.text = String(format: "%.1f%%", accuracy)
        }
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
        
        // Ensure the button is always on top of other views
        view.bringSubviewToFront(backButton)
    }
    
    @objc private func backButtonTapped() {
        if let navigationController = self.navigationController {
            // Pop to previous view controller
            navigationController.popViewController(animated: true)
        } else {
            // If no navigation controller, handle modal dismissal
            dismiss(animated: true, completion: nil)
        }
    }
    
    // Error handling helper
    private func handleError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showCompletionMessage() {
        let alert = UIAlertController(
            title: "Congratulations! 🎉",
            message: "You have practiced all available words. Would you like to review them again?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Review Again", style: .default) { [weak self] _ in
            Task {
                // Reset practice status for all words
                if let userData = try? await SupabaseDataController.shared.getUser(byPhone: SupabaseDataController.shared.phoneNumber ?? "") {
                    self?.levels = userData.userLevels
                    self?.updateUI()
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Back", style: .cancel) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func refreshData() {
        Task {
            do {
                guard let userId = SupabaseDataController.shared.userId else {
                    print("No user logged in")
                    return
                }
                let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                self.levels = userData.userLevels
                
                if self.levels.isEmpty {
                    showCompletionMessage()
                } else {
                    updateUI()
                }
            } catch {
                handleError(error)
            }
        }
    }
    
    private func clearUserDefaults() {
        // Only clear app-specific data, not user session
        UserDefaults.standard.removeObject(forKey: "LastPracticedWord")
        UserDefaults.standard.removeObject(forKey: "LastPracticedLevel")
        UserDefaults.standard.synchronize()
    }
    
    private func startNoiseMonitoring() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .defaultToSpeaker])
            try audioSession.setActive(true)
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
                guard let self = self else { return }
                
                let channelData = buffer.floatChannelData?[0]
                let frameLength = UInt(buffer.frameLength)
                
                var sum: Float = 0
                for i in 0..<frameLength {
                    let sample = channelData?[Int(i)] ?? 0
                    sum += sample * sample
                }
                
                let avgPower = 10 * log10f(sum / Float(frameLength))
                
                DispatchQueue.main.async {
                    self.updateWarningForNoiseLevel(avgPower)
                }
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
        } catch {
            print("Error setting up noise monitoring: \(error.localizedDescription)")
        }
    }
    
    private func stopNoiseMonitoring() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
    }
    
    private func updateWarningForNoiseLevel(_ power: Float) {
        // Threshold for "noisy" environment (adjust as needed)
        let noisyThreshold: Float = -30
        
        if power > noisyThreshold {
            UIView.animate(withDuration: 0.3) {
                self.warningLabel.alpha = 1.0
                self.warningLabel.text = "⚠️ High background noise detected.\nPlease move to a quieter place for better recognition."
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.warningLabel.alpha = 0
            }
        }
    }
}
