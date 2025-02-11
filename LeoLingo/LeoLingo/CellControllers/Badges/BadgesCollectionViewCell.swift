//
//  BadgesCollectionViewCell.swift
//  LeoLingo
//
//  Created by Batch - 2  on 22/01/25.
//

import UIKit

class BadgesCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "BadgesCollectionViewCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
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
    
    func configure(with name: String, title: String) {
        imageView.image = UIImage(named: name)
        label.text = title
    }
    
}
