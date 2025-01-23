//
//  BadgesBottomCollectionViewCell.swift
//  LeoLingo
//
//  Created by Batch - 2  on 21/01/25.
//

import UIKit

class BadgesBottomCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "BadgesBottomCollectionViewCell"

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with name: String, description: String) {
        imageView.image = UIImage(named: name)
        descriptionLabel.text = description
    }

}
