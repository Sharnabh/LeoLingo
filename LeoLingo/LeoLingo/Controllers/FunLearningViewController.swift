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
    
    let gameImages: [String] = ["JungleAdventureLogo", "JungleRunLogo", "SingAlongLogo"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gameCellNib = UINib(nibName: "FunLearningGamesCollectionViewCell", bundle: nil)
        gamesCollectionView.register(gameCellNib, forCellWithReuseIdentifier: "FunLearningGamesCollectionViewCell")
        gamesCollectionView.setCollectionViewLayout(configureLayout(), animated: true)
        
        gamesCollectionView.backgroundColor = .none

        headingLabel.layer.cornerRadius = 10
        
        gamesCollectionView.delegate = self
        gamesCollectionView.dataSource = self
    }

}

extension FunLearningViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func configureLayout() -> UICollectionViewLayout {
        // Create item size
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),     // Reduced from 0.7 to 0.5
            heightDimension: .fractionalHeight(0.9)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Create group same size as item
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),     // Reduced from 0.7 to 0.5
            heightDimension: .fractionalHeight(0.7)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Configure section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = -50                 // Negative spacing to bring items closer
        
        // Add visual effects
        section.visibleItemsInvalidationHandler = { items, offset, environment in
            items.forEach { item in
                let distanceFromCenter = abs((item.frame.midX - offset.x) - environment.container.contentSize.width / 2.0)
                let minScale: CGFloat = 0.8
                let maxScale: CGFloat = 1.1
                let scale = max(maxScale - (distanceFromCenter / environment.container.contentSize.width), minScale)
                item.transform = CGAffineTransform(scaleX: scale, y: scale)
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
