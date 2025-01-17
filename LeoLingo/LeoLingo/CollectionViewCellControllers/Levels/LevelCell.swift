import UIKit

class LevelCell: UICollectionViewCell {
    
    @IBOutlet var levelLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var wordView: [UIView]!
    @IBOutlet var accuracyLabel: [UILabel]!
    @IBOutlet var attemptsLabel: [UILabel]!
    
    func configureData(level: String, description: String, data: [(String, Int, String)]) {
        levelLabel.text = level
        descriptionLabel.text = description
        
        
        
        for i in 0...min(data.count, wordView.count) {
            let (title, accuracy, attempts) = data[i]
            accuracyLabel[i].text = "Accuracy: \(accuracy)%"
            attemptsLabel[i].text = "Attempts: \(attempts)"
            
            let color: UIColor
            switch accuracy {
            case 0:
                color = .systemGray
            case 1...75:
                color = .systemRed
            default:
                color = .systemGreen
            }
            if let wordView = wordView[i] as? ProgressView {
                wordView.configure(title: title, progress: Double(accuracy)/100.0, color: color)
            }
        }
    }
    
    
    
}
