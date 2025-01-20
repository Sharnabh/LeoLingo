import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(name: String, imageName: String) {
        titleLabel.text = name
        imageView.image = UIImage(named: imageName)
    }

}
