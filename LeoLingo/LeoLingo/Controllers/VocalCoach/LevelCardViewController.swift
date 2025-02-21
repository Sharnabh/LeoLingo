//
//  LevelCardViewController.swift
//  LeoLingo
//
//  Created by Tarun   on 21/02/25.
//

import UIKit
import AVFoundation
import Speech

class LevelCardViewController: UIViewController {
    
    private let synthesizer = AVSpeechSynthesizer()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private var isListening = false {
        didSet {
            updateSpeakButtonAppearance()
        }
    }
    
    private var selectedCardIndex: Int?
    private var levels: [Level]
    var selectedLevelIndex: Int
    
    private var collectionView: UICollectionView!
    
    private lazy var speakButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(speakButtonTapped), for: .touchUpInside)
        updateSpeakButtonGradient(isListening: false)
        
        // Configure button content
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
    
    // MARK: - Initialization
    init(selectedLevelIndex: Int) {
        self.selectedLevelIndex = selectedLevelIndex
        self.levels = DataController.shared.getAllLevels()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.selectedLevelIndex = 0
        self.levels = DataController.shared.getAllLevels()
        super.init(coder: coder)
    }
    
    // MARK: - View Lifecycle
    override func loadView() {
        super.loadView()
        view = UIView()
        view.backgroundColor = UIColor(red: 0.988, green: 0.969, blue: 0.886, alpha: 1.0)
        
        // Initialize collection view
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.itemSize = CGSize(width: 450, height: 450)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.register(LevelCardCell.self, forCellWithReuseIdentifier: "LevelCardCell")
        
        view.addSubview(collectionView)
        view.addSubview(speakButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        requestSpeechAuthorization()
        
        // Scroll to the selected level's first word
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let indexPath = IndexPath(item: 0, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    private func setupUI() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 500),
            
            speakButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            speakButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            speakButton.heightAnchor.constraint(equalToConstant: 50),
            speakButton.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        // Add a back button if needed
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func speakButtonTapped() {
        if isListening {
            stopListening()
        } else {
            startListening(for: selectedCardIndex ?? 0)
        }
    }
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    print("Speech recognition authorized")
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
    
    private func startListening(for cardIndex: Int) {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: cardIndex, section: 0)) as? LevelCardCell else { return }
        
        selectedCardIndex = cardIndex
        isListening = true
        
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
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let spokenText = result.bestTranscription.formattedString
                if result.isFinal {
                    let currentWord = self.levels[self.selectedLevelIndex].words[cardIndex]
                    if let wordData = DataController.shared.wordData(by: currentWord.id),
                       spokenText.lowercased().contains(wordData.wordTitle.lowercased()) {
                        // Correct pronunciation
                        cell.showSuccessAnimation()
                    } else {
                        // Incorrect pronunciation
                        cell.showFailureAnimation()
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
        } catch {
            print("Failed to start audio engine: \(error)")
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
        selectedCardIndex = nil
    }
    
    private func updateSpeakButtonGradient(isListening: Bool) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        gradientLayer.cornerRadius = 25
        
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
        speakButton.layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        
        speakButton.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func updateSpeakButtonAppearance() {
        updateSpeakButtonGradient(isListening: isListening)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: isListening ? "waveform.circle.fill" : "mic.circle.fill", withConfiguration: imageConfig)
        let text = isListening ? "Listening..." : "Speak the Word!"
        
        let attributedString = NSMutableAttributedString()
        
        if let image = image {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = image.withTintColor(isListening ? .green : .white)
            imageAttachment.bounds = CGRect(x: 0, y: -5, width: 20, height: 20)
            attributedString.append(NSAttributedString(attachment: imageAttachment))
        }
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: isListening ? UIColor.green : UIColor.white,
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
        
        // Configure cell with the word
        if let wordData = DataController.shared.wordData(by: word.id) {
            cell.configure(with: wordData) { [weak self] in
                // Tap to pronounce callback
                self?.pronounceWord(wordData.wordTitle)
            }
        }
        
        return cell
    }
}
