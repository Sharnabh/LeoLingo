import UIKit
import AVFoundation
import Speech
import Combine

class WaveformView: UIView {
    private var barLayers: [CALayer] = []
    private var displayLink: CADisplayLink?
    private let numberOfBars: Int = 50
    private let waveformColor = UIColor(red: 0.294, green: 0.557, blue: 0.310, alpha: 0.9)
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
        barLayers.forEach { $0.removeFromSuperlayer() }
        barLayers.removeAll()
        
        let barWidth: CGFloat = 3
        let spacing: CGFloat = 4
        let totalWidth = CGFloat(numberOfBars) * (barWidth + spacing)
        let startX = (bounds.width - totalWidth) / 2
        
        for i in 0..<numberOfBars {
            let bar = CALayer()
            bar.backgroundColor = waveformColor.cgColor
            let x = startX + CGFloat(i) * (barWidth + spacing)
            let initialHeight: CGFloat = 15 + CGFloat(arc4random_uniform(15))
            bar.frame = CGRect(x: x, y: bounds.height/2 - initialHeight/2, width: barWidth, height: initialHeight)
            bar.cornerRadius = barWidth/2
            bar.shadowColor = UIColor.black.cgColor
            bar.shadowOffset = CGSize(width: 0, height: 1)
            bar.shadowRadius = 2
            bar.shadowOpacity = 0.2
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
        barLayers.forEach { bar in
            bar.opacity = 1.0
            let initialHeight: CGFloat = 20 + CGFloat(arc4random_uniform(20))
            bar.frame = CGRect(x: bar.frame.origin.x, y: bounds.height/2 - initialHeight/2, width: bar.frame.width, height: initialHeight)
        }
    }
    
