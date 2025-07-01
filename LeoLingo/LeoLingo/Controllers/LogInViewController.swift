//
//  LogInViewViewController.swift
//  LeoLingo
//
//  Created by Sharnabh on 10/01/25.
//

import UIKit
import SwiftUI
import AuthenticationServices

/*
 * MARK: - Login Flow Update Summary
 * 
 * This LoginViewController has been updated to handle first-time vs existing users:
 * 
 * 1. Apple Sign In Flow (authorizationController):
 *    - Checks if user exists with Apple ID (existing user) → Landing Page
 *    - Checks if user exists with same email but different Apple ID → Update and go to Landing Page
 *    - If user doesn't exist → Create new user and go to Questionnaire
 *
 * 2. Regular Login Flow (validateLogin):
 *    - After successful login, checks if user has completed questionnaire
 *    - Uses child_name field to determine completion (nil/empty = first-time)
 *    - First-time users → Questionnaire
 *    - Existing users → Landing Page
 *
 * 3. OTP Login Flow (handleOTPSuccess):
 *    - For login: Checks user completion status after OTP verification
 *    - For signup: Always goes to Questionnaire (new user)
 *
 * The logic uses the child_name field in the User struct to determine if a user
 * has completed the initial questionnaire setup.
 */

class LogInViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    @IBOutlet var logInCollectionView: UICollectionView!
    private var loadingView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginCollectionViewCell = UINib(nibName: "LogInViewCell", bundle: nil)
        logInCollectionView.register(loginCollectionViewCell, forCellWithReuseIdentifier: "LogInCell")
        
        logInCollectionView.delegate = self
        logInCollectionView.dataSource = self
        
        logInCollectionView.layer.borderWidth = 2
        logInCollectionView.layer.borderColor = CGColor(red: 170/255, green: 102/255, blue: 71/255, alpha: 1)
        logInCollectionView.layer.cornerRadius = 57
        
        logInCollectionView.setCollectionViewLayout(setupLayoutCollectionViewLayout(), animated: true)
        
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
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [ASAuthorization.Scope.fullName, ASAuthorization.Scope.email]
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
                    
                    // Check if user exists with the same Apple ID (existing user)
                    if let existingUser = users.first(where: { $0.apple_id == userIdentifier }) {
                        // Existing user - sign them in using Apple ID and redirect to landing page
                        _ = try await SupabaseDataController.shared.signInWithApple(appleId: userIdentifier)
                        DispatchQueue.main.async { [weak self] in
                            self?.hideLoading()
                            self?.redirectToLandingPage()
                        }
                    } else if let existingUserWithEmail = users.first(where: { $0.email == email && $0.email != "" }) {
                        // User exists with same email but different Apple ID - update and sign in with Apple ID
                        _ = try await SupabaseDataController.shared.updateUserAppleId(userId: existingUserWithEmail.id, appleId: userIdentifier)
                        _ = try await SupabaseDataController.shared.signInWithApple(appleId: userIdentifier)
                        DispatchQueue.main.async { [weak self] in
                            self?.hideLoading()
                            self?.redirectToLandingPage()
                        }
                    } else {
                        // First-time user - create new user and redirect to questionnaire
                        _ = try await SupabaseDataController.shared.signUpWithApple(name: fullName, email: email, appleId: userIdentifier)
                        DispatchQueue.main.async { [weak self] in
                            self?.hideLoading()
                            self?.redirectToQuestionnaire(email: email)
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

extension LogInViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func setupLayoutCollectionViewLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = logInCollectionView.dequeueReusableCell(withReuseIdentifier: "LogInCell", for: indexPath) as! LogInCollectionViewCell
        cell.delegate = self
        return cell
    }
    
    
}

// MARK: - LogInCellDelegate
extension LogInViewController: LogInCellDelegate {
    func switchToLandingPage() {
        let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
        if let landingPage = storyboard.instantiateViewController(withIdentifier: "HomePageViewController") as? HomePageViewController {
            landingPage.modalPresentationStyle = .fullScreen
            present(landingPage, animated: true)
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func switchToSignUpVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signUpVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
            // Ensure we have a navigation controller
            if let navigationController = self.navigationController {
                navigationController.pushViewController(signUpVC, animated: true)
            } else {
                // If no navigation controller, create one and set it as root
                let navController = UINavigationController(rootViewController: signUpVC)
                navController.modalPresentationStyle = .fullScreen
                present(navController, animated: true)
            }
        }
    }
    
