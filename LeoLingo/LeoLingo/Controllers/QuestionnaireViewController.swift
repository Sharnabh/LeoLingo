//
//  QuestionnaireViewController.swift
//  LeoLingo
//
//  Created by Sharnabh on 11/01/25.
//

import UIKit

class QuestionnaireViewController: UIViewController {

    @IBOutlet var nameAgeView: UIView!
    @IBOutlet var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        nameAgeView.layer.borderWidth = 2
        nameAgeView.layer.borderColor = CGColor(red: 170/255, green: 102/255, blue: 71/255, alpha: 1)
        nameAgeView.layer.cornerRadius = 57
        
        // Initialize progress bar
        progressView.progress = 0.0
        progressView.progressTintColor = UIColor(red: 170/255, green: 102/255, blue: 71/255, alpha: 1)
    }
    
    func updateProgress(to value: Double) {
        DispatchQueue.main.async {
            self.progressView.setProgress(Float(value), animated: true)
        }
    }
    
}
