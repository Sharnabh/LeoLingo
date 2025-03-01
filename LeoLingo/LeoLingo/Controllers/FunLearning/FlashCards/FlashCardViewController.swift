//
//  FlashCardViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 28/02/25.
//

import UIKit

class FlashCardViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var selectedIndex: Int? = 0 // Track selected index for zoom effect

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Welcome to Flashcards")

        setupCollectionViewLayout()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.isUserInteractionEnabled = true
        
        let firstNib = UINib(nibName: "FlashCard", bundle: nil)
        collectionView.register(firstNib, forCellWithReuseIdentifier: "FlashCardCell")

        collectionView.isPagingEnabled = false // Paging should be off since we're controlling snapping manually
        collectionView.decelerationRate = .fast // Smooth snapping effect
    }
    
    func setupCollectionViewLayout() {
        let layout = SnappingCollectionViewLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 300
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: 350, height: 512)
        
        let screenWidth = UIScreen.main.bounds.width
        let sideInset = (screenWidth - 350) / 2
        layout.sectionInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
        
        collectionView.collectionViewLayout = layout
    }
}

extension FlashCardViewController: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
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

    // MARK: - Snapping & Instant Zoom Effect
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scaleVisibleCells()
    }

    private func scaleVisibleCells() {
        let centerPoint = view.convert(collectionView.center, to: collectionView)
        
        for cell in collectionView.visibleCells {
            let indexPath = collectionView.indexPath(for: cell)!
            let cellCenter = collectionView.layoutAttributesForItem(at: indexPath)?.frame.midX ?? 0
            let distance = abs(centerPoint.x - cellCenter)
        
            let scale: CGFloat = distance < 50 ? 1 : 0.75  // Center item = 1.1x, Side items = 0.85x
            
            UIView.animate(withDuration: 0.2) {
                cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }
}

