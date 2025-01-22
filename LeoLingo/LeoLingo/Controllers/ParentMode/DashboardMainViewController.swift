//
//  BadgesMainViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 22/01/25.
//

import UIKit

class DashboardMainViewController: UIViewController {

    @IBOutlet var dashbaordView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        dashbaordView.backgroundColor = .none
        dashbaordView.layer.borderColor = .none
        dashbaordView.layer.borderWidth = 0
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
