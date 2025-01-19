//
//  WordReportViewController.swift
//  LeoLingo
//
//  Created by Sharnabh on 16/01/25.
//

import UIKit

class WordReportViewController: UIViewController, UIPopoverPresentationControllerDelegate {


    @IBOutlet var reportCollectionView: UICollectionView!
    @IBOutlet var progressSectionView: ProgressSection!
    @IBOutlet var headingView: UIView!
    
    let allWords: [Word] = [
        Word(wordTitle: "A", record: Record(attempts: 5, accuracy: [30, 40, 70, 60, 90]), isPracticed: true),
        Word(wordTitle: "B", record: Record(attempts: 3, accuracy: [50, 60, 80]), isPracticed: true),
        Word(wordTitle: "C", record: Record(attempts: 4, accuracy: [20, 30, 50, 70]), isPracticed: true),
        Word(wordTitle: "D", isPracticed: false),
        Word(wordTitle: "E", record: Record(attempts: 5, accuracy: [10, 20, 30, 40, 50]), isPracticed: true),
        Word(wordTitle: "F", record: Record(attempts: 3, accuracy: [60, 70, 85]), isPracticed: true),
        Word(wordTitle: "G", record: Record(attempts: 3, accuracy: [25, 35, 55]), isPracticed: true),
        Word(wordTitle: "H", isPracticed: false),
        Word(wordTitle: "I", record: Record(attempts: 2, accuracy: [90, 95]), isPracticed: true),
        Word(wordTitle: "J", record: Record(attempts: 5, accuracy: [10, 15, 20, 25, 30]), isPracticed: true),
        Word(wordTitle: "K", record: Record(attempts: 3, accuracy: [40, 45, 55]), isPracticed: true),
        Word(wordTitle: "L", isPracticed: false),
        Word(wordTitle: "M", record: Record(attempts: 4, accuracy: [30, 35, 50, 60]), isPracticed: true),
        Word(wordTitle: "N", record: Record(attempts: 2, accuracy: [85, 90]), isPracticed: true),
        Word(wordTitle: "O", record: Record(attempts: 5, accuracy: [15, 25, 35, 45, 55]), isPracticed: true),
        Word(wordTitle: "P", isPracticed: false),
        Word(wordTitle: "Q", record: Record(attempts: 3, accuracy: [65, 70, 85]), isPracticed: true),
        Word(wordTitle: "R", record: Record(attempts: 4, accuracy: [50, 55, 60, 75]), isPracticed: true),
        Word(wordTitle: "S", record: Record(attempts: 2, accuracy: [95, 100]), isPracticed: true),
        Word(wordTitle: "T", isPracticed: false)
    ]
    
    var previouslySelectedIndexPath: IndexPath?

    var filteredWords: [Word] = []
    var isFiltered: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        
        headingView.layer.shadowColor = UIColor.black.cgColor
        headingView.layer.shadowOffset = CGSize(width: 0, height: 1)
        headingView.layer.shadowOpacity = 0.5
        headingView.layer.shadowRadius = 4
        headingView.layer.cornerRadius = 20
        headingView.layer.masksToBounds = false
        
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
        
        progressSectionView.layer.cornerRadius = 20
        progressSectionView.layer.borderWidth = 5
        progressSectionView.layer.borderColor = UIColor(red: 225/255, green: 168/255, blue: 63/255, alpha: 1).cgColor
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 1. Deselect the previously selected item (if exists)
        if let previouslySelectedIndexPath = previouslySelectedIndexPath {
            if let previousCell = collectionView.cellForItem(at: previouslySelectedIndexPath) as? WordReportCollectionViewCell {
                // Reset the color of the previously selected item
                previousCell.backgroundColor = .white
                previousCell.wordLabel.textColor = .black
                previousCell.layer.cornerRadius = 10
                previousCell.layer.shadowColor = UIColor.black.cgColor
                previousCell.layer.shadowOffset = CGSize(width: 0, height: 1)
                previousCell.layer.shadowRadius = 4
                previousCell.layer.shadowOpacity = 0.5
                previousCell.layer.masksToBounds = false // or your original color
            }
        }
        
        // 2. Select the new item
        guard let cell = collectionView.cellForItem(at: indexPath) as? WordReportCollectionViewCell else { return }
        
        let word = filteredWords[indexPath.item]
        cell.backgroundColor = UIColor(red: 178/255, green: 132/255, blue: 51/255, alpha: 1)
        cell.wordLabel.textColor = .white
        cell.updateLabel(with: word.wordTitle)
        cell.layer.cornerRadius = 10
        
        // 3. Update the progress section view
        progressSectionView.configureView(word: word)
        
        // 4. Save the current selected indexPath for later deselection
        previouslySelectedIndexPath = indexPath
    }

}

extension WordReportViewController: WordReportHeaderViewDelegate {
    func didTapAllButton() {
        isFiltered = false
        filteredWords = allWords
        reportCollectionView.reloadData()
    }
    
    func didTapFilterButton(_ sender: UIButton) {
        let filterVC = FilterViewController()
        filterVC.delegate = self
        filterVC.modalPresentationStyle = .popover

        if let popoverController = filterVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.sourceView = sender
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: 100, width: 0, height: 0) // Position
            popoverController.permittedArrowDirections = .up
        }

        present(filterVC, animated: true)
    }
}

extension WordReportViewController: FilterViewControllerDelegate {
    func didApplyFilter(averageAccuracy: Float, isPracticed: Bool, isPassed: Bool) {
        isFiltered = true
        filteredWords = allWords.filter { $0.isPracticed == isPracticed }
        reportCollectionView.reloadData()
    }
}
