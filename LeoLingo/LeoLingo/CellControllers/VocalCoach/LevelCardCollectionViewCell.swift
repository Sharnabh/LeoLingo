//
//  SoundCardCollectionViewCell.swift
//  LeoLingo
//
//  Created by Batch - 2 on 16/01/25.
//

import UIKit

class LevelCardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = true
        self.contentView.isUserInteractionEnabled = true
        imageView.isUserInteractionEnabled = true
    }
    
    func updatelevelCard(with indexPath: IndexPath) {
        imageView.image = UIImage(named: SampleDataController.shared.getLevelCards()[indexPath.row].levelCardImage)
    }
    
}
