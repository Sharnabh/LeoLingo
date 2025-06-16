//
//  ViewController.swift
//  LeoLingo
//
//  Created by Sharnabh on 09/01/25.
//

import UIKit
import SwiftUI
import AuthenticationServices

class SignUpViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    @IBOutlet var signUpCollectionView: UICollectionView!
    private var loadingView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let signUpCollectionViewCell = UINib(nibName: "SignUpViewCell", bundle: nil)
        signUpCollectionView.register(signUpCollectionViewCell, forCellWithReuseIdentifier: "SignUpCell")
        
        signUpCollectionView.delegate = self
        signUpCollectionView.dataSource = self
        
        signUpCollectionView.layer.borderWidth = 2
        signUpCollectionView.layer.borderColor = CGColor(red: 170/255, green: 102/255, blue: 71/255, alpha: 1)
        signUpCollectionView.layer.cornerRadius = 57
        
        signUpCollectionView.setCollectionViewLayout(setupCollectionViewLayout(), animated: true)
        
        self.navigationItem.hidesBackButton = true
    }
    
    private func showLoading() {
        // Create container view
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        containerView.center = view.center
        
        // Add blur effect
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = containerView.bounds
        blurView.layer.cornerRadius = 10
        blurView.clipsToBounds = true
        containerView.addSubview(blurView)
        
        // Create activity indicator
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        activityIndicator.center = CGPoint(x: containerView.bounds.width/2, y: containerView.bounds.height/2)
        activityIndicator.startAnimating()
        
        // Add activity indicator to blur view's content view
        blurView.contentView.addSubview(activityIndicator)
        
        // Add dim background
        let dimView = UIView(frame: view.bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.addSubview(dimView)
        
        // Add container view
        view.addSubview(containerView)
        
        // Store both views for removal
        let containerWithBackground = UIView(frame: view.bounds)
        containerWithBackground.addSubview(dimView)
        containerWithBackground.addSubview(containerView)
        view.addSubview(containerWithBackground)
        self.loadingView = containerWithBackground
    }
    
    private func hideLoading() {
        loadingView?.removeFromSuperview()
        loadingView = nil
    }

    // MARK: - Apple Sign In
    func handleAppleSignIn() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = self.view.window else {
            // If window is nil, return the key window as fallback
            return UIApplication.shared.windows.first ?? UIWindow()
        }
        return window
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let email = appleIDCredential.email ?? ""
            let fullName = appleIDCredential.fullName?.givenName ?? "Apple User"
            let userIdentifier = appleIDCredential.user
            // Check if user exists in Supabase
            self.showLoading()
            Task {
                do {
                    let users = try await SupabaseDataController.shared.getAllUsers()
                    if let existingUser = users.first(where: { $0.apple_id == userIdentifier }) {
                        // User exists, log them in
                        DispatchQueue.main.async { [weak self] in
                            self?.hideLoading()
                            let storyBoard = UIStoryboard(name: "Questionnaire", bundle: nil)
                            if let questionnaireVC = storyBoard.instantiateViewController(withIdentifier: "NameAndAgeVC") as? QuestionnaireViewController {
                                questionnaireVC.getEmail(email: existingUser.email)
                                questionnaireVC.modalPresentationStyle = .fullScreen
                                self?.navigationController?.pushViewController(questionnaireVC, animated: true)
                            }
                        }
                    } else {
                        // User does not exist, create new user
                        let newUser = try await SupabaseDataController.shared.signUpWithApple(name: fullName, email: email, appleId: userIdentifier)
                        DispatchQueue.main.async { [weak self] in
                            self?.hideLoading()
                            let storyBoard = UIStoryboard(name: "Questionnaire", bundle: nil)
                            if let questionnaireVC = storyBoard.instantiateViewController(withIdentifier: "NameAndAgeVC") as? QuestionnaireViewController {
                                questionnaireVC.getEmail(email: newUser.email)
                                questionnaireVC.modalPresentationStyle = .fullScreen
                                self?.navigationController?.pushViewController(questionnaireVC, animated: true)
                            }
                        }
                    }
                } catch {
                    DispatchQueue.main.async { [weak self] in
                        self?.hideLoading()
                        self?.showAlert(message: "Apple Sign In failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.hideLoading()
        self.showAlert(message: "Apple Sign In failed: \(error.localizedDescription)")
    }
}

extension SignUpViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func setupCollectionViewLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = signUpCollectionView.dequeueReusableCell(withReuseIdentifier: "SignUpCell", for: indexPath) as! SignUpCollectionViewCell
        cell.delegate = self
        return cell
    }
    
    
}

// MARK: - SignUpCellDelegate
extension SignUpViewController: SignUpCellDelegate {
    
    
    func switchToQuestionnaireVC() {
        // Remove this method or make it empty since we don't want to switch to questionnaire immediately
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func switchToLoginVC() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func checkUserExists(email: String, completion: @escaping (Bool) -> Void) {
        Task {
            do {
                let users = try await SupabaseDataController.shared.getAllUsers()
                let exists = users.contains { $0.email == email }
                DispatchQueue.main.async {
                    completion(exists)
                }
            } catch {
                print("Error checking user: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    // Add new password validation function
    private func validatePassword(_ password: String) -> Bool {
        let capitalLetterRegex = ".*[A-Z]+.*"
        let smallLetterRegex = ".*[a-z]+.*"
        let numberRegex = ".*[0-9]+.*"
        let specialCharRegex = ".*[!@#$%^&*(),.?\":{}|<>]+.*"
        
        let capitalLetterTest = NSPredicate(format: "SELF MATCHES %@", capitalLetterRegex)
        let smallLetterTest = NSPredicate(format: "SELF MATCHES %@", smallLetterRegex)
        let numberTest = NSPredicate(format: "SELF MATCHES %@", numberRegex)
        let specialCharTest = NSPredicate(format: "SELF MATCHES %@", specialCharRegex)
        
        return password.count >= 8 &&
               capitalLetterTest.evaluate(with: password) &&
               smallLetterTest.evaluate(with: password) &&
               numberTest.evaluate(with: password) &&
               specialCharTest.evaluate(with: password)
    }

    func signUp(name: String, email: String, password: String) {
        if !validatePassword(password) {
            showAlert(message: "Password must be at least 8 characters long and include at least one capital letter, one small letter, one number, and one special character.")
            return
        }
        showLoading()
        Task {
            do {
                // Use the existing signUp method from SupabaseDataController
                let userData = try await SupabaseDataController.shared.signUp(
                    name: name,
                    email: email,
                    password: password
                )
                
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoading()
                    // Switch to questionnaire after successful signup
                    let storyBoard = UIStoryboard(name: "Questionnaire", bundle: nil)
                    if let questionnaireVC = storyBoard.instantiateViewController(withIdentifier: "NameAndAgeVC") as? QuestionnaireViewController {
                        questionnaireVC.getEmail(email: email)
                        questionnaireVC.modalPresentationStyle = .fullScreen
                        self?.navigationController?.pushViewController(questionnaireVC, animated: true)
                    }
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoading()
                    self?.showAlert(message: "Sign up failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func initiateOTPSignup(name: String, email: String, password: String) {
        if !validatePassword(password) {
            showAlert(message: "Password must be at least 8 characters long and include at least one capital letter, one small letter, one number, and one special character.")
            return
        }
        showLoading()
        Task {
            do {
                // Start OTP verification process
                try await SupabaseDataController.shared.initiateSignup(name: name, email: email, password: password)
                
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoading()
                    self?.showOTPVerification(email: email, type: .signup)
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoading()
                    if let supabaseError = error as? SupabaseError {
                        self?.showAlert(message: supabaseError.localizedDescription ?? "Signup failed")
                    } else {
                        self?.showAlert(message: "Signup failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    private func showOTPVerification(email: String, type: OTPType) {
        let otpView = OTPVerificationView(
            email: email,
            otpType: type,
            onVerificationSuccess: { [weak self] in
                self?.handleOTPSuccess(type: type, email: email)
            }
        )
        
        let hostingController = UIHostingController(rootView: otpView)
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true)
    }
    
    private func handleOTPSuccess(type: OTPType, email: String) {
        Task {
            do {
                switch type {
                case .signup:
                    _ = try await SupabaseDataController.shared.completeSignup()
                    DispatchQueue.main.async { [weak self] in
                        self?.dismiss(animated: true) {
                            // Switch to questionnaire after successful signup
                            let storyBoard = UIStoryboard(name: "Questionnaire", bundle: nil)
                            if let questionnaireVC = storyBoard.instantiateViewController(withIdentifier: "NameAndAgeVC") as? QuestionnaireViewController {
                                questionnaireVC.getEmail(email: email)
                                questionnaireVC.modalPresentationStyle = .fullScreen
                                self?.navigationController?.pushViewController(questionnaireVC, animated: true)
                            }
                        }
                    }
                case .login:
                    // Handle login completion if needed
                    break
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.dismiss(animated: true) {
                        self?.showAlert(message: "Verification failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
