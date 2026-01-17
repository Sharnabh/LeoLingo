//
//  PopoverViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 21/01/25.
//

import UIKit
import ImageIO

class PopoverViewController: UIViewController {

    @IBOutlet weak var levelBadge: UIImageView?
    @IBOutlet weak var congratsLabel: UILabel?
    
    var message: String?
    var imageName: String?
    var onProceed: (() -> Void)?
    
    // GIF animation properties
    private var animatedImageView: UIImageView?
    private var gifImages: [UIImage] = []
    private var gifDuration: TimeInterval = 0
    private var hasSetupGif = false
    
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
        print("🔍 PopoverViewController: Loading GIF '\(imageName)'")
        if let levelBadge = levelBadge {
            print("📐 levelBadge frame: \(levelBadge.frame)")
        }
        
        if loadGif(named: imageName) {
            // GIF loaded successfully, hide the original imageView
            if let levelBadge = levelBadge {
                levelBadge.isHidden = true
                levelBadge.alpha = 0
            }
            print("✅ GIF loaded successfully, levelBadge hidden")
        } else {
            print("📷 GIF not found, keeping static image")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Start animation when view appears
        animatedImageView?.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop animation when view disappears
        animatedImageView?.stopAnimating()
    }
    
    private func loadGif(named name: String) -> Bool {
        // Try multiple ways to find the GIF
        var gifData: Data?
        
        // Method 1: Direct path
        if let gifPath = Bundle.main.path(forResource: name, ofType: "gif") {
            gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath))
            print("📁 Found GIF at path: \(gifPath)")
        }
        
        // Method 2: URL for resource
        if gifData == nil, let gifURL = Bundle.main.url(forResource: name, withExtension: "gif") {
            gifData = try? Data(contentsOf: gifURL)
            print("📁 Found GIF at URL: \(gifURL)")
        }
        
        guard let data = gifData,
              let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("❌ Could not load GIF data for: \(name).gif")
            return false
        }
        
        let imageCount = CGImageSourceGetCount(source)
        print("🎬 GIF has \(imageCount) frames")
        
        guard imageCount > 0 else {
            print("❌ GIF has no frames")
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
            print("❌ Could not extract frames from GIF")
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
            print("✅ Animated ImageView created, frame: \(animatedImageView.frame), isAnimating: \(animatedImageView.isAnimating)")
        }
        
        print("✅ \(name).gif loaded with \(imageCount) frames, duration: \(gifDuration)s")
        return true
    }

    func configurePopover(message: String, image: String) {
        self.message = message
        self.imageName = image
    }
}
