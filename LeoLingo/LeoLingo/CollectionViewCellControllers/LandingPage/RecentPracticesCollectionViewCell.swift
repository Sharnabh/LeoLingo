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
    
    func updateLabel(with word: Word) {
        let title = word.wordTitle
        var maxAccuracy: Double?
        var color: UIColor
        switch word.isPracticed {
        case true:
            guard let record = word.record,
                  let accuracy = record.accuracy,
                  !accuracy.isEmpty else { return }
            maxAccuracy = accuracy.max()
            guard let accuracy = maxAccuracy,
                  let view = imageView as? ProgressView else { return }
            switch accuracy {
            case 1..<70:
                color = UIColor.systemRed
            case 70...100:
                color = UIColor.systemGreen
            default:
                color = UIColor.systemGray
            }
            
            view.configure(title: title, progress: Double(accuracy)/100.0, color: color)
        case false:
            color = UIColor.systemGray
            
            guard let view = imageView as? ProgressView else { return }
            view.configure(title: title, progress: 100.0, color: color)
        }
    }

}
