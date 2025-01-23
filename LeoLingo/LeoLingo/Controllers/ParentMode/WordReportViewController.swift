//
//  WordReportViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 20/01/25.
//

import UIKit

class WordReportViewController: UIViewController {
    
    private let levels: [Level] = DataController.shared.allLevels()
    
    var selectedRow: Int = 0
    var selectedFilter: FIlterOptions = .all
    private var isFilteringAllLevels = false
    private var filteredWords: [Word] = []


    @IBOutlet var levelsTableView: UITableView!
    @IBOutlet var levelsView: UIView!
    @IBOutlet var reportCollectionView: UICollectionView!
    @IBOutlet var recordingView: RecorrdingView!
    
    @IBOutlet var levelAverageLabel: UILabel!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var accuracyLabel: UILabel!
    @IBOutlet var accuracyGraph: ProgressGraphView!
    
    @IBOutlet var filterView: FilterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingView.layer.borderColor = UIColor(red: 178/255, green: 132/255, blue: 51/255, alpha: 1).cgColor
        recordingView.layer.borderWidth = 3
        recordingView.layer.cornerRadius = 0
        
        levelsView.layer.borderColor = UIColor(red: 178/255, green: 132/255, blue: 51/255, alpha: 1).cgColor
        levelsView.layer.borderWidth = 5
        levelsView.layer.cornerRadius = 0
        
        reportCollectionView.layer.borderColor = UIColor(red: 178/255, green: 132/255, blue: 51/255, alpha: 1).cgColor
        reportCollectionView.layer.borderWidth = 5
        reportCollectionView.layer.cornerRadius = 0
        
        filterView.layer.cornerRadius = 20
        filterView.layer.shadowColor = UIColor.black.cgColor
        filterView.layer.shadowOffset = CGSize(width: 4, height: 4)
        filterView.layer.shadowOpacity = 0.4
        filterView.layer.shadowRadius = 5
        filterView.clipsToBounds = false
        
        

        levelsTableView.delegate = self
        levelsTableView.dataSource = self
        
        let reportNib = UINib(nibName: "WordReportCollectionViewCell", bundle: nil)
        reportCollectionView.register(reportNib, forCellWithReuseIdentifier: WordReportCollectionViewCell.identifier)
        
        reportCollectionView.delegate = self
        reportCollectionView.dataSource = self
        
        filteredWords = levels.flatMap { $0.words }
        
    }

    @IBAction func filterButtonTapped(_ sender: UIButton) {
        UIView.transition(with: filterView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.filterView.isHidden.toggle()
                self.filterView.configureTableView()
            }) { _ in
                if let selectedOption = self.filterView.option {
                    sender.setTitle(selectedOption, for: .normal)
                    self.isFilteringAllLevels = true
                    self.selectedFilter = FIlterOptions(rawValue: selectedOption) ?? .all
                    self.applyFilter(option: selectedOption)
                    
                    
                }
            }
    }
    
    private func applyFilter(option: String) {
        // If "All" is selected, show all words across all levels
        if isFilteringAllLevels {
                filteredWords = getFilteredWords() // Apply the filter across all levels
            } else if let level = levels[safe: selectedRow] {
                // If a specific level is selected, show words from that level only
                filteredWords = getFilteredWords(for: level) // Apply the filter for the selected level
            }
            
            // Reload collection view to reflect filtered words
            reportCollectionView.reloadData()
    }

    
    private func getFilteredWords() -> [Word] {
        let allWords = levels.flatMap { $0.words }

            switch selectedFilter {
            case .all:
                return allWords
            case .accurate:
                return allWords.filter { word in
                    word.record?.accuracy!.contains { $0 >= 70 } ?? false
                }
            case .inaccurate:
                return allWords.filter { word in
                    word.record?.accuracy!.allSatisfy { $0 < 70 } ?? false
                }
            }
    }

    
    private func getFilteredWords(for level: Level) -> [Word] {
        switch selectedFilter {
            case .all:
                return level.words
            case .accurate:
                return level.words.filter { word in
                    word.record?.accuracy!.contains { $0 >= 70 } ?? false
                }
            case .inaccurate:
                return level.words.filter { word in
                    word.record?.accuracy!.allSatisfy { $0 < 70 } ?? false
                }
            }
    }

}

extension WordReportViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            levels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = levelsTableView.dequeueReusableCell(withIdentifier: "LevelCell", for: indexPath) as! LevelsTableViewCell
        let level = levels[indexPath.row]
        
        cell.configureCell(level: level.levelTitle, completed: level.isCompleted)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
//        levelAverageLabel.text = "\(levels[selectedRow].avgAccuracy)%"
        levelAverageLabel.text = String(format: "%.1f%%", levels[selectedRow].avgAccuracy)
        isFilteringAllLevels = false
        reportCollectionView.reloadData()
    }
}

extension WordReportViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isFilteringAllLevels ? filteredWords.count : levels[selectedRow].words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = reportCollectionView.dequeueReusableCell(
                    withReuseIdentifier: WordReportCollectionViewCell.identifier,
                    for: indexPath
                ) as! WordReportCollectionViewCell

        switch isFilteringAllLevels {
            case true:
            let word = filteredWords[indexPath.item]
            cell.updateLabel(with: word)
        case false:
            let level = levels[selectedRow]
            let word = level.words[indexPath.item]
            cell.updateLabel(with: word)
        }
                
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var word: Word
        switch isFilteringAllLevels {
        case true:
             word = filteredWords[indexPath.item]
        case false:
             word = levels[selectedRow].words[indexPath.item]
        }
        
                
        wordLabel.text = word.wordTitle
        accuracyLabel.text = String(format: "%.1f%%", word.avgAccuracy)
        
        if let record = word.record {
            accuracyGraph.updateChartData(accuracyData: record.accuracy!)
            recordingView.configureTableData(with: record, isEnabled: true)
        } else {
            accuracyGraph.updateChartData(accuracyData: [0])
            recordingView.configureTableData(with: nil, isEnabled: false)
        }
    }
    }


extension Array {
    subscript(safe index: Int) -> Element? {
        return index >= 0 && index < count ? self[index] : nil
    }
}
