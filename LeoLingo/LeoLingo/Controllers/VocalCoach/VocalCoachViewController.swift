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
        
        let backButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
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
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.itemSize = CGSize(width: 380, height: 280)
        soundCards.collectionViewLayout = layout
    }
  @IBAction func continueButtonTapped(_ sender: UIButton) {
//           performSegue(withIdentifier: "PracticeScreenSegue", sender: self)
     }
//       
//       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//           if segue.identifier == "PracticeScreenSegue" {
//               if let destinationVC = segue.destination as? PracticeScreenViewController {
//                   // Pass any necessary data to the PracticeScreenViewController
//                   // Example: destinationVC.someProperty = someValue
//               }
//           }
//       }
       
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = indexPath.row // or use your data source
        let storyboard = UIStoryboard(name: "WordsInCards", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "WordsInCards") as? WordsInCardViewController {
            detailVC.selectedItem = selectedItem // Pass data to the next VC
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
