//
//  LockScreenViewController.swift
//  LeoLingo
//
//  Created by Sharnabh on 16/01/25.
//

import UIKit
import LocalAuthentication
import AudioToolbox

class LockScreenViewController: UIViewController {

    
    @IBOutlet var passcodeButtons: [UIButton]!
    @IBOutlet var deleteButton: UIButton!
    
    @IBOutlet var circleView1: UIView!
    @IBOutlet var circleView2: UIView!
    @IBOutlet var circleView3: UIView!
    @IBOutlet var circleView4: UIView!
    @IBOutlet var passcodeView: UIView!
    var myPasscode: String = ""
    let user = DataController.shared.getallUsers()
    var code = ""
    let passCodeLength = 4
    
    // Use both impact and notification feedback
    private let impactGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        code = user[0].passcode ?? "1234"
        print(user[0])

        configureCircleView(circleView: circleView1)
        configureCircleView(circleView: circleView2)
        configureCircleView(circleView: circleView3)
        configureCircleView(circleView: circleView4)
        
        
        passcodeView.layer.borderWidth = 2
        passcodeView.layer.borderColor = CGColor(red: 170/255, green: 102/255, blue: 71/255, alpha: 1)
        passcodeView.layer.cornerRadius = 30
        
        // Request Touch ID authentication when view loads
        authenticateWithTouchID()
        
        // Prepare both generators
        impactGenerator.prepare()
        notificationGenerator.prepare()
    }
    
    @IBAction func backButtonTapped1(_ sender: UIBarButtonItem) {
//        let storyboard = UIStoryboard(name: "Tarun", bundle: nil)
//        if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomePageViewController") as? HomePageViewController {
//            homeVC.modalPresentationStyle = .fullScreen
//            self.present(homeVC, animated: true, completion: nil)
//        }
        self.dismiss(animated: true)
    }
    
//    @objc func backButtonTapped() {
//        let storyboard = UIStoryboard(name: "Tarun", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "HomePageViewController")
//        self.present(vc, animated: true)
//    }
    
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
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let sceneDelegate = windowScene.delegate as? SceneDelegate {
                            let tabBarBC = storyboard?.instantiateViewController(withIdentifier: "parentModeTabBar") as! UITabBarController
                            sceneDelegate.window?.rootViewController = tabBarBC
                        }
                    } else {
                        // Trigger both feedbacks for stronger effect
                        impactGenerator.impactOccurred(intensity: 1.0)
                        notificationGenerator.notificationOccurred(.error)
                        
                        // Play system sound for wrong passcode
                        AudioServicesPlaySystemSound(1521) // "Wrong Password" vibration
                        
                        // Shake animation
                        shakePasscodeView()
                        
                        // Clear the passcode after wrong attempt
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.myPasscode = ""
                            self.updateCircleViews()
                            // Prepare for next use
                            self.impactGenerator.prepare()
                            self.notificationGenerator.prepare()
                        }
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
    
    private func shakePasscodeView() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.5
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        passcodeView.layer.add(animation, forKey: "shake")
    }
    
    private func authenticateWithTouchID() {
        let context = LAContext()
        var error: NSError?
        
        // Check if device can use biometric authentication
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock Parent Mode"
            
            // Check specific biometry type
            switch context.biometryType {
            case .touchID:
                // Proceed with Touch ID
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        
                        if success {
                            // Navigate to parent mode on success
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let sceneDelegate = windowScene.delegate as? SceneDelegate {
                                let tabBarBC = self.storyboard?.instantiateViewController(withIdentifier: "parentModeTabBar") as! UITabBarController
                                sceneDelegate.window?.rootViewController = tabBarBC
                            }
                        } else {
                            // Touch ID failed or was cancelled, user can still use passcode
                            if let error = error {
                                print("Touch ID authentication failed: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            case .faceID:
                // Skip biometric authentication if Face ID is available instead of Touch ID
                print("Face ID is not supported in this version")
            case .none:
                print("No biometric authentication available")
            @unknown default:
                print("Unknown biometry type")
            }
        } else {
            // Handle the case where biometric authentication is not available
            if let error = error {
                print("Biometric authentication not available: \(error.localizedDescription)")
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