    func checkUserExists(email: String, completion: @escaping (Bool) -> Void) {
        showLoading()
        Task {
            do {
                let users = try await SupabaseDataController.shared.getAllUsers()
                let exists = users.contains { $0.email == email }
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoading()
                    completion(exists)
                }
            } catch {
                print("Error checking user: \(error.localizedDescription)")
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoading()
                    completion(false)
                }
            }
        }
    }
    
    func validateLogin(email: String, password: String, completion: @escaping (Bool) -> Void) {
        showLoading()
        Task {
            do {
                // Use the existing signIn method which handles validation
                let userData = try await SupabaseDataController.shared.signIn(email: email, password: password)
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoading()
                    // Check if this is a first-time user or existing user
                    self?.checkIfFirstTimeUser(email: email) { isFirstTime in
                        if isFirstTime {
                            // First-time user - redirect to questionnaire
                            self?.redirectToQuestionnaire(email: email)
                        } else {
                            // Existing user - redirect to landing page
                            self?.redirectToLandingPage()
                        }
                    }
                    completion(true)
                }
            } catch {
                print("Login failed: \(error.localizedDescription)")
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoading()
                    completion(false)
                }
            }
        }
    }
    
    func initiateOTPLogin(email: String, password: String) {
        showLoading()
        Task {
            do {
                // Start OTP verification process
                try await SupabaseDataController.shared.initiateLogin(email: email, password: password)
                
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoading()
                    self?.showOTPVerification(email: email, type: .login)
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoading()
                    if let supabaseError = error as? SupabaseError {
                        self?.showAlert(message: supabaseError.localizedDescription ?? "Login failed")
                    } else {
                        self?.showAlert(message: "Login failed: \(error.localizedDescription)")
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
                self?.handleOTPSuccess(type: type)
            }
        )
        
        let hostingController = UIHostingController(rootView: otpView)
        hostingController.modalPresentationStyle = .fullScreen
        present(hostingController, animated: true)
    }
    
    private func handleOTPSuccess(type: OTPType) {
        Task {
            do {
                switch type {
                case .login:
                    let userData = try await SupabaseDataController.shared.completeLogin()
                    DispatchQueue.main.async { [weak self] in
                        self?.dismiss(animated: true) {
                            // Check if this is a first-time user by looking at user data
                            // If user has completed questionnaire, go to landing page
                            // Otherwise, go to questionnaire
                            self?.checkUserCompletionStatus(userData: userData)
                        }
                    }
                case .signup:
                    // Handle signup completion - new user should go to questionnaire
                    DispatchQueue.main.async { [weak self] in
                        self?.dismiss(animated: true) {
                            // For signup, always redirect to questionnaire
                            if let email = SupabaseDataController.shared.currentUser?.email {
                                self?.redirectToQuestionnaire(email: email)
                            }
                        }
                    }
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
    
    private func checkUserCompletionStatus(userData: Any) {
        // Check if user has completed the initial setup/questionnaire
        Task {
            do {
                let users = try await SupabaseDataController.shared.getAllUsers()
                if let currentUser = users.first(where: { $0.email == SupabaseDataController.shared.currentUser?.email }) {
                    DispatchQueue.main.async { [weak self] in
                        // Check if this is their first login based on questionnaire completion
                        if self?.isFirstTimeLogin(user: currentUser) == true {
                            self?.redirectToQuestionnaire(email: currentUser.email)
                        } else {
                            self?.redirectToLandingPage()
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self?.redirectToLandingPage()
                    }
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.redirectToLandingPage()
                }
            }
        }
    }
    
    private func isFirstTimeLogin(user: SupabaseDataController.User) -> Bool {
        // Check if user has completed the questionnaire by looking at child_name
        // If child_name is nil or empty, it means they haven't completed the questionnaire
        return user.child_name == nil || user.child_name?.isEmpty == true
    }
}

// MARK: - Navigation Helper Methods
extension LogInViewController {
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
            present(questionnaireVC, animated: true)
        }
    }
    
    // MARK: - User Check Helper Methods
    private func checkIfFirstTimeUser(email: String, completion: @escaping (Bool) -> Void) {
        Task {
            do {
                let users = try await SupabaseDataController.shared.getAllUsers()
                if let user = users.first(where: { $0.email == email }) {
                    // Check if user has completed questionnaire (child_name is set)
                    let isFirstTime = user.child_name == nil || user.child_name?.isEmpty == true
                    DispatchQueue.main.async {
                        completion(isFirstTime)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(true) // User doesn't exist, treat as first-time
                    }
                }
            } catch {
                print("Error checking user existence: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(true) // Default to first-time user on error
                }
            }
        }
    }
}
