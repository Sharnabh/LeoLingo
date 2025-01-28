////
////  DashboardParentModeViewController.swift
////  LeoLingo
////
////  Created by Batch - 2 on 21/01/25.
////
//
//import UIKit
//
//class DashboardParentModeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
//    
//    
//    
//    @IBOutlet var levelView: UIView!
//    
//    @IBOutlet var levelBadgeImage: UIImageView!
//    
//    @IBOutlet var practiceTimeView: UIView!
//    
//    @IBOutlet var practiceTime: UILabel!
//    @IBOutlet var averageAccuracyView: UIView!
//    @IBOutlet var badgesEarnedView: UIView!
//    @IBOutlet var mostInaccurateView: UIView!
//    @IBOutlet var mojoSuggestion: UIView!
//    @IBOutlet var beginnerProgressBar: UIProgressView!
//    @IBOutlet var collectionView: UICollectionView!
//  
//    @IBOutlet var averageAccuracy: UILabel!
//    
//    @IBOutlet var badge1Image: UIImageView!
//    
//    @IBOutlet var badge2Image: UIImageView!
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        updateView()
//

import UIKit

class DashboardViewController: UIViewController {
    
    private let levels: [Level] = DataController.shared.getAllLevels()
    
    var earnedBadges: [Badge] = DataController.shared.getEarnedBadges()
    
    var minAccuracyWords: [Word]?
    
    
    @IBOutlet var levelView: UIView!
    
    @IBOutlet var levelBadgeImage: UIImageView!
    
    @IBOutlet var practiceTimeView: UIView!
    
    @IBOutlet var practiceTime: UILabel!
    @IBOutlet var averageAccuracyView: UIView!
    @IBOutlet var badgesEarnedView: UIView!
    @IBOutlet var mostInaccurateView: UIView!
    @IBOutlet var mojoSuggestion: UIView!
    @IBOutlet var beginnerProgressBar: UIProgressView!
    @IBOutlet var collectionView: UICollectionView!
  
    @IBOutlet var averageAccuracy: UILabel!
    
    @IBOutlet var badge1Image: UIImageView!
    @IBOutlet var badge1Label: UILabel!
    
    @IBOutlet var badge2Image: UIImageView!
    @IBOutlet var badge2Label: UILabel!
    
    @IBOutlet var averageAccuracyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
                
        badge1Image.image = UIImage(named: earnedBadges[0].badgeImage)
        badge1Label.text = earnedBadges[0].badgeTitle
        badge1Label.adjustsFontSizeToFitWidth = true
        
        badge2Image.image = UIImage(named: earnedBadges[1].badgeImage)
        badge2Label.text = earnedBadges[1].badgeTitle
        badge2Label.adjustsFontSizeToFitWidth = true
        
        let words = levels.flatMap { $0.words }
        let wordsWithRecord = words.filter { $0.record != nil }
        let sortedWords = wordsWithRecord.sorted { $0.avgAccuracy < $1.avgAccuracy }
        minAccuracyWords = Array(sortedWords.prefix(2))
        
        let sectionAvgAccuracy = levels.reduce(0.0) { $0 + $1.avgAccuracy} / Double(levels.count)
        averageAccuracyLabel.text = String(format: "%.1f%%", sectionAvgAccuracy)
        

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "WordReportCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WordCell")
        
        configureFlowLayout()
    }
    
    
    func updateView() {
        levelView.layer.cornerRadius = 21
        levelView.layer.borderWidth = 3
        levelView.layer.borderColor = UIColor(red: 78/255, green: 157/255, blue: 50/255, alpha: 1.0).cgColor
        levelView.clipsToBounds = false

        // Drop shadow
        levelView.layer.shadowColor = UIColor.black.cgColor
        levelView.layer.shadowOpacity = 0.4
        levelView.layer.shadowOffset = CGSize(width: 0, height: 8)  //
        levelView.layer.shadowRadius = 15
        
        practiceTimeView.layer.cornerRadius = 17
        practiceTimeView.layer.borderWidth = 3
        practiceTimeView.layer.borderColor = UIColor(red: 225/255, green: 168/255, blue: 63/255, alpha: 1.0).cgColor
        practiceTimeView.clipsToBounds = false
        
        averageAccuracyView.layer.cornerRadius = 17
        averageAccuracyView.layer.borderWidth = 3
        averageAccuracyView.layer.borderColor = UIColor(red: 225/255, green: 168/255, blue: 63/255, alpha: 1.0).cgColor
        averageAccuracyView.clipsToBounds = false
        
        badgesEarnedView.layer.cornerRadius = 17
        badgesEarnedView.layer.borderWidth = 3
        badgesEarnedView.layer.borderColor = UIColor(red: 225/255, green: 168/255, blue: 63/255, alpha: 1.0).cgColor
        badgesEarnedView.clipsToBounds = false
        
        mostInaccurateView.layer.cornerRadius = 21
        mostInaccurateView.layer.borderWidth = 3
        mostInaccurateView.layer.borderColor = UIColor(red: 225/255, green: 168/255, blue: 63/255, alpha: 1.0).cgColor
        mostInaccurateView.clipsToBounds = false
        
        mojoSuggestion.layer.cornerRadius = 21
        mojoSuggestion.layer.borderWidth = 3
        mojoSuggestion.layer.borderColor = UIColor(red: 141/255, green: 91/255, blue: 66/255, alpha: 1.0).cgColor
        mojoSuggestion.clipsToBounds = false
        
        
        
    }
    @IBAction func seeAllButtonTapped(_ sender: UIButton) {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 1
        }
    }
    @IBAction func moreBadgesButtonTapped(_ sender: UIButton) {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 2
        }
    }
}

extension DashboardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    private func configureFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 150, height: 180)
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        collectionView.collectionViewLayout = layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        minAccuracyWords?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WordReportCollectionViewCell.identifier, for: indexPath) as! WordReportCollectionViewCell
        
        guard let word = minAccuracyWords else { return cell }
        cell.updateLabel(with: word[indexPath.item])
        return cell
    }
    
    
    
}
