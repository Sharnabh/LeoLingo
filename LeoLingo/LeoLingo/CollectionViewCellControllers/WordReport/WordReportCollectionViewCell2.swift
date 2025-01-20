//
//  WordReportCollectionViewCell.swift
//  LeoLingo
//
//  Created by Sharnabh on 18/01/25.
//

import UIKit

class WordReportCollectionViewCell2: UICollectionViewCell {
    
    static let identifier = "WordCell"
    
    @IBOutlet var wordLabel: UILabel!
    
    func updateLabel(with word: String) {
        wordLabel.text = word
    }
}
