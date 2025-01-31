//
//  BadgesEarnedCollectionViewCell.swift
//  LeoLingo
//
//  Created by Aditya Bhardwaj on 26/01/25.
//

import UIKit

class BadgesEarnedCollectionViewCell: UICollectionViewCell {

    static let identifier = "BadgesEarnedCollectionViewCell"
    
    @IBOutlet weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization Code
    }
    
    func configure(with name: String) {
        imageView.image = UIImage(named: name)
    }

}
