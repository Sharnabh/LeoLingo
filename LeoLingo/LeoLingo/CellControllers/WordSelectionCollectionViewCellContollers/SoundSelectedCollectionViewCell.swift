//
//  SoundSelectedCollectionViewCell.swift
//  LeoLingo
//
//  Created by Sharnabh on 12/01/25.
//

import UIKit

class SoundSelectedCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var letterLabel: UILabel!
    @IBOutlet var wordLabel: UILabel!
    func configureCell(with letter: String, words: [String]) {
        wordLabel.adjustsFontSizeToFitWidth = true
        letterLabel.adjustsFontSizeToFitWidth = true
        letterLabel.text = letter
        wordLabel.text = words.joined(separator: ", ")
    }
}
