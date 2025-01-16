//
//  NameAgeViewController.swift
//  LeoLingo
//
//  Created by Sharnabh on 11/01/25.
//

import UIKit

class NameAgeViewController: UIViewController {

    var ageList: [String] = ["2-3 years", "3-4 years", "4-5 years", "5-6 years", "6-7 years"]
    
    @IBOutlet var childNameTextField: UITextField!
    @IBOutlet weak var agePickerView: UIPickerView!
//    @IBOutlet var nameAgeView: UIView!
    @IBOutlet var nameView: UIView!
    @IBOutlet var ageView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        agePickerView.delegate = self
        agePickerView.dataSource = self
        
        nameView.layer.borderWidth = 2
        nameView.layer.borderColor = CGColor(red: 70/255, green: 156/255, blue: 89/255, alpha: 1)
        nameView.layer.cornerRadius = 18
        nameView.clipsToBounds = true
        
        ageView.layer.borderWidth = 2
        ageView.layer.borderColor = CGColor(red: 70/255, green: 156/255, blue: 89/255, alpha: 1)
        ageView.layer.cornerRadius = 18
        ageView.clipsToBounds = true
        
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        let name = childNameTextField.text
        let age = agePickerView.selectedRow(inComponent: 0)
        print("\(name ?? "nil") - \(age)\n")
        
        // Get reference to the parent QuestionnaireViewController
        if let questionnaireVC = parent as? QuestionnaireViewController {
            // Update progress
            questionnaireVC.updateProgress(to: 0.25) 
        }
    }
    
}


extension NameAgeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        ageList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        ageList[row]
    }

}
