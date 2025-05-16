//
//  LevelCardViewController.swift
//  LeoLingo
//
//  Created by Tarun   on 21/02/25.
//

import UIKit
import AVFoundation
import Speech
import Combine

class LevelCardViewController: UIViewController {
    @IBOutlet var cardCollectionView: UICollectionView!
    
    private var cancellables = Set<AnyCancellable>()
    private let synthesizer = AVSpeechSynthesizer()
    private let speechProcessor = SpeechProcessor()
    private var speechSubscription: AnyCancellable?
    
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
    
    private var isListening = false {
        didSet {
            updateSpeakButtonAppearance()
        }
    }
    
    private var selectedCardIndex: Int?
    private var levels: [Level]
    var selectedLevelIndex: Int
    
    private var collectionView: UICollectionView!
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "BaseBackdrop")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var levelLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Level \(selectedLevelIndex + 1)"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = UIColor(red: 139/255, green: 69/255, blue: 19/255, alpha: 1.0)
        label.textAlignment = .center
        label.backgroundColor = .white
        label.layer.cornerRadius = 20
        label.layer.masksToBounds = true
        return label
    }()
    
    private lazy var speakButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 79/255, green: 144/255, blue: 76/255, alpha: 1.0) // #4F904C
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(speakButtonTapped), for: .touchUpInside)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: "mic.circle.fill", withConfiguration: imageConfig)
        let text = "Speak the Word!"
        
        let attributedString = NSMutableAttributedString()
        
        if let image = image {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = image.withTintColor(.white)
            imageAttachment.bounds = CGRect(x: 0, y: -5, width: 20, height: 20)
            attributedString.append(NSAttributedString(attachment: imageAttachment))
        }
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 16, weight: .bold)
        ]
        
        attributedString.append(NSAttributedString(string: "  \(text)", attributes: textAttributes))
        button.setAttributedTitle(attributedString, for: .normal)
        
        return button
    }()
    
    private lazy var customBackButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 24, y: 0, width: 60, height: 60))
        button.backgroundColor = .white
        button.layer.cornerRadius = 30
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.2
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: "chevron.left", withConfiguration: symbolConfig)?
            .withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // Add these properties after the existing properties
    private lazy var feedbackView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black.withAlphaComponent(0.85)
        view.layer.cornerRadius = 20
        view.alpha = 0
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.3
        return view
    }()

    private lazy var feedbackLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        return label
    }()

    private lazy var accuracyMeter: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.layer.cornerRadius = 6
        progressView.clipsToBounds = true
        progressView.layer.sublayers![1].cornerRadius = 6
        progressView.subviews[1].clipsToBounds = true
        progressView.transform = CGAffineTransform(scaleX: 1, y: 2)
        return progressView
    }()
    
    private lazy var celebrationPlayer: AVAudioPlayer? = {
        guard let url = Bundle.main.url(forResource: "celebration", withExtension: "mp3") else { return nil }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            return player
        } catch {
            print("Could not create audio player: \(error)")
            return nil
        }
    }()
    
    // MARK: - Initialization
    init(selectedLevelIndex: Int) {
        self.selectedLevelIndex = selectedLevelIndex
        self.levels = []  // Initialize empty, will fetch in viewDidLoad
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        self.selectedLevelIndex = 0
        self.levels = []  // Initialize empty, will fetch in viewDidLoad
        super.init(coder: coder)
        self.modalPresentationStyle = .fullScreen
    }
    
    // MARK: - View Lifecycle
    override func loadView() {
        super.loadView()
        
        // Add background image
        view.addSubview(backgroundImageView)
        
        // Initialize collection view with custom layout
        let layout = SnappingCollectionViewLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 0
        
        // Card size calculation
        let screenWidth = UIScreen.main.bounds.width
        let cardWidth = screenWidth * 0.45 // Reduced from 0.55 to 0.45 for smaller cards
        let cardHeight = cardWidth * 0.9 // Reduced from 1.0 to 0.9 for better proportion
        layout.itemSize = CGSize(width: cardWidth, height: cardHeight)
        
        // Center the current card
        let sideInset = (screenWidth - cardWidth) / 2
        layout.sectionInset = UIEdgeInsets(top: 0, 
                                         left: sideInset, 
                                         bottom: 0, 
                                         right: sideInset)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.clipsToBounds = false
        collectionView.register(LevelCardCell.self, forCellWithReuseIdentifier: "LevelCardCell")
        
        view.addSubview(collectionView)
        view.addSubview(levelLabel)
        view.addSubview(speakButton)
        view.addSubview(customBackButton)
        view.addSubview(warningLabel)
        view.addSubview(feedbackView)
        view.addSubview(feedbackLabel)
        view.addSubview(accuracyMeter)
        
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update gradient background frame
        if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
        
        // Update speak button gradient frame
        if let gradientLayer = speakButton.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = speakButton.bounds
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioSession()
        speechProcessor.requestSpeechRecognitionPermission()
        
        // Hide the default navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Set vocal coach as active
        UserDefaults.standard.set(true, forKey: "isVocalCoachActive")
        
        // Fetch data from Supabase
        Task {
            do {
                let userData = try await SupabaseDataController.shared.getUser(byId: SupabaseDataController.shared.userId!)
                self.levels = userData.userLevels
                
                // Validate selectedLevelIndex
                if selectedLevelIndex >= levels.count {
                    selectedLevelIndex = 0
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    
                    // Select first card by default if we have words
                    if !self.levels.isEmpty && self.levels[self.selectedLevelIndex].words.count > 0 {
                        self.selectedCardIndex = 0
                        
                        // Scroll to first item without animation
                        let indexPath = IndexPath(item: 0, section: 0)
                        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                        
                        // Get and speak the direction for the first word
                        let direction = self.getDirection(for: 0, at: self.selectedLevelIndex)
                        self.pronounceWord(direction)
                        
                        // Update speak button state
                        self.updateSpeakButtonAppearance()
                    }
                }
            } catch {
                handleError(error)
            }
        }
        
        setupFeedbackUI()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            // Configure specific audio session properties
            try audioSession.setPreferredIOBufferDuration(0.2)
            try audioSession.setPreferredSampleRate(44100.0)
            
            // Ensure input is available
            guard audioSession.availableInputs?.count ?? 0 > 0 else {
                print("No audio input available")
                return
            }
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Deactivate audio session when leaving
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Could not deactivate audio session: \(error.localizedDescription)")
        }
        
        // Only set vocal coach as inactive if we're going back to home
        if isMovingFromParent {
            UserDefaults.standard.set(false, forKey: "isVocalCoachActive")
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Background image
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Level label
            levelLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            levelLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            levelLabel.widthAnchor.constraint(equalToConstant: 200),
            levelLabel.heightAnchor.constraint(equalToConstant: 40),
            
            // Back button - Updated constraints
            customBackButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            customBackButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            customBackButton.widthAnchor.constraint(equalToConstant: 60),
            customBackButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Collection view - Updated constraints for smaller size
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25),
            
            // Speak button
            speakButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            speakButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            speakButton.widthAnchor.constraint(equalToConstant: 200),
            speakButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Warning label
            warningLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            warningLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            warningLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            warningLabel.heightAnchor.constraint(equalToConstant: 40),
            
            // Feedback view
            feedbackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feedbackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            feedbackView.widthAnchor.constraint(equalToConstant: 280),
            feedbackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            // Feedback label
            feedbackLabel.topAnchor.constraint(equalTo: feedbackView.topAnchor, constant: 20),
            feedbackLabel.leadingAnchor.constraint(equalTo: feedbackView.leadingAnchor, constant: 16),
            feedbackLabel.trailingAnchor.constraint(equalTo: feedbackView.trailingAnchor, constant: -16),
            
            // Accuracy meter
            accuracyMeter.topAnchor.constraint(equalTo: feedbackLabel.bottomAnchor, constant: 16),
            accuracyMeter.leadingAnchor.constraint(equalTo: feedbackView.leadingAnchor, constant: 24),
            accuracyMeter.trailingAnchor.constraint(equalTo: feedbackView.trailingAnchor, constant: -24),
            accuracyMeter.bottomAnchor.constraint(equalTo: feedbackView.bottomAnchor, constant: -20),
            accuracyMeter.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    private func setupFeedbackUI() {
        view.addSubview(feedbackView)
        feedbackView.addSubview(feedbackLabel)
        feedbackView.addSubview(accuracyMeter)
        
        NSLayoutConstraint.activate([
            feedbackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feedbackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            feedbackView.widthAnchor.constraint(equalToConstant: 280),
            feedbackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            feedbackLabel.topAnchor.constraint(equalTo: feedbackView.topAnchor, constant: 20),
            feedbackLabel.leadingAnchor.constraint(equalTo: feedbackView.leadingAnchor, constant: 16),
            feedbackLabel.trailingAnchor.constraint(equalTo: feedbackView.trailingAnchor, constant: -16),
            
            accuracyMeter.topAnchor.constraint(equalTo: feedbackLabel.bottomAnchor, constant: 16),
            accuracyMeter.leadingAnchor.constraint(equalTo: feedbackView.leadingAnchor, constant: 24),
            accuracyMeter.trailingAnchor.constraint(equalTo: feedbackView.trailingAnchor, constant: -24),
            accuracyMeter.bottomAnchor.constraint(equalTo: feedbackView.bottomAnchor, constant: -20),
            accuracyMeter.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    @objc private func backButtonTapped() {
        // Dismiss current view controller
        dismiss(animated: true) {
            // Get the root view controller
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                
                // Find and present VocalCoachViewController
                let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
                if let vocalCoachVC = storyboard.instantiateViewController(withIdentifier: "VocalCoachViewController") as? VocalCoachViewController {
                    vocalCoachVC.modalPresentationStyle = .fullScreen
                    rootVC.present(vocalCoachVC, animated: true)
                }
            }
        }
    }
    
    private func showConfettiEffect() {
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
        
        // Remove confetti layer after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            confettiLayer.removeFromSuperlayer()
        }
    }
    
    @objc private func speakButtonTapped() {
        if isListening {
            stopListening()
        } else {
            guard let selectedCardIndex = selectedCardIndex,
                  selectedCardIndex < levels[selectedLevelIndex].words.count else { return }
            
            let currentWord = levels[selectedLevelIndex].words[selectedCardIndex]
            
            // Start recording with current word and attempt number
            let attemptNumber = currentWord.record?.attempts ?? 0
            if let wordData = SupabaseDataController.shared.wordData(by: currentWord.id) {
                isListening = true
                updateSpeakButtonAppearance()
                
                // Start recording with current word and attempt number
                speechProcessor.startRecording(
                    word: wordData.wordTitle,
                    wordId: currentWord.id,
                    attemptNumber: attemptNumber + 1
                )
                
                // Subscribe to speech recognition results
                speechSubscription?.cancel() // Cancel any existing subscription
                
                // Create new subscription
                speechSubscription = speechProcessor.$userSpokenText
                    .receive(on: DispatchQueue.main)
                    .filter { !$0.isEmpty }
                    .sink { [weak self] completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            print("Speech recognition error: \(error)")
                            self?.stopListening()
                        }
                    } receiveValue: { [weak self] spokenText in
                        guard let self = self,
                              let currentWord = self.getCurrentWord() else { return }
                        
                        self.evaluateUserSpeech(spokenText)
                    }
            }
        }
    }
    
    private func updateSpeakButtonState(isListening: Bool) {
        let title = isListening ? "Listening..." : "Speak the Word!"
        speakButton.setTitle(title, for: .normal)
        speakButton.backgroundColor = isListening ? .systemRed : .systemGreen
    }
    
    private func pronounceWord(_ word: String) {
        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    private func getDirections(for word: String) {
        let currentWord = levels[selectedLevelIndex].words[selectedCardIndex ?? 0]
        if let wordData = DataController.shared.wordData(by: currentWord.id) {
            let exercise = SampleDataController.shared.getExercisesData()[String(word.prefix(1).lowercased())]
            let description = exercise?.description ?? ""
            
            let alertController = UIAlertController(title: "How to Pronounce '\(word)'", 
                                                  message: description, 
                                                  preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Got it!", style: .default))
            present(alertController, animated: true)
        }
    }
    
    private func updateSpeakButtonAppearance() {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: isListening ? "waveform.circle.fill" : "mic.circle.fill", 
                          withConfiguration: imageConfig)
        let text = isListening ? "Listening..." : "Speak the Word!"
        
        let attributedString = NSMutableAttributedString()
        
        if let image = image {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = image.withTintColor(.white)
            imageAttachment.bounds = CGRect(x: 0, y: -5, width: 20, height: 20)
            attributedString.append(NSAttributedString(attachment: imageAttachment))
        }
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 16, weight: .bold)
        ]
        
        attributedString.append(NSAttributedString(string: "  \(text)", attributes: textAttributes))
        speakButton.setAttributedTitle(attributedString, for: .normal)
    }

    func getDirection(for index: Int, at levelIndex: Int) -> String {
        guard !levels.isEmpty,
              levelIndex < levels.count,
              index < levels[levelIndex].words.count else {
            return ""
        }
        
        let appLevels = SupabaseDataController.shared.getLevelsData()
        let currentWord = levels[levelIndex].words[index]
        
        for level in appLevels {
            if let word = level.words.first(where: { $0.id == currentWord.id }) {
                return "This is \(word.wordTitle). Say \(word.wordTitle)."
            }
        }
        return ""
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCardIndex = indexPath.item
        let direction = getDirection(for: indexPath.item, at: selectedLevelIndex)
        pronounceWord(direction)
        updateSpeakButtonAppearance()
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
        
        guard let currentWord = getCurrentWord() else { return }
        let currentAttempt = levels[selectedLevelIndex].words[selectedCardIndex ?? 0].record?.attempts ?? 0
        
        // Start recording with current word and attempt number
        speechProcessor.startRecording(word: currentWord, wordId: levels[selectedLevelIndex].words[selectedCardIndex ?? 0].id, attemptNumber: currentAttempt + 1)
        isListening = true
        
        // Handle speech recognition results
        speechSubscription = speechProcessor.$userSpokenText
            .filter { !$0.isEmpty }
            .sink { [weak self] spokenText in
                guard let self = self else { return }
                
                self.evaluateUserSpeech(spokenText)
            }
    }
    
    private func stopListening() {
        speechSubscription?.cancel()
        speechProcessor.stopRecording()
        isListening = false
    }
    
    private func recordAccuracy(_ accuracy: Double) {
        guard let selectedCardIndex = selectedCardIndex else { return }
        let currentWord = levels[selectedLevelIndex].words[selectedCardIndex]
        
        Task {
            do {
                // Get recording path from speech processor if available
                let recordingPath = speechProcessor.getRecordingURL()?.path
                
                print("DEBUG: Recording accuracy to Supabase:")
                print("  - Word ID: \(currentWord.id)")
                print("  - Accuracy: \(accuracy)%")
                print("  - Recording path: \(recordingPath ?? "No recording")")
                
                // Update word progress in Supabase
                try await SupabaseDataController.shared.updateWordProgress(
                    wordId: currentWord.id,
                    accuracy: accuracy,
                    recordingPath: recordingPath
                )
                
                // Refresh local data to update the filtered word list
                await refreshData()
                
                print("DEBUG: Successfully recorded accuracy and refreshed data")
            } catch {
                print("DEBUG: Error recording accuracy: \(error)")
                handleError(error)
            }
        }
    }
    
    private func handleCorrectPronunciation() {
        guard let selectedCardIndex = selectedCardIndex else { return }
        
        // Mark current word as practiced in database
        Task {
            do {
                let currentWord = levels[selectedLevelIndex].words[selectedCardIndex]
                try await SupabaseDataController.shared.updateWordProgress(wordId: currentWord.id, accuracy: nil)
                
                // Update local data
                levels[selectedLevelIndex].words[selectedCardIndex].isPracticed = true
                
                // Show success feedback
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if let cell = self.collectionView.cellForItem(at: IndexPath(item: selectedCardIndex, section: 0)) as? LevelCardCell {
                        cell.showSuccessAnimation()
                    }
                }
                
                // Refresh data
                await refreshData()
            } catch {
                print("Error updating word progress: \(error)")
            }
        }
    }
    
    private func handleIncorrectPronunciation() {
        // Just stop listening and let user try again
        stopListening()
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
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } catch {
                handleError(error)
            }
        }
    }
    
    private func handleError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func getCurrentWord() -> String? {
        guard let selectedCardIndex = selectedCardIndex,
              selectedCardIndex < levels[selectedLevelIndex].words.count else { return nil }
        
        let currentData = levels[selectedLevelIndex].words[selectedCardIndex]
        if let wordData = SupabaseDataController.shared.wordData(by: currentData.id) {
            return wordData.wordTitle
        }
        return nil
    }
    
    private func showCompletionMessage() {
        let alert = UIAlertController(
            title: "Congratulations! 🎉",
            message: "You have completed all the words in this level. Would you like to go back to the level selection?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Go Back", style: .default) { [weak self] _ in
            self?.dismiss(animated: true) {
                // Get the root view controller
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    
                    // Find and present VocalCoachViewController
                    let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
                    if let vocalCoachVC = storyboard.instantiateViewController(withIdentifier: "VocalCoachViewController") as? VocalCoachViewController {
                        vocalCoachVC.modalPresentationStyle = .fullScreen
                        rootVC.present(vocalCoachVC, animated: true)
                    }
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    private func evaluateUserSpeech(_ spokenText: String) {
        guard let currentWord = getCurrentWord(),
              let selectedCardIndex = selectedCardIndex else { return }
        
        // Calculate accuracy using Levenshtein distance
        let distance = speechProcessor.levenshteinDistance(spokenText.lowercased(), currentWord.lowercased())
        let maxLength = max(spokenText.count, currentWord.count)
        let accuracy = max(0, 100.0 - (Double(distance) / Double(maxLength)) * 100.0)
        
        print("DEBUG: Speech evaluation:")
        print("  - Spoken text: \(spokenText)")
        print("  - Target word: \(currentWord)")
        print("  - Calculated accuracy: \(accuracy)%")
        
        // Record accuracy in Supabase
        recordAccuracy(accuracy)
        
        // Update UI based on accuracy
        updateFeedback(accuracy: accuracy, word: currentWord)
        
        // Mark card as completed if accuracy is good
        if accuracy >= 80.0 {
            if let cell = collectionView.cellForItem(at: IndexPath(item: selectedCardIndex, section: 0)) as? LevelCardCell {
                cell.markAsCompleted()
            }
            
            // Auto-scroll to next card after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard let self = self else { return }
                let nextIndex = selectedCardIndex + 1
                if nextIndex < self.levels[self.selectedLevelIndex].words.count {
                    let indexPath = IndexPath(item: nextIndex, section: 0)
                    self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                    self.selectedCardIndex = nextIndex
                    
                    // Get the direction for the next word
                    let direction = self.getDirection(for: nextIndex, at: self.selectedLevelIndex)
                    self.pronounceWord(direction)
                } else {
                    // Show completion message if this was the last word
                    self.showCompletionMessage()
                }
            }
        }
        
        // Stop listening
        stopListening()
    }
    
    private func updateFeedback(accuracy: Double, word: String) {
        // Set progress and color based on accuracy
        accuracyMeter.progress = Float(accuracy / 100.0)
        
        // Set feedback message and color based on accuracy
        if accuracy >= 80.0 {
            feedbackLabel.text = "Excellent! 🌟\nPerfect pronunciation!"
            accuracyMeter.progressTintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
            
            // Play celebration sound
            celebrationPlayer?.play()
            
            // Mark card as completed and scroll to next
            if let currentIndex = selectedCardIndex {
                if let cell = collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? LevelCardCell {
                    cell.markAsCompleted()
                }
                
                // Scroll to next card after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    guard let self = self else { return }
                    let nextIndex = currentIndex + 1
                    if nextIndex < self.levels[self.selectedLevelIndex].words.count {
                        let indexPath = IndexPath(item: nextIndex, section: 0)
                        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                        self.selectedCardIndex = nextIndex
                    }
                }
            }
        } else if accuracy >= 50.0 {
            feedbackLabel.text = "Good effort! 💪\nKeep practicing!"
            accuracyMeter.progressTintColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
        } else {
            feedbackLabel.text = "Try again! 👂\nSay: \"\(word)\""
            accuracyMeter.progressTintColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1)
        }
        
        // Show feedback with animation
        feedbackView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: []) {
            self.feedbackView.alpha = 1
            self.feedbackView.transform = .identity
        }
        
        // Hide feedback after delay with animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            UIView.animate(withDuration: 0.3) {
                self.feedbackView.alpha = 0
                self.feedbackView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let itemWidth = layout.itemSize.width + layout.minimumLineSpacing
        let offset = scrollView.contentOffset.x
        let index = round(offset / itemWidth)
        selectedCardIndex = Int(index)
        
        // Get and speak the direction for the selected word
        if let selectedCardIndex = selectedCardIndex {
            let direction = getDirection(for: selectedCardIndex, at: selectedLevelIndex)
            pronounceWord(direction)
            updateSpeakButtonAppearance()
        }
    }
}

