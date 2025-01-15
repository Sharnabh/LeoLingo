//
//  SpeechLevelViewController.swift
//  LeoLingo
//
//  Created by Sharnabh on 11/01/25.
//

import UIKit

class SpeechLevelViewController: UIViewController {
    
    let speechLevels: [String] = [
        "Nonverbal",
        "Nonverbal but can tell yes / no",
        "Cannot speak but know words",
        "Does speak but not everyone understands ",
    ]

    @IBOutlet var speechLevelTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        speechLevelTableView.delegate = self
        speechLevelTableView.dataSource = self
        
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

    @IBAction func continueButtonTapped(_ sender: UIButton) {
        if let questionnaireVC = navigationController?.parent as? QuestionnaireViewController {
            // Update progress
            questionnaireVC.moveToNextStep()
        }
    }
}


extension SpeechLevelViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        speechLevels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = speechLevelTableView.dequeueReusableCell(withIdentifier: "SpeechLevels", for: indexPath)
        let levels = speechLevels[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = levels
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(speechLevels[indexPath.row])
    }
    
}
