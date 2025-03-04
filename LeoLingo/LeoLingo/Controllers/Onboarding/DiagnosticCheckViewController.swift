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
    
    @IBOutlet weak var tableView: UITableView!
    var options: [String] = ["Yes", "No"]
    var selectedIndexPath = Set<IndexPath>()
    
    var isDiagnosed: Bool? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
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

extension DiagnosticCheckViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = options[indexPath.row]
        let checkmarkImage = UIImage(systemName: "checkmark.circle.fill")
        let emptyImage = UIImage(systemName: "circle")
        content.image = selectedIndexPath.contains(indexPath) ? checkmarkImage : emptyImage
        content.imageProperties.tintColor = .accent
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath.removeAll()
        selectedIndexPath.insert(indexPath)
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
