//
//  BadgesViewController.swift
//  LeoLingo
//
//  Created by Aditya Bhardwaj on 20/01/25.
//

import UIKit

class BadgesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var badgesCollectionView: UICollectionView!
    var layout: UICollectionViewFlowLayout?
    
    @IBOutlet weak var collectionView: UICollectionView!
    var layoutMain: UICollectionViewFlowLayout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let padding = CGFloat(20)
        layout = UICollectionViewFlowLayout()
        if let layout = layout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 150, height: 150)
            layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
            badgesCollectionView.collectionViewLayout = layout
            badgesCollectionView.delegate = self
            badgesCollectionView.dataSource = self
            badgesCollectionView.register(BadgesCollectionViewCell.self, forCellWithReuseIdentifier: BadgesCollectionViewCell.identifier)
        }
        layoutMain = UICollectionViewFlowLayout()
        if let layout = layoutMain {
            layout.itemSize = CGSize(width: 450, height: 150)
            layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
            collectionView.collectionViewLayout = layout
            collectionView.delegate = self
            collectionView.dataSource = self
            let BadgesNib = UINib(nibName: "BadgesBottomCollectionViewCell", bundle: nil)
            collectionView.register(BadgesNib, forCellWithReuseIdentifier: "Badges")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == badgesCollectionView {
            return 8
        }
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == badgesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BadgesCollectionViewCell.identifier, for: indexPath) as! BadgesCollectionViewCell
            
            cell.configure(with: "Aditya")
            
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Badges", for: indexPath) as! BadgesBottomCollectionViewCell
        
        cell.configure(with: "Aditya", description: "Description")
        
        return cell
    }

}
