//
//  BadgesBottomCollectionViewCell.swift
//  LeoLingo
//
//  Created by Aditya Bhardwaj on 20/01/25.
//

import UIKit

class BadgesBottomCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("efa")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with name: String, description: String) {
        imageView.image = UIImage(systemName: "house.fill")
        descriptionLabel.text = description
    }

}
