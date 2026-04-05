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
    @IBOutlet weak var accuracyLabel: UILabel!
    
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
        setupAccuracyLabel()
    }
    
    private func setupAccuracyLabel() {
        if accuracyLabel == nil {
            accuracyLabel = UILabel()
            accuracyLabel.translatesAutoresizingMaskIntoConstraints = false
            accuracyLabel.textAlignment = .center
            accuracyLabel.font = .systemFont(ofSize: 14, weight: .medium)
            contentView.addSubview(accuracyLabel)
            
            NSLayoutConstraint.activate([
                accuracyLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
                accuracyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                accuracyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                accuracyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
            ])
        }
    }
    
    func updateLabel(with word: Word) {
        if let appWord = DataController.shared.wordData(by: word.id) {
            let title = appWord.wordTitle
            var color: UIColor
            switch word.isPracticed {
            case true:
                guard let record = word.record else { return }
                let accuracy = record.avgAccuracy
                guard let view = imageView as? ProgressView else { return }
                switch accuracy {
                case 1..<70:
                    color = UIColor.systemRed
                case 70...100:
                    color = UIColor.systemGreen
                default:
                    color = UIColor.systemGray
                }
                
                view.configure(title: title, progress: Double(accuracy)/100.0, color: color)
                accuracyLabel.text = String(format: "%.1f%%", accuracy)
                accuracyLabel.textColor = color
            case false:
                color = UIColor.systemGray
                
                guard let view = imageView as? ProgressView else { return }
                view.configure(title: title, progress: 0.0, color: color)
                accuracyLabel.text = "Not practiced"
                accuracyLabel.textColor = color
            }
        }
    }
}
