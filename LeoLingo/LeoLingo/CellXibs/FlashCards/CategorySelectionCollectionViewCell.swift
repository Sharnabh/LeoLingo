//
//  CategorySelectionCollectionViewCell.swift
//  LeoLingo
//
//  Created by Batch - 2 on 27/02/25.
//

import UIKit

class CategorySelectionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = true
        self.contentView.isUserInteractionEnabled = true
        imageView.isUserInteractionEnabled = true
    }
    
    func updateCategoryCard(with indexPath: IndexPath) {        imageView.image = UIImage(named: SampleDataController.shared.getCategoryCards()[indexPath.row].categoryCardImage)
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
