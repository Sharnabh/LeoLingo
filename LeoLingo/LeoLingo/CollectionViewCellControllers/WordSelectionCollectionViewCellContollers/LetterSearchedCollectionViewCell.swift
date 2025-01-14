//
//  LetterSearchedCollectionViewCell.swift
//  LeoLingo
//
//  Created by Sharnabh on 12/01/25.
//

import UIKit

protocol LetterSearchedDelegate: AnyObject {
    func didTapRemoveButton(at indexPath: IndexPath)
}

class LetterSearchedCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var searchedWordLabel: UILabel!
    @IBOutlet var removeButton: UIButton!
    
    weak var delegate: LetterSearchedDelegate?
    var indexPath: IndexPath?
    
    func configureCell(with word: String, at indexPath: IndexPath) {
        searchedWordLabel.text =  word
        self.indexPath = indexPath
    }

    @IBAction func removeButtonTapped(_ sender: UIButton) {
        guard let indexPath = indexPath else { return }
        
        self.delegate?.didTapRemoveButton(at: indexPath)
    }
}
