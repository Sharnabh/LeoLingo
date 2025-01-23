//
//  PopoverViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 21/01/25.
//

import UIKit

class PopoverViewController: UIViewController {

    @IBOutlet var levelBadge: UIImageView!
    @IBOutlet var congratsLabel: UILabel!
    
    var message: String?
    var imageName: String?
    var onProceed: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let message = message {
            congratsLabel.text = message
        }
        
        if let imageName = imageName, let image = UIImage(named: imageName) {
            levelBadge.image = image
        } else {
            levelBadge.image = UIImage(named: "defaultBadge") 
        }
    }
    
    @IBAction func proceedButtonTapped(_ sender: UIButton) {
        dismiss(animated: true) {
            self.onProceed?()
        }
    }

    func configurePopover(message: String, image: String) {
        self.message = message
        self.imageName = image
    }
}
