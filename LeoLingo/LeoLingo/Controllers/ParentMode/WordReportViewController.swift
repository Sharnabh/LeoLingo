//
//  WordReportViewController.swift
//  LeoLingo
//
//  Created by Sharnabh on 16/01/25.
//

import UIKit

class WordReportViewController: UIViewController {

    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var reportCollectionView: UICollectionView!
    
    let allWords: [Word] = [
        Word(wordTitle: "A", record: [Record(attempts: 5, accuracy: [30, 40, 70, 60, 90])], isPracticed: true),
        Word(wordTitle: "B", record: [Record(attempts: 3, accuracy: [50, 60, 80])], isPracticed: true),
        Word(wordTitle: "C", record: [Record(attempts: 4, accuracy: [20, 30, 50, 70])], isPracticed: true),
        Word(wordTitle: "D", record: [Record(attempts: 0)], isPracticed: false),
        Word(wordTitle: "E", record: [Record(attempts: 5, accuracy: [10, 20, 30, 40, 50])], isPracticed: true),
        Word(wordTitle: "F", record: [Record(attempts: 2, accuracy: [60, 70, 85])], isPracticed: true),
        Word(wordTitle: "G", record: [Record(attempts: 3, accuracy: [25, 35, 55])], isPracticed: true),
        Word(wordTitle: "H", record: [Record(attempts: 0)], isPracticed: false),
        Word(wordTitle: "I", record: [Record(attempts: 1, accuracy: [90, 95])], isPracticed: true),
        Word(wordTitle: "J", record: [Record(attempts: 5, accuracy: [10, 15, 20, 25, 30])], isPracticed: true),
        Word(wordTitle: "K", record: [Record(attempts: 3, accuracy: [40, 45, 55])], isPracticed: true),
        Word(wordTitle: "L", record: [Record(attempts: 0)], isPracticed: false),
        Word(wordTitle: "M", record: [Record(attempts: 4, accuracy: [30, 35, 50, 60])], isPracticed: true),
        Word(wordTitle: "N", record: [Record(attempts: 1, accuracy: [85, 90])], isPracticed: true),
        Word(wordTitle: "O", record: [Record(attempts: 5, accuracy: [15, 25, 35, 45, 55])], isPracticed: true),
        Word(wordTitle: "P", record: [Record(attempts: 0)], isPracticed: false),
        Word(wordTitle: "Q", record: [Record(attempts: 2, accuracy: [65, 70, 85])], isPracticed: true),
        Word(wordTitle: "R", record: [Record(attempts: 4, accuracy: [50, 55, 60, 75])], isPracticed: true),
        Word(wordTitle: "S", record: [Record(attempts: 1, accuracy: [95, 100])], isPracticed: true),
        Word(wordTitle: "T", record: [Record(attempts: 0)], isPracticed: false)
    ]

    var filteredWords: [Word] = []
    var isFiltered: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        
        headingLabel.layer.cornerRadius = 20
        headingLabel.layer.masksToBounds = true
        
        let wordReportNib = UINib(nibName: "WordReportCell", bundle: nil)
        reportCollectionView.register(wordReportNib, forCellWithReuseIdentifier: WordReportCollectionViewCell.identifier)
        reportCollectionView.register(WordReportHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: WordReportHeaderCollectionReusableView.identifier)
        reportCollectionView.setCollectionViewLayout(setupLayout(), animated: true)
        reportCollectionView.layer.cornerRadius = 20
        reportCollectionView.layer.borderWidth = 5
        reportCollectionView.layer.borderColor = UIColor(red: 225/255, green: 168/255, blue: 63/255, alpha: 1).cgColor
        
        filteredWords = allWords
        
        reportCollectionView.delegate = self
        reportCollectionView.dataSource = self
    }

}


extension WordReportViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    private func setupLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 7)
//        group.interItemSpacing = .fixed(30)
        
        let section = NSCollectionLayoutSection(group: group)
//        section.interGroupSpacing = 30
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 40)
        section.boundarySupplementaryItems = [header]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let headerView = reportCollectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: WordReportHeaderCollectionReusableView.identifier,
            for: indexPath) as! WordReportHeaderCollectionReusableView
        
        headerView.delegate = self  // Set delegate
        
        return headerView
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isFiltered ? filteredWords.count : allWords.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = reportCollectionView.dequeueReusableCell(withReuseIdentifier: WordReportCollectionViewCell.identifier, for: indexPath) as! WordReportCollectionViewCell
        let word = filteredWords[indexPath.item]
        
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 10
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.layer.shadowRadius = 4
        cell.layer.shadowOpacity = 0.5
        cell.layer.masksToBounds = false
        
        cell.updateLabel(with: word.wordTitle)
        
        return cell
    }
}

extension WordReportViewController: WordReportHeaderViewDelegate {
    func didTapAllButton() {
        print("All")
    }
    
    func didTapFilterButton() {
        print("Filter")
    }
    
    
}
