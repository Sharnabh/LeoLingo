//
//  SignUpCollectionViewCell.swift
//  LeoLingo
//
//  Created by Sharnabh on 10/01/25.
//

import UIKit
import AuthenticationServices

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
    @IBOutlet weak var socialButtonsStackView: UIStackView!
    
    // Native Apple Sign-In Button
    private lazy var nativeAppleButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .signUp, style: .black)
        button.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Custom Google Sign-In Button following Google's iOS guidelines
    private lazy var nativeGoogleButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure with Google logo and text
        var config = UIButton.Configuration.plain()
        
        // Create Google "G" logo using the asset
        if let googleImage = UIImage(named: "google_logo") {
            // Resize the image to fit properly
            let imageSize = CGSize(width: 20, height: 20)
            let renderer = UIGraphicsImageRenderer(size: imageSize)
            let resizedImage = renderer.image { context in
                googleImage.draw(in: CGRect(origin: .zero, size: imageSize))
            }
            config.image = resizedImage
            config.imagePadding = 12
            config.imagePlacement = .leading
        }
        
        // Configure title following Google's guidelines
        var titleAttr = AttributedString("Sign up with Google")
        titleAttr.font = .systemFont(ofSize: 17, weight: .medium)
        titleAttr.foregroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        config.attributedTitle = titleAttr
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 16)
        config.background.backgroundColor = .white
        button.configuration = config
        
        // Add subtle shadow matching Google's design
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 3
        button.layer.shadowOpacity = 0.15
        
        // Hover effect
        button.addTarget(self, action: #selector(googleButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(googleButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return button
    }()
    
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
        setupNativeButtons()
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
    
    private func setupNativeButtons() {
        // Remove all existing arranged subviews from stack
        socialButtonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add native buttons to stack
        socialButtonsStackView.addArrangedSubview(nativeAppleButton)
        socialButtonsStackView.addArrangedSubview(nativeGoogleButton)
        
        // Set constraints for equal sizing
        NSLayoutConstraint.activate([
            nativeAppleButton.heightAnchor.constraint(equalToConstant: 50),
            nativeGoogleButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupActions() {
        passwordToggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        switchToLoginVCButton.addTarget(self, action: #selector(switchToLogin), for: .touchUpInside)
        nativeAppleButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
        nativeGoogleButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
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
    
    @objc private func googleButtonTouchDown() {
        // Subtle press effect following Google's guidelines
        UIView.animate(withDuration: 0.1) {
            self.nativeGoogleButton.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
            self.nativeGoogleButton.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }
    }
    
    @objc private func googleButtonTouchUp() {
        UIView.animate(withDuration: 0.1) {
            self.nativeGoogleButton.backgroundColor = .white
            self.nativeGoogleButton.transform = .identity
        }
    }
}
