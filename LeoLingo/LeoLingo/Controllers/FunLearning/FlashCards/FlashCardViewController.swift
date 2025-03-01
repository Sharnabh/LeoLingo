//
//  FlashCardViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 28/02/25.
//

import UIKit

class FlashCardViewController: UIViewController {
    
    
    @IBOutlet var collectionView: UICollectionView!
    
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("welcome to flashcards")

        setupCollectionViewLayout()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.isUserInteractionEnabled = true
        
        let firstNib = UINib(nibName: "FlashCard", bundle: nil)
        collectionView.register(firstNib, forCellWithReuseIdentifier: "FlashCardCell")
    }
    
    func setupCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 0
//        layout.minimumLineSpacing = 16
//        layout.minimumInteritemSpacing = 16
//        layout.itemSize = CGSize(width: 380, height: 260)
        collectionView.collectionViewLayout = layout
    }
    

}
extension FlashCardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SampleDataController.shared.countLevelCards()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlashCardCell", for: indexPath) as! FlashCardCollectionViewCell
        cell.layer.cornerRadius = 21
        cell.backgroundColor = .clear
        cell.isUserInteractionEnabled = true
        cell.contentView.isUserInteractionEnabled = true
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? FlashCardCollectionViewCell {
            cell.animateTapDown()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? FlashCardCollectionViewCell {
            cell.animateTapUp()
        }
    }
}


    
   
