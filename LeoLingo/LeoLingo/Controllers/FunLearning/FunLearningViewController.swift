//
//  FunLearningViewController.swift
//  LeoLingo
//
//  Created by Sharnabh on 15/01/25.
//  Copyright © 2025 Sharnabh. All rights reserved.
//
//  PROPRIETARY AND CONFIDENTIAL
//  This software is protected by copyright and commercial license.
//  Unauthorized copying, distribution, modification, or reverse engineering is prohibited.
//

import UIKit
import SwiftUI

class FunLearningViewController: UIViewController {

    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var gamesCollectionView: UICollectionView!
    @IBOutlet var parentModeButton: UIButton!
    
    var currentIndex = 1
    
    let gameImages: [String] = [ "JungleRunLogo", "FlashCardsGameLogo", "SingAlongLogo",]
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.77)
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowRadius = 2
        button.layer.shadowOpacity = 0.2
        button.layer.masksToBounds = false
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: "chevron.left", withConfiguration: symbolConfig)?
            .withTintColor(UIColor(named: "AccentColor") ?? .systemGreen, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        
        // Explicitly set content mode to center
        button.imageView?.contentMode = .center
        
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a container view to hold the back button with fixed size
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        containerView.addSubview(backButton)
        
        // Setup back button in navigation bar
        let backBarButton = UIBarButtonItem(customView: containerView)
        navigationItem.leftBarButtonItem = backBarButton
        
        // Create custom Kids Mode button with home screen style
        let customButton = UIButton(type: .custom)
        customButton.frame = CGRect(x: 0, y: 0, width: 151, height: 46)
        
        // Configure button appearance to match home screen
        var config = UIButton.Configuration.filled()
        config.title = "Kid Mode"
        config.imagePlacement = .trailing
        config.imagePadding = 15
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)
        
        // Set image
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 26)
        let personImage = UIImage(systemName: "person.circle.fill", withConfiguration: imageConfig)
        config.image = personImage
        
        // Colors to match home screen
        config.baseBackgroundColor = UIColor.white.withAlphaComponent(0.77)
        config.baseForegroundColor = .black
        
        // Apply configuration
        customButton.configuration = config
        
        // Add shadow
        customButton.layer.shadowColor = UIColor.black.cgColor
        customButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        customButton.layer.shadowRadius = 2
        customButton.layer.shadowOpacity = 0.2
        
        customButton.addTarget(self, action: #selector(kidsModeButtonTapped), for: .touchUpInside)
        
        // Create bar button item with custom button
        let customBarButton = UIBarButtonItem(customView: customButton)
        navigationItem.rightBarButtonItem = customBarButton
        
        // Hide the original button since we're using the custom one
        parentModeButton.isHidden = true
        
        let gameCellNib = UINib(nibName: "FunLearningGamesCollectionViewCell", bundle: nil)
        gamesCollectionView.register(gameCellNib, forCellWithReuseIdentifier: "FunLearningGamesCollectionViewCell")
        gamesCollectionView.setCollectionViewLayout(configureLayout(), animated: true)
        
        gamesCollectionView.backgroundColor = .none

        headingLabel.layer.cornerRadius = 20
        headingLabel.layer.masksToBounds = true
        
        gamesCollectionView.delegate = self
        gamesCollectionView.dataSource = self
    }
    
    @objc private func backButtonTapped() {
        if let navigationController = self.navigationController {
            // If we're in a navigation controller, dismiss the entire navigation controller
            navigationController.dismiss(animated: true)
        } else {
            // If we're presented directly, just dismiss this view controller
            dismiss(animated: true)
        }
    }

    @objc private func kidsModeButtonTapped() {
        let lockScreenView = UIHostingController(rootView: ParentModeLockScreenView())
        lockScreenView.modalPresentationStyle = .fullScreen
        present(lockScreenView, animated: true)
    }
}

extension FunLearningViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    
    func configureLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // Group will show one full item, allowing partial peeking of others
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(0.7)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 1
        )

        group.contentInsets = NSDirectionalEdgeInsets(top: 40, leading: 0, bottom: 0, trailing: 0)

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = -250  // Negative spacing allows overlap

        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, offset, environment in
            let centerX = offset.x + environment.container.contentSize.width / 2
            
            // First, sort visible items by their distance from center (closest first)
            let sortedItems = visibleItems.sorted { item1, item2 -> Bool in
                let distance1 = abs(item1.frame.midX - centerX)
                let distance2 = abs(item2.frame.midX - centerX)
                return distance1 < distance2
            }
            
            // Track which item is in the center to set as top
            var centerItemIndex: Int?
            var minDistance = CGFloat.greatestFiniteMagnitude
            
            // Apply transformations to all items first
            for (index, item) in sortedItems.enumerated() {
                let distanceFromCenter = abs(item.frame.midX - centerX)
                
                // Find the center-most item
                if distanceFromCenter < minDistance {
                    minDistance = distanceFromCenter
                    centerItemIndex = index
                }
                
                // Apply scale transformation based on distance
                let scale = max(1.1 - (distanceFromCenter / environment.container.contentSize.width), 0.85)
                item.transform = CGAffineTransform(scaleX: scale, y: scale)
                
                // Set initial z-index, but we'll modify it later
                item.zIndex = 0
            }
            
            // Now set z-indexes to ensure proper ordering
            // Items closer to center get higher z-index
            for (index, item) in sortedItems.enumerated() {
                let distanceFromCenter = abs(item.frame.midX - centerX)
                
                if index == centerItemIndex {
                    item.zIndex = 100 // Center item always on top
                } else {
                    // Cards closer to center should be above cards further away
                    // But all non-center cards should be behind the center card
                    // Using inverse of distance to make closer cards have higher z-index
                    let baseZIndex: CGFloat = 50 // Base z-index for non-center cards
                    let distanceScale = 1.0 - (distanceFromCenter / environment.container.contentSize.width)
                    item.zIndex = Int(baseZIndex * distanceScale)
                }
            }
            
            // Update current index if needed
            if let centerIndex = centerItemIndex {
                let indexPath = sortedItems[centerIndex].indexPath
                self?.currentIndex = indexPath.item
            }
        }

        return UICollectionViewCompositionalLayout(section: section)
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        gameImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = gamesCollectionView.dequeueReusableCell(withReuseIdentifier: "FunLearningGamesCollectionViewCell", for: indexPath) as! FunLearningGamesCollectionViewCell
        let game = gameImages[indexPath.item]
        cell.layer.cornerRadius = 27
        cell.updateImageView(with: game)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 1
        {
            // Directly open the SwiftUI flashcard game
            let flashcardVC = SwiftUIFlashCardConnector.createCategorySelectionViewController()
            flashcardVC.modalPresentationStyle = .fullScreen
            self.present(flashcardVC, animated: true)
        }
        if indexPath.item == 0
        {
            let storyboard = UIStoryboard(name: "JungleRun", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "jungleRunNav") as? UINavigationController {
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
        }
        if indexPath.item == 2
        {
            let storyboard = UIStoryboard(name: "SingAlong", bundle: nil)
            if let singAlongVC = storyboard.instantiateViewController(withIdentifier: "SingAlongViewController") as? SingAlongViewController {
                singAlongVC.modalPresentationStyle = .fullScreen
                present(singAlongVC, animated: true)
            }
        }
    }
    
    
}
