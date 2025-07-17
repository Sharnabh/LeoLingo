//
//  SignUpViewCollectionViewCell.swift
//  LeoLingo
//
//  Created by Sharnabh on 10/01/25.
//

import UIKit

protocol SignUpCellDelegate: AnyObject {
    func showAlert(message: String)
    func switchToLoginVC()
    func switchToQuestionnaireVC()
    func checkUserExists(email: String, completion: @escaping (Bool) -> Void)
    func signUp(name: String, email: String, password: String)
    func initiateOTPSignup(name: String, email: String, password: String)
    func handleAppleSignIn()
    func handleGoogleSignIn()
}

class SignUpCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var parentsNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var switchToLoginVCButton: UIButton!
    @IBOutlet var appleSignInButton: UIButton!
    @IBOutlet var googleSignInButton: UIButton!
    
    // Add password visibility button
    private let passwordToggleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    weak var delegate: SignUpCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupActions()
    }
    
    private func setupUI() {
        // Setup password toggle button
        passwordTextField.rightView = passwordToggleButton
        passwordTextField.rightViewMode = .always
        passwordTextField.isSecureTextEntry = true
        
        // Setup text fields
        emailTextField.keyboardType = .emailAddress
        parentsNameTextField.autocapitalizationType = .words
    }
    
    private func setupActions() {
        passwordToggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        switchToLoginVCButton.addTarget(self, action: #selector(switchToLogin), for: .touchUpInside)
        appleSignInButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
        googleSignInButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
    }
    
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        passwordToggleButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func signUpButtonTapped() {
        guard let name = parentsNameTextField.text, !name.isEmpty else {
            delegate?.showAlert(message: "Please enter parent's name")
            return
        }
        
        guard let email = emailTextField.text, !email.isEmpty else {
            delegate?.showAlert(message: "Please enter email address")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            delegate?.showAlert(message: "Please enter password")
            return
        }
        
        // Check if user already exists
        delegate?.checkUserExists(email: email) { [weak self] exists in
            if exists {
                self?.delegate?.showAlert(message: "User already exists. Please login.")
                self?.delegate?.switchToLoginVC()
            } else {
                // Proceed with OTP-based signup
                self?.delegate?.initiateOTPSignup(name: name, email: email, password: password)
            }
        }
    }
    
    @objc private func switchToLogin() {
        delegate?.switchToLoginVC()
    }
    
    @objc private func switchToQuestionnaire() {
        delegate?.switchToQuestionnaireVC()
    }
    
    @objc private func appleSignInTapped() {
        delegate?.handleAppleSignIn()
    }
    
    @objc private func googleSignInTapped() {
        delegate?.handleGoogleSignIn()
    }
}
