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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .white
        
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
        let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
        if let vocalCoachVC = storyboard.instantiateViewController(withIdentifier: "VocalCoachViewController") as? VocalCoachViewController {
            if let presentingViewController = self.presentingViewController,
               presentingViewController is HomePageViewController {
                self.dismiss(animated: true)
            } else {
                guard let navigationController = self.navigationController else {
                        print("No navigation controller found")
                        return
                    }
                    
                    // Look for `A` in the navigation stack
                    for viewController in navigationController.viewControllers {
                        if viewController is VocalCoachViewController {
                            navigationController.popToViewController(viewController, animated: true)
                            return
                        }
                    }
                    
                navigationController.setViewControllers([vocalCoachVC], animated: true)
            }
        }
    }


    @IBAction func kidsModeButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "ParentMode", bundle: nil)
        if let parentHomeVC = storyboard.instantiateViewController(withIdentifier: "ParentModeLockScreen") as? LockScreenViewController {
            parentHomeVC.modalPresentationStyle = .fullScreen
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
