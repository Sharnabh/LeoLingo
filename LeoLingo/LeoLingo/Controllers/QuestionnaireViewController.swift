//
//  QuestionnaireViewController.swift
//  LeoLingo
//
//  Created by Sharnabh on 11/01/25.
//

import UIKit

class QuestionnaireViewController: UIViewController {

    @IBOutlet var nameAgeView: UIView!
    @IBOutlet var progressView: UIProgressView!
    
    // Add total number of steps
    private let totalSteps: Float = 5.0 // Adjust this based on your total child view controllers
    private var currentStep: Float = 0.0
    
    var phoneNumber: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        nameAgeView.layer.borderWidth = 2
        nameAgeView.layer.borderColor = CGColor(red: 170/255, green: 102/255, blue: 71/255, alpha: 1)
        nameAgeView.layer.cornerRadius = 30
        
        // Initialize progress bar
        progressView.progress = 0.0
        progressView.progressTintColor = UIColor(red: 170/255, green: 102/255, blue: 71/255, alpha: 1)
        
        // Initialize progress with first step
        updateProgress(step: 1)
    }
    
    // Updated progress function to work with steps
    func updateProgress(step: Int) {
        currentStep = Float(step)
        let progressValue = currentStep / totalSteps
        DispatchQueue.main.async {
            self.progressView.setProgress(progressValue, animated: true)
        }
    }
    
    // Add method to handle forward navigation
    func moveToNextStep() {
        let nextStep = min(currentStep + 1, totalSteps)
        updateProgress(step: Int(nextStep))
    }
    
    // Add method to handle backward navigation
    func moveToPreviousStep() {
        let previousStep = max(currentStep - 1, 0)
        updateProgress(step: Int(previousStep))
    }
    
    func getPhoneNumber(phone: String) {
        phoneNumber = phone
    }
    
    func returnPhoneNumber() -> String {
        return phoneNumber
    }
}

