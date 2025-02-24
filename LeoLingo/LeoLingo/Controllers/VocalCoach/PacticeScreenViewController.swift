import UIKit
import AVFoundation
import Speech

class PracticeScreenViewController: UIViewController {
    
    var levels = DataController.shared.getAllLevels()
    private let synthesizer = AVSpeechSynthesizer()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var noiseTimer: Timer?
    
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
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let image = UIImage(systemName: "chevron.left", withConfiguration: symbolConfig)?
            .withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @IBOutlet var directionLabel: UILabel!
    @IBOutlet var mojoImage: UIImageView!
    @IBOutlet var wordImage: UIImageView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var wrongButton: UIButton!
    @IBOutlet weak var headingTitle: UILabel!
    
    var mojoImageData = ["mojo2", "mojoHearing"]
    
    var levelIndex = 0
    var currentIndex = 0
    var consecutiveWrongAttempts = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackButton()
        setupMicButton()
        setupWarningLabel()
        requestSpeechAuthorization()
        startNoiseMonitoring()
        
        headingTitle.layer.cornerRadius = 21
        headingTitle.layer.masksToBounds = true
        
        // Add tap gesture to wordImage
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(wordImageTapped))
        wordImage.isUserInteractionEnabled = true
        wordImage.addGestureRecognizer(tapGesture)
        
        updateUI()
        directionLabel.adjustsFontSizeToFitWidth = true
        
        // Hide the default back button
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopNoiseMonitoring()
        
        // Save current progress
        UserDefaults.standard.set(levelIndex, forKey: "LastPracticedLevelIndex")
        UserDefaults.standard.set(currentIndex, forKey: "LastPracticedWordIndex")
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
                UIColor.green.withAlphaComponent(0.3).cgColor,
                UIColor.blue.withAlphaComponent(0.3).cgColor
            ]
        } else {
            gradientLayer.colors = [
                UIColor.blue.cgColor,
                UIColor.purple.cgColor
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
        let text = isListening ? "Listening..." : "Speak the Word!"
        
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
        // Move existing startListening code here
        recognitionTask?.cancel()
        recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set up audio session: \(error)")
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let spokenText = result.bestTranscription.formattedString
                if result.isFinal {
                    let currentWord = self.getCurrentWord()
                    let distance = self.levenshteinDistance(spokenText.lowercased(), currentWord.lowercased())
                    let similarity = 1.0 - Double(distance) / Double(max(spokenText.count, currentWord.count))
                    
                    // Record the accuracy
                    self.recordAccuracy(similarity * 100)
                    
                    if similarity >= 0.7 {
                        self.handleCorrectPronunciation()
                    } else {
                        self.handleIncorrectPronunciation()
                    }
                    self.stopListening()
                }
            }
            
            if error != nil {
                self.stopListening()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isListening = true
        } catch {
            print("Failed to start audio engine: \(error)")
            return
        }
    }
    
    private func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        
        isListening = false
    }
    
    private func getCurrentWord() -> String {
        let currentData = levels[levelIndex].words[currentIndex]
        return DataController.shared.wordData(by: currentData.id)?.wordTitle ?? ""
    }
    
    private func handleCorrectPronunciation() {
        consecutiveWrongAttempts = 0
        
        // Show success feedback
        showPopover(isCorrect: true, levelChange: currentIndex == levels[levelIndex].words.count - 1)
        
        // Move to next word
        moveToNextWord()
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
    
    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1Array = Array(s1)
        let s2Array = Array(s2)
        let m = s1Array.count
        let n = s2Array.count
        
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        
        // Initialize first row and column
        for i in 0...m {
            dp[i][0] = i
        }
        for j in 0...n {
            dp[0][j] = j
        }
        
        // Fill the dp table
        for i in 1...m {
            for j in 1...n {
                if s1Array[i-1] == s2Array[j-1] {
                    dp[i][j] = dp[i-1][j-1]
                } else {
                    dp[i][j] = min(
                        dp[i-1][j] + 1,    // deletion
                        dp[i][j-1] + 1,    // insertion
                        dp[i-1][j-1] + 1   // substitution
                    )
                }
            }
        }
        
        return dp[m][n]
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
        let level = DataController.shared.getLevel(by: levels[levelIndex].id)
        let data = level!.words[index]
        return "This is \(data.wordTitle). Say \(data.wordTitle)."
    }
    
    func updateUI() {
        let currentData = levels[levelIndex].words[currentIndex]
        directionLabel.text = ""
        let word = DataController.shared.wordData(by: currentData.id)!
        wordImage.image = UIImage(named: word.wordImage)
        mojoImage.image = UIImage(named: "mojo2")
        
        let direction = "This is \(word.wordTitle). Say \(word.wordTitle)."
        
        // Sequence the animations
        animateWordImage()
        
        // Start typing effect after word image animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.typeEffect(text: direction, label: self?.directionLabel)
            
            // Pronounce direction after typing effect
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(direction.count) * 0.05 + 0.2) { [weak self] in
                self?.pronounceDirection(direction)
            }
        }
        
        nextButton.layer.cornerRadius = 21
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
        currentIndex += 1
        
        if currentIndex >= levels[levelIndex].words.count {
            currentIndex = 0
            levelIndex = (levelIndex + 1) % levels.count
            
            DataController.shared.updateLevels(levels)
            showLevelChangePopover()
            showConfettiEffect()
        } else {
            DataController.shared.updateLevels(levels)
            updateUI()
        }
    }
    
    func showFunLearningPopOver() {
        let storyboard = UIStoryboard(name: "Tarun", bundle: nil)
        if let popoverVC = storyboard.instantiateViewController(withIdentifier: "PopoverViewController") as? PopoverViewController {
            popoverVC.modalPresentationStyle = .popover
            popoverVC.preferredContentSize = CGSize(width: 300, height: 200)
            
            // Configure the popover presentation controller
            if let popoverController = popoverVC.popoverPresentationController {
                popoverController.sourceView = wordImage
                popoverController.sourceRect = wordImage.bounds
                popoverController.permittedArrowDirections = .any
                popoverController.delegate = self
            }
            
            popoverVC.configurePopover(message: "Lets Play Some Games!", image: "mojo2")
            popoverVC.onProceed = { [weak self] in
                self?.navigateToFunLearning()
            }
            present(popoverVC, animated: true, completion: nil)
        }
    }
    
    func showLevelChangePopover() {
        let storyboard = UIStoryboard(name: "Tarun", bundle: nil)
        if let popoverVC = storyboard.instantiateViewController(withIdentifier: "PopoverViewController") as? PopoverViewController {
            popoverVC.modalPresentationStyle = .popover
            popoverVC.preferredContentSize = CGSize(width: 300, height: 200)
            
            // Configure the popover presentation controller
            if let popoverController = popoverVC.popoverPresentationController {
                popoverController.sourceView = wordImage
                popoverController.sourceRect = wordImage.bounds
                popoverController.permittedArrowDirections = .any
                popoverController.delegate = self
            }
            
            let level = DataController.shared.getLevel(by: levels[levelIndex].id)
            popoverVC.configurePopover(message: "Congratulations!! You have completed this level. Would you like to proceed to the next level? ", image: level!.levelImage)
            popoverVC.onProceed = { [weak self] in
                self?.updateUI()
            }
            present(popoverVC, animated: true, completion: nil)
        }
    }
    
    func showPopover(isCorrect: Bool, levelChange: Bool) {
        let storyboard = UIStoryboard(name: "Tarun", bundle: nil)
        if let popoverVC = storyboard.instantiateViewController(withIdentifier: "PopoverViewController") as? PopoverViewController {
            popoverVC.modalPresentationStyle = .popover
            popoverVC.preferredContentSize = CGSize(width: 300, height: 200)
            
            // Configure the popover presentation controller
            if let popoverController = popoverVC.popoverPresentationController {
                // Use mic button as source instead of next/wrong buttons
                popoverController.sourceView = micButton
                popoverController.sourceRect = micButton.bounds
                popoverController.permittedArrowDirections = .any
                popoverController.delegate = self
            }
            
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
//            funLearningVC.modalPresentationStyle = .fullScreen
//            present(funLearningVC, animated: true)
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
        
        // Initialize record if it doesn't exist
        if currentWord.record == nil {
            levels[levelIndex].words[currentIndex].record = Record(attempts: 0, accuracy: [], recording: [])
        }
        
        // Update the record
        levels[levelIndex].words[currentIndex].isPracticed = true
        levels[levelIndex].words[currentIndex].record?.accuracy?.append(accuracy)
        levels[levelIndex].words[currentIndex].record?.attempts += 1
        
        // Calculate average accuracy for the word
        if let accuracies = levels[levelIndex].words[currentIndex].record?.accuracy {
            let avgAccuracy = accuracies.reduce(0.0, +) / Double(accuracies.count)
            // Store the average accuracy in UserDefaults or your persistence layer
            UserDefaults.standard.set(avgAccuracy, forKey: "word_accuracy_\(currentWord.id)")
        }
        
        // Save to persistent storage
        DataController.shared.updateLevels(levels)
        
        // Update level progress
        updateLevelProgress(accuracy)
    }
    
    private func updateLevelProgress(_ accuracy: Double) {
        let currentLevel = levels[levelIndex]
        
        // Calculate overall level progress
        let totalWords = currentLevel.words.count
        let practicedWords = currentLevel.words.filter { $0.isPracticed }.count
        let progressValue = Double(practicedWords) / Double(totalWords)
        
        // Store progress in UserDefaults
        UserDefaults.standard.set(progressValue, forKey: "level_progress_\(currentLevel.id)")
        
        // Calculate and store level accuracy
        let wordAccuracies = currentLevel.words.compactMap { word -> Double? in
            return UserDefaults.standard.double(forKey: "word_accuracy_\(word.id)")
        }
        
        if !wordAccuracies.isEmpty {
            let avgAccuracy = wordAccuracies.reduce(0.0, +) / Double(wordAccuracies.count)
            UserDefaults.standard.set(avgAccuracy, forKey: "level_accuracy_\(currentLevel.id)")
        }
        
        // Save changes
        DataController.shared.updateLevels(levels)
        
        // Update UI
        updateProgressUI()
    }
    
    private func updateProgressUI() {
        let currentLevel = levels[levelIndex]
        
        // Get progress and accuracy from UserDefaults
        let progress = UserDefaults.standard.double(forKey: "level_progress_\(currentLevel.id)")
        let accuracy = UserDefaults.standard.double(forKey: "level_accuracy_\(currentLevel.id)")
        
        // Update progress bar if it exists
        if let progressBar = view.viewWithTag(100) as? UIProgressView {
            progressBar.progress = Float(progress)
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
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Ensure the button is always on top of other views
        view.bringSubviewToFront(backButton)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension PracticeScreenViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none // Forces popover style on iPad
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none // Forces popover style on iPad even after trait changes
    }
}
