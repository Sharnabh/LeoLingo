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
    @IBOutlet var nameView: UIView!
    @IBOutlet var ageView: UIView!
    @IBOutlet var nameTextField: UITextField!
    
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
        guard let name = childNameTextField.text, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            let alert = UIAlertController(title: "Missing Information", 
                                        message: "Please enter the child's name", 
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let age = ageList[agePickerView.selectedRow(inComponent: 0)]
        
        // Save child's name to Supabase
        Task {
            do {
                try await SupabaseDataController.shared.updateChildName(name)
                // Move to next step after successful update
                if let questionnaireVC = navigationController?.parent as? QuestionnaireViewController {
                    questionnaireVC.moveToNextStep()
                }
            } catch {
                // Show error alert
                let alert = UIAlertController(title: "Error", 
                                            message: "Failed to save child's name. Please try again.", 
                                            preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
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
