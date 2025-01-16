//
//  FunLearningViewController.swift
//  LeoLingo
//
//  Created by Sharnabh on 15/01/25.
//

import UIKit

class FunLearningViewController: UIViewController {

    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var gamesCollectionView: UICollectionView!
//    @IBOutlet var nextButton: UIButton!
//    @IBOutlet var previousButton: UIButton!
    @IBOutlet var parentModeButton: UIButton!
    
    var currentIndex = 1
    
    let gameImages: [String] = ["JungleAdventureLogo", "JungleRunLogo", "SingAlongLogo"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gameCellNib = UINib(nibName: "FunLearningGamesCollectionViewCell", bundle: nil)
        gamesCollectionView.register(gameCellNib, forCellWithReuseIdentifier: "FunLearningGamesCollectionViewCell")
        gamesCollectionView.setCollectionViewLayout(configureLayout(), animated: true)
        
        gamesCollectionView.backgroundColor = .none

        headingLabel.layer.cornerRadius = 20
        headingLabel.layer.masksToBounds = true
        
        gamesCollectionView.delegate = self
        gamesCollectionView.dataSource = self
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        let nextIndex = min(currentIndex + 1, gamesCollectionView.numberOfItems(inSection: 0) - 1)
        let indexPath = IndexPath(item: nextIndex, section: 0)
        gamesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        currentIndex = nextIndex
    }
    @IBAction func previousButtonTapped(_ sender: UIButton) {
        let previousIndex = max(currentIndex - 1, 0)
        let indexPath = IndexPath(item: previousIndex, section: 0)
        gamesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        currentIndex = previousIndex
    }

//     private func updateButtonStates() {
//        let visibleItems = gamesCollectionView.indexPathsForVisibleItems.sorted()
//        if let currentIndex = visibleItems.first {
//            previousButton.isEnabled = currentIndex.item > 0
//            nextButton.isEnabled = currentIndex.item < gameImages.count - 1
//        }
//    }
}

extension FunLearningViewController: UICollectionViewDelegate, UICollectionViewDataSource {

//    func updateIndex() {
//        let visibleRect = CGRect(origin: gamesCollectionView.contentOffset, size: gamesCollectionView.bounds.size)
//        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
//                
//        if let indexPath = gamesCollectionView.indexPathForItem(at: visiblePoint) {
//            currentIndex = indexPath.item
//            print(currentIndex)
//        }
//    }
//    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        updateIndex()
//    }
//    
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        updateIndex()
//    }
    
    func configureLayout() -> UICollectionViewLayout {
        // Create item size
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),     // Reduced from 0.7 to 0.5
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Create group same size as item
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),     // Reduced from 0.7 to 0.5
            heightDimension: .fractionalHeight(0.7)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 40, leading: 0, bottom: 0, trailing: 0)
        
        // Configure section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        section.visibleItemsInvalidationHandler = { (visibleItems, offset, environment) in
            let centerX = offset.x + environment.container.contentSize.width / 2
            
            visibleItems.forEach { item in
                let distanceFromCenter = abs(item.frame.midX - centerX)
                let scale = max(1.2 - (distanceFromCenter / environment.container.contentSize.width), 0.85)
                item.transform = CGAffineTransform(scaleX: scale, y: scale)
                item.zIndex = Int(scale * 10)
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
        cell.updateImageView(with: game)
        
        return cell
    }
    
    
}
