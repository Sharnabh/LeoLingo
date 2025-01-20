//
//  WordReportViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 20/01/25.
//

import UIKit

class WordReportViewController: UIViewController {
    
    private let levels: [Level] = [
        Level(levelTitle: "Level 1", words: [
            Word(wordTitle: "A", record: Record(attempts: 5, accuracy: [30, 40, 70, 60, 90], recording: ["1", "2", "3", "4", "5"]), isPracticed: true),
            Word(wordTitle: "B", record: Record(attempts: 3, accuracy: [50, 60, 80], recording: ["1", "2", "3"]), isPracticed: true),
            Word(wordTitle: "C", record: Record(attempts: 4, accuracy: [20, 30, 50, 70], recording: ["1", "2", "3", "4"]), isPracticed: true),
            Word(wordTitle: "D", record: Record(attempts: 2, accuracy: [50, 80], recording: ["1", "2"]), isPracticed: true)
        ]),
        Level(levelTitle: "Level 2", words: [
            Word(wordTitle: "E", record: Record(attempts: 5, accuracy: [10, 20, 30, 40, 50], recording: ["1", "2", "3", "4", "5"]), isPracticed: true),
            Word(wordTitle: "F", record: Record(attempts: 3, accuracy: [60, 70, 85], recording: ["1", "2", "3"]), isPracticed: true),
            Word(wordTitle: "G", record: Record(attempts: 3, accuracy: [25, 35, 55], recording: ["1", "2", "3"]), isPracticed: true),
            Word(wordTitle: "H", isPracticed: false)
        ]),
        Level(levelTitle: "Level 3", words: [
            Word(wordTitle: "I", record: Record(attempts: 2, accuracy: [90, 95], recording: ["1", "2"]), isPracticed: true),
            Word(wordTitle: "J", record: Record(attempts: 5, accuracy: [10, 15, 20, 25, 30], recording: ["1", "2", "3", "4", "5"]), isPracticed: true),
            Word(wordTitle: "K", record: Record(attempts: 3, accuracy: [40, 45, 55], recording: ["1", "2", "3"]), isPracticed: true),
            Word(wordTitle: "L", isPracticed: false)
        ]),
        Level(levelTitle: "Level 4", words: [
            Word(wordTitle: "M", record: Record(attempts: 4, accuracy: [30, 35, 50, 60], recording: ["1", "2", "3", "4"]), isPracticed: true),
            Word(wordTitle: "N", record: Record(attempts: 2, accuracy: [85, 90], recording: ["1", "2"]), isPracticed: true),
            Word(wordTitle: "O", record: Record(attempts: 5, accuracy: [15, 25, 35, 45, 55], recording: ["1", "2", "3", "4", "5"]), isPracticed: true),
            Word(wordTitle: "P", isPracticed: false)
        ]),
        Level(levelTitle: "Level 5", words: [
            Word(wordTitle: "Q", record: Record(attempts: 3, accuracy: [65, 70, 85], recording: ["1", "2", "3"]), isPracticed: true),
            Word(wordTitle: "R", record: Record(attempts: 4, accuracy: [50, 55, 60, 75], recording: ["1", "2", "3", "4"]), isPracticed: true),
            Word(wordTitle: "S", record: Record(attempts: 2, accuracy: [95, 100], recording: ["1", "2"]), isPracticed: true),
            Word(wordTitle: "T", isPracticed: false)
        ]),
    ]
    
    var selectedRow: Int = 0

    @IBOutlet var levelsTableView: UITableView!
    @IBOutlet var reportCollectionView: UICollectionView!
    @IBOutlet var recordingView: RecorrdingView!
    
    @IBOutlet var levelAverageLabel: UILabel!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var accuracyLabel: UILabel!
    @IBOutlet var accuracyGraph: ProgressGraphView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        levelsTableView.delegate = self
        levelsTableView.dataSource = self
        
        let reportNib = UINib(nibName: "WordReportCollectionViewCell", bundle: nil)
        reportCollectionView.register(reportNib, forCellWithReuseIdentifier: WordReportCollectionViewCell.identifier)
        
        reportCollectionView.delegate = self
        reportCollectionView.dataSource = self
        
    }

}

extension WordReportViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            levels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = levelsTableView.dequeueReusableCell(withIdentifier: "LevelCell", for: indexPath) as! LevelsTableViewCell
        let level = levels[indexPath.row]
        print(level.isCompleted)
        cell.configureCell(level: level.levelTitle, completed: level.isCompleted)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        levelAverageLabel.text = "\(levels[selectedRow].avgAccuracy)%"
        reportCollectionView.reloadData()
    }
}

extension WordReportViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = reportCollectionView.dequeueReusableCell(withReuseIdentifier: WordReportCollectionViewCell.identifier, for: indexPath) as! WordReportCollectionViewCell
        let level = levels[selectedRow].words
        let word = level[indexPath.item]
        
        cell.updateLabel(with: word)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let level = levels[selectedRow].words
            
        // Ensure indexPath.item is within bounds to avoid crashes
        guard indexPath.item < level.count else { return }
        
        let word = level[indexPath.item]
        
        wordLabel.text = word.wordTitle
        accuracyLabel.text = String(format: "%.1f%%", word.avgAccuracy)  // Format to 1 decimal place
        
        if let record = word.record {
            accuracyGraph.updateChartData(accuracyData: record.accuracy)
            recordingView.configureTableData(with: record, isEnabled: true)
        } else {
            accuracyGraph.updateChartData(accuracyData: [0])
            recordingView.configureTableData(with: nil, isEnabled: false)
        }
    }
}
