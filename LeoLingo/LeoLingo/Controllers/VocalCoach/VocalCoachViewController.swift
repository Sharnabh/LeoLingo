import UIKit

// Dummy data for sound cards
let soundCardsImage: [String] = ["Earlywords", "BodyParts", "Earlywords", "BodyParts", "Earlywords", "BodyParts","Earlywords", "BodyParts", "Earlywords", "BodyParts", "Earlywords", "BodyParts"]

class VocalCoachViewController: UIViewController {
    @IBOutlet var practiceCardView: UIView!
    @IBOutlet var soundCards: UICollectionView!
    @IBOutlet var WordLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePracticeCardView()
        setupCollectionViewLayout()
        
        soundCards.delegate = self
        soundCards.dataSource = self
        soundCards.backgroundColor = .clear
        
        let firstNib = UINib(nibName: "SoundCards", bundle: nil)
        soundCards.register(firstNib, forCellWithReuseIdentifier: "First")
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
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.itemSize = CGSize(width: 380, height: 280)
        soundCards.collectionViewLayout = layout
    }
    @IBAction func continueButtonTapped(_ sender: UIButton) {
    }
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            // Check if the current view controller is being popped
            if self.isMovingFromParent {
                // Create your desired view controller
                if let navigationController = navigationController {
                    if let desiredViewController = storyboard?.instantiateViewController(withIdentifier: "HomePageViewController") {
                        // Set the desired view controller as the root
                        navigationController.setViewControllers([desiredViewController], animated: true)
                    }
                }
            }
        }
 }


extension VocalCoachViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return soundCardsImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "First", for: indexPath) as! SoundCardCollectionViewCell
        cell.layer.cornerRadius = 21
        cell.backgroundColor = .clear
        let imageName = soundCardsImage[indexPath.item]
        cell.imageView.image = UIImage(named: imageName)
        
        return cell
    }
}
