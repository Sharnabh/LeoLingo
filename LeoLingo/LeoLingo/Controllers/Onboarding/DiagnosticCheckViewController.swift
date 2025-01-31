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

        navigationItem.leftBarButtonItem?.image = UIImage(systemName: "chevron.left.circle")
        yesCheckmarkButton.setImage(UIImage(systemName: "square"), for: .normal)
        
        noCheckmarkButton.setImage(UIImage(systemName: "square"), for: .normal)
        
        let backButton =  UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = UIColor(red: 44/255, green: 144/255, blue: 71/255, alpha: 1)
        
        navigationItem.leftBarButtonItem = backButton
        
    }
    
    @objc private func backButtonTapped() {
        if let questionnaireVC = navigationController?.parent as? QuestionnaireViewController {
            // Update progress before popping
            questionnaireVC.moveToPreviousStep()
        }
        navigationController?.popViewController(animated: true)
    }

    @IBAction func yesButtonTapped(_ sender: UIButton) {
        yesCheckmarkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        noCheckmarkButton.setImage(UIImage(systemName: "square"), for: .normal)
        isDiagnosed = true
        print(isDiagnosed!)
        
    }
    
    @IBAction func noButtonTapped(_ sender: UIButton) {
        noCheckmarkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        yesCheckmarkButton.setImage(UIImage(systemName: "square"), for: .normal)
        isDiagnosed = false
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
            if let questionnaireVC = navigationController?.parent as? QuestionnaireViewController {
                // Update progress
                questionnaireVC.moveToNextStep()
            }
        } else  {
            let alert = UIAlertController(title: "Alert", message: "Please select if your child is Diagnosed with Speech Delay.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alert, animated: true)
        }
    }
}
