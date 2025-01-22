//
//  BadgesViewController.swift
//  LeoLingo
//
//  Created by Batch - 2  on 21/01/25.
//

import UIKit

class BadgesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var badges: [Badge] = [
        Badge(badgeTitle: "Bee", badgeDescription: "Busy Bee(You have taken the first step)", badgeImage: "bee", isEarned: true),
        Badge(badgeTitle: "Turtle", badgeDescription: "Persistent Achiever(Steady Progress Over Time", badgeImage: "turtle", isEarned: false),
        Badge(badgeTitle: "Elephant", badgeDescription: "Master of Speech(Major Milestones Reached)", badgeImage: "elephant", isEarned: false),
        Badge(badgeTitle: "Dog", badgeDescription: "Loyal Learner(Regular Practice)", badgeImage: "dog", isEarned: true),
        Badge(badgeTitle: "Bunny", badgeDescription: "Quick Learner(Fast Improvement)", badgeImage: "bunny", isEarned: false),
        Badge(badgeTitle: "Lion", badgeDescription: "Learner(Fast Improvements)", badgeImage: "lion", isEarned: false)
    ]
    
    var earnedBadges: [Badge] = []
    
    @IBOutlet weak var badgesEarnedCollectionView: UICollectionView!
    var layout: UICollectionViewFlowLayout?
    
    @IBOutlet weak var badgescollectionView: UICollectionView!
    var layoutMain: UICollectionViewFlowLayout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let padding = CGFloat(40)
        layout = UICollectionViewFlowLayout()
        if let layout = layout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 150, height: 150)
            layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
            badgesEarnedCollectionView.collectionViewLayout = layout
            badgesEarnedCollectionView.delegate = self
            badgesEarnedCollectionView.dataSource = self
            badgesEarnedCollectionView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.44)
            badgesEarnedCollectionView.layer.cornerRadius = 20
            badgesEarnedCollectionView.register(BadgesCollectionViewCell.self, forCellWithReuseIdentifier: BadgesCollectionViewCell.identifier)
        }
        layoutMain = UICollectionViewFlowLayout()
        if let layout = layoutMain {
            layout.itemSize = CGSize(width: view.bounds.width/3, height: 150)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            badgescollectionView.collectionViewLayout = layout
            badgescollectionView.delegate = self
            badgescollectionView.dataSource = self
            badgescollectionView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.44)
            badgescollectionView.layer.cornerRadius = 20
            let BadgesNib = UINib(nibName: "BadgesBottomCollectionViewCell", bundle: nil)
            badgescollectionView.register(BadgesNib, forCellWithReuseIdentifier: BadgesBottomCollectionViewCell.identifier)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == badgesEarnedCollectionView {
            var earnedBadgesCounter = 0
            for badge in badges {
                if badge.isEarned {
                    earnedBadgesCounter += 1
                    earnedBadges.append(badge)
                }
            }
            return earnedBadgesCounter
        }
        return badges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == badgesEarnedCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BadgesCollectionViewCell.identifier, for: indexPath) as! BadgesCollectionViewCell
            
            cell.configure(with: "\(earnedBadges[indexPath.row].badgeImage)")
            
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BadgesBottomCollectionViewCell.identifier, for: indexPath) as! BadgesBottomCollectionViewCell
        
        cell.configure(with: "\(badges[indexPath.row].badgeImage)", description: "\(badges[indexPath.row].badgeDescription)")
        
        return cell
    }
}
