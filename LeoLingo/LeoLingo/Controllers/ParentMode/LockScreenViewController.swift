//
//  LockScreenViewController.swift
//  LeoLingo
//
//  Created by Sharnabh on 16/01/25.
//

import UIKit

class LockScreenViewController: UIViewController {

    
    @IBOutlet var passcodeButtons: [UIButton]!
    @IBOutlet var deleteButton: UIButton!
    
    @IBOutlet var circleView1: UIView!
    @IBOutlet var circleView2: UIView!
    @IBOutlet var circleView3: UIView!
    @IBOutlet var circleView4: UIView!
    @IBOutlet var passcodeView: UIView!
    var myPasscode: String = ""
    let code: String = "1234"
    let passCodeLength = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureCircleView(circleView: circleView1)
        configureCircleView(circleView: circleView2)
        configureCircleView(circleView: circleView3)
        configureCircleView(circleView: circleView4)
        
        
        passcodeView.layer.borderWidth = 2
        passcodeView.layer.borderColor = CGColor(red: 170/255, green: 102/255, blue: 71/255, alpha: 1)
        passcodeView.layer.cornerRadius = 30
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
                print(myPasscode)
                updateCircleViews()
                navigationItem.rightBarButtonItem?.isEnabled = false // Disable when deleting
            }
        } else {
            // Add new digit if we haven't reached the maximum length
            if myPasscode.count < passCodeLength {
                myPasscode += String(sender.tag)
                print(myPasscode)
                updateCircleViews()
                
                // Enable the bar button item when passcode length is 4
                if myPasscode.count == passCodeLength {
                    if myPasscode == code {
                        performSegue(withIdentifier: "WordReportSegue", sender: self)
                    } else {
                        print("Bhag")
                    }
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
