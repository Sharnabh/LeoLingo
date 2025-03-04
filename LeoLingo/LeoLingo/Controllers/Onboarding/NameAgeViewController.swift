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
        guard let name = childNameTextField.text, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            let alert = UIAlertController(title: "Missing Information", 
                                        message: "Please enter the child's name", 
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let age = ageList[agePickerView.selectedRow(inComponent: 0)]
        print("DEBUG: Attempting to save child name: \(name) and age: \(age)")
        
        // Update the child's name in the database
        Task {
            do {
                if let userId = SupabaseDataController.shared.userId {
                    print("DEBUG: Found user ID: \(userId)")
                    try await SupabaseDataController.shared.updateChildName(userId: userId, childName: name)
                    print("DEBUG: Successfully updated child name in database")
                    
                    // Verify the update
                    let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                    print("DEBUG: Verified user data - Child name: \(String(describing: userData.childName))")
                } else {
                    print("DEBUG: No user ID found in UserDefaults")
                }
            } catch {
                print("DEBUG: Error updating child name: \(error)")
            }
        }
        
        // Try getting the parent through the navigation hierarchy
        if let questionnaireVC = navigationController?.parent as? QuestionnaireViewController {
            questionnaireVC.moveToNextStep()
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
