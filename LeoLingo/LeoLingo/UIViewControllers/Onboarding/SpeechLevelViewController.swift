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
        
        navigationItem.leftBarButtonItem?.image = UIImage(named: "chevron.left.circle")
    }

    @IBAction func continueButtonTapped(_ sender: UIButton) {
        if let questionnaireVC = parent as? QuestionnaireViewController {
            // Update progress
            questionnaireVC.updateProgress(to: 0.50)
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
