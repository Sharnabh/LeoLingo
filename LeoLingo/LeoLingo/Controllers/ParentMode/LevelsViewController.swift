//
//  LevelsViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 17/01/25.
//

import UIKit
import Charts

class LevelsViewController: UIViewController {
    
    private let levels = [
            ("Level 1", "In this journey, we will imitate dogs and cows...", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")]),
            ("Level 2", "In this journey, we will imitate dogs and cows...", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")]),
            ("Level 3", "In this journey, we will imitate dogs and cows...", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")]),
            ("Level 4", "In this journey, we will imitate dogs and cows...", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")]),
        ]

    @IBOutlet var headingView: UIView!
    @IBOutlet var levelsCollectionView: UICollectionView!
    @IBOutlet var levelsLayout: UICollectionViewFlowLayout!
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        
        
        headingView.layer.shadowColor = UIColor.black.cgColor
        headingView.layer.shadowOffset = CGSize(width: 0, height: 1)
        headingView.layer.shadowOpacity = 0.5
        headingView.layer.shadowRadius = 4
        headingView.layer.cornerRadius = 20
        headingView.layer.masksToBounds = false
        
    }

}

extension LevelsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        levels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LevelCell", for: indexPath) as! LevelCell
        let (level, description, data) = levels[indexPath.item]
        cell.configureData(level: level, description: description, data: data)
        return cell
    }
    
    
}
