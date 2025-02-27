import UIKit
import AVFoundation
import Speech
import Combine

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
    
    private var isListening = false {
        didSet {
            updateMicButtonAppearance()
        }
    }
    
    private lazy var micButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(micButtonTapped), for: .touchUpInside)
        return button
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
    @IBOutlet weak var headingTitle: UILabel!
    
    var mojoImageData = ["mojo2", "mojoHearing"]
    
    var levelIndex = 0
    var currentIndex = 0
    var consecutiveWrongAttempts = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Clear any persisted data
        clearUserDefaults()
        
        // Load levels from Supabase
        Task {
            do {
                let userData = try await SupabaseDataController.shared.getUser(byPhone: SupabaseDataController.shared.phoneNumber ?? "")
                // Keep original level order but only include unpracticed words
                self.levels = userData.userLevels.map { level in
                    var filteredLevel = level
                    filteredLevel.words = level.words.filter { !$0.isPracticed }
                    return filteredLevel
                }
                
                // Remove empty levels
                self.levels = self.levels.filter { !$0.words.isEmpty }
                
                if self.levels.isEmpty {
                    // Show completion message if no unpracticed words available
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
        setupMicButton()
        setupWarningLabel()
        requestSpeechAuthorization()
        startNoiseMonitoring()
        
        // Add speech processor setup
        speechProcessor.requestSpeechRecognitionPermission()
        
        headingTitle.layer.cornerRadius = 21
        headingTitle.layer.masksToBounds = true
        
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
    
    private func setupMicButton() {
        view.addSubview(micButton)
        
        NSLayoutConstraint.activate([
            micButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            micButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            micButton.heightAnchor.constraint(equalToConstant: 60),
            micButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])
        
        updateMicButtonAppearance()
    }
    
    private func updateMicButtonAppearance() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 200, height: 60)
        gradientLayer.cornerRadius = 30
        
        if isListening {
                gradientLayer.colors = [
                    UIColor(red: 0.5, green: 0.8, blue: 0.5, alpha: 1).cgColor, // Lighter green
                    UIColor(red: 0.3, green: 0.6, blue: 0.3, alpha: 1).cgColor  // Darker green
                ]
            } else {
                gradientLayer.colors = [
                    UIColor(red: 0.1, green: 0.6, blue: 0.1, alpha: 1).cgColor, // Solid green
                    UIColor(red: 0.1, green: 0.5, blue: 0.1, alpha: 1).cgColor
                ]
            }
        
        // Remove existing gradient layers
        micButton.layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        
        // Add new gradient layer
        micButton.layer.insertSublayer(gradientLayer, at: 0)
        
        // Configure button content
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(systemName: isListening ? "waveform.circle.fill" : "mic.circle.fill", withConfiguration: imageConfig)
        let text = isListening ? "Listening..." : "Speak"
        
        let attributedString = NSMutableAttributedString()
        
        if let image = image {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = image.withTintColor(isListening ? .green : .white)
            imageAttachment.bounds = CGRect(x: 0, y: -7, width: 30, height: 30)
            attributedString.append(NSAttributedString(attachment: imageAttachment))
        }
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: isListening ? UIColor.green : UIColor.white,
            .font: UIFont.systemFont(ofSize: 20, weight: .bold)
        ]
        
        attributedString.append(NSAttributedString(string: "  \(text)", attributes: textAttributes))
        
        micButton.setAttributedTitle(attributedString, for: .normal)
    }
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self.micButton.isEnabled = true
                default:
                    self.micButton.isEnabled = false
                }
            }
        }
    }
    
    @objc private func micButtonTapped() {
        if audioEngine.isRunning {
            stopListening()
        } else {
            startListening()
        }
    }
    
    private func setupWarningLabel() {
        view.addSubview(warningLabel)
        
        NSLayoutConstraint.activate([
            warningLabel.bottomAnchor.constraint(equalTo: micButton.topAnchor, constant: -8),
            warningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            warningLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            warningLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
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
    
    private func startListening() {
        // Check noise level before starting
        if warningLabel.alpha == 1.0 {
            // Show alert for noisy environment
            let alert = UIAlertController(
                title: "Noisy Environment",
                message: "The background noise level is high. Would you like to continue anyway?",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
                self?.startSpeechRecognition()
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
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
    }
    
    private func stopListening() {
        speechSubscription?.cancel()
        speechProcessor.stopRecording()
        isListening = false
    }
    
    private func getCurrentWord() -> String {
        let currentData = levels[levelIndex].words[currentIndex]
        let appLevels = SupabaseDataController.shared.getLevelsData()
        for level in appLevels {
            for word in level.words {
                if word.id == currentData.id {
                    return word.wordTitle
                }
            }
        }
        return ""
    }
    
    private func handleCorrectPronunciation() {
        consecutiveWrongAttempts = 0
        
        // Mark current word as practiced in database
        Task {
            do {
                let currentWord = levels[levelIndex].words[currentIndex]
                try await SupabaseDataController.shared.updateWordProgress(wordId: currentWord.id, accuracy: nil)
                
                // Update local data
                levels[levelIndex].words[currentIndex].isPracticed = true
                
                // Show success feedback and move to next word on main thread
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let isLastWordInLevel = currentIndex == levels[levelIndex].words.count - 1
                    
                    // Show the success popup first
                    self.showPopover(isCorrect: true, levelChange: isLastWordInLevel)
                    
                    // Remove the practiced word from our local array
                    self.levels[self.levelIndex].words.remove(at: self.currentIndex)
                    
                    // If the level is now empty, remove it
                    if self.levels[self.levelIndex].words.isEmpty {
                        self.levels.remove(at: self.levelIndex)
                    }
                    
                    // Progress to next word or level
                    if self.levels.isEmpty {
                        self.showCompletionMessage()
                    } else {
                        // If current level is empty, move to next level
                        if self.currentIndex >= self.levels[self.levelIndex].words.count {
                            self.levelIndex = min(self.levelIndex, self.levels.count - 1)
                            self.currentIndex = 0
                            self.showLevelChangePopover()
                            self.showConfettiEffect()
                        }
                        self.updateUI()
                    }
                }
            } catch {
                print("Error updating word progress: \(error)")
                // On error, still try to move to next word
                DispatchQueue.main.async { [weak self] in
                    self?.moveToNextWord()
                }
            }
        }
    }
    
    private func handleIncorrectPronunciation() {
        consecutiveWrongAttempts += 1
        
        if consecutiveWrongAttempts == 3 {
            showFunLearningPopOver()
        } else {
            showPopover(isCorrect: false, levelChange: false)
            moveToNextWord()
        }
    }
    
    @objc private func wordImageTapped() {
        let currentData = levels[levelIndex].words[currentIndex]
        if let word = DataController.shared.wordData(by: currentData.id) {
            pronounceWord(word.wordTitle)
        }
    }
    
    private func pronounceWord(_ word: String) {
        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    private func pronounceDirection(_ direction: String) {
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
            
            // Start typing effect after word image animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                guard let self = self else { return }
                self.typeEffect(text: direction, label: self.directionLabel)
                
                // Pronounce direction after typing effect
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(direction.count) * 0.05 + 0.2) { [weak self] in
                    guard let self = self else { return }
                    self.pronounceDirection(direction)
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
        // If we have no levels left, show completion
        if levels.isEmpty {
            showCompletionMessage()
            return
        }
        
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
        }
        
        // Only update UI if we have valid indices
        if levelIndex < levels.count && currentIndex < levels[levelIndex].words.count {
            updateUI()
        } else {
            showCompletionMessage()
        }
    }
    
    func showFunLearningPopOver() {
        let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
        if let popoverVC = storyboard.instantiateViewController(withIdentifier: "PopoverViewController") as? PopoverViewController {
            // Change to full screen presentation
            popoverVC.modalPresentationStyle = .fullScreen
            popoverVC.modalTransitionStyle = .crossDissolve
            
            popoverVC.configurePopover(message: "Lets Play Some Games!", image: "mojo2")
            popoverVC.onProceed = { [weak self] in
                self?.navigateToFunLearning()
            }
            present(popoverVC, animated: true, completion: nil)
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
                popoverVC.onProceed = { [weak self] in
                    self?.updateUI()
                }
                present(popoverVC, animated: true, completion: nil)
            }
        }
    }
    
    func showPopover(isCorrect: Bool, levelChange: Bool) {
        let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
        if let popoverVC = storyboard.instantiateViewController(withIdentifier: "PopoverViewController") as? PopoverViewController {
            // Change to full screen presentation
            popoverVC.modalPresentationStyle = .fullScreen
            popoverVC.modalTransitionStyle = .crossDissolve
            
            // Update messages to reflect pronunciation accuracy
            if isCorrect && !levelChange {
                popoverVC.configurePopover(message: "Great pronunciation!", image: "mojo2")
            } else if isCorrect && levelChange {
                showLevelChangePopover()
                return
            } else {
                popoverVC.configurePopover(message: "Let's try that pronunciation again.", image: "SadMojo")
            }
            present(popoverVC, animated: true, completion: nil)
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
                
                // Refresh local data to update the filtered word list
                await refreshData()
            } catch {
                handleError(error)
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
                let userData = try await SupabaseDataController.shared.getUser(byPhone: SupabaseDataController.shared.phoneNumber ?? "")
                // Keep original level order but only include unpracticed words
                self.levels = userData.userLevels.map { level in
                    var filteredLevel = level
                    filteredLevel.words = level.words.filter { !$0.isPracticed }
                    return filteredLevel
                }
                
                // Remove empty levels
                self.levels = self.levels.filter { !$0.words.isEmpty }
                
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
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }
    }
}
