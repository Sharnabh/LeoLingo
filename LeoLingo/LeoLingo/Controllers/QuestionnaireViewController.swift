//
//  QuestionnaireViewController.swift
//  LeoLingo
//
//  Created by Sharnabh on 11/01/25.
//

import UIKit

class QuestionnaireViewController: UIViewController {

    var ageList: [String] = ["2-3 years", "3-4 years", "4-5 years", "5-6 years", "6-7 years"]
    
    @IBOutlet var childNameTextField: UITextField!
    @IBOutlet weak var agePickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        agePickerView.delegate = self
        agePickerView.dataSource = self
        
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        let name = childNameTextField.text
        let age = agePickerView.selectedRow(inComponent: 0)
        print("\(name ?? "nil")\n\(age)")
    }
    
}


extension QuestionnaireViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
