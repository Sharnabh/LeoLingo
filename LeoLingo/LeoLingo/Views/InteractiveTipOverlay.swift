import UIKit

class InteractiveTipOverlay: UIView {
    
    struct Step {
        let targetView: UIView?
        let title: String
        let message: String
    }
    
    private let steps: [Step]
    private var currentIndex = 0
    private let onFinish: () -> Void
    
    // Subviews
    private let maskLayer = CAShapeLayer()
    private let pulseLayer = CAShapeLayer()
    private let bubbleView = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let nextButton = UIButton()
    private let skipButton = UIButton()
    private let arrowLayer = CAShapeLayer()
    private let mascotLabel = UILabel()
    
    init(frame: CGRect, steps: [Step], onFinish: @escaping () -> Void) {
        self.steps = steps
        self.onFinish = onFinish
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.backgroundColor = .clear
        
        // Setup background mask
        maskLayer.fillColor = UIColor.black.withAlphaComponent(0.68).cgColor
        maskLayer.fillRule = .evenOdd
        self.layer.addSublayer(maskLayer)
        
        // Setup pulse layer for drawing attention
        pulseLayer.fillColor = UIColor.clear.cgColor
        pulseLayer.strokeColor = UIColor(red: 255/255, green: 123/255, blue: 61/255, alpha: 1.0).cgColor // App theme orange
        pulseLayer.lineWidth = 3.0
        self.layer.addSublayer(pulseLayer)
        
        // Setup popover bubble view
        bubbleView.backgroundColor = .white
        bubbleView.layer.cornerRadius = 20
        bubbleView.layer.shadowColor = UIColor.black.cgColor
        bubbleView.layer.shadowOpacity = 0.25
        bubbleView.layer.shadowOffset = CGSize(width: 0, height: 6)
        bubbleView.layer.shadowRadius = 10
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bubbleView)
        
        // Mascot/Icon badge
        mascotLabel.text = "🦁 Leo Tip"
        mascotLabel.font = .systemFont(ofSize: 14, weight: .bold)
        mascotLabel.textColor = UIColor(red: 255/255, green: 123/255, blue: 61/255, alpha: 1.0)
        mascotLabel.backgroundColor = UIColor(red: 255/255, green: 242/255, blue: 235/255, alpha: 1.0)
        mascotLabel.layer.cornerRadius = 10
        mascotLabel.layer.masksToBounds = true
        mascotLabel.textAlignment = .center
        mascotLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(mascotLabel)
        
        // Title
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(titleLabel)
        
        // Message
        messageLabel.textColor = .darkGray
        messageLabel.font = .systemFont(ofSize: 14, weight: .medium)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(messageLabel)
        
