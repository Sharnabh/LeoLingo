//
//  BadgesCollectionViewCell.swift
//  LeoLingo
//
//  Created by Batch - 2  on 21/01/25.
//

import UIKit

class BadgesCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "BadgesCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 75
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    func configure(with name: String) {
        imageView.image = UIImage(named: name)
    }
    
}
