//
//  LevelsTableViewCell.swift
//  LeoLingo
//
//  Created by Batch - 2 on 20/01/25.
//

import UIKit

class LevelsTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet var levelLabel: UILabel!
    @IBOutlet var completedImageView: UIImageView!
    
    func configureCell(level: String, completed: Bool) {
        levelLabel.text = level
        switch completed {
             
        case true:
            completedImageView.image = UIImage(named: "CheckMark")
        case false:
            completedImageView.isHidden = true
        }
    }

}
