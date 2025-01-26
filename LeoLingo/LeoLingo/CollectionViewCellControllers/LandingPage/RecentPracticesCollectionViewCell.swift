//
//  RecentPracticesCollectionViewCell.swift
//  LeoLingo
//
//  Created by Aditya Bhardwaj on 26/01/25.
//

import UIKit

class RecentPracticesCollectionViewCell: UICollectionViewCell {

    static let identifier = "RecentPracticesCollectionViewCell"
    
    @IBOutlet weak var imageView: UIView!
    
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
        // Initialization code
    }
    
    func configure(with name: Word) {
        let title = name.wordTitle
        var maxAccuracy: Double?
        var color: UIColor
        maxAccuracy = name.record?.accuracy!.max()
        guard let accuracy = maxAccuracy else { return }
        switch accuracy {
        case 1..<70:
            color = UIColor.systemRed
        case 70...100:
            color = UIColor.systemGreen
        default:
            color = UIColor.systemGray
        }
        guard let imageView = imageView as? ProgressView else { return }
        imageView.configure(title: title, progress: 100.0, color: color)
    }

}
