//
//  DashboardParentModeViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 21/01/25.
//

import UIKit

class DashboardViewController: UIViewController {
    
    private let levels: [Level] = [
        Level(levelTitle: "Level 1", words: [
            Word(wordTitle: "A", record: Record(attempts: 5, accuracy: [30, 40, 70, 60, 90], recording: ["1", "2", "3", "4", "5"]), isPracticed: true),
            Word(wordTitle: "B", record: Record(attempts: 3, accuracy: [50, 60, 80], recording: ["1", "2", "3"]), isPracticed: true),
            Word(wordTitle: "C", record: Record(attempts: 4, accuracy: [20, 30, 50, 70], recording: ["1", "2", "3", "4"]), isPracticed: true),
            Word(wordTitle: "D", record: Record(attempts: 2, accuracy: [50, 80], recording: ["1", "2"]), isPracticed: true)
        ]),
        Level(levelTitle: "Level 2", words: [
            Word(wordTitle: "E", record: Record(attempts: 5, accuracy: [10, 20, 30, 40, 50], recording: ["1", "2", "3", "4", "5"]), isPracticed: true),
            Word(wordTitle: "F", record: Record(attempts: 3, accuracy: [60, 70, 85], recording: ["1", "2", "3"]), isPracticed: true),
            Word(wordTitle: "G", record: Record(attempts: 3, accuracy: [25, 35, 55], recording: ["1", "2", "3"]), isPracticed: true),
            Word(wordTitle: "H", isPracticed: false)
        ]),
        Level(levelTitle: "Level 3", words: [
            Word(wordTitle: "I", record: Record(attempts: 2, accuracy: [90, 95], recording: ["1", "2"]), isPracticed: true),
            Word(wordTitle: "J", record: Record(attempts: 5, accuracy: [10, 15, 20, 25, 30], recording: ["1", "2", "3", "4", "5"]), isPracticed: true),
            Word(wordTitle: "K", record: Record(attempts: 3, accuracy: [40, 45, 55], recording: ["1", "2", "3"]), isPracticed: true),
            Word(wordTitle: "L", isPracticed: false)
        ]),
        Level(levelTitle: "Level 4", words: [
            Word(wordTitle: "M", record: Record(attempts: 4, accuracy: [30, 35, 50, 60], recording: ["1", "2", "3", "4"]), isPracticed: true),
            Word(wordTitle: "N", record: Record(attempts: 2, accuracy: [85, 90], recording: ["1", "2"]), isPracticed: true),
            Word(wordTitle: "O", record: Record(attempts: 5, accuracy: [15, 25, 35, 45, 55], recording: ["1", "2", "3", "4", "5"]), isPracticed: true),
            Word(wordTitle: "P", isPracticed: false)
        ]),
        Level(levelTitle: "Level 5", words: [
            Word(wordTitle: "Q", record: Record(attempts: 3, accuracy: [65, 70, 85], recording: ["1", "2", "3"]), isPracticed: true),
            Word(wordTitle: "R", record: Record(attempts: 4, accuracy: [50, 55, 60, 75], recording: ["1", "2", "3", "4"]), isPracticed: true),
            Word(wordTitle: "S", record: Record(attempts: 2, accuracy: [95, 100], recording: ["1", "2"]), isPracticed: true),
            Word(wordTitle: "T", isPracticed: false)
        ]),
    ]
    
    var badges: [Badge] = [
        Badge(badgeTitle: "Bee", badgeDescription: "Busy Bee(You have taken the first step)", badgeImage: "bee", isEarned: true),
        Badge(badgeTitle: "Turtle", badgeDescription: "Persistent Achiever(Steady Progress Over Time", badgeImage: "turtle", isEarned: false),
        Badge(badgeTitle: "Elephant", badgeDescription: "Master of Speech(Major Milestones Reached)", badgeImage: "elephant", isEarned: false),
        Badge(badgeTitle: "Dog", badgeDescription: "Loyal Learner(Regular Practice)", badgeImage: "dog", isEarned: true),
        Badge(badgeTitle: "Bunny", badgeDescription: "Quick Learner(Fast Improvement)", badgeImage: "bunny", isEarned: false),
        Badge(badgeTitle: "Lion", badgeDescription: "Learner(Fast Improvements)", badgeImage: "lion", isEarned: false)
    ]
    
    var earnedBadges: [Badge] = []
    
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
        
        earnedBadges = badges.filter { $0.isEarned }
        
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
