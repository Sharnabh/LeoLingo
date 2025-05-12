//
//  SIngViewController.swift
//  LeoLingo
//
//  Created by Tarun   on 05/03/25.
//

import UIKit
import AVFoundation
import Speech
import Lottie

class SingViewController: UIViewController {
    var poem: Poem!
    private var audioPlayer: AVAudioPlayer?
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine: AVAudioEngine?
    private var score: Int = 0
    private var isRecording = false
    private var starViews: [UIImageView] = []
    private var leftLottieView: LottieAnimationView?
    private var rightLottieView: LottieAnimationView?
    private var currentLineIndex: Int = 0
    private var lineTimings: [(startTime: TimeInterval, endTime: TimeInterval)] = []
    private var displayLink: CADisplayLink?
    
    private let scoreContainerView: UIView = {
        let view = UIView()
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(hex: "FFD700").cgColor, UIColor(hex: "4F904C").cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = CGRect(x: 0, y: 0, width: 200, height: 120)
        gradient.cornerRadius = 28
        view.layer.insertSublayer(gradient, at: 0)
        view.backgroundColor = .clear
        view.layer.cornerRadius = 28
        view.layer.shadowColor = UIColor.yellow.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 8
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let scoreTitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let scoreValueLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true // Hide the numeric score
        return label
    }()
    
    private let starsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let feedbackLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
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
    
    private let poemTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let poemContentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private var lineLabels: [UILabel] = []
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
        let image = UIImage(systemName: "music.note", withConfiguration: symbolConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = UIColor(hex: "4F904C")
        button.layer.cornerRadius = 50
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.borderColor = UIColor(hex: "FFD700").cgColor
        button.layer.borderWidth = 3
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let recordButton: UIButton = {
        let button = UIButton(type: .system)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium)
        let image = UIImage(systemName: "face.smiling", withConfiguration: symbolConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.backgroundColor = UIColor(hex: "FFD700")
        button.layer.cornerRadius = 50
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.borderColor = UIColor(hex: "4F904C").cgColor
        button.layer.borderWidth = 3
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let lyricsBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.2, green: 0.4, blue: 0.2, alpha: 0.7)
        view.layer.cornerRadius = 28
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor(hex: "FFD700").withAlphaComponent(0.4).cgColor
        view.layer.borderWidth = 2
        return view
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
        
        // Lottie Animations
        let leftLottie = LottieAnimationView(name: "baabaa")
        leftLottie.loopMode = .loop
        leftLottie.play()
        leftLottie.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(leftLottie)
        self.leftLottieView = leftLottie
        
        let rightLottie = LottieAnimationView(name: "baabaa")
        rightLottie.loopMode = .loop
        rightLottie.play()
        rightLottie.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rightLottie)
        self.rightLottieView = rightLottie
        
        view.addSubview(poemTitleLabel)
        view.addSubview(lyricsBackgroundView)
        view.addSubview(poemContentScrollView)
        view.addSubview(scoreContainerView)
        view.addSubview(playButton)
        view.addSubview(recordButton)
        
        scoreContainerView.addSubview(scoreTitleLabel)
        scoreContainerView.addSubview(starsStackView)
        scoreContainerView.addSubview(feedbackLabel)
        scoreContainerView.addSubview(scoreValueLabel)
        
        setupScoreStars()
        setupLyricsLines()
        
