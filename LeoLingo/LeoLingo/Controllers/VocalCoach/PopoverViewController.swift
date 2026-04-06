//
//  PopoverViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 21/01/25.
//

import UIKit
import ImageIO
import AVFoundation

class PopoverViewController: UIViewController {

    @IBOutlet weak var levelBadge: UIImageView?
    @IBOutlet weak var congratsLabel: UILabel?
    
    var message: String?
    var imageName: String?
    var onProceed: (() -> Void)?
    var showConfetti: Bool = false
    
    // GIF animation properties
    private var animatedImageView: UIImageView?
    private var gifImages: [UIImage] = []
    private var gifDuration: TimeInterval = 0
    private var hasSetupGif = false
    
    // Confetti properties
    private var confettiLayer: CAEmitterLayer?
    private var celebrationPlayer: AVAudioPlayer?
    
    // New feedback label
    private lazy var feedbackLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = UIColor(red: 0.482, green: 0.314, blue: 0.227, alpha: 1.0)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the old congratsLabel from storyboard (if it exists)
        if let congratsLabel = congratsLabel {
            congratsLabel.isHidden = true
            congratsLabel.alpha = 0
        }
        
        // Setup new feedback label
        setupFeedbackLabel()
        
        // Always ensure levelBadge is visible initially (if it exists)
        if let levelBadge = levelBadge {
            levelBadge.isHidden = false
            levelBadge.alpha = 1
            
            // Set static image first as placeholder
            if let imageName = imageName {
                if let image = UIImage(named: imageName) {
                    levelBadge.image = image
                } else {
                    levelBadge.image = UIImage(named: "mojo2")
                }
            } else {
                levelBadge.image = UIImage(named: "mojo2")
            }
        }
    }
    
    private func setupFeedbackLabel() {
        view.addSubview(feedbackLabel)
        
        if let message = message {
            feedbackLabel.text = message
        }
        
        NSLayoutConstraint.activate([
            feedbackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            feedbackLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            feedbackLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            feedbackLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Setup GIF after layout is complete (only once)
        if !hasSetupGif, let imageName = imageName {
            hasSetupGif = true
            setupGifAnimation(named: imageName)
        }
    }
    
    private func setupGifAnimation(named imageName: String) {
        
        if loadGif(named: imageName) {
            // GIF loaded successfully, hide the original imageView
            if let levelBadge = levelBadge {
                levelBadge.isHidden = true
                levelBadge.alpha = 0
            }
        } else {
            print("📷 GIF not found, keeping static image")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Start animation when view appears
        animatedImageView?.startAnimating()
        
        // Start confetti if requested
        if showConfetti {
            startConfettiEffect()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop animation when view disappears
        animatedImageView?.stopAnimating()
        stopConfettiEffect()
    }
    
    private func loadGif(named name: String) -> Bool {
        // Try multiple ways to find the GIF
        var gifData: Data?
        
        // Method 1: Direct path
        if let gifPath = Bundle.main.path(forResource: name, ofType: "gif") {
            gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath))
        }
        
        // Method 2: URL for resource
        if gifData == nil, let gifURL = Bundle.main.url(forResource: name, withExtension: "gif") {
            gifData = try? Data(contentsOf: gifURL)
        }
        
        guard let data = gifData,
              let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return false
        }
        
        let imageCount = CGImageSourceGetCount(source)
        
        guard imageCount > 0 else {
            return false
        }
        
        var totalDuration: TimeInterval = 0
        gifImages.removeAll()
        
        for i in 0..<imageCount {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any]
                let gifProperties = properties?[kCGImagePropertyGIFDictionary as String] as? [String: Any]
                let frameDuration = gifProperties?[kCGImagePropertyGIFUnclampedDelayTime as String] as? TimeInterval
                    ?? gifProperties?[kCGImagePropertyGIFDelayTime as String] as? TimeInterval
                    ?? 0.1
                totalDuration += frameDuration
                gifImages.append(UIImage(cgImage: cgImage))
            }
        }
        
        guard !gifImages.isEmpty else {
            return false
        }
        
        gifDuration = max(totalDuration, 0.5) // Minimum 0.5 seconds
        
        // Create animated image view
        animatedImageView = UIImageView()
        animatedImageView?.animationImages = gifImages
        animatedImageView?.animationDuration = gifDuration
        animatedImageView?.animationRepeatCount = 0 // Loop forever
        animatedImageView?.contentMode = .scaleAspectFit
        animatedImageView?.backgroundColor = .clear
        animatedImageView?.image = gifImages.first // Show first frame initially
        
        if let animatedImageView = animatedImageView {
            view.addSubview(animatedImageView)
            animatedImageView.translatesAutoresizingMaskIntoConstraints = false
            
            // Center the animated GIF in the view, above the text
            NSLayoutConstraint.activate([
                animatedImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                animatedImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
                animatedImageView.widthAnchor.constraint(equalToConstant: 600),
                animatedImageView.heightAnchor.constraint(equalToConstant: 600)
            ])
            
            view.bringSubviewToFront(animatedImageView)
            view.layoutIfNeeded()
            animatedImageView.startAnimating()
        }
        
        return true
    }

    func configurePopover(message: String, image: String, showConfetti: Bool = false) {
        self.message = message
        self.imageName = image
        self.showConfetti = showConfetti
    }
    
    private func startConfettiEffect() {
        confettiLayer?.removeFromSuperlayer()
        let newConfettiLayer = CAEmitterLayer()
        confettiLayer = newConfettiLayer
        newConfettiLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -10)
        newConfettiLayer.emitterShape = .line
        newConfettiLayer.emitterSize = CGSize(width: view.bounds.width, height: 1)
        
        let colors: [UIColor] = [.red, .green, .blue, .yellow, .purple, .orange]
        let shapes: [UIImage] = [UIImage(named: "confetti1")!, UIImage(named: "confetti2")!, UIImage(named: "confetti3")!]
        var cells: [CAEmitterCell] = []
        for color in colors {
            for shape in shapes {
                let cell = CAEmitterCell()
                cell.birthRate = 8
                cell.lifetime = 2.0
                cell.velocity = CGFloat.random(in: 200...300)
                cell.velocityRange = 100
                cell.emissionLongitude = .pi
                cell.emissionRange = .pi / 2
                cell.spin = 3
                cell.spinRange = 5
                cell.scale = 0.15
                cell.scaleRange = 0.25
                cell.contents = shape.cgImage
                cell.color = color.cgColor
                cells.append(cell)
            }
        }
        newConfettiLayer.emitterCells = cells
        view.layer.addSublayer(newConfettiLayer)
        
        // Play celebration sound
        if let soundURL = Bundle.main.url(forResource: "celebration", withExtension: "mp3") {
            do {
                celebrationPlayer = try AVAudioPlayer(contentsOf: soundURL)
                celebrationPlayer?.prepareToPlay()
                celebrationPlayer?.play()
            } catch {
                print("Error playing celebration sound: \(error.localizedDescription)")
            }
        }
    }
    
    private func stopConfettiEffect() {
        confettiLayer?.removeFromSuperlayer()
        confettiLayer = nil
        celebrationPlayer?.stop()
        celebrationPlayer = nil
    }
}
