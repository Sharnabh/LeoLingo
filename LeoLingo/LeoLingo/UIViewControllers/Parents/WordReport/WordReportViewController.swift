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
            Word(wordTitle: "A", record: Record(attempts: 5, accuracy: [30, 40, 70, 60, 90]), isPracticed: true),
            Word(wordTitle: "B", record: Record(attempts: 3, accuracy: [50, 60, 80]), isPracticed: true),
            Word(wordTitle: "C", record: Record(attempts: 4, accuracy: [20, 30, 50, 70]), isPracticed: true),
            Word(wordTitle: "D", isPracticed: false)
        ]),
        Level(levelTitle: "Level 2", words: [
            Word(wordTitle: "E", record: Record(attempts: 5, accuracy: [10, 20, 30, 40, 50]), isPracticed: true),
            Word(wordTitle: "F", record: Record(attempts: 3, accuracy: [60, 70, 85]), isPracticed: true),
            Word(wordTitle: "G", record: Record(attempts: 3, accuracy: [25, 35, 55]), isPracticed: true),
            Word(wordTitle: "H", isPracticed: false)
        ]),
        Level(levelTitle: "Level 3", words: [
            Word(wordTitle: "I", record: Record(attempts: 2, accuracy: [90, 95]), isPracticed: true),
            Word(wordTitle: "J", record: Record(attempts: 5, accuracy: [10, 15, 20, 25, 30]), isPracticed: true),
            Word(wordTitle: "K", record: Record(attempts: 3, accuracy: [40, 45, 55]), isPracticed: true),
            Word(wordTitle: "L", isPracticed: false)
        ]),
        Level(levelTitle: "Level 4", words: [
            Word(wordTitle: "M", record: Record(attempts: 4, accuracy: [30, 35, 50, 60]), isPracticed: true),
            Word(wordTitle: "N", record: Record(attempts: 2, accuracy: [85, 90]), isPracticed: true),
            Word(wordTitle: "O", record: Record(attempts: 5, accuracy: [15, 25, 35, 45, 55]), isPracticed: true),
            Word(wordTitle: "P", isPracticed: false)
        ]),
        Level(levelTitle: "Level 5", words: [
            Word(wordTitle: "Q", record: Record(attempts: 3, accuracy: [65, 70, 85]), isPracticed: true),
            Word(wordTitle: "R", record: Record(attempts: 4, accuracy: [50, 55, 60, 75]), isPracticed: true),
            Word(wordTitle: "S", record: Record(attempts: 2, accuracy: [95, 100]), isPracticed: true),
            Word(wordTitle: "T", isPracticed: false)
        ]),
    ]

    @IBOutlet var levelsTableView: UITableView!
    @IBOutlet var recordingTableView: UITableView!
    @IBOutlet var reportCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        levelsTableView.delegate = self
        levelsTableView.dataSource = self
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
    
    
}
