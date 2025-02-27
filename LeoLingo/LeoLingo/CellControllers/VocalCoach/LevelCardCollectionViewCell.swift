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
        
        // Add shadow and corner radius
        self.layer.cornerRadius = 21
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 0.2
        self.clipsToBounds = false
        self.contentView.layer.cornerRadius = 21
        self.contentView.clipsToBounds = true
    }
    
    func updatelevelCard(with indexPath: IndexPath) {
        imageView.image = UIImage(named: SampleDataController.shared.getLevelCards()[indexPath.row].levelCardImage)
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
