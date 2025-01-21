//
//  FunLearningGamesCollectionViewCell.swift
//  LeoLingo
//
//  Created by Sharnabh on 15/01/25.
//

import UIKit

class FunLearningGamesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var gameImage: UIImageView!
    
    func updateImageView(with image: String) {
        gameImage.image = UIImage(named: image)
    }
}
