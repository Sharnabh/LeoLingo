//
//  RecorrdingTableViewCell.swift
//  LeoLingo
//
//  Created by Sharnabh on 21/01/25.
//

import UIKit

class RecorrdingTableViewCell: UITableViewCell {

    @IBOutlet var playButton: UIButton!
    @IBOutlet var attemptLabel: UILabel!
    
    var playAction: (() -> Void)?

    @IBAction func playButtonTapped(_ sender: UIButton) {
        playAction?()
    }
    
    func configureTitle(text: String) {
        attemptLabel.text = text
    }
}
