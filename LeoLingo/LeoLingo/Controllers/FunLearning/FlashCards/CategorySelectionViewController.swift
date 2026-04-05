//
//  CategorySelectionViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 27/02/25.
//

import UIKit
import SwiftUI

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
        
        // Handle Body Parts category (index 0) separately
        if indexPath.item == 0 {
            let splashScreen = UIHostingController(rootView: HumanBodySplashScreen())
            // Configure the hosting controller
            splashScreen.modalPresentationStyle = .fullScreen
            
            // Create and configure FlashCardVC
            let storyboard = UIStoryboard(name: "FlashCardsGame", bundle: nil)
            if let flashCardVC = storyboard.instantiateViewController(withIdentifier: "FlashCardViewController") as? FlashCardViewController {
                flashCardVC.selectedIndex = indexPath.item
                
                // Present splash screen first, then navigate to FlashCardVC
                present(splashScreen, animated: true) { [weak self] in
                    // After a short delay, dismiss splash and show FlashCardVC
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        splashScreen.dismiss(animated: true) {
                            self?.navigationController?.pushViewController(flashCardVC, animated: true)
                        }
                    }
                }
            }
            return
        }
        
        // Handle all other categories
        let storyboard = UIStoryboard(name: "FlashCardsGame", bundle: nil)
        if let flashCardVC = storyboard.instantiateViewController(withIdentifier: "FlashCardViewController") as? FlashCardViewController {
            flashCardVC.selectedIndex = indexPath.item
            navigationController?.pushViewController(flashCardVC, animated: true)
        }
    }


    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("Selected level card at index: \(indexPath.item)")
//        if indexPath.item == 0 {
//            let splashScreen = UIHostingController(rootView: HumanBodySplashScreen())
//            navigationController?.pushViewController(splashScreen, animated: true)
//        }
//
////        let storyboard = UIStoryboard(name: "FlashCardsGame", bundle: nil)
////        if let flashCardVC = storyboard.instantiateViewController(withIdentifier: "FlashCardViewController") as? FlashCardViewController {
////         
////            flashCardVC.selectedIndex = indexPath.item
////            
////            if let navigationController = self.navigationController {
////                navigationController.pushViewController(flashCardVC, animated: true)
////            } else {
////                flashCardVC.modalPresentationStyle = .fullScreen
////                present(flashCardVC, animated: true)
////            }
////        }
//    }


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
