//
//  SetPasscodeViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 15/01/25.
//

import UIKit

class SetPasscodeViewController: UIViewController {

    @IBOutlet var circleView1: UIView!
    @IBOutlet var circleView2: UIView!
    @IBOutlet var circleView3: UIView!
    @IBOutlet var circleView4: UIView!
    @IBOutlet var passcodeButtons: [UIButton]!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var rightBarButtonItem: UIBarButtonItem!
    
    var myPasscode: String = ""
    let passCodeLength: Int = 4
    var phoneNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureCircleView(circleView: circleView1)
        configureCircleView(circleView: circleView2)
        configureCircleView(circleView: circleView3)
        configureCircleView(circleView: circleView4)

        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let backButton =  UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = UIColor(red: 44/255, green: 144/255, blue: 71/255, alpha: 1)
        
        navigationItem.leftBarButtonItem = backButton
        
        rightBarButtonItem.tintColor = UIColor(red: 44/255, green: 144/255, blue: 71/255, alpha: 1)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc private func doneButtonTapped() {
        Task {
            do {
                // Update passcode in Supabase using stored phone number
                try await SupabaseDataController.shared.updatePasscode(passcode: myPasscode)
                
                // Switch to main thread for UI updates
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    let storyBoard = UIStoryboard(name: "VocalCoach", bundle: nil)
                    if let vocalCoachVC = storyBoard.instantiateViewController(withIdentifier: "HomePageViewController") as? HomePageViewController {
                        vocalCoachVC.modalPresentationStyle = .fullScreen
                        self.present(vocalCoachVC, animated: true)
                    }
                }
            } catch {
                // Handle error on main thread
                DispatchQueue.main.async { [weak self] in
                    self?.showAlert(message: "Failed to set passcode: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func setPhoneNumber() {
        if let questionnaireVC = navigationController?.parent as? QuestionnaireViewController {
            // Update progress before popping
            phoneNumber = questionnaireVC.returnPhoneNumber()
        }
    }
    
    @objc private func backButtonTapped() {
        if let questionnaireVC = navigationController?.parent as? QuestionnaireViewController {
            // Update progress before popping
            questionnaireVC.moveToPreviousStep()
        }
        navigationController?.popViewController(animated: true)
    }
    
    func configureCircleView(circleView: UIView) {
        circleView.layer.cornerRadius = circleView.frame.size.width / 2
        circleView.layer.borderWidth = 1
        circleView.layer.borderColor = UIColor.black.cgColor
    }
    
    @IBAction func passcodeTapped(_ sender: UIButton) {
        if sender == deleteButton {
            // Remove last digit and clear last filled circle
            if !myPasscode.isEmpty {
                myPasscode.removeLast()
                updateCircleViews()
                navigationItem.rightBarButtonItem?.isEnabled = false // Disable when deleting
            }
        } else {
            // Add new digit if we haven't reached the maximum length
            if myPasscode.count < passCodeLength {
                myPasscode += String(sender.tag)
                updateCircleViews()
                
                // Enable the bar button item when passcode length is 4
                if myPasscode.count == passCodeLength {
                    navigationItem.rightBarButtonItem?.isEnabled = true
                }
            }
        }
    }
    
    private func updateCircleViews() {
        // Reset all circles to white
        circleView1.backgroundColor = .white
        circleView2.backgroundColor = .white
        circleView3.backgroundColor = .white
        circleView4.backgroundColor = .white
        
        // Fill circles based on passcode length
        for i in 0..<myPasscode.count {
            switch i {
            case 0: circleView1.backgroundColor = .black
            case 1: circleView2.backgroundColor = .black
            case 2: circleView3.backgroundColor = .black
            case 3: circleView4.backgroundColor = .black
            default: break
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for button in passcodeButtons {
            button.layoutIfNeeded()
            button.layer.cornerRadius = button.bounds.width / 2
            button.clipsToBounds = true
        }
        
        deleteButton.layoutIfNeeded()
        deleteButton.layer.cornerRadius = deleteButton.bounds.width / 2
        deleteButton.clipsToBounds = true
    }
}
