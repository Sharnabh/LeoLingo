//
//  BadgesViewController.swift
//  LeoLingo
//
//  Created by Batch - 2  on 21/01/25.
//

import UIKit

class BadgesViewController: UIViewController {
    
    @IBOutlet weak var badgesEarnedCollectionView: UICollectionView!
    var layout: UICollectionViewFlowLayout?
    
    @IBOutlet weak var badgescollectionView: UICollectionView!
    var layoutMain: UICollectionViewFlowLayout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createLayout()
    }
}
    
extension BadgesViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == badgesEarnedCollectionView {
            return DataController.shared.countEarnedBadges()
        }
        return DataController.shared.countBadges()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == badgesEarnedCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BadgesCollectionViewCell.identifier, for: indexPath) as! BadgesCollectionViewCell
            
            let earnedBadges = DataController.shared.getEarnedBadges()
            
            cell.configure(with: "\(earnedBadges[indexPath.row].badgeImage)", title: "\(earnedBadges[indexPath.row].badgeTitle)")
            
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BadgesBottomCollectionViewCell.identifier, for: indexPath) as! BadgesBottomCollectionViewCell
        
        let badges = DataController.shared.getBadges()
        let status = DataController.shared.getBadgesStatus(badges[indexPath.row])
        
        cell.configure(with: "\(badges[indexPath.row].badgeImage)", description: "\(badges[indexPath.row].badgeDescription)", status: status)
        
        return cell
    }
    
    func createLayout() {
        layout = UICollectionViewFlowLayout()
        if let layout = layout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 150, height: 175)
            badgesEarnedCollectionView.collectionViewLayout = layout
            badgesEarnedCollectionView.delegate = self
            badgesEarnedCollectionView.dataSource = self
            badgesEarnedCollectionView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.44)
            badgesEarnedCollectionView.layer.cornerRadius = 21
            let badgesNib = UINib(nibName: "BadgesCollectionViewCell", bundle: nil)
            badgesEarnedCollectionView.register(badgesNib, forCellWithReuseIdentifier: BadgesCollectionViewCell.identifier)
        }
        layoutMain = UICollectionViewFlowLayout()
        if let layout = layoutMain {
            layout.itemSize = CGSize(width: view.bounds.width/3, height: 150)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            badgescollectionView.collectionViewLayout = layout
            badgescollectionView.delegate = self
            badgescollectionView.dataSource = self
            badgescollectionView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.44)
            badgescollectionView.layer.cornerRadius = 21
            let BadgesNib = UINib(nibName: "BadgesBottomCollectionViewCell", bundle: nil)
            badgescollectionView.register(BadgesNib, forCellWithReuseIdentifier: BadgesBottomCollectionViewCell.identifier)
        }
    }
}
