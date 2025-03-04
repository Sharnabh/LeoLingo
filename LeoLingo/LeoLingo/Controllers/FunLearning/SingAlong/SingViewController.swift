//
//  SIngViewController.swift
//  LeoLingo
//
//  Created by Tarun   on 05/03/25.
//

import UIKit
import AVFoundation
import Speech

class SingViewController: UIViewController {
    var poem: Poem!
    private var audioPlayer: AVAudioPlayer?
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine: AVAudioEngine?
    private var score: Int = 0
    private var isRecording = false
    
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
    
    private let poemTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let poemContentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium)
        let image = UIImage(systemName: "play.circle.fill", withConfiguration: symbolConfig)?
            .withTintColor(UIColor(hex: "4F904C"), renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let recordButton: UIButton = {
        let button = UIButton(type: .system)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium)
        let image = UIImage(systemName: "mic.circle.fill", withConfiguration: symbolConfig)?
            .withTintColor(UIColor(hex: "4F904C"), renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        setupUI()
        setupSpeechRecognition()
        setupAudioPlayer()
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
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 161/255, green: 105/255, blue: 77/255, alpha: 1.0)
        
        view.addSubview(poemTitleLabel)
        view.addSubview(poemContentLabel)
        view.addSubview(scoreLabel)
        view.addSubview(playButton)
        view.addSubview(recordButton)
        
        NSLayoutConstraint.activate([
            poemTitleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            poemTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            poemTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            poemContentLabel.topAnchor.constraint(equalTo: poemTitleLabel.bottomAnchor, constant: 20),
            poemContentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            poemContentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            poemContentLabel.heightAnchor.constraint(equalToConstant: 200),
            
            scoreLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Horizontal arrangement of play and record buttons below score
            playButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 40),
            playButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -20),
            playButton.widthAnchor.constraint(equalToConstant: 100),
            playButton.heightAnchor.constraint(equalToConstant: 100),
            
            recordButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 40),
            recordButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 20),
            recordButton.widthAnchor.constraint(equalToConstant: 100),
            recordButton.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        poemTitleLabel.text = poem.title
        poemContentLabel.text = poem.content
        updateScoreLabel()
        
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
    }
    
    private func setupSpeechRecognition() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
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
    
    private func setupAudioPlayer() {
        guard let url = Bundle.main.url(forResource: poem.audioFileName, withExtension: "mp3") else {
            print("Could not find audio file")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error setting up audio player: \(error)")
        }
    }
    
    @objc private func playButtonTapped() {
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }
    
    @objc private func recordButtonTapped() {
        if isRecording {
            stopRecording()
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium)
            let image = UIImage(systemName: "mic.circle.fill", withConfiguration: symbolConfig)?
                .withTintColor(UIColor(hex: "4F904C"), renderingMode: .alwaysOriginal)
            recordButton.setImage(image, for: .normal)
        } else {
            startRecording()
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium)
            let image = UIImage(systemName: "stop.circle.fill", withConfiguration: symbolConfig)?
                .withTintColor(UIColor(hex: "4F904C"), renderingMode: .alwaysOriginal)
            recordButton.setImage(image, for: .normal)
        }
        isRecording.toggle()
    }
    
    private func startRecording() {
        audioEngine = AVAudioEngine()
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let spokenText = result.bestTranscription.formattedString.lowercased()
                self.evaluatePerformance(spokenText)
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
    
    private func stopRecording() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to reset audio session: \(error)")
        }
    }
    
    private func evaluatePerformance(_ spokenText: String) {
        let poemWords = poem.content.lowercased().components(separatedBy: .whitespacesAndNewlines)
        let spokenWords = spokenText.components(separatedBy: .whitespacesAndNewlines)
        
        var correctWords = 0
        for word in spokenWords {
            if poemWords.contains(word) {
                correctWords += 1
            }
        }
        
        let accuracy = Double(correctWords) / Double(poemWords.count)
        let points = Int(accuracy * 100 * Double(poem.scoreMultiplier))
        
        score = max(score, points)
        updateScoreLabel()
    }
    
    private func updateScoreLabel() {
        scoreLabel.text = "Score: \(score) points"
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    
    deinit {
        stopRecording()
    }
}
