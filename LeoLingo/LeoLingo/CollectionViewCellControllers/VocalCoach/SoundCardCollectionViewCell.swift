//
//  SoundCardCollectionViewCell.swift
//  LeoLingo
//
//  Created by Batch - 2 on 16/01/25.
//

import UIKit

class SoundCardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    func updateSoundCard(with indexPath: IndexPath) {
        imageView.image = UIImage(named: CardsDataController.shared.getCards()[indexPath.row].cardImage)
    }
    
}
