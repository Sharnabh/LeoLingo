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
    func checkUserExists(phone: String, completion: @escaping (Bool) -> Void)
    func signUp(name: String, phone: String, password: String)
}

class SignUpCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var parentsNameTextField: UITextField!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var switchToLoginVCButton: UIButton!
    
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
        phoneNumberTextField.keyboardType = .phonePad
        parentsNameTextField.autocapitalizationType = .words
    }
    
    private func setupActions() {
        passwordToggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        switchToLoginVCButton.addTarget(self, action: #selector(switchToLogin), for: .touchUpInside)
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
        
        guard let phone = phoneNumberTextField.text, !phone.isEmpty else {
            delegate?.showAlert(message: "Please enter phone number")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            delegate?.showAlert(message: "Please enter password")
            return
        }
        
        // Check if user already exists
        delegate?.checkUserExists(phone: phone) { [weak self] exists in
            if exists {
                self?.delegate?.showAlert(message: "User already exists. Please login.")
                self?.delegate?.switchToLoginVC()
            } else {
                // Proceed with signup
                self?.delegate?.signUp(name: name, phone: phone, password: password)
            }
        }
    }
    
    @objc private func switchToLogin() {
        delegate?.switchToLoginVC()
    }
}
