//
//  HeaderCollectionReusableView.swift
//  LeoLingo
//
//  Created by Galgotias on 21/01/25.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var titleLabel: UILabel!
        @IBOutlet weak var progressBar: UIProgressView!
        
        func configure(title: String, progress: Float) {
            titleLabel.text = title
            progressBar.progress = progress
        }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
}
