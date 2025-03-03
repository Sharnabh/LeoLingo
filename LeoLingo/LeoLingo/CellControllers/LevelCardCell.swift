import UIKit

class LevelCardCell: UICollectionViewCell, CAAnimationDelegate {
    
    private var tapToPronounceAction: (() -> Void)?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 252/255, green: 247/255, blue: 228/255, alpha: 1.0) // #FCF7E4
        view.layer.cornerRadius = 25
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(red: 75/255, green: 141/255, blue: 80/255, alpha: 1.0).cgColor // #4B8D50
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private lazy var wordTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private lazy var wordImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    private lazy var tapInstructionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tap card to hear pronunciation"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGray
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(wordTitleLabel)
        containerView.addSubview(wordImageView)
        containerView.addSubview(tapInstructionLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            wordTitleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            wordTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            wordTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            wordImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            wordImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            wordImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            wordImageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.4),
            
            tapInstructionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            tapInstructionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            tapInstructionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
    }
    
    func configure(with wordData: AppWord, tapToPronounce: @escaping () -> Void) {
        print("Loading image: \(wordData.wordImage)")
        
        if let image = UIImage(named: wordData.wordImage) {
            wordImageView.image = image
        } else {
            print("Failed to load image: \(wordData.wordImage)")
            wordImageView.backgroundColor = .lightGray
        }
        
        wordTitleLabel.text = wordData.wordTitle
        self.tapToPronounceAction = tapToPronounce
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func showSuccessAnimation() {
        // Use layer animations for success effect without affecting transform
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 0.2
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.1
        scaleAnimation.autoreverses = true
        
        // Add border animation
        UIView.animate(withDuration: 0.2, animations: {
            self.containerView.layer.borderColor = UIColor.systemGreen.cgColor
            self.containerView.layer.borderWidth = 5
        }) { _ in
            // Add bounce animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let bounceAnimation = CABasicAnimation(keyPath: "position.y")
                bounceAnimation.duration = 0.2
                bounceAnimation.fromValue = self.layer.position.y
                bounceAnimation.toValue = self.layer.position.y - 10
                bounceAnimation.autoreverses = true
                bounceAnimation.delegate = self
                
                // Set animation key for identification in delegate method
                bounceAnimation.setValue("bounceAnimation", forKey: "animationName")
                
                self.layer.add(bounceAnimation, forKey: "bounceAnimation")
            }
        }
        
        self.layer.add(scaleAnimation, forKey: "scaleAnimation")
    }
    
    // MARK: - CAAnimationDelegate
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let animationName = anim.value(forKey: "animationName") as? String,
           animationName == "bounceAnimation" {
            // Reset border
            UIView.animate(withDuration: 0.2) {
                self.containerView.layer.borderWidth = 0
            }
        }
    }
    
    func showFailureAnimation() {
        // Add gentle failure animation
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0]
        self.layer.add(animation, forKey: "shake")
        
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView.layer.borderColor = UIColor.systemRed.cgColor
            self.containerView.layer.borderWidth = 5
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIView.animate(withDuration: 0.2) {
                    self.containerView.layer.borderWidth = 0
                }
            }
        }
    }
    
    @objc private func imageTapped() {
        // Add subtle tap animation
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
            self.tapToPronounceAction?()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        wordImageView.image = nil
        wordTitleLabel.text = nil
        tapToPronounceAction = nil
        containerView.layer.borderWidth = 0
        transform = .identity
    }
} 