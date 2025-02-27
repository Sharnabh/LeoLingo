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
    
    private let synthesizer = AVSpeechSynthesizer()
    private let speechProcessor = SpeechProcessor()
    
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
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.backgroundColor = .white
        button.layer.cornerRadius = 25
        
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
        let cardWidth = screenWidth * 0.75 // 75% of screen width
        let cardHeight = cardWidth * 1.2
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
            
            // Back button
            customBackButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            customBackButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            customBackButton.widthAnchor.constraint(equalToConstant: 50),
            customBackButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Collection view
            collectionView.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            
            // Speak button
            speakButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            speakButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            speakButton.widthAnchor.constraint(equalToConstant: 200),
            speakButton.heightAnchor.constraint(equalToConstant: 50)
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
    
    @objc private func speakButtonTapped() {
        if isListening {
            speechProcessor.stopRecording()
            isListening = false
        } else {
            guard let selectedCardIndex = selectedCardIndex else { return }
            let currentWord = levels[selectedLevelIndex].words[selectedCardIndex]
            if let wordData = DataController.shared.wordData(by: currentWord.id) {
                isListening = true
                speechProcessor.startRecording()
                
                // Subscribe to speech recognition results
                speechProcessor.$userSpokenText
                    .filter { !$0.isEmpty }
                    .sink { [weak self] spokenText in
                        guard let self = self else { return }
                        if spokenText.lowercased().contains(wordData.wordTitle.lowercased()) {
                            if let cell = self.collectionView.cellForItem(at: IndexPath(item: selectedCardIndex, section: 0)) as? LevelCardCell {
                                cell.showSuccessAnimation()
                            }
                        } else {
                            if let cell = self.collectionView.cellForItem(at: IndexPath(item: selectedCardIndex, section: 0)) as? LevelCardCell {
                                cell.showFailureAnimation()
                            }
                        }
                        self.isListening = false
                    }
            }
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
}

extension LevelCardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return levels[selectedLevelIndex].words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LevelCardCell", for: indexPath) as! LevelCardCell
        let word = levels[selectedLevelIndex].words[indexPath.item]
        
        if let wordData = DataController.shared.wordData(by: word.id) {
            cell.configure(with: wordData) { [weak self] in
                guard let self = self else { return }
                self.getDirections(for: wordData.wordTitle)
            }
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
