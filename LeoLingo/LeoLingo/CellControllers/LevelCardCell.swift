import UIKit

class LevelCardCell: UICollectionViewCell {
    
    private var tapToPronounceAction: (() -> Void)?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 25
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private lazy var wordImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var wordTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .darkGray
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
        containerView.addSubview(wordImageView)
        containerView.addSubview(wordTitleLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        wordImageView.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            wordImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            wordImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            wordImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            wordImageView.heightAnchor.constraint(equalTo: wordImageView.widthAnchor),
            
            wordTitleLabel.topAnchor.constraint(equalTo: wordImageView.bottomAnchor, constant: 16),
            wordTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            wordTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            wordTitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }
    
    func configure(with wordData: AppWord, tapToPronounce: @escaping () -> Void) {
        wordImageView.image = UIImage(named: wordData.wordImage)
        wordTitleLabel.text = wordData.wordTitle
        self.tapToPronounceAction = tapToPronounce
        
        // Add tap instruction label
        let tapLabel = UILabel()
        tapLabel.translatesAutoresizingMaskIntoConstraints = false
        tapLabel.text = "Tap image to hear pronunciation"
        tapLabel.font = .systemFont(ofSize: 12, weight: .medium)
        tapLabel.textColor = .gray
        tapLabel.textAlignment = .center
        
        containerView.addSubview(tapLabel)
        
        NSLayoutConstraint.activate([
            tapLabel.topAnchor.constraint(equalTo: wordImageView.bottomAnchor, constant: 4),
            tapLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            tapLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            wordTitleLabel.topAnchor.constraint(equalTo: tapLabel.bottomAnchor, constant: 8)
        ])
    }
    
    func showSuccessAnimation() {
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            self.containerView.layer.borderColor = UIColor.green.cgColor
            self.containerView.layer.borderWidth = 3
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.containerView.transform = .identity
                self.containerView.layer.borderWidth = 0
            }
        }
    }
    
    func showFailureAnimation() {
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            self.containerView.layer.borderColor = UIColor.red.cgColor
            self.containerView.layer.borderWidth = 3
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.containerView.transform = .identity
                self.containerView.layer.borderWidth = 0
            }
        }
    }
    
    @objc private func imageTapped() {
        tapToPronounceAction?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        wordImageView.image = nil
        wordTitleLabel.text = nil
        tapToPronounceAction = nil
        containerView.layer.borderWidth = 0
    }
} 