extension LevelCardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard !levels.isEmpty, selectedLevelIndex < levels.count else { return 0 }
        return levels[selectedLevelIndex].words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LevelCardCell", for: indexPath) as? LevelCardCell,
              !levels.isEmpty,
              selectedLevelIndex < levels.count,
              indexPath.item < levels[selectedLevelIndex].words.count else {
            return UICollectionViewCell()
        }
        
        let currentWord = levels[selectedLevelIndex].words[indexPath.item]
        if let wordData = DataController.shared.wordData(by: currentWord.id) {
            cell.configure(with: wordData) { [weak self] in
                self?.selectedCardIndex = indexPath.item
                let direction = self?.getDirection(for: indexPath.item, at: self?.selectedLevelIndex ?? 0) ?? ""
                self?.pronounceWord(direction)
            }
            
            // Updated cell appearance with enhanced shadow
            cell.layer.cornerRadius = 25
            cell.layer.borderWidth = 2
            cell.layer.borderColor = UIColor(red: 75/255, green: 141/255, blue: 80/255, alpha: 1.0).cgColor
            cell.clipsToBounds = false
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 4)
            cell.layer.shadowRadius = 8
            cell.layer.shadowOpacity = 0.3
            cell.layer.masksToBounds = false
            
            // Make sure the shadow is visible
            cell.contentView.layer.masksToBounds = true
            cell.contentView.layer.cornerRadius = 25
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let itemWidth = layout.itemSize.width + layout.minimumLineSpacing
        let offset = scrollView.contentOffset.x
        let index = round(offset / itemWidth)
        selectedCardIndex = Int(index)
        
        // Enhanced scale effect for cards (no fade)
        let centerX = scrollView.contentOffset.x + (scrollView.bounds.width / 2.0)
        
        for cell in collectionView.visibleCells {
            let cellCenter = cell.center.x
            let distance = abs(cellCenter - centerX)
            let maxDistance = scrollView.bounds.width / 2.0
            
            // Scale effect only (no fade)
            let scale = max(0.7, min(1.0, 1.0 - (distance / maxDistance) * 0.3))
            
            // Apply scale transform only
            cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            // Keep opacity at 100%
            cell.alpha = 1.0
            
            // Add depth effect
            let zIndex = 1000 - Int(distance)
            cell.layer.zPosition = CGFloat(zIndex)
        }
    }
}

// Custom Layout for snapping effect
class SnappingCollectionViewLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }
        
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return .zero }
        
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalCenter = proposedContentOffset.x + collectionView.bounds.size.width / 2
        
        for layoutAttributes in rectAttributes {
            let itemHorizontalCenter = layoutAttributes.center.x
            if abs(itemHorizontalCenter - horizontalCenter) < abs(offsetAdjustment) {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }
        
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
}
