//
//  DiagnosticCheckViewController.swift
//  LeoLingo
//
//  Created by Sharnabh on 12/01/25.
//

import UIKit

class DiagnosticCheckViewController: UIViewController {

    
    
    @IBOutlet var yesCheckmarkButton: UIButton!
    @IBOutlet var noCheckmarkButton: UIButton!
    var isDiagnosed: Bool? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem?.image = UIImage(named: "chevron.left.circle")
//        yesCheckmarkButton.setImage(UIImage(named: "square"), for: .normal)
//        
//        noCheckmarkButton.setImage(UIImage(named: "square"), for: .normal)
        
    }

    @IBAction func yesButtonTapped(_ sender: UIButton) {
        yesCheckmarkButton.setImage(UIImage(named: "checkmark.square.fill"), for: .normal)
        isDiagnosed = true
        noCheckmarkButton.setImage(UIImage(named: "square"), for: .normal)
        print(isDiagnosed!)
        
    }
    
    @IBAction func noButtonTapped(_ sender: UIButton) {
        noCheckmarkButton.setImage(UIImage(named: "checkmark.square.fill"), for: .normal)
        isDiagnosed = false
        yesCheckmarkButton.setImage(UIImage(named: "square"), for: .normal)
        print(isDiagnosed!)
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        if let diagnosed = isDiagnosed {
            switch diagnosed {
                
            case true:
                print("True")
            case false:
                print("False")
            }
            performSegue(withIdentifier: "SwitchToSelectWord", sender: self)
        } else  {
            let alert = UIAlertController(title: "Alert", message: "Please select if your child is Diagnosed with Speech Delay.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alert, animated: true)
        }
    }
}
