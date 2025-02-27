//
//  ViewController.swift
//  LeoLingo
//
//  Created by Sharnabh on 09/01/25.
//

import UIKit
import AuthenticationServices

class SignUpViewController: UIViewController {

    @IBOutlet var signUpCollectionView: UICollectionView!
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
        let storyBoard = UIStoryboard(name: "Questionnaire", bundle: nil)
        if let destinationVC = storyBoard.instantiateViewController(withIdentifier: "NameAndAgeVC") as? QuestionnaireViewController {
            navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func switchToLoginVC() {
        navigationController?.popViewController(animated: true)
    }
    
    func checkUserExists(phone: String, completion: @escaping (Bool) -> Void) {
        Task {
            do {
                let users = try await SupabaseDataController.shared.getAllUsers()
                let exists = users.contains { $0.phone_number == phone }
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
    
    func signUp(name: String, phone: String, password: String) {
        Task {
            do {
                // Use the existing signUp method from SupabaseDataController
                let userData = try await SupabaseDataController.shared.signUp(
                    name: name,
                    phoneNumber: phone,
                    password: password
                )
                
                DispatchQueue.main.async { [weak self] in
                    self?.showAlert(message: "Sign up successful!")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        let vc = QuestionnaireViewController()
                        vc.getPhoneNumber(phone: phone)
                        self?.switchToQuestionnaireVC()
                    }
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.showAlert(message: "Sign up failed: \(error.localizedDescription)")
                }
            }
        }
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appleButton = ASAuthorizationAppleIDButton()
        appleButton.frame = CGRect(x: 50, y: 400, width: 280, height: 50)
        appleButton.addTarget(self, action: #selector(handleAppleSignIn), for: .touchUpInside)
        view.addSubview(appleButton)
    }
    
    @objc func handleAppleSignIn() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

extension ViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userID = appleIDCredential.user
            let email = appleIDCredential.email ?? "No Email"
            let fullName = appleIDCredential.fullName?.givenName ?? "No Name"
            
            print("Apple Sign-In Successful: \(userID), \(email), \(fullName)")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Sign-In Failed: \(error.localizedDescription)")
    }
}

extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

