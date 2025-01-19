import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var starImageView: UIImageView!
    
    func configure(name: String, imageName: String) {
        titleLabel.text = name
        imageView.image = UIImage(named: imageName)
        starImageView.image = UIImage(named: "star_image")
        
        // Apply rounded corners and shadows
        contentView.layer.cornerRadius = 10
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowOffset = CGSize(width: 2, height: 2)
        contentView.layer.shadowRadius = 4
    }
}
