//
//  HomePageViewController.swift
//  LeoLingo
//
//  Created by Tarun   on 15/01/25.
//

import UIKit

class HomePageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var remainingTimeView: UIView!
    @IBOutlet var timeLeft: UILabel!
    @IBOutlet var timeLeftBar: UIProgressView!
    
    @IBOutlet var practicesView: UIView!
    @IBOutlet var badgesView: UIView!
    @IBOutlet var levelProgress: UIProgressView!
    @IBOutlet var levelView: UIView!

    @IBOutlet weak var badgesEarnedCollectionView: UICollectionView!
    @IBOutlet weak var recentPracticesCollectionView: UICollectionView!
    
    var badgesLayout: UICollectionViewFlowLayout?
    var practicesLayout: UICollectionViewFlowLayout?
    var sortedWords: [Word]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLevelView()
        generateCollectionViewLayout()
        let words = DataController.shared.getAllLevels().flatMap { $0.words }
        let newWords = words.filter { $0.record != nil }
        sortedWords = Array(newWords.reversed().prefix(3))
        
        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == badgesEarnedCollectionView {
            return BadgesDataController.shared.countEarnedBadges()
        }
        return sortedWords?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == badgesEarnedCollectionView {
            let cell = badgesEarnedCollectionView.dequeueReusableCell(withReuseIdentifier: BadgesEarnedCollectionViewCell.identifier, for: indexPath) as! BadgesEarnedCollectionViewCell
            
            cell.configure(with: BadgesDataController.shared.getEarnedBadges()[indexPath.row].badgeImage)
            
            return cell
        }
        let cell = recentPracticesCollectionView.dequeueReusableCell(withReuseIdentifier: WordReportCollectionViewCell.identifier, for: indexPath) as! WordReportCollectionViewCell
        
        guard let word = sortedWords else { return cell }
        cell.updateLabel(with: word[indexPath.item])
        cell.accuracyLabel.isHidden = true
        cell.attemptsLabel.isHidden = true
        cell.accuracy.isHidden = true
        cell.attempts.isHidden = true
        
        return cell
    }
    
    func generateCollectionViewLayout() {
        badgesLayout = UICollectionViewFlowLayout()
        if let layout = badgesLayout {
            layout.itemSize = CGSize(width: 90, height: 90)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.scrollDirection = .horizontal
            badgesEarnedCollectionView.collectionViewLayout = layout
            badgesEarnedCollectionView.delegate = self
            badgesEarnedCollectionView.dataSource = self
            badgesEarnedCollectionView.layer.cornerRadius = 21
            
            let nib = UINib(nibName: "BadgesEarnedCollectionViewCell", bundle: nil)
            badgesEarnedCollectionView.register(nib, forCellWithReuseIdentifier: BadgesEarnedCollectionViewCell.identifier)
        }
        
        practicesLayout = UICollectionViewFlowLayout()
        if let layout = practicesLayout {
            layout.itemSize = CGSize(width: 126, height: 126)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 0
            
            recentPracticesCollectionView.collectionViewLayout = layout
            recentPracticesCollectionView.delegate = self
            recentPracticesCollectionView.dataSource = self
            recentPracticesCollectionView.layer.cornerRadius = 21
            
            let nib = UINib(nibName: "WordReportCollectionViewCell", bundle: nil)
            recentPracticesCollectionView.register(nib, forCellWithReuseIdentifier: WordReportCollectionViewCell.identifier)
        }
    }
    
  
    func updateLevelView() {
        // Corner radius and border
          
        levelView.layer.cornerRadius = 21
        levelView.layer.borderWidth = 3
        levelView.layer.borderColor = UIColor(red: 78/255, green: 157/255, blue: 50/255, alpha: 1.0).cgColor
        levelView.clipsToBounds = false

        // Drop shadow
        levelView.layer.shadowColor = UIColor.black.cgColor
        levelView.layer.shadowOpacity = 0.6
        levelView.layer.shadowOffset = CGSize(width: 0, height: 10)  //
        levelView.layer.shadowRadius = 20


        // Level progress
        levelProgress.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)

        // remaining time
        remainingTimeView.layer.cornerRadius = 25
        remainingTimeView.layer.borderWidth = 3
        remainingTimeView.layer.borderColor = UIColor(red: 222/255, green: 168/255, blue: 62/255, alpha: 1.0).cgColor
        timeLeftBar.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)

        // badges
        badgesView.layer.cornerRadius = 21
        badgesView.layer.borderWidth = 3
        badgesView.layer.borderColor = UIColor(red: 78/255, green: 157/255, blue: 50/255, alpha: 1.0).cgColor
        badgesView.clipsToBounds = false

        badgesView.layer.shadowColor = UIColor.black.cgColor
        badgesView.layer.shadowOpacity = 0.4
        badgesView.layer.shadowOffset = CGSize(width: 0, height: 1)
        badgesView.layer.shadowRadius = 5

        //recent practices
        practicesView.layer.cornerRadius = 21  // Rounded corners
        practicesView.layer.borderWidth = 3    // Border thickness
        practicesView.layer.borderColor = UIColor(red: 78/255, green: 157/255, blue: 50/255, alpha: 1.0).cgColor
        practicesView.clipsToBounds = false  // Clips content to rounded corners

        practicesView.layer.shadowColor = UIColor.black.cgColor
        practicesView.layer.shadowOpacity = 0.4  // 62% opacity
        practicesView.layer.shadowOffset = CGSize(width: 0, height: 1)  // Offset of 16pt downward
        practicesView.layer.shadowRadius = 5  // Blur radius of 43pt

        //switch mode view
        //          switchModeView.layer.cornerRadius = 25
        //          switchModeView.layer.opacity = 0.77
        //          switchModeView.layer.shadowColor = UIColor.black.cgColor
        //          switchModeView.layer.shadowOpacity = 0.22
        //          switchModeView.layer.shadowOffset = CGSize(width: 0, height: 0.2)
        //          switchModeView.layer.shadowRadius = 1
        //
        //          profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        //          profileImageView.clipsToBounds = true

    }
     
    @IBAction func kidsModeButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "ParentMode", bundle: nil)
        if let parentHomeVC = storyboard.instantiateViewController(withIdentifier: "ParentModeLockScreen") as? LockScreenViewController {
            parentHomeVC.modalPresentationStyle = .fullScreen
            self.present(parentHomeVC, animated: true, completion: nil)
        }
    }
    @IBAction func vocalCoachButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Tarun", bundle: nil)
        if let vocalCoachVC = storyboard.instantiateViewController(withIdentifier: "VocalCoachGreeting") as? GreetViewController {
            vocalCoachVC.modalPresentationStyle = .fullScreen
            self.present(vocalCoachVC, animated: true, completion: nil)
        }
    }
    @IBAction func funLearningButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "FunLearning", bundle: nil)
        if let funLearningVC = storyboard.instantiateViewController(withIdentifier: "FunLearningNavBar") as? UINavigationController {
            funLearningVC.modalPresentationStyle = .fullScreen
            present(funLearningVC, animated: true)
        }
    }
    
}
