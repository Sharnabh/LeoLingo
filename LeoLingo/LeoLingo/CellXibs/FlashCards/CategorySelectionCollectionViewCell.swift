//
//  CategorySelectionCollectionViewCell.swift
//  LeoLingo
//
//  Created by Batch - 2 on 27/02/25.
//

import UIKit

class CategorySelectionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    let categoryCardImages = ["BodyParts","Fruits","Vegitables","Animals","Colors","Shapes","Numbers","Letters","Actions"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = true
        self.contentView.isUserInteractionEnabled = true
        imageView.isUserInteractionEnabled = true
    }
    
    func updateCategoryCard(with indexPath: IndexPath) {
        if indexPath.row < categoryCardImages.count {
            imageView.image = UIImage(named: categoryCardImages[indexPath.row])
        } else {
            imageView.image = nil 
        }
    }
    
}