        // Next button (Primary)
        nextButton.setTitle("Next", for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.backgroundColor = UIColor(red: 75/255, green: 142/255, blue: 79/255, alpha: 1.0) // App theme green
        nextButton.layer.cornerRadius = 12
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(nextButton)
        
        // Skip button (Secondary)
        skipButton.setTitle("Skip", for: .normal)
        skipButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        skipButton.setTitleColor(.gray, for: .normal)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(skipButton)
        
        // Arrow layer
        arrowLayer.fillColor = UIColor.white.cgColor
        self.layer.addSublayer(arrowLayer)
        
        // Set constraints
        NSLayoutConstraint.activate([
            mascotLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
            mascotLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 16),
            mascotLabel.widthAnchor.constraint(equalToConstant: 85),
            mascotLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: mascotLabel.bottomAnchor, constant: 8),
            
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            
            skipButton.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
            skipButton.centerYAnchor.constraint(equalTo: nextButton.centerYAnchor),
            
            nextButton.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16),
            nextButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            nextButton.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -16),
            nextButton.widthAnchor.constraint(equalToConstant: 80),
            nextButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Load first step
        showStep(at: 0)
    }
    
    private func showStep(at index: Int) {
        guard index < steps.count else {
            dismissOverlay()
            return
        }
        
        let step = steps[index]
        titleLabel.text = step.title
        messageLabel.text = step.message
        
        if index == steps.count - 1 {
            nextButton.setTitle("Done", for: .normal)
        } else {
            nextButton.setTitle("Next", for: .normal)
        }
        
        // Update mask and layouts
        layoutOverlayForCurrentStep()
        
        // Trigger subtle animation
        bubbleView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        bubbleView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.bubbleView.transform = .identity
            self.bubbleView.alpha = 1
        }, completion: nil)
    }
    
    private func layoutOverlayForCurrentStep() {
        let step = steps[currentIndex]
        
        // Reset animations on pulse layer
        pulseLayer.removeAllAnimations()
        
        let path = UIBezierPath(rect: self.bounds)
        
        if let target = step.targetView, let window = target.window {
            // Convert target frame to overlay coordinates
            let targetRectInWindow = target.convert(target.bounds, to: window)
            let targetFrame = window.convert(targetRectInWindow, to: self)
            
            // Add padding to cutout
            let padding: CGFloat = 8
            let cutoutRect = targetFrame.insetBy(dx: -padding, dy: -padding)
            let cutoutPath = UIBezierPath(roundedRect: cutoutRect, cornerRadius: 12)
            
            // Mask subtraction: path.reversing() with evenOdd rule
            path.append(cutoutPath)
            maskLayer.path = path.cgPath
            
            // Configure and animate pulse ring around cutout
            pulseLayer.path = cutoutPath.cgPath
            pulseLayer.isHidden = false
            
            let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
            pulseAnimation.duration = 1.2
            pulseAnimation.fromValue = 1.0
            pulseAnimation.toValue = 1.05
            pulseAnimation.repeatCount = .infinity
            pulseAnimation.autoreverses = true
            
            // Pulse anchor point needs to be the center of the cutout
            let center = CGPoint(x: cutoutRect.midX, y: cutoutRect.midY)
            pulseLayer.position = center
            pulseLayer.bounds = cutoutRect
            
            pulseLayer.add(pulseAnimation, forKey: "pulse")
            
            // Position bubble relative to target view
            positionBubble(relativeTo: cutoutRect)
        } else {
            // No target view, draw plain dimmed background (center tip)
            maskLayer.path = path.cgPath
            pulseLayer.isHidden = true
            positionBubbleInCenter()
        }
    }
    
    private func positionBubble(relativeTo targetRect: CGRect) {
        let screenWidth = self.bounds.width
        let bubbleWidth: CGFloat = min(300, screenWidth - 32)
        
        // Remove prior constraint constants that might conflict
        bubbleView.constraints.forEach { constraint in
            if constraint.firstAttribute == .width {
                bubbleView.removeConstraint(constraint)
            }
        }
        
        // Determine if target is in the top half or bottom half of the screen
        let isTopHalf = targetRect.midY < self.bounds.height / 2
        
        // Clean out old constraints on bubble relative to superview
        self.constraints.forEach { constraint in
            if constraint.firstItem as? UIView == bubbleView || constraint.secondItem as? UIView == bubbleView {
                self.removeConstraint(constraint)
            }
        }
        
        // Width constraint
        bubbleView.widthAnchor.constraint(equalToConstant: bubbleWidth).isActive = true
        
        // X constraint: try to center horizontally above/below target
        let targetMidX = targetRect.midX
        let idealBubbleMinX = targetMidX - (bubbleWidth / 2)
        
        // Constrain bubble boundaries to screen edges
        let actualBubbleMinX = max(16, min(screenWidth - bubbleWidth - 16, idealBubbleMinX))
        bubbleView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: actualBubbleMinX).isActive = true
        
        // Y constraint and Arrow drawing
        let arrowWidth: CGFloat = 16
        let arrowHeight: CGFloat = 10
        let arrowPath = UIBezierPath()
        
        if isTopHalf {
            // Target is in top half: place bubble below target
            let bubbleY = targetRect.maxY + 15
            bubbleView.topAnchor.constraint(equalTo: self.topAnchor, constant: bubbleY).isActive = true
            
            // Draw arrow pointing UP
            let arrowX = max(actualBubbleMinX + 20, min(actualBubbleMinX + bubbleWidth - 20, targetMidX))
            arrowPath.move(to: CGPoint(x: arrowX, y: bubbleY))
            arrowPath.addLine(to: CGPoint(x: arrowX - arrowWidth/2, y: bubbleY + arrowHeight))
            arrowPath.addLine(to: CGPoint(x: arrowX + arrowWidth/2, y: bubbleY + arrowHeight))
            arrowPath.close()
        } else {
            // Target is in bottom half: place bubble above target
            // We need to estimate or allow auto-layout to set bubble height
            // So we set bottom constraint of bubble relative to target's top
            let distanceToBottom = self.bounds.height - targetRect.minY + 15
            bubbleView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -distanceToBottom).isActive = true
            
            // Set up local layout pass to resolve height, or compute bubble height
            // Draw arrow pointing DOWN after auto-layout has updated frames, or use layoutSubviews.
            // For simplicity, we can draw the arrow dynamically using layoutSubviews.
        }
        
        // Keep values for layoutSubviews to redraw arrow
        self.layoutIfNeeded()
        drawArrow(targetRect: targetRect, isTopHalf: isTopHalf, actualBubbleMinX: actualBubbleMinX, bubbleWidth: bubbleWidth)
    }
    
    private func positionBubbleInCenter() {
        // Clean out old constraints on bubble relative to superview
        self.constraints.forEach { constraint in
            if constraint.firstItem as? UIView == bubbleView || constraint.secondItem as? UIView == bubbleView {
                self.removeConstraint(constraint)
            }
        }
        
        arrowLayer.path = nil
        
        let screenWidth = self.bounds.width
        let bubbleWidth: CGFloat = min(300, screenWidth - 32)
        
        bubbleView.widthAnchor.constraint(equalToConstant: bubbleWidth).isActive = true
        bubbleView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        bubbleView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    private func drawArrow(targetRect: CGRect, isTopHalf: Bool, actualBubbleMinX: CGFloat, bubbleWidth: CGFloat) {
        let arrowWidth: CGFloat = 16
        let arrowHeight: CGFloat = 10
        let arrowPath = UIBezierPath()
        
        let targetMidX = targetRect.midX
        let arrowX = max(actualBubbleMinX + 24, min(actualBubbleMinX + bubbleWidth - 24, targetMidX))
        
        if isTopHalf {
            // Pointing up
            let arrowY = targetRect.maxY + 15
            arrowPath.move(to: CGPoint(x: arrowX, y: arrowY - 1))
            arrowPath.addLine(to: CGPoint(x: arrowX - arrowWidth/2, y: arrowY + arrowHeight))
            arrowPath.addLine(to: CGPoint(x: arrowX + arrowWidth/2, y: arrowY + arrowHeight))
            arrowPath.close()
        } else {
            // Pointing down
            // Retrieve actual frame of bubble to get its top/bottom
            let bubbleMaxY = bubbleView.frame.maxY
            arrowPath.move(to: CGPoint(x: arrowX, y: bubbleMaxY + 1))
            arrowPath.addLine(to: CGPoint(x: arrowX - arrowWidth/2, y: bubbleMaxY - arrowHeight))
            arrowPath.addLine(to: CGPoint(x: arrowX + arrowWidth/2, y: bubbleMaxY - arrowHeight))
            arrowPath.close()
        }
        
        arrowLayer.path = arrowPath.cgPath
    }
    
    @objc private func nextTapped() {
        currentIndex += 1
        if currentIndex < steps.count {
            showStep(at: currentIndex)
        } else {
            dismissOverlay()
        }
    }
    
    @objc private func skipTapped() {
        dismissOverlay()
    }
    
    private func dismissOverlay() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
            self.bubbleView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.removeFromSuperview()
            self.onFinish()
        }
    }
}
