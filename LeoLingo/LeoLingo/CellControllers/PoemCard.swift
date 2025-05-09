import UIKit

class PoemCard: UIView {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let difficultyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let musicIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "music.note.list"))
        imageView.tintColor = UIColor(hex: "FFD700")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var onPlayTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupTapGesture()
    }
    
    private func setupUI() {
        backgroundColor = UIColor(red: 0.2, green: 0.5, blue: 0.3, alpha: 0.95)
        layer.cornerRadius = 24
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.35
        layer.borderColor = UIColor(hex: "FFD700").cgColor
        layer.borderWidth = 3
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(hex: "A1D490").cgColor, UIColor(hex: "4F904C").cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = bounds
        gradient.cornerRadius = 24
        layer.insertSublayer(gradient, at: 0)
        
        addSubview(titleLabel)
        addSubview(imageView)
        addSubview(difficultyLabel)
        addSubview(musicIcon)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4),
            
            difficultyLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            difficultyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            difficultyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            musicIcon.topAnchor.constraint(equalTo: difficultyLabel.bottomAnchor, constant: 10),
            musicIcon.centerXAnchor.constraint(equalTo: centerXAnchor),
            musicIcon.widthAnchor.constraint(equalToConstant: 40),
            musicIcon.heightAnchor.constraint(equalToConstant: 40),
            musicIcon.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    
    @objc private func cardTapped() {
        // Bouncy tap animation
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.layer.shadowOpacity = 0.5
        }) { _ in
            UIView.animate(withDuration: 0.15, animations: {
                self.transform = .identity
                self.layer.shadowOpacity = 0.35
            }) { _ in
                self.onPlayTapped?()
            }
        }
    }
    
    func configure(with poem: Poem) {
        titleLabel.text = poem.title
        difficultyLabel.text = "Difficulty: \(poem.difficulty.rawValue)"
        imageView.image = UIImage(named: poem.imageName)
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
} 