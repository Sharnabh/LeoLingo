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
        button.backgroundColor = UIColor(red: 44/255, green: 144/255, blue: 71/255, alpha: 1.0)
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
    
    // MARK: - Initialization
    init(selectedLevelIndex: Int) {
        self.selectedLevelIndex = selectedLevelIndex
        self.levels = DataController.shared.getAllLevels()
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        self.selectedLevelIndex = 0
        self.levels = DataController.shared.getAllLevels()
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
        
        // Scroll to the first word with animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            let indexPath = IndexPath(item: 0, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
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
            warningLabel.heightAnchor.constraint(equalToConstant: 40)
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
            speechProcessor.stopRecording()
            isListening = false
            updateSpeakButtonState(isListening: false)
        } else {
            guard let selectedCardIndex = selectedCardIndex else { return }
            let currentWord = levels[selectedLevelIndex].words[selectedCardIndex]
            
            if let wordData = DataController.shared.wordData(by: currentWord.id) {
                isListening = true
                updateSpeakButtonState(isListening: true)
                
                let attemptNumber = currentWord.record?.attempts ?? 0
                speechProcessor.startRecording(
                    word: wordData.wordTitle,
                    wordId: currentWord.id,
                    attemptNumber: attemptNumber + 1
                )
                
                // Subscribe to speech recognition results
                speechProcessor.$userSpokenText
                    .filter { !$0.isEmpty }
                    .sink { [weak self] spokenText in
                        guard let self = self else { return }
                        
                        let normalizedSpoken = spokenText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                        let normalizedExpected = wordData.wordTitle.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        let isCorrect = normalizedSpoken.contains(normalizedExpected)
                        
                        if let cell = self.collectionView.cellForItem(at: IndexPath(item: selectedCardIndex, section: 0)) as? LevelCardCell {
                            if isCorrect {
                                cell.showSuccessAnimation()
                                self.showConfettiEffect() // Add confetti effect on success
                            } else {
                                cell.showFailureAnimation()
                            }
                        }
                        
                        self.isListening = false
                        self.updateSpeakButtonState(isListening: false)
                    }
                    .store(in: &cancellables)
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
        if let gradientLayer = speakButton.layer.sublayers?.first as? CAGradientLayer {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            if isListening {
                gradientLayer.colors = [
                    UIColor(red: 44/255, green: 144/255, blue: 71/255, alpha: 0.3).cgColor,
                    UIColor(red: 78/255, green: 157/255, blue: 50/255, alpha: 0.3).cgColor
                ]
            } else {
                gradientLayer.colors = [
                    UIColor(red: 44/255, green: 144/255, blue: 71/255, alpha: 1.0).cgColor,
                    UIColor(red: 78/255, green: 157/255, blue: 50/255, alpha: 1.0).cgColor
                ]
            }
            
            CATransaction.commit()
        }
        
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
    
    private func recordAccuracy(_ accuracy: Double) {
        guard let selectedCardIndex = selectedCardIndex else { return }
        let currentWord = levels[selectedLevelIndex].words[selectedCardIndex]
        
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
        // Show feedback to user
        let alert = UIAlertController(
            title: "Let's Try Again",
            message: "That wasn't quite right. Would you like to try again?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Try Again", style: .default))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
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
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
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
        guard let selectedCardIndex = selectedCardIndex else { return nil }
        let currentData = levels[selectedLevelIndex].words[selectedCardIndex]
        if let wordData = DataController.shared.wordData(by: currentData.id) {
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
}

extension LevelCardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return levels[selectedLevelIndex].words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LevelCardCell", for: indexPath) as? LevelCardCell else {
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
        
        // Enhanced scale and fade effect for cards
        let centerX = scrollView.contentOffset.x + (scrollView.bounds.width / 2.0)
        
        for cell in collectionView.visibleCells {
            let cellCenter = cell.center.x
            let distance = abs(cellCenter - centerX)
            
            // More dramatic scale effect
            let scale = max(0.7, min(1.0, 1.0 - (distance / scrollView.bounds.width) * 0.5))
            // More dramatic fade effect
            let alpha = max(0.3, min(1.0, 1.0 - (distance / scrollView.bounds.width) * 1.2))
            
            cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            cell.alpha = alpha
            
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
