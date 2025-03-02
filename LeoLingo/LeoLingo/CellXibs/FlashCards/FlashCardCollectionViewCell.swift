//
//  FlashCardCollectionViewCell.swift
//  LeoLingo
//
//  Created by Batch - 2 on 28/02/25.
//

import UIKit

class FlashCardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var flashCardCell: UIView!
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var title: UILabel!
    
    
    
    private let colors: [UIColor] = [
            UIColor(red: 229/255, green: 96/255, blue: 76/255, alpha: 1),
            UIColor(red: 234/255, green: 178/255, blue: 50/255, alpha: 1),
            UIColor(red: 93/255, green: 67/255, blue: 34/255, alpha: 1),
            UIColor(red: 233/255, green: 183/255, blue: 183/255, alpha: 1),
            UIColor(red: 136/255, green: 167/255, blue: 233/255, alpha: 1),
            UIColor(red: 0/255, green: 168/255, blue: 157/255, alpha: 1),
            UIColor(red: 171/255, green: 48/255, blue: 101/255, alpha: 1),
            UIColor(red: 39/255, green: 95/255, blue: 127/255, alpha: 1)
        ]
        
    func configureCell(categoryIndex: Int, wordIndex: Int) {
        
        let categories = SampleDataController.shared.getCategoriesData()
        
        guard categoryIndex < categories.count else { return }
        
        let selectedCategory = categories[categoryIndex]
        
        guard wordIndex < selectedCategory.words.count else { return }
        
        let word = selectedCategory.words[wordIndex]
        
        imageView.image = UIImage(named: word.wordImage)
        title.text = word.wordTitle
        
        let colorIndex = wordIndex % colors.count
        flashCardCell.backgroundColor = colors[colorIndex]
    }


    
    // Add tap down effect
    func animateTapDown() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.layer.shadowOpacity = 0.1
        }
    }
    
    // Add tap up effect
    func animateTapUp() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
            self.transform = CGAffineTransform.identity
            self.layer.shadowOpacity = 0.2
        }
    }

    
}
