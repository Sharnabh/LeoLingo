//
//  WordReportCollectionViewCell.swift
//  LeoLingo
//
//  Created by Batch - 2 on 20/01/25.
//

import UIKit

class WordReportCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "WordCell"
    
    @IBOutlet var progressView: UIView!
    @IBOutlet var accuracyLabel: UILabel!
    @IBOutlet var attemptsLabel: UILabel!
    @IBOutlet var accuracy: UILabel!
    @IBOutlet var attempts: UILabel!
    
    
    func updateLabel(with word: Word) {
        if let appWord = SupabaseDataController.shared.wordData(by: word.id) {
            let title = appWord.wordTitle
            var color: UIColor
            switch word.isPracticed {
            case true:
                guard let record = word.record else { return }
                let accuracy = record.avgAccuracy
                guard let view = progressView as? ProgressView else { return }
                switch accuracy {
                case 1..<70:
                    color = UIColor.systemRed
                case 70...100:
                    color = UIColor.systemGreen
                default:
                    color = UIColor.systemGray
                }
                
                view.configure(title: title, progress: Double(accuracy)/100.0, color: color)
                accuracyLabel.text = String(format: "%.1f%%", accuracy)
                attemptsLabel.text = String(record.attempts)
            case false:
                color = UIColor.systemGray
                
                guard let view = progressView as? ProgressView else { return }
                view.configure(title: title, progress: 100.0, color: color)
                accuracyLabel.text = "0%"
                attemptsLabel.text = "0"
            }
        }
    }
}
