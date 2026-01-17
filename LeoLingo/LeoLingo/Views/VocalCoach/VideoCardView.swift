// filepath: /Users/deadlinehub/Documents/GitHub/LeoLingo/LeoLingo/LeoLingo/Views/VocalCoach/VideoCardView.swift
import UIKit
import AVFoundation

class VideoCardView: UIView {
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerLooper: AVPlayerLooper?
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor(red: 0.294, green: 0.557, blue: 0.310, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 32
        return button
    }()
    
    private let wordBubbleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "A"
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        label.textColor = UIColor(red: 0.482, green: 0.314, blue: 0.227, alpha: 1.0)
        label.textAlignment = .center
        label.backgroundColor = .white
        label.layer.cornerRadius = 70
        label.clipsToBounds = true
        return label
    }()
    
    var onContinueTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor(red: 0.979, green: 0.908, blue: 0.671, alpha: 1.0)
        layer.cornerRadius = 21
        layer.borderWidth = 2
        layer.borderColor = UIColor(red: 0.631, green: 0.412, blue: 0.302, alpha: 1.0).cgColor
        
        // Add a background view behind the video (so transparent video is visible)
        let videoBackgroundView = UIView()
        videoBackgroundView.backgroundColor = backgroundColor // Same as card background
        videoBackgroundView.frame = CGRect(x: 16, y: 89, width: 289, height: 351)
        addSubview(videoBackgroundView)
        
        // Setup video player
        setupVideoPlayer()
        
        // Add word bubble
        addSubview(wordBubbleLabel)
        
        // Add continue button
        addSubview(continueButton)
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
        setupConstraints()
    }
    
    private func setupVideoPlayer() {
        // Find the video file
        guard let videoURL = Bundle.main.url(forResource: "mojodance", withExtension: "mp4") else {
            print("❌ Video file not found")
            return
        }
        
        print("✅ Setting up video player in VideoCardView")
        
        // Create player
        let asset = AVURLAsset(url: videoURL)
        let playerItem = AVPlayerItem(asset: asset)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        queuePlayer.isMuted = true
        
        // Setup looper
        let templateItem = AVPlayerItem(asset: asset)
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: templateItem)
        
        // Create player layer
        playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer?.videoGravity = .resizeAspect
        playerLayer?.backgroundColor = UIColor.clear.cgColor
        playerLayer?.masksToBounds = true
        
        // IMPORTANT: Add the layer AFTER all other sublayers are added
        // We'll add it in layoutSubviews to ensure it's on top
        
        player = queuePlayer
        
        print("✅ Video player layer created (will be added in layoutSubviews)")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Add player layer if not already added
        if let playerLayer = playerLayer, playerLayer.superlayer == nil {
            // Insert the layer above the background view but below word bubble and button
            layer.insertSublayer(playerLayer, at: 1)
            print("✅ Video player layer added to view hierarchy")
        }
        
        // Position video player layer (left side of the card, below the word bubble)
        playerLayer?.frame = CGRect(x: 16, y: 89, width: 289, height: 351)
        
        print("📍 Player layer frame updated: \(playerLayer?.frame ?? .zero)")
        print("📊 Player layer superlayer: \(playerLayer?.superlayer != nil ? "exists" : "nil")")
        print("📊 Player: \(player != nil ? "exists" : "nil")")
        print("📊 Current item: \(player?.currentItem != nil ? "exists" : "nil")")
        print("📊 Player rate: \(player?.rate ?? 0)")
        print("📊 Layer zPosition: \(playerLayer?.zPosition ?? 0)")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Word bubble (top right area)
            wordBubbleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 60),
            wordBubbleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60),
            wordBubbleLabel.widthAnchor.constraint(equalToConstant: 140),
            wordBubbleLabel.heightAnchor.constraint(equalToConstant: 140),
            
            // Continue button (bottom center)
            continueButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            continueButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            continueButton.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    @objc private func continueButtonTapped() {
        onContinueTapped?()
    }
    
    func play() {
        player?.play()
        print("▶️ Playing video")
    }
    
    func pause() {
        player?.pause()
        print("⏸ Pausing video")
    }
    
    func updateWordLabel(text: String) {
        wordBubbleLabel.text = text
    }
    
    deinit {
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        playerLooper = nil
        print("🗑 VideoCardView deallocated")
    }
}
