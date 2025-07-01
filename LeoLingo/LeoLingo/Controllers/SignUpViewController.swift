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
            var fullName = "Apple User" // Default fallback
                if let personName = appleIDCredential.fullName {
                    var nameComponents: [String] = []
                    
                    if let givenName = personName.givenName, !givenName.isEmpty {
                        nameComponents.append(givenName)
                    }
                    if let familyName = personName.familyName, !familyName.isEmpty {
                        nameComponents.append(familyName)
                    }
                    
                    if !nameComponents.isEmpty {
                        fullName = nameComponents.joined(separator: " ")
                    }
                }
            let userIdentifier = appleIDCredential.user
            // Check if user exists in Supabase
            self.showLoading()
            Task {
                do {
                    let users = try await SupabaseDataController.shared.getAllUsers()
                    
                    // Check if user exists with the same Apple ID
                    if let existingUser = users.first(where: { $0.apple_id == userIdentifier }) {
                        // Existing user - sign them in using Apple ID and check if they've completed questionnaire
                        _ = try await SupabaseDataController.shared.signInWithApple(appleId: userIdentifier)
                        DispatchQueue.main.async { [weak self] in
                            self?.hideLoading()
                            // Check if user has completed questionnaire
                            if self?.isFirstTimeUser(user: existingUser) == true {
                                // Haven't completed questionnaire - go to questionnaire
                                self?.redirectToQuestionnaire(email: existingUser.email)
                            } else {
                                // Completed questionnaire - go to landing page
                                self?.redirectToLandingPage()
                            }
                        }
                    } else if !email.isEmpty, let existingUserWithEmail = users.first(where: { $0.email == email }) {
                        // User exists with same email but different Apple ID - update and sign in with Apple ID
                        _ = try await SupabaseDataController.shared.updateUserAppleId(userId: existingUserWithEmail.id, appleId: userIdentifier)
                        _ = try await SupabaseDataController.shared.signInWithApple(appleId: userIdentifier)
                        DispatchQueue.main.async { [weak self] in
                            self?.hideLoading()
                            // Check if user has completed questionnaire
                            if self?.isFirstTimeUser(user: existingUserWithEmail) == true {
                                // Haven't completed questionnaire - go to questionnaire
                                self?.redirectToQuestionnaire(email: existingUserWithEmail.email)
                            } else {
                                // Completed questionnaire - go to landing page
                                self?.redirectToLandingPage()
                            }
                        }
                    } else if !email.isEmpty {
                        // First-time user - create new user and go to questionnaire
                        _ = try await SupabaseDataController.shared.signUpWithApple(name: fullName, email: email, appleId: userIdentifier)
                        DispatchQueue.main.async { [weak self] in
                            self?.hideLoading()
                            self?.redirectToQuestionnaire(email: email)
                        }
                    } else {
                        // Email not provided by Apple (subsequent sign-ins) - this shouldn't happen for new users
                        // but if it does, we need to handle it
                        DispatchQueue.main.async { [weak self] in
                            self?.hideLoading()
                            self?.showAlert(message: "Unable to retrieve email from Apple ID. Please try signing in with your email and password instead, or contact support if you're a new user.")
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
        // self.navigationController?.popViewController(animated: true)
        guard let navigationController = self.navigationController else {
            self.dismiss(animated: true)
            return
        }
        
        // Check if there's a view controller to pop back to
        if navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
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

/*
 * MARK: - SignUp Flow Update Summary
 * 
 * This SignUpViewController has been updated to handle first-time vs existing users:
 * 
 * Apple Sign In Flow (authorizationController):
 * 1. Checks if user exists with Apple ID:
 *    - If exists and has completed questionnaire (child_name filled) → Landing Page
 *    - If exists but hasn't completed questionnaire (child_name empty/nil) → Questionnaire
 * 
 * 2. Checks if user exists with same email but different Apple ID:
 *    - Updates Apple ID and follows same logic as above
 * 
 * 3. If user doesn't exist:
 *    - Creates new user → Always goes to Questionnaire (first-time signup)
 *
 * Regular SignUp Flow:
 * - New users always go to Questionnaire after successful signup
 * - OTP signup also goes to Questionnaire after verification
 *
 * The logic uses the child_name field in the User struct to determine if a user
 * has completed the initial questionnaire setup.
 */

// MARK: - Navigation Helper Methods
extension SignUpViewController {
    private func redirectToLandingPage() {
        let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
        if let landingPage = storyboard.instantiateViewController(withIdentifier: "HomePageViewController") as? HomePageViewController {
            landingPage.modalPresentationStyle = .fullScreen
            present(landingPage, animated: true)
        }
    }
    
    private func redirectToQuestionnaire(email: String) {
        let storyBoard = UIStoryboard(name: "Questionnaire", bundle: nil)
        if let questionnaireVC = storyBoard.instantiateViewController(withIdentifier: "NameAndAgeVC") as? QuestionnaireViewController {
            questionnaireVC.getEmail(email: email)
            questionnaireVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(questionnaireVC, animated: true)
        }
    }
    
    // MARK: - User Check Helper Methods
    private func isFirstTimeUser(user: SupabaseDataController.User) -> Bool {
        // Check if user has completed the questionnaire by looking at child_name
        // If child_name is nil or empty, it means they haven't completed the questionnaire
        return user.child_name == nil || user.child_name?.isEmpty == true
    }
}
