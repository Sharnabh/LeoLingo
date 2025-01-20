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
    
    
    func updateLabel(with word: String) {
        
    }
    
}
