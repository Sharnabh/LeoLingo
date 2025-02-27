//
//  CategorySelectionViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 27/02/25.
//

import UIKit

class CategorySelectionViewController: UIViewController {
    

    @IBOutlet var CategoryCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        setupCollectionViewLayout()

        CategoryCollectionView.delegate = self
        CategoryCollectionView.dataSource = self
        CategoryCollectionView.backgroundColor = .clear
        CategoryCollectionView.isUserInteractionEnabled = true
        
        let firstNib = UINib(nibName: "CategoryCards", bundle: nil)
        CategoryCollectionView.register(firstNib, forCellWithReuseIdentifier: "Category")
    }
    
    
    func setupCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.itemSize = CGSize(width: 380, height: 260)
        CategoryCollectionView.collectionViewLayout = layout
    }

}
extension CategorySelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SampleDataController.shared.countLevelCards()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Category", for: indexPath) as! CategorySelectionCollectionViewCell
        cell.layer.cornerRadius = 21
        cell.backgroundColor = .clear
        cell.isUserInteractionEnabled = true
        cell.contentView.isUserInteractionEnabled = true
        cell.updateCategoryCard(with: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected level card at index: \(indexPath.item)")
        
    }
}
