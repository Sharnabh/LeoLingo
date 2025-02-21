//
//  SoundCardCollectionViewCell.swift
//  LeoLingo
//
//  Created by Batch - 2 on 16/01/25.
//

import UIKit

class LevelCardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    func updatelevelCard(with indexPath: IndexPath) {
        imageView.image = UIImage(named: SampleDataController.shared.getLevelCards()[indexPath.row].levelCardImage)
    }
    
}
