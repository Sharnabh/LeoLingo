//
//  LogInViewCollectionViewCell.swift
//  LeoLingo
//
//  Created by Sharnabh on 10/01/25.
//

import UIKit

protocol LogInCellDelegate: AnyObject {
    func showAlert(message: String)
    func switchToSignUpVC()
    func switchToLandingPage()
    func checkUserExists(email: String, completion: @escaping (Bool) -> Void)
    func validateLogin(email: String, password: String, completion: @escaping (Bool) -> Void)
    func initiateOTPLogin(email: String, password: String)
    func handleAppleSignIn()
}

class LogInCollectionViewCell: UICollectionViewCell {
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var switchToSignupVCButton: UIButton!
    @IBOutlet var appleSignInButton: UIButton!
    
    // Add password visibility button
    private let passwordToggleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    // Add delegate to handle navigation and database operations
    weak var delegate: LogInCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupActions()
    }
    
    private func setupUI() {
        // Initially hide password field
        passwordTextField.isHidden = true
        
        // Setup password toggle button
        passwordTextField.rightView = passwordToggleButton
        passwordTextField.rightViewMode = .always
        passwordTextField.isSecureTextEntry = true
        
        // Setup text fields
        emailTextField.keyboardType = .emailAddress
        emailTextField.delegate = self
    }
    
    private func setupActions() {
        passwordToggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        switchToSignupVCButton.addTarget(self, action: #selector(switchToSignup), for: .touchUpInside)
        appleSignInButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
    }
    
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        passwordToggleButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func loginButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty else {
            delegate?.showAlert(message: "Please enter email address")
            return
        }
        
        // Check if user exists
        if passwordTextField.isHidden {
            checkUserExists(email: email)
        } else {
            guard let password = passwordTextField.text, !password.isEmpty else {
                delegate?.showAlert(message: "Please enter password")
                return
            }
            validateLogin(email: email, password: password)
        }
    }
    
    @objc private func switchToSignup() {
        delegate?.switchToSignUpVC()
    }
    
    @objc private func appleSignInTapped() {
        delegate?.handleAppleSignIn()
    }
    
    private func checkUserExists(email: String) {
        // Replace with your actual database check
        delegate?.checkUserExists(email: email) { [weak self] exists in
            if exists {
                self?.passwordTextField.isHidden = false
            } else {
                self?.delegate?.showAlert(message: "User not found. Please sign up.")
            }
        }
    }
    
    private func validateLogin(email: String, password: String) {
        // Use OTP-based authentication instead of direct login
        delegate?.initiateOTPLogin(email: email, password: password)
    }
}

// MARK: - UITextFieldDelegate
extension LogInCollectionViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextField {
            // Hide password field when user starts editing email
            passwordTextField.isHidden = true
            passwordTextField.text = "" // Clear password for security
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField {
            if let email = textField.text, !email.isEmpty {
                checkUserExists(email: email)
            }
        }
    }
}
