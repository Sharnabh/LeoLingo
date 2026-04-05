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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Refresh data and sync with UserDefaults
        refreshBadgeData()
    }
    
    private func refreshBadgeData() {
        print("DEBUG: BadgesVC - Starting badge data refresh")
        
        // Check what's in UserDefaults first
        let savedBadgeIDs = UserDefaults.standard.earnedBadgeIDs
        print("DEBUG: BadgesVC - Found \(savedBadgeIDs.count) earned badges in UserDefaults")
        
        // Ensure we have the latest user data and sync badges with UserDefaults
        Task {
            if let userId = SupabaseDataController.shared.userId {
                print("DEBUG: BadgesVC - Fetching user data for ID: \(userId)")
                do {
                    let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                    
                    // Count earned badges
                    let earnedBadges = userData.userBadges.filter { $0.isEarned }
                    print("DEBUG: BadgesVC - Found \(earnedBadges.count) earned badges in user data")
                    
                    // Sync earned badges with UserDefaults to ensure persistence
                    for badge in userData.userBadges where badge.isEarned {
                        print("DEBUG: BadgesVC - Adding earned badge to UserDefaults: \(badge.badgeTitle) (ID: \(badge.id))")
                        UserDefaults.standard.addEarnedBadge(badge.id)
                    }
                    
                    // Reload badges on main thread after fetching latest data
                    DispatchQueue.main.async {
                        self.badgesEarnedCollectionView.reloadData()
                        self.badgescollectionView.reloadData()
                        print("DEBUG: BadgesVC - Badge collection views reloaded")
                    }
                } catch {
                    print("ERROR: BadgesVC - Error refreshing badge data: \(error)")
                }
            } else {
                print("ERROR: BadgesVC - No user ID found, cannot fetch badge data")
            }
        }
    }
}
    
extension BadgesViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == badgesEarnedCollectionView {
            if let badges = SupabaseDataController.shared.getEarnedBadgesData(), !badges.isEmpty {
                print("DEBUG: BadgesVC - Found \(badges.count) earned badges for display")
                return badges.count
            } else {
                print("DEBUG: BadgesVC - No earned badges found or empty array returned")
                return 0
            }
        }
        
        let allBadges = SupabaseDataController.shared.getUserBadgesData()
        print("DEBUG: BadgesVC - Found \(allBadges.count) total badges")
        return allBadges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == badgesEarnedCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BadgesCollectionViewCell.identifier, for: indexPath) as! BadgesCollectionViewCell
            
            // Get earned badges safely
            guard let earnedBadges = SupabaseDataController.shared.getEarnedBadgesData(),
                  indexPath.row < earnedBadges.count else {
                print("DEBUG: BadgesVC - Failed to get earned badge at index \(indexPath.row)")
                return UICollectionViewCell()
            }
            
            // Get the badge at this specific index
            let badge = earnedBadges[indexPath.row]
            
            // Log badge details for debugging
            print("DEBUG: BadgesVC - Processing badge with ID: \(badge.id), title: \(badge.badgeTitle)")
            
            // Find the corresponding app badge to get the image
            let appBadges = SampleDataController.shared.getBadgesData()
            if let appBadge = appBadges.first(where: { $0.id == badge.id }) {
                print("DEBUG: BadgesVC - Configuring earned badge cell: \(appBadge.badgeTitle) with image: \(appBadge.badgeImage)")
                cell.configure(with: "\(appBadge.badgeImage)", title: "\(appBadge.badgeTitle)")
            } else {
                // Try fuzzy matching by title if ID doesn't match
                print("DEBUG: BadgesVC - Could not find badge by ID, trying title match for: \(badge.badgeTitle)")
                if let appBadge = appBadges.first(where: { $0.badgeTitle.lowercased() == badge.badgeTitle.lowercased() }) {
                    print("DEBUG: BadgesVC - Found badge by title match: \(appBadge.badgeTitle) with image: \(appBadge.badgeImage)")
                    // Update UserDefaults with the correct ID for future reference
                    UserDefaults.standard.addEarnedBadge(appBadge.id)
                    cell.configure(with: "\(appBadge.badgeImage)", title: "\(appBadge.badgeTitle)")
                } else {
                    print("DEBUG: BadgesVC - Could not find app badge matching ID: \(badge.id) or title: \(badge.badgeTitle)")
                    // Fallback configuration
                    cell.configure(with: "star", title: badge.badgeTitle)
                }
            }

            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BadgesBottomCollectionViewCell.identifier, for: indexPath) as! BadgesBottomCollectionViewCell
        
        // Get all badges (earned and unearned)
        let badges = SupabaseDataController.shared.getUserBadgesData()
        guard indexPath.row < badges.count else {
            print("DEBUG: BadgesVC - Out of bounds index for badges: \(indexPath.row)")
            return UICollectionViewCell()
        }
        
        // Get current badge and its earned status
        let badge = badges[indexPath.row]
        let status = badge.isEarned
        
        // Find the app badge for additional information like image and description
        let appBadges = SampleDataController.shared.getBadgesData()
        if let appBadge = appBadges.first(where: { $0.id == badge.id }) {
            print("DEBUG: BadgesVC - Configuring all badge cell: \(appBadge.badgeTitle), earned: \(status)")
            cell.configure(with: "\(appBadge.badgeImage)", description: "\(appBadge.badgeDescription)", status: status)
        } else {
            // Fallback if app badge not found
            print("DEBUG: BadgesVC - Could not find app badge for ID: \(badge.id)")
            cell.configure(with: "star", description: "Badge description unavailable", status: status)
        }
        
        return cell
    }
    
    func createLayout() {
        layout = UICollectionViewFlowLayout()
        if let layout = layout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 120, height: 140)
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
