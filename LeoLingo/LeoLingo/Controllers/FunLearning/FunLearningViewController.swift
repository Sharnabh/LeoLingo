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
    @IBOutlet var parentModeButton: UIButton!
    
    var currentIndex = 1
    
    let gameImages: [String] = [ "JungleRunLogo", "FlashCardsGameLogo", "SingAlongLogo"]
    
    private lazy var backButton: UIButton = {
        let size: CGFloat = 46
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: size, height: size))
        button.backgroundColor = .white
        button.layer.cornerRadius = size/2
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.2
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: "chevron.left", withConfiguration: symbolConfig)?
            .withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .center
        
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup back button in navigation bar
        let backBarButton = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButton
        
        // Create custom Kids Mode button
        let customButton = UIButton(frame: CGRect(x: 0, y: 0, width: 151, height: 46))
        customButton.backgroundColor = .white.withAlphaComponent(0.77)
        customButton.setTitle("Kid Mode", for: .normal)
        customButton.setTitleColor(.black, for: .normal)
        customButton.layer.cornerRadius = 23 // Half of height for capsule shape
        
        // Configure image
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 26)
        let personImage = UIImage(systemName: "person.circle.fill", withConfiguration: imageConfig)
        customButton.setImage(personImage, for: .normal)
        customButton.tintColor = .black
        
        // Set image padding and position
        customButton.configuration = .plain()
        customButton.configuration?.imagePlacement = .trailing
        customButton.configuration?.imagePadding = 8
        customButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)
        customButton.configuration?.background.backgroundColor = .white.withAlphaComponent(0.77)
        customButton.configuration?.background.cornerRadius = 23
        
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
        let storyboard = UIStoryboard(name: "ParentMode", bundle: nil)
        if let parentHomeVC = storyboard.instantiateViewController(withIdentifier: "ParentModeLockScreen") as? LockScreenViewController {
            parentHomeVC.modalPresentationStyle = .fullScreen
            // Present directly from this view controller
            self.present(parentHomeVC, animated: true, completion: nil)
        }
    }
}

extension FunLearningViewController: UICollectionViewDelegate, UICollectionViewDataSource {


    
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
        cell.layer.cornerRadius = 27
        cell.updateImageView(with: game)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 1
        {
            let storyboard = UIStoryboard(name: "FlashCardsGame", bundle: nil)
            if let flashCardVC = storyboard.instantiateViewController(withIdentifier: "CategorySelectionViewController") as? CategorySelectionViewController {
             
                if let navigationController = self.navigationController {
                    navigationController.pushViewController(flashCardVC, animated: true)
                } else {
                    flashCardVC.modalPresentationStyle = .fullScreen
                    present(flashCardVC, animated: true)
                }
            }
            
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
