//
//  CategorySelectionViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 27/02/25.
//

import UIKit

class CategorySelectionViewController: UIViewController {
    

    @IBOutlet var categoryCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        setupCollectionViewLayout()

        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.backgroundColor = .clear
        categoryCollectionView.isUserInteractionEnabled = true
        
        let firstNib = UINib(nibName: "CategoryCards", bundle: nil)
        categoryCollectionView.register(firstNib, forCellWithReuseIdentifier: "Category")
        
    }
    
//    func CategorycollectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("Selected level card at index: \(indexPath.item)")
//        
//        // Create the LevelCardViewController
//        let flashCardVC = FlashCardViewController(selectedLevelIndex: indexPath.item)
//        flashCardVC.title = "Level \(indexPath.item + 1)"
//        
//        if let navController = self.navigationController {
//            // We have a navigation controller, just push
//            navController.pushViewController(flashCardVC, animated: true)
//        } else {
//            // Create a new navigation controller and present it
//            let navController = UINavigationController(rootViewController: flashCardVC)
//            navController.modalPresentationStyle = .fullScreen
//            present(navController, animated: true, completion: nil)
//        }
//    }
    
    
    func setupCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.itemSize = CGSize(width: 380, height: 260)
        categoryCollectionView.collectionViewLayout = layout
    }

}
extension CategorySelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SampleDataController.shared.countCategoryCards()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Category", for: indexPath) as! CategorySelectionCollectionViewCell
        cell.layer.cornerRadius = 21
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor(red: 161/255, green: 105/255, blue: 77/255, alpha: 1.0).cgColor
        cell.backgroundColor = .clear
        cell.isUserInteractionEnabled = true
        cell.contentView.isUserInteractionEnabled = true
        cell.updateCategoryCard(with: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected level card at index: \(indexPath.item)")
        

        let storyboard = UIStoryboard(name: "FlashCardsGame", bundle: nil)
        if let flashCardVC = storyboard.instantiateViewController(withIdentifier: "FlashCardViewController") as? FlashCardViewController {
         
            if let navigationController = self.navigationController {
                navigationController.pushViewController(flashCardVC, animated: true)
            } else {
                flashCardVC.modalPresentationStyle = .fullScreen
                present(flashCardVC, animated: true)
            }
        }
    }


    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CategorySelectionCollectionViewCell {
            cell.animateTapDown()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CategorySelectionCollectionViewCell {
            cell.animateTapUp()
        }
    }
}
