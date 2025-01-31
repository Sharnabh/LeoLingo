import UIKit

class VocalCoachViewController: UIViewController {
    
    @IBOutlet var practiceCardView: UIView!
    @IBOutlet var soundCards: UICollectionView!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet weak var headingTitle: UILabel!
    
    let levels = DataController.shared.getAllLevels()
    var words: [Word] = []
    var word: Word!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headingTitle.layer.cornerRadius = 21
        headingTitle.layer.masksToBounds = true
        
        words = levels.flatMap { $0.words }
        word = words.first{ $0.isPracticed == false }
        wordLabel.text = word?.wordTitle
        
        updatePracticeCardView()
        setupCollectionViewLayout()
        
        soundCards.delegate = self
        soundCards.dataSource = self
        soundCards.backgroundColor = .clear
        
        let firstNib = UINib(nibName: "SoundCards", bundle: nil)
        soundCards.register(firstNib, forCellWithReuseIdentifier: "First")
        
        let backButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        backButtonItem.tintColor = .white
        navigationItem.leftBarButtonItem = backButtonItem
    }
    
    @objc private func backButtonTapped() {
        if let presentingVC = self.presentingViewController?.presentingViewController {
            presentingVC.dismiss(animated: true, completion: nil)
        }
    }
    
    func updatePracticeCardView() {
        practiceCardView.layer.cornerRadius = 21
        practiceCardView.layer.borderWidth = 2
        practiceCardView.layer.borderColor = UIColor(red: 222/255, green: 168/255, blue: 62/255, alpha: 1.0).cgColor
        
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
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Handle navigation when the view controller is popped
        if self.isMovingFromParent {
            if let navigationController = navigationController {
                if let homeVC = storyboard?.instantiateViewController(withIdentifier: "HomePageViewController") {
                    navigationController.setViewControllers([homeVC], animated: true)
                }
            }
        }
    }
    
}


extension VocalCoachViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SampleDataController.shared.countCards()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "First", for: indexPath) as! SoundCardCollectionViewCell
        cell.layer.cornerRadius = 21
        cell.backgroundColor = .clear
        cell.updateSoundCard(with: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "WordsInCards", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "WordsInCards") as? WordsInCardViewController {
            
            // Pass the selected item (for example, an image name)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
}