    func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)
        barLayers.forEach { bar in
            let finalHeight: CGFloat = 20
            bar.frame = CGRect(x: bar.frame.origin.x, y: bounds.height/2 - finalHeight/2, width: bar.frame.width, height: finalHeight)
        }
        CATransaction.commit()
    }
    
    @objc private func updateBars() {
        phase += 0.03
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for (index, bar) in barLayers.enumerated() {
            let normalizedIndex = CGFloat(index) / CGFloat(numberOfBars)
            let primaryWave = sin(phase * 0.8 + normalizedIndex * 5.0)
            let secondaryWave = sin(phase * 1.2 + normalizedIndex * 3.0) * 0.6
            let fastWave = sin(phase * 2.5 + normalizedIndex * 1.5) * 0.4
            let pulseEffect = sin(phase * 0.5) * 0.2
            let noise = CGFloat(arc4random_uniform(8)) / 120.0
            let combinedWave = primaryWave + secondaryWave + fastWave + pulseEffect + noise
            let minHeight: CGFloat = 15
            let maxHeight: CGFloat = 75
            let heightRange = maxHeight - minHeight
            let waveHeight = minHeight + (heightRange * abs(combinedWave))
            let heightRatio = waveHeight / maxHeight
            let alpha = 0.7 + (heightRatio * 0.3)
            bar.backgroundColor = waveformColor.withAlphaComponent(alpha).cgColor
            let yPosition = bounds.height/2 - waveHeight/2
            bar.frame = CGRect(x: bar.frame.origin.x, y: yPosition, width: bar.frame.width, height: waveHeight)
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
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var noiseTimer: Timer?
    private let speechProcessor = SpeechProcessor()
    private var speechSubscription: AnyCancellable?
    private var countdownTimer: Timer?
    
    // TalkingMojo GIF properties
    private var talkingMojoImageView: UIImageView?
    private var talkingMojoImages: [UIImage] = []
    private var talkingMojoDuration: TimeInterval = 0
    
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
        label.font = .systemFont(ofSize: 56, weight: .black)
        label.textColor = UIColor(red: 0.294, green: 0.557, blue: 0.310, alpha: 1.0)
        label.alpha = 0
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowRadius = 4
        label.layer.shadowOpacity = 0.3
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.numberOfLines = 1
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
    
    private lazy var controlsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.984, green: 0.969, blue: 0.894, alpha: 1.0)
        view.layer.cornerRadius = 25
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor(red: 0.631, green: 0.412, blue: 0.302, alpha: 1.0).cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var playPauseButton: UIButton = {
        return createControlButton(systemName: "pause.fill", action: #selector(playPauseButtonTapped))
    }()
    
    private lazy var skipButton: UIButton = {
        return createControlButton(systemName: "forward.fill", action: #selector(skipButtonTapped))
    }()
    
    private lazy var replayButton: UIButton = {
        return createControlButton(systemName: "arrow.counterclockwise", action: #selector(replayButtonTapped))
    }()
    
    private lazy var previousButton: UIButton = {
        return createControlButton(systemName: "backward.fill", action: #selector(previousButtonTapped))
    }()
    
    private lazy var speedTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Speed"
        label.textColor = UIColor(red: 0.482, green: 0.314, blue: 0.227, alpha: 1.0)
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var speedSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0.5
        slider.maximumValue = 1.5
        slider.value = 1.0
        slider.minimumTrackTintColor = UIColor(red: 0.294, green: 0.557, blue: 0.310, alpha: 1.0)
        slider.maximumTrackTintColor = UIColor(red: 0.631, green: 0.412, blue: 0.302, alpha: 0.3)
        slider.thumbTintColor = UIColor(red: 0.294, green: 0.557, blue: 0.310, alpha: 1.0)
        slider.addTarget(self, action: #selector(speedSliderChanged(_:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private lazy var speedLabel: UILabel = {
        let label = UILabel()
        label.text = "1.0x"
        label.textColor = UIColor(red: 0.482, green: 0.314, blue: 0.227, alpha: 1.0)
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var speedIconLeft: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        imageView.image = UIImage(systemName: "tortoise.fill", withConfiguration: config)?
            .withTintColor(UIColor(red: 0.631, green: 0.412, blue: 0.302, alpha: 1.0), renderingMode: .alwaysOriginal)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var speedIconRight: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        imageView.image = UIImage(systemName: "hare.fill", withConfiguration: config)?
            .withTintColor(UIColor(red: 0.631, green: 0.412, blue: 0.302, alpha: 1.0), renderingMode: .alwaysOriginal)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var isPlaybackPaused = false
    private var currentSpeechRate: Float = 1.0
    private let synthesizer = AVSpeechSynthesizer()
    
    private func createControlButton(systemName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.layer.cornerRadius = 28
        button.layer.borderWidth = 2.5
        button.layer.borderColor = UIColor(red: 0.631, green: 0.412, blue: 0.302, alpha: 0.4).cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        let image = UIImage(systemName: systemName, withConfiguration: config)?
            .withTintColor(UIColor(red: 0.482, green: 0.314, blue: 0.227, alpha: 1.0), renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTapUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return button
    }
    
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
    
    private let masteryThreshold: Double = 70.0
    
    /// Filters out mastered words and completed levels for personalized practice
    /// A word is considered mastered if:
    /// - mastered flag is true in database, OR
    /// - any accuracy score is >= masteryThreshold (70%)
    private func filteredLevelsForNewSession(from userLevels: [Level]) -> [Level] {
        var result: [Level] = []
        
        print("DEBUG: === FILTERING SESSION START ===")
        print("DEBUG: Processing \(userLevels.count) levels")
        
        for (levelIndex, level) in userLevels.enumerated() {
            print("DEBUG: Processing Level #\(levelIndex + 1) - ID: \(level.id)")
            print("DEBUG: Level has \(level.words.count) total words")
            
            // Print all word IDs in this level
            print("DEBUG: Word IDs in this level:")
            for (wordIndex, word) in level.words.enumerated() {
                let wordTitle = SupabaseDataController.shared.wordData(by: word.id)?.wordTitle ?? "Unknown"
                print("DEBUG:   [\(wordIndex)] \(word.id) - \(wordTitle)")
            }
            
            // Filter words that still need practice
            let remainingWords = level.words.filter { word in
                // Skip if already marked as mastered
                if let mastered = word.record?.mastered, mastered {
                    print("DEBUG: ❌ Skipping word \(word.id) - mastered flag is true")
                    return false
                }
                
                // Check accuracy history - if any attempt reached threshold, consider mastered
                guard let accuracies = word.record?.accuracy, !accuracies.isEmpty else {
                    // No practice history - include this word
                    print("DEBUG: ✅ Including word \(word.id) - no practice history")
                    return true
                }
                
                // If any accuracy >= threshold, word is mastered - skip it
                let hasMasteredAttempt = accuracies.contains { $0 >= masteryThreshold }
                if hasMasteredAttempt {
                    let maxAccuracy = accuracies.max() ?? 0
                    print("DEBUG: ❌ Skipping word \(word.id) - has accuracy \(maxAccuracy)% >= \(masteryThreshold)%")
                    return false
                }
                
                // Word still needs practice
                let maxAccuracy = accuracies.max() ?? 0
                print("DEBUG: ✅ Including word \(word.id) - max accuracy \(maxAccuracy)% < \(masteryThreshold)%")
                return true
            }
            
            // Only include level if it has remaining words to practice
            if !remainingWords.isEmpty {
                var newLevel = level
                newLevel.words = remainingWords
                result.append(newLevel)
                print("DEBUG: ✅ Level \(level.id) has \(remainingWords.count) words remaining for practice")
            } else {
                print("DEBUG: ❌ Level \(level.id) is completed - all words mastered")
            }
        }
        
        print("DEBUG: Filtered \(result.count) levels with unmastered words from \(userLevels.count) total levels")
        print("DEBUG: Total words after filter: \(result.flatMap { $0.words }.count)")
        print("DEBUG: === FILTERING SESSION END ===")
        return result
    }
    
    private func applySessionFilterIfNeeded() {
        print("DEBUG: Applying session filter...")
        print("DEBUG: Before filter - Levels: \(levels.count), Total words: \(levels.flatMap { $0.words }.count)")
        
        levels = filteredLevelsForNewSession(from: levels)
        
        print("DEBUG: After filter - Levels: \(levels.count), Total words: \(levels.flatMap { $0.words }.count)")
        
        if levels.isEmpty {
            print("DEBUG: All words mastered! Showing completion message.")
            showCompletionMessage()
            return
        }
        
        // Reset indices after filtering
        levelIndex = 0
        currentIndex = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearUserDefaults()
        directionLabel.adjustsFontSizeToFitWidth = true
        UserDefaults.standard.set(true, forKey: "isVocalCoachActive")
        BadgeEarningManager.shared.startPracticeSession()
        
        // Hide the storyboard mojoImage immediately
        mojoImage.isHidden = true
        mojoImage.alpha = 0
        
        Task {
            do {
                guard let userId = SupabaseDataController.shared.userId else {
                    print("DEBUG: No user ID found")
                    return
                }
                let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                self.levels = userData.userLevels
                
                print("DEBUG: Loaded \(self.levels.count) levels with \(self.levels.flatMap { $0.words }.count) total words")
                
                // Apply personalized filtering - skip mastered words and completed levels
                self.applySessionFilterIfNeeded()
                
                print("DEBUG: After filtering - \(self.levels.count) levels with \(self.levels.flatMap { $0.words }.count) words remaining")
                
                if self.levels.isEmpty {
                    showCompletionMessage()
                } else {
                    DispatchQueue.main.async {
                        self.updateUI()
                    }
                }
            } catch {
                handleError(error)
            }
        }
        
        setupBackButton()
        setupCountdownLabel()
        setupWarningLabel()
        setupPlaybackControls()
        requestSpeechAuthorization()
        startNoiseMonitoring()
        speechProcessor.requestSpeechRecognitionPermission()
        
        levelLabel.layer.cornerRadius = 21
        levelLabel.layer.masksToBounds = true
        
        setupTalkingMojoGif()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(wordImageTapped))
        wordImage.isUserInteractionEnabled = true
        wordImage.addGestureRecognizer(tapGesture)
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopNoiseMonitoring()
        BadgeEarningManager.shared.endPracticeSession()
        if isMovingFromParent {
            UserDefaults.standard.set(false, forKey: "isVocalCoachActive")
        }
    }
    
    private func setupCountdownLabel() {}
    
    private func updateCountdownLabel() {
        if isListening { countdownLabel.alpha = 0 }
    }
    
    private func startCountdown() {
        var count = 3
        countdownLabel.alpha = 1
        countdownLabel.text = "\(count)"
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }
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
            warningLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -200),
            warningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            warningLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            warningLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized: print("Speech recognition authorized")
                default: self?.handleError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Speech recognition not authorized"]))
                }
            }
        }
    }
    
    private func startListening() {
        if warningLabel.alpha == 1.0 {
            let alert = UIAlertController(title: "Noisy Environment", message: "The background noise level is high. Please move to a quieter place.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in self?.startCountdown() })
            present(alert, animated: true)
        } else {
            startSpeechRecognition()
        }
    }
    
    private func startSpeechRecognition() {
        speechSubscription?.cancel()
        let currentWord = getCurrentWord()
        let currentAttempt = levels[levelIndex].words[currentIndex].record?.attempts ?? 0
        speechProcessor.startRecording(word: currentWord, wordId: levels[levelIndex].words[currentIndex].id, attemptNumber: currentAttempt + 1)
        isListening = true
        
        speechSubscription = speechProcessor.$userSpokenText
            .filter { !$0.isEmpty }
            .sink { [weak self] spokenText in
                guard let self = self else { return }
                let distance = self.speechProcessor.levenshteinDistance(spokenText.lowercased(), currentWord.lowercased())
                let maxLength = max(spokenText.count, currentWord.count)
                let accuracy = max(0, 100.0 - (Double(distance) / Double(maxLength)) * 100.0)
                self.recordAccuracy(accuracy)
                if accuracy >= 70.0 {
                    self.handleCorrectPronunciation()
                } else {
                    self.handleIncorrectPronunciation()
                }
                self.stopListening()
            }
        
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
            currentWordAttempts = 0
            consecutiveWrongWords += 1
            if consecutiveWrongWords >= 3 {
                consecutiveWrongWords = 0
                showFunLearningPopOver()
            } else {
                showPopover(isCorrect: false, levelChange: false) {
                    self.moveToNextWord()
                }
            }
        } else {
            showPopover(isCorrect: false, levelChange: false) {
                let currentWord = self.getCurrentWord()
                let direction = "This is \(currentWord). Say \(currentWord)."
                self.directionLabel.text = direction
                self.pronounceDirection(direction)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.startCountdown()
                }
            }
        }
        
        Task {
            do {
                let currentWord = levels[levelIndex].words[currentIndex]
                let spokenText = speechProcessor.userSpokenText
                let wordTitle = getCurrentWord()
                let distance = speechProcessor.levenshteinDistance(spokenText.lowercased(), wordTitle.lowercased())
                let maxLength = max(spokenText.count, wordTitle.count)
                let accuracy = max(0, 100.0 - (Double(distance) / Double(maxLength)) * 100.0)
                try await SupabaseDataController.shared.updateWordProgress(wordId: currentWord.id, accuracy: accuracy, recordingPath: speechProcessor.getRecordingURL()?.path)
            } catch {
                print("Error updating word progress: \(error)")
            }
        }
    }
    
    private func handleCorrectPronunciation() {
        consecutiveWrongWords = 0
        currentWordAttempts = 0
        
        Task {
            do {
                let currentWord = levels[levelIndex].words[currentIndex]
                let spokenText = speechProcessor.userSpokenText
                let wordTitle = getCurrentWord()
                let distance = speechProcessor.levenshteinDistance(spokenText.lowercased(), wordTitle.lowercased())
                let maxLength = max(spokenText.count, wordTitle.count)
                let accuracy = max(0, 100.0 - (Double(distance) / Double(maxLength)) * 100.0)
                
                // Update word progress in Supabase (this will mark as mastered if accuracy >= 70%)
                try await SupabaseDataController.shared.updateWordProgress(
                    wordId: currentWord.id,
                    accuracy: accuracy,
                    recordingPath: speechProcessor.getRecordingURL()?.path
                )
                
                // DON'T refresh or re-filter - just move to next word
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    // Show success and move to next word
                    self.showPopover(isCorrect: true, levelChange: false) {
                        self.updateUIAfterPopover()
                    }
                }
            } catch {
                print("Error in handleCorrectPronunciation: \(error)")
            }
        }
    }
    
    private func markAndFilterAfterRefresh() {
        applySessionFilterIfNeeded()
        
        // Ensure indices are valid after filtering
        if levelIndex >= levels.count {
            levelIndex = 0
        }
        if !levels.isEmpty && currentIndex >= levels[levelIndex].words.count {
            currentIndex = 0
        }
    }
    
    @objc private func wordImageTapped() {
        let currentData = levels[levelIndex].words[currentIndex]
        if let word = DataController.shared.wordData(by: currentData.id) {
            pronounceWord(word.wordTitle)
        }
    }
    
    private func pronounceWord(_ word: String) {
        startTalkingAnimation()
        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * currentSpeechRate
        synthesizer.speak(utterance)
        let estimatedDuration = Double(word.count) * 0.08 / Double(currentSpeechRate)
        DispatchQueue.main.asyncAfter(deadline: .now() + estimatedDuration) { [weak self] in
            self?.stopTalkingAnimation()
        }
    }
    
    private func pronounceDirection(_ direction: String) {
        startTalkingAnimation()
        let utterance = AVSpeechUtterance(string: direction)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * currentSpeechRate
        synthesizer.speak(utterance)
        let estimatedDuration = Double(direction.count) * 0.06 / Double(currentSpeechRate)
        DispatchQueue.main.asyncAfter(deadline: .now() + estimatedDuration) { [weak self] in
            self?.stopTalkingAnimation()
        }
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
        guard !levels.isEmpty, levelIndex < levels.count, currentIndex < levels[levelIndex].words.count else {
            showCompletionMessage()
            return
        }
        
        let currentData = levels[levelIndex].words[currentIndex]
        directionLabel.text = ""
        let appLevels = SupabaseDataController.shared.getLevelsData()
        var wordImageName: String?
        var wordTitle: String?
        
        // Find and display correct level title
        if let currentLevel = appLevels.first(where: { $0.id == levels[levelIndex].id }) {
            levelLabel.text = currentLevel.levelTitle
            print("DEBUG: Displaying level: \(currentLevel.levelTitle)")
        }
        
        let totalWordsInLevel = levels[levelIndex].words.count
        let progress = Float(currentIndex) / Float(totalWordsInLevel)
        levelProgress.setProgress(progress, animated: true)
        
        for level in appLevels {
            if let word = level.words.first(where: { $0.id == currentData.id }) {
                wordImageName = word.wordImage
                wordTitle = word.wordTitle
                break
            }
        }
        
        if let wordImageName = wordImageName {
            self.wordImage.image = UIImage(named: wordImageName)
        }
        // mojoImage is permanently hidden - talkingMojoImageView replaces it
        
        if let wordTitle = wordTitle {
            let direction = "This is \(wordTitle). Say \(wordTitle)."
            countdownLabel.text = wordTitle
            countdownLabel.font = .systemFont(ofSize: 32, weight: .bold)
            countdownLabel.alpha = 1.0
            animateWordImage()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                guard let self = self else { return }
                self.directionLabel.text = direction
                self.pronounceDirection(direction)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.countdownLabel.font = .systemFont(ofSize: 56, weight: .black)
                    self.startCountdown()
                }
            }
        }
    }
    
    func animateWordImage() {
        wordImage.transform = CGAffineTransform(translationX: 0, y: -500)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.wordImage.transform = .identity
        }, completion: nil)
    }
    
    func moveToNextWord() {
        // Move to next word in the CURRENT filtered session
        currentIndex += 1
        
        if currentIndex >= levels[levelIndex].words.count {
            levelIndex += 1
            currentIndex = 0
            
            if levelIndex >= levels.count {
                showCompletionMessage()
                return
            }
            
            showLevelChangePopover()
        } else {
            updateUI()
        }
    }
    
    func showFunLearningPopOver() {
        let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
        if let popoverVC = storyboard.instantiateViewController(withIdentifier: "PopoverViewController") as? PopoverViewController {
            popoverVC.modalPresentationStyle = .fullScreen
            popoverVC.modalTransitionStyle = .crossDissolve
            popoverVC.configurePopover(message: "Lets Play Some Games!", image: "mojo2")
            present(popoverVC, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    guard let self = self else { return }
                    popoverVC.dismiss(animated: true) {
                        let storyboard = UIStoryboard(name: "FunLearning", bundle: nil)
                        if let funLearningNavController = storyboard.instantiateViewController(withIdentifier: "FunLearningNavBar") as? UINavigationController {
                            funLearningNavController.modalPresentationStyle = .fullScreen
                            self.present(funLearningNavController, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func showLevelChangePopover() {
        let appLevels = SupabaseDataController.shared.getLevelsData()
        guard let level = appLevels.first(where: { $0.id == levels[levelIndex].id }) else {
            updateUI()
            return
        }
        
        // Check if this is the FIRST TIME this level is being completed
        // We check this by seeing if there's a previous level (the one we just finished)
        guard levelIndex > 0 else {
            // This is level 0 (first level), so just continue
            updateUI()
            return
        }
        
        // Get the PREVIOUS level that was just completed
        let previousLevelIndex = levelIndex - 1
        let previousLevel = levels[previousLevelIndex]
        
        // Check if we already showed the badge for THIS level
        let levelBadgeShownKey = "LevelBadgeShown_\(level.id.uuidString)"
        let alreadyShown = UserDefaults.standard.bool(forKey: levelBadgeShownKey)
        
        if alreadyShown {
            // Already shown this level's badge, just continue
            print("DEBUG: Level badge for \(level.levelTitle) already shown this session, skipping popup")
            updateUI()
            return
        }
        
        // First time showing this level badge - show popup
        let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
        if let popoverVC = storyboard.instantiateViewController(withIdentifier: "PopoverViewController") as? PopoverViewController {
            popoverVC.modalPresentationStyle = .fullScreen
            popoverVC.modalTransitionStyle = .crossDissolve
            popoverVC.configurePopover(message: "Congratulations!! You have unlocked \(level.levelTitle).", image: level.levelImage)
            
            // Mark this level badge as shown
            UserDefaults.standard.set(true, forKey: levelBadgeShownKey)
            
            // Award the level badge
            Task {
                do {
                    let allBadges = SupabaseDataController.shared.getBadgesData()
                    if let levelBadge = allBadges.first(where: { $0.badgeTitle == level.levelTitle }) {
                        try await SupabaseDataController.shared.updateBadgeStatus(badgeId: levelBadge.id, isEarned: true, showPopup: false)
                        print("DEBUG: ✅ Awarded badge: \(levelBadge.badgeTitle)")
                    }
                } catch {
                    print("DEBUG: Error awarding level badge: \(error)")
                }
            }
            
            present(popoverVC, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    guard let self = self else { return }
                    popoverVC.dismiss(animated: true) {
                        // After level change popup, start practicing the new level
                        self.updateUI()
                    }
                }
            }
        }
    }
    
    func showPopover(isCorrect: Bool, levelChange: Bool, completion: (() -> Void)? = nil) {
        let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
        if let popoverVC = storyboard.instantiateViewController(withIdentifier: "PopoverViewController") as? PopoverViewController {
            popoverVC.modalPresentationStyle = .fullScreen
            popoverVC.modalTransitionStyle = .crossDissolve
            
            if isCorrect && !levelChange {
                popoverVC.configurePopover(message: "Great pronunciation!", image: "DancingMojo", showConfetti: true)
                present(popoverVC, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                        guard let self = self else { return }
                        popoverVC.dismiss(animated: true) {
                            // Just call updateUIAfterPopover - it already handles everything
                            self.updateUIAfterPopover()
                        }
                    }
                }
            } else {
                popoverVC.configurePopover(message: "Let's try that pronunciation again.", image: "SadMojo")
                present(popoverVC, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        popoverVC.dismiss(animated: true) { completion?() }
                    }
                }
            }
        }
    }
    
    private func updateUIAfterPopover() {
        // Move to next word
        currentIndex += 1
        
        // Check if we've completed the current level
        if currentIndex >= levels[levelIndex].words.count {
            // Move to next level
            levelIndex += 1
            currentIndex = 0
            
            // Check if we've completed all levels
            if levelIndex >= levels.count {
                showCompletionMessage()
                return
            }
            
            // Show level change popup for the new level
            showLevelChangePopover()
            return
        }
        
        // Normal word transition - update UI
        guard !levels.isEmpty, levelIndex < levels.count, currentIndex < levels[levelIndex].words.count else {
            showCompletionMessage()
            return
        }
        
        let currentData = levels[levelIndex].words[currentIndex]
        directionLabel.text = ""
        let appLevels = SupabaseDataController.shared.getLevelsData()
        var wordImageName: String?
        var wordTitle: String?
        
        // Update level title and progress
        if let currentLevel = appLevels.first(where: { $0.id == levels[levelIndex].id }) {
            levelLabel.text = currentLevel.levelTitle
            print("DEBUG: updateUIAfterPopover - Displaying level: \(currentLevel.levelTitle)")
        }
        
        let totalWordsInLevel = levels[levelIndex].words.count
        let progress = Float(currentIndex) / Float(totalWordsInLevel)
        levelProgress.setProgress(progress, animated: true)
        
        for level in appLevels {
            if let word = level.words.first(where: { $0.id == currentData.id }) {
                wordImageName = word.wordImage
                wordTitle = word.wordTitle
                break
            }
        }
        
        if let wordImageName = wordImageName {
            self.wordImage.image = UIImage(named: wordImageName)
        }
        
        if let wordTitle = wordTitle {
            let direction = "This is \(wordTitle). Say \(wordTitle)."
            countdownLabel.text = wordTitle
            countdownLabel.font = .systemFont(ofSize: 32, weight: .bold)
            countdownLabel.alpha = 1.0
            animateWordImage()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                guard let self = self else { return }
                self.directionLabel.text = direction
                self.pronounceDirection(direction)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.countdownLabel.font = .systemFont(ofSize: 56, weight: .black)
                    self.startCountdown()
                }
            }
        }
    }
    
    private func recordAccuracy(_ accuracy: Double) {
        let currentWord = levels[levelIndex].words[currentIndex]
        Task {
            do {
                let recordingPath = speechProcessor.getRecordingURL()?.path
                try await SupabaseDataController.shared.updateWordProgress(wordId: currentWord.id, accuracy: accuracy, recordingPath: recordingPath)
                // Don't refresh or re-filter - keep the current session intact
            } catch {
                print("Error in recordAccuracy: \(error)")
            }
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
        view.bringSubviewToFront(backButton)
    }
    
    @objc private func backButtonTapped() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func setupPlaybackControls() {
        view.addSubview(controlsContainerView)
        controlsContainerView.addSubview(waveformView)
        controlsContainerView.addSubview(countdownLabel)
        
        let dividerLine = UIView()
        dividerLine.backgroundColor = UIColor(red: 0.631, green: 0.412, blue: 0.302, alpha: 0.3)
        dividerLine.translatesAutoresizingMaskIntoConstraints = false
        
        let speedHeaderStack = UIStackView(arrangedSubviews: [speedTitleLabel, speedLabel])
        speedHeaderStack.axis = .horizontal
        speedHeaderStack.distribution = .equalSpacing
        speedHeaderStack.translatesAutoresizingMaskIntoConstraints = false
        
        let speedSliderStack = UIStackView(arrangedSubviews: [speedIconLeft, speedSlider, speedIconRight])
        speedSliderStack.axis = .horizontal
        speedSliderStack.alignment = .center
        speedSliderStack.spacing = 10
        speedSliderStack.translatesAutoresizingMaskIntoConstraints = false
        
        controlsContainerView.addSubview(dividerLine)
        controlsContainerView.addSubview(speedHeaderStack)
        controlsContainerView.addSubview(speedSliderStack)
        
        NSLayoutConstraint.activate([
            controlsContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            controlsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlsContainerView.widthAnchor.constraint(equalToConstant: 350),
            controlsContainerView.heightAnchor.constraint(equalToConstant: 150),
            waveformView.topAnchor.constraint(equalTo: controlsContainerView.topAnchor, constant: 12),
            waveformView.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor),
            waveformView.widthAnchor.constraint(equalToConstant: 280),
            waveformView.heightAnchor.constraint(equalToConstant: 55),
            countdownLabel.centerXAnchor.constraint(equalTo: waveformView.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: waveformView.centerYAnchor),
            countdownLabel.leadingAnchor.constraint(greaterThanOrEqualTo: waveformView.leadingAnchor, constant: 10),
            countdownLabel.trailingAnchor.constraint(lessThanOrEqualTo: waveformView.trailingAnchor, constant: -10),
            dividerLine.topAnchor.constraint(equalTo: waveformView.bottomAnchor, constant: 10),
            dividerLine.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 20),
            dividerLine.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor, constant: -20),
            dividerLine.heightAnchor.constraint(equalToConstant: 1.5),
            speedHeaderStack.topAnchor.constraint(equalTo: dividerLine.bottomAnchor, constant: 8),
            speedHeaderStack.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 25),
            speedHeaderStack.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor, constant: -25),
            speedSliderStack.topAnchor.constraint(equalTo: speedHeaderStack.bottomAnchor, constant: 5),
            speedSliderStack.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 25),
            speedSliderStack.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor, constant: -25),
            speedSliderStack.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -12),
            speedIconLeft.widthAnchor.constraint(equalToConstant: 24),
            speedIconLeft.heightAnchor.constraint(equalToConstant: 24),
            speedIconRight.widthAnchor.constraint(equalToConstant: 24),
            speedIconRight.heightAnchor.constraint(equalToConstant: 24)
        ])
        controlsContainerView.bringSubviewToFront(countdownLabel)
        currentSpeechRate = 1.0
    }
    
    @objc private func playPauseButtonTapped() {
        isPlaybackPaused.toggle()
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        let imageName = isPlaybackPaused ? "pause.fill" : "play.fill"
        let image = UIImage(systemName: imageName, withConfiguration: config)?
            .withTintColor(UIColor(red: 0.482, green: 0.314, blue: 0.227, alpha: 1.0), renderingMode: .alwaysOriginal)
        playPauseButton.setImage(image, for: .normal)
        
        if isPlaybackPaused {
            if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
            stopListening()
            countdownTimer?.invalidate()
        } else {
            let currentWord = getCurrentWord()
            let direction = "This is \(currentWord). Say \(currentWord)."
            directionLabel.text = direction
            countdownLabel.text = currentWord
            countdownLabel.font = .systemFont(ofSize: 32, weight: .bold)
            countdownLabel.alpha = 1.0
            pronounceDirection(direction)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.countdownLabel.font = .systemFont(ofSize: 56, weight: .black)
                self?.startCountdown()
            }
        }
    }
    
    @objc private func skipButtonTapped() {
        synthesizer.stopSpeaking(at: .immediate)
        stopListening()
        countdownTimer?.invalidate()
        isPlaybackPaused = false
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        let image = UIImage(systemName: "pause.fill", withConfiguration: config)?
            .withTintColor(UIColor(red: 0.482, green: 0.314, blue: 0.227, alpha: 1.0), renderingMode: .alwaysOriginal)
        playPauseButton.setImage(image, for: .normal)
        moveToNextWord()
    }
    
    @objc private func previousButtonTapped() {
        synthesizer.stopSpeaking(at: .immediate)
        stopListening()
        countdownTimer?.invalidate()
        isPlaybackPaused = false
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        let image = UIImage(systemName: "pause.fill", withConfiguration: config)?
            .withTintColor(UIColor(red: 0.482, green: 0.314, blue: 0.227, alpha: 1.0), renderingMode: .alwaysOriginal)
        playPauseButton.setImage(image, for: .normal)
        
        if currentIndex > 0 {
            currentIndex -= 1
        } else if levelIndex > 0 {
            levelIndex -= 1
            currentIndex = levels[levelIndex].words.count - 1
        } else {
            showAlert(message: "This is the first word")
            return
        }
        updateUI()
    }
    
    @objc private func replayButtonTapped() {
        synthesizer.stopSpeaking(at: .immediate)
        stopListening()
        countdownTimer?.invalidate()
        isPlaybackPaused = false
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        let image = UIImage(systemName: "pause.fill", withConfiguration: config)?
            .withTintColor(UIColor(red: 0.482, green: 0.314, blue: 0.227, alpha: 1.0), renderingMode: .alwaysOriginal)
        playPauseButton.setImage(image, for: .normal)
        let currentWord = getCurrentWord()
        let direction = "This is \(currentWord). Say \(currentWord)."
        directionLabel.text = direction
        pronounceDirection(direction)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.startCountdown()
        }
    }
    
    @objc private func speedSliderChanged(_ sender: UISlider) {
        let roundedValue = round(sender.value * 20) / 20
        currentSpeechRate = roundedValue
        speedLabel.text = String(format: "%.2fx", roundedValue)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func buttonTapDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            sender.alpha = 0.7
        }
    }
    
    @objc private func buttonTapUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
    }
    
    // MARK: - TalkingMojo GIF
    private func setupTalkingMojoGif() {
        guard let gifPath = Bundle.main.path(forResource: "TalkingMojo", ofType: "gif"),
              let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath)),
              let source = CGImageSourceCreateWithData(gifData as CFData, nil) else {
            print("❌ GIF file 'TalkingMojo.gif' not found")
            return
        }
        
        print("✅ Loading TalkingMojo.gif")
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
                talkingMojoImages.append(UIImage(cgImage: cgImage))
            }
        }
        
        talkingMojoDuration = totalDuration
        talkingMojoImageView = UIImageView(frame: mojoImage.frame)
        talkingMojoImageView?.animationImages = talkingMojoImages
        talkingMojoImageView?.animationDuration = talkingMojoDuration
        talkingMojoImageView?.animationRepeatCount = 0
        talkingMojoImageView?.contentMode = .scaleAspectFit
        talkingMojoImageView?.backgroundColor = .clear
        // Show the first frame as static image (always visible)
        talkingMojoImageView?.image = talkingMojoImages.first
        talkingMojoImageView?.isHidden = false
        
        if let talkingMojoImageView = talkingMojoImageView {
            view.addSubview(talkingMojoImageView)
            talkingMojoImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                talkingMojoImageView.centerXAnchor.constraint(equalTo: mojoImage.centerXAnchor),
                talkingMojoImageView.centerYAnchor.constraint(equalTo: mojoImage.centerYAnchor),
                talkingMojoImageView.widthAnchor.constraint(equalTo: mojoImage.widthAnchor),
                talkingMojoImageView.heightAnchor.constraint(equalTo: mojoImage.heightAnchor)
            ])
        }
        
        // Hide the original static mojoImage permanently
        mojoImage.isHidden = true
        mojoImage.alpha = 0
        
        print("✅ TalkingMojo GIF loaded with \(imageCount) frames")
    }
    
    private func startTalkingAnimation() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Just start animating - GIF is already visible
            self.talkingMojoImageView?.startAnimating()
        }
    }
    
    private func stopTalkingAnimation() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // Stop animating but keep showing the first frame
            self.talkingMojoImageView?.stopAnimating()
        }
    }
    
    private func handleError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showCompletionMessage() {
        let alert = UIAlertController(title: "Congratulations! 🎉", message: "You have practiced all available words. Would you like to review them again?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Review Again", style: .default) { [weak self] _ in
            Task {
                if let userId = SupabaseDataController.shared.userId,
                   let userData = try? await SupabaseDataController.shared.getUser(byId: userId) {
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
    
    private func clearUserDefaults() {
        UserDefaults.standard.removeObject(forKey: "LastPracticedWord")
        UserDefaults.standard.removeObject(forKey: "LastPracticedLevel")
        
        // Clear all level badge shown flags for NEW practice session
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix("LevelBadgeShown_") {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        UserDefaults.standard.synchronize()
        print("DEBUG: Cleared all level badge shown flags for new session")
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
                DispatchQueue.main.async { self.updateWarningForNoiseLevel(avgPower) }
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
        let noisyThreshold: Float = -30
        if power > noisyThreshold {
            UIView.animate(withDuration: 0.3) {
                self.warningLabel.alpha = 1.0
                self.warningLabel.text = "⚠️ High background noise detected.\nPlease move to a quieter place for better recognition."
            }
        } else {
            UIView.animate(withDuration: 0.3) { self.warningLabel.alpha = 0 }
        }
    }
}
