import UIKit

class VocalCoachViewController: UIViewController {
    
    @IBOutlet var practiceCardView: UIView!
    @IBOutlet var soundCards: UICollectionView!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet weak var headingTitle: UILabel!
    
    let levels = DataController.shared.getAllLevels()
    var words: [Word] = []
    var word: Word!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackButton()
        
        headingTitle.layer.cornerRadius = 21
        headingTitle.layer.masksToBounds = true
        
        words = levels.flatMap { $0.words }
        word = words.first{ $0.isPracticed == false }
        let word = DataController.shared.wordData(by: word.id)
        wordLabel.text = word?.wordTitle
        
        updatePracticeCardView()
        setupCollectionViewLayout()
        
        soundCards.delegate = self
        soundCards.dataSource = self
        soundCards.backgroundColor = .clear
        soundCards.isUserInteractionEnabled = true
        
        let firstNib = UINib(nibName: "SoundCards", bundle: nil)
        soundCards.register(firstNib, forCellWithReuseIdentifier: "First")
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
    
    func updatePracticeCardView() {
        practiceCardView.layer.cornerRadius = 21
        practiceCardView.layer.borderWidth = 2
        practiceCardView.layer.borderColor = UIColor(red: 161/255, green: 105/255, blue: 77/255, alpha: 1.0).cgColor
        
        practiceCardView.clipsToBounds = false
        practiceCardView.layer.shadowColor = UIColor.black.cgColor
        practiceCardView.layer.shadowOpacity = 0.62
        practiceCardView.layer.shadowOffset = CGSize(width: 0, height: 1)
        practiceCardView.layer.shadowRadius = 10
        view.bringSubviewToFront(practiceCardView)
    }
    
    func setupCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.itemSize = CGSize(width: 380, height: 260)
        soundCards.collectionViewLayout = layout
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
        if let practiceVC = storyboard.instantiateViewController(withIdentifier: "PracticeScreenViewController") as? PracticeScreenViewController {
            // Always start from the beginning
            practiceVC.levelIndex = 0
            practiceVC.currentIndex = 0
            
            if let navigationController = self.navigationController {
                navigationController.pushViewController(practiceVC, animated: true)
            } else {
                practiceVC.modalPresentationStyle = .fullScreen
                present(practiceVC, animated: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            if let navigationController = self.navigationController {
                if let homeVC = storyboard?.instantiateViewController(withIdentifier: "HomePageViewController") {
                    navigationController.setViewControllers([homeVC], animated: true)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected level card at index: \(indexPath.item)")
        
        // Create the LevelCardViewController
        let levelCardVC = LevelCardViewController(selectedLevelIndex: indexPath.item)
        levelCardVC.title = "Level \(indexPath.item + 1)"
        
        if let navController = self.navigationController {
            // We have a navigation controller, just push
            navController.pushViewController(levelCardVC, animated: true)
        } else {
            // Create a new navigation controller and present it
            let navController = UINavigationController(rootViewController: levelCardVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true, completion: nil)
        }
    }
    
    @objc private func backButtonTapped() {
        if let navController = self.navigationController {
            // First try to find HomePageViewController in the navigation stack
            for viewController in navController.viewControllers {
                if viewController is HomePageViewController {
                    navController.popToViewController(viewController, animated: true)
                    return
                }
            }
            
            // If not found in stack, create and set a new HomePageViewController
            if let homeVC = storyboard?.instantiateViewController(withIdentifier: "HomePageViewController") {
                navController.setViewControllers([homeVC], animated: true)
            }
        } else {
            // If no navigation controller, handle modal dismissal
            dismiss(animated: true, completion: nil)
        }
    }
}

extension VocalCoachViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SampleDataController.shared.countLevelCards()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "First", for: indexPath) as! LevelCardCollectionViewCell
        cell.layer.cornerRadius = 21
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor(red: 161/255, green: 105/255, blue: 77/255, alpha: 1.0).cgColor
        cell.backgroundColor = .clear
        cell.isUserInteractionEnabled = true
        cell.contentView.isUserInteractionEnabled = true
        cell.updatelevelCard(with: indexPath)
        
        return cell
    }
    
    // Add touch handling methods
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? LevelCardCollectionViewCell {
            cell.animateTapDown()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? LevelCardCollectionViewCell {
            cell.animateTapUp()
        }
    }
}
