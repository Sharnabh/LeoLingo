//
//  LevelsViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 17/01/25.
//

import UIKit

class LevelsViewController: UIViewController {
    
//    private let segmentedLevels = [
//        [
//            ("Level 1", "In this journey, we will imitate dogs and cows. Also we will practice basic words like mom and dada and some greetings.", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")]),
//        ("Level 2", "In this journey, we will imitate dogs and cows. Also we will practice basic words like mom and dada and some greetings.", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")]),
//        ("Level 3", "In this journey, we will imitate dogs and cows. Also we will practice basic words like mom and dada and some greetings.", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")]),
//        ("Level 4", "In this journey, we will imitate dogs and cows. Also we will practice basic words like mom and dada and some greetings.", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")])
//        ],
//        [
//            ("Level 11", "In this journey, we will imitate dogs and cows. Also we will practice basic words like mom and dada and some greetings.", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")]),
//        ("Level 12", "In this journey, we will imitate dogs and cows. Also we will practice basic words like mom and dada and some greetings.", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")]),
//        ("Level 13", "In this journey, we will imitate dogs and cows. Also we will practice basic words like mom and dada and some greetings.", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")]),
//        ("Level 14", "In this journey, we will imitate dogs and cows. Also we will practice basic words like mom and dada and some greetings.", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")])
//        ],
//        [
//            ("Level 21", "In this journey, we will imitate dogs and cows. Also we will practice basic words like mom and dada and some greetings.", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")]),
//            ("Level 22", "In this journey, we will imitate dogs and cows. Also we will practice basic words like mom and dada and some greetings.", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")]),
//            ("Level 23", "In this journey, we will imitate dogs and cows. Also we will practice basic words like mom and dada and some greetings.", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")]),
//            ("Level 24", "In this journey, we will imitate dogs and cows. Also we will practice basic words like mom and dada and some greetings.", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")])        ]
//    ]
    private let segmentedLevels = [
            [
                ("Level 1", "In this journey, we will imitate dogs and cows. Also we will practice basic words like mom and dada and some greetings.", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")]),
        ("Level 2", "In this journey, we will imitate dogs and cows. Also we will practice basic words like mom and dada and some greetings.", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")])
            ],
            [
            ("Level 3", "In this journey, we will imitate dogs and cows. Also we will practice basic words like mom and dada and some greetings.", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")]),
            ("Level 4", "In this journey, we will imitate dogs and cows. Also we will practice basic words like mom and dada and some greetings.", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")])
            ],
            [
            ("Level 5", "In this journey, we will imitate dogs and cows. Also we will practice basic words like mom and dada and some greetings.", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")]),
            ("Level 6", "In this journey, we will imitate dogs and cows. Also we will practice basic words like mom and dada and some greetings.", [("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5"), ("Mom", 70, "3/5"), ("Dada", 85, "3/5"), ("Bye", 35, "3/5")])
            ]
        ]
    
    private var currentLevel: [(String, String, [(String, Int, String)])] = []

    @IBOutlet var headingView: UIView!
    @IBOutlet var levelsCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentLevel = segmentedLevels[0]

        navigationItem.hidesBackButton = true
        
        
        headingView.layer.shadowColor = UIColor.black.cgColor
        headingView.layer.shadowOffset = CGSize(width: 0, height: 1)
        headingView.layer.shadowOpacity = 0.5
        headingView.layer.shadowRadius = 4
        headingView.layer.cornerRadius = 20
        headingView.layer.masksToBounds = false
        
        let levelNib = UINib(nibName: "Levels", bundle: nil)
        levelsCollectionView.register(levelNib, forCellWithReuseIdentifier: "LevelCell")
        levelsCollectionView.setCollectionViewLayout(setupLayout(), animated: true)
        levelsCollectionView.backgroundColor = .none
        levelsCollectionView.delegate = self
        levelsCollectionView.dataSource = self
        
    }

    @IBAction func levelChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        currentLevel = segmentedLevels[selectedIndex]
        
        UIView.transition(with: levelsCollectionView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.levelsCollectionView.reloadData()
        })
    }
}

extension LevelsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func setupLayout() -> UICollectionViewLayout{
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(30)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = 30
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        segmentedLevels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = levelsCollectionView.dequeueReusableCell(withReuseIdentifier: "LevelCell", for: indexPath) as! LevelCell
        let (level, description, data) = currentLevel[indexPath.item]
        cell.configureData(level: level, description: description, data: data)
        cell.layer.cornerRadius = 30
        cell.layer.borderWidth = 5
        cell.layer.borderColor = CGColor(red: 225/255, green: 168/255, blue: 63/255, alpha: 1)
        return cell
    }
    
    
}
