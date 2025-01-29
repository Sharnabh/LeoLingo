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
    func checkUserExists(phone: String, completion: @escaping (Bool) -> Void)
    func validateLogin(phone: String, password: String, completion: @escaping (Bool) -> Void)
}

class LogInCollectionViewCell: UICollectionViewCell {
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var switchToSignupVCButton: UIButton!
    
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
        phoneNumberTextField.keyboardType = .phonePad
        phoneNumberTextField.delegate = self
    }
    
    private func setupActions() {
        passwordToggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        switchToSignupVCButton.addTarget(self, action: #selector(switchToSignup), for: .touchUpInside)
    }
    
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        passwordToggleButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func loginButtonTapped() {
        guard let phone = phoneNumberTextField.text, !phone.isEmpty else {
            delegate?.showAlert(message: "Please enter phone number")
            return
        }
        
        // Check if user exists
        if passwordTextField.isHidden {
            checkUserExists(phone: phone)
        } else {
            guard let password = passwordTextField.text, !password.isEmpty else {
                delegate?.showAlert(message: "Please enter password")
                return
            }
            validateLogin(phone: phone, password: password)
        }
    }
    
    @objc private func switchToSignup() {
        delegate?.switchToSignUpVC()
    }
    
    private func checkUserExists(phone: String) {
        // Replace with your actual database check
        delegate?.checkUserExists(phone: phone) { [weak self] exists in
            if exists {
                self?.passwordTextField.isHidden = false
            } else {
                self?.delegate?.showAlert(message: "User not found. Please sign up.")
            }
        }
    }
    
    private func validateLogin(phone: String, password: String) {
        // Replace with your actual login validation
        delegate?.validateLogin(phone: phone, password: password) { [weak self] success in
            if !success {
                self?.delegate?.showAlert(message: "Incorrect password")
            } else {
                self?.delegate?.switchToLandingPage()
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension LogInCollectionViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == phoneNumberTextField {
            // Hide password field when user starts editing phone number
            passwordTextField.isHidden = true
            passwordTextField.text = "" // Clear password for security
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == phoneNumberTextField {
            if let phone = textField.text, !phone.isEmpty {
                checkUserExists(phone: phone)
            }
        }
    }
}