        NSLayoutConstraint.activate([
            poemTitleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            poemTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            poemTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            leftLottie.centerYAnchor.constraint(equalTo: lyricsBackgroundView.centerYAnchor),
            leftLottie.trailingAnchor.constraint(equalTo: lyricsBackgroundView.leadingAnchor, constant: -8),
            leftLottie.widthAnchor.constraint(equalToConstant: 200),
            leftLottie.heightAnchor.constraint(equalToConstant: 200),
            
            rightLottie.centerYAnchor.constraint(equalTo: lyricsBackgroundView.centerYAnchor),
            rightLottie.leadingAnchor.constraint(equalTo: lyricsBackgroundView.trailingAnchor, constant: 8),
            rightLottie.widthAnchor.constraint(equalToConstant: 200),
            rightLottie.heightAnchor.constraint(equalToConstant: 200),
            
            lyricsBackgroundView.topAnchor.constraint(equalTo: poemTitleLabel.bottomAnchor, constant: 20),
            lyricsBackgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lyricsBackgroundView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            lyricsBackgroundView.heightAnchor.constraint(equalToConstant: 300),
            
            poemContentScrollView.topAnchor.constraint(equalTo: lyricsBackgroundView.topAnchor),
            poemContentScrollView.leadingAnchor.constraint(equalTo: lyricsBackgroundView.leadingAnchor),
            poemContentScrollView.trailingAnchor.constraint(equalTo: lyricsBackgroundView.trailingAnchor),
            poemContentScrollView.bottomAnchor.constraint(equalTo: lyricsBackgroundView.bottomAnchor),
            
            scoreContainerView.topAnchor.constraint(equalTo: lyricsBackgroundView.bottomAnchor, constant: 24),
            scoreContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scoreContainerView.widthAnchor.constraint(equalToConstant: 200),
            scoreContainerView.heightAnchor.constraint(equalToConstant: 120),
            
            scoreTitleLabel.topAnchor.constraint(equalTo: scoreContainerView.topAnchor, constant: 12),
            scoreTitleLabel.centerXAnchor.constraint(equalTo: scoreContainerView.centerXAnchor),
            
            starsStackView.topAnchor.constraint(equalTo: scoreTitleLabel.bottomAnchor, constant: 8),
            starsStackView.centerXAnchor.constraint(equalTo: scoreContainerView.centerXAnchor),
            starsStackView.heightAnchor.constraint(equalToConstant: 32),
            starsStackView.widthAnchor.constraint(equalToConstant: 120),
            
            feedbackLabel.topAnchor.constraint(equalTo: starsStackView.bottomAnchor, constant: 6),
            feedbackLabel.centerXAnchor.constraint(equalTo: scoreContainerView.centerXAnchor),
            feedbackLabel.leadingAnchor.constraint(equalTo: scoreContainerView.leadingAnchor, constant: 8),
            feedbackLabel.trailingAnchor.constraint(equalTo: scoreContainerView.trailingAnchor, constant: -8),
            feedbackLabel.bottomAnchor.constraint(lessThanOrEqualTo: scoreContainerView.bottomAnchor, constant: -8),
            
            playButton.topAnchor.constraint(equalTo: scoreContainerView.bottomAnchor, constant: 30),
            playButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -30),
            playButton.widthAnchor.constraint(equalToConstant: 100),
            playButton.heightAnchor.constraint(equalToConstant: 100),
            
            recordButton.topAnchor.constraint(equalTo: scoreContainerView.bottomAnchor, constant: 30),
            recordButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 30),
            recordButton.widthAnchor.constraint(equalToConstant: 100),
            recordButton.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        poemTitleLabel.text = poem.title
        poemContentLabel.text = poem.content
        updateScoreLabel()
        
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        
        playButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        playButton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside])
        recordButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        recordButton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside])
        
        poemTitleLabel.alpha = 0
        lyricsBackgroundView.alpha = 0
        scoreContainerView.alpha = 0
        playButton.alpha = 0
        recordButton.alpha = 0
        leftLottie.alpha = 0
        rightLottie.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            UIView.animate(withDuration: 0.7, delay: 0, options: [.curveEaseOut], animations: {
                self.poemTitleLabel.alpha = 1
            })
            UIView.animate(withDuration: 0.7, delay: 0.1, options: [.curveEaseOut], animations: {
                self.lyricsBackgroundView.alpha = 1
                self.leftLottieView?.alpha = 1
                self.rightLottieView?.alpha = 1
            })
            UIView.animate(withDuration: 0.7, delay: 0.2, options: [.curveEaseOut], animations: {
                self.scoreContainerView.alpha = 1
            })
            UIView.animate(withDuration: 0.7, delay: 0.3, options: [.curveEaseOut], animations: {
                self.playButton.alpha = 1
                self.recordButton.alpha = 1
            })
        }
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
            audioPlayer?.delegate = self
            calculateLineTimings()
        } catch {
            print("Error setting up audio player: \(error)")
        }
    }
    
    private func calculateLineTimings() {
        let lines = poem.content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let totalDuration = audioPlayer?.duration ?? 0
        let averageLineDuration = totalDuration / Double(lines.count)
        
        lineTimings = lines.enumerated().map { index, _ in
            let startTime = Double(index) * averageLineDuration
            let endTime = startTime + averageLineDuration
            return (startTime, endTime)
        }
    }
    
    private func startAudioPlayback() {
        currentLineIndex = 0
        highlightCurrentLine(currentLineIndex)
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateLineHighlight))
        displayLink?.add(to: .main, forMode: .common)
        
        audioPlayer?.play()
    }
    
    @objc private func updateLineHighlight() {
        guard let player = audioPlayer, player.isPlaying else { return }
        
        let currentTime = player.currentTime
        if currentLineIndex < lineTimings.count {
            let (startTime, endTime) = lineTimings[currentLineIndex]
            
            if currentTime >= endTime {
                currentLineIndex += 1
                if currentLineIndex < lineTimings.count {
                    highlightCurrentLine(currentLineIndex)
                }
            }
        }
    }
    
    @objc private func playButtonTapped() {
        if audioPlayer?.isPlaying == true {
            audioPlayer?.pause()
            displayLink?.invalidate()
            displayLink = nil
        } else {
            startAudioPlayback()
        }
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
    
    private func setupScoreStars() {
        for _ in 0..<5 {
            let starView = UIImageView(image: UIImage(systemName: "star.fill"))
            starView.tintColor = .lightGray
            starView.contentMode = .scaleAspectFit
            starViews.append(starView)
            starsStackView.addArrangedSubview(starView)
        }
    }
    
    @objc private func buttonTouchDown(_ button: UIButton) {
        UIView.animate(withDuration: 0.1) {
            button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    @objc private func buttonTouchUp(_ button: UIButton) {
        UIView.animate(withDuration: 0.1) {
            button.transform = .identity
        }
    }
    
    private func updateScoreLabel() {
        // Only update stars and feedback
        let filledStars = min(5, Int(Double(score) / 20.0))
        for (index, starView) in starViews.enumerated() {
            UIView.animate(withDuration: 0.3, delay: 0.05 * Double(index), options: [.autoreverse, .repeat], animations: {
                if index < filledStars {
                    starView.tintColor = .yellow
                    starView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                } else {
                    starView.tintColor = .lightGray
                    starView.transform = .identity
                }
            }, completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    starView.transform = .identity
                }
            })
        }
        // Update feedback message
        let feedback: String
        switch score {
        case 0...20:
            feedback = "Keep trying! You can do it! 🌟"
        case 21...40:
            feedback = "Good job! Keep practicing! 🌟🌟"
        case 41...60:
            feedback = "Great singing! 🌟🌟🌟"
        case 61...80:
            feedback = "Amazing performance! 🌟🌟🌟🌟"
        default:
            feedback = "Perfect! You're a star! 🌟🌟🌟🌟🌟"
        }
        UIView.animate(withDuration: 0.3) {
            self.feedbackLabel.text = feedback
        }
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    
    deinit {
        stopRecording()
    }
    
    private func setupLyricsLines() {
        // Remove old labels if any
        for label in lineLabels { label.removeFromSuperview() }
        lineLabels.removeAll()
        
        let lines = poem.content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        var lastLabel: UILabel? = nil
        for (i, line) in lines.enumerated() {
            let label = UILabel()
            label.text = line
            label.font = .systemFont(ofSize: 24)
            label.textColor = .white
            label.textAlignment = .center
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            poemContentScrollView.addSubview(label)
            lineLabels.append(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: poemContentScrollView.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: poemContentScrollView.trailingAnchor),
                label.widthAnchor.constraint(equalTo: poemContentScrollView.widthAnchor)
            ])
            if let last = lastLabel {
                label.topAnchor.constraint(equalTo: last.bottomAnchor, constant: 8).isActive = true
            } else {
                label.topAnchor.constraint(equalTo: poemContentScrollView.topAnchor).isActive = true
            }
            lastLabel = label
        }
        if let last = lastLabel {
            last.bottomAnchor.constraint(equalTo: poemContentScrollView.bottomAnchor).isActive = true
        }
    }
    
    private func highlightCurrentLine(_ index: Int) {
        for (i, label) in lineLabels.enumerated() {
            if i == index {
                label.backgroundColor = UIColor(hex: "FFD700").withAlphaComponent(0.5)
                label.textColor = UIColor(hex: "4F904C")
                label.font = .systemFont(ofSize: 26, weight: .bold)
                label.layer.cornerRadius = 14
                label.layer.masksToBounds = true
                label.layer.shadowColor = UIColor.yellow.cgColor
                label.layer.shadowOpacity = 0.7
                label.layer.shadowRadius = 8
                label.layer.shadowOffset = CGSize(width: 0, height: 2)
                // Auto-scroll to this label
                let rect = label.convert(label.bounds, to: poemContentScrollView)
                poemContentScrollView.scrollRectToVisible(rect, animated: true)
            } else {
                label.backgroundColor = .clear
                label.textColor = .white
                label.font = .systemFont(ofSize: 24)
                label.layer.cornerRadius = 0
                label.layer.shadowOpacity = 0
            }
        }
    }
}

extension SingViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        displayLink?.invalidate()
        displayLink = nil
        currentLineIndex = 0
        highlightCurrentLine(currentLineIndex)
    }
}
