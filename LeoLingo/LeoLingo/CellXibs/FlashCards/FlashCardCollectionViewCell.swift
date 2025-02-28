//
//  FlashCardCollectionViewCell.swift
//  LeoLingo
//
//  Created by Batch - 2 on 28/02/25.
//

import UIKit

class FlashCardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var image: UIImageView!
    
    @IBOutlet var title: UILabel!
    
    
    
    private let colors: [UIColor] = [
            UIColor.systemRed,
            UIColor.systemBlue,
            UIColor.systemGreen,
            UIColor.systemOrange,
            UIColor.systemPurple
        ]
        
        func configureCell(at index: Int) {
            self.backgroundColor = colors[index % colors.count]
            
            image.image = UIImage(named: "rat")
            title.text = "Rat"
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
