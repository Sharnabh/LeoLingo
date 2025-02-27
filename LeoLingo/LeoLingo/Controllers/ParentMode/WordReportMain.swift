//
//  ParentModeViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 21/01/25.
//

import UIKit

class WordReportMain: UIViewController {

    @IBOutlet var wordReportView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wordReportView.layer.borderColor = UIColor(red: 143/255, green: 91/255, blue: 66/255, alpha: 1).cgColor
        wordReportView.layer.borderWidth = 2
        wordReportView.layer.cornerRadius = 20
        wordReportView.clipsToBounds = true
    }
    
    @IBAction func switchToKidsMode(_ sender: UIButton) {
        let alertVC = UIAlertController(title: "Do you want to exit Parent mode", message: nil, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in 
            let storyboard = UIStoryboard(name: "Tarun", bundle: nil)
            if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomePageViewController") as? HomePageViewController {
                homeVC.modalPresentationStyle = .fullScreen
                self.present(homeVC, animated: true, completion: nil)
            }

        }))
        alertVC.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alertVC, animated: true)
        
    }
    
}
