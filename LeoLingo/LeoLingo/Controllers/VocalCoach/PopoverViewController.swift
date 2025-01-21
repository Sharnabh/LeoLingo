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
       var onProceed: (() -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        congratsLabel.text = message
        // Do any additional setup after loading the view.
    }
    @IBAction func proceedButtonTapped(_ sender: UIButton) {
            dismiss(animated: true) {
                self.onProceed?()
            }
        }

 

}
