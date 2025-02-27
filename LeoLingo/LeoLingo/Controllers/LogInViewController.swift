//
//  LogInViewViewController.swift
//  LeoLingo
//
//  Created by Sharnabh on 10/01/25.
//

import UIKit

class LogInViewController: UIViewController {

    @IBOutlet var logInCollectionView: UICollectionView!
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

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
        if let vocalCoachVC = storyboard.instantiateViewController(withIdentifier: "VocalCoachViewController") as? VocalCoachViewController {
            // ... existing code ...
        }
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
            navigationController?.pushViewController(signUpVC, animated: true)
        }
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
    
    func validateLogin(phone: String, password: String, completion: @escaping (Bool) -> Void) {
        Task {
            do {
                // Use the existing signIn method which handles validation
                let userData = try await SupabaseDataController.shared.signIn(phoneNumber: phone, password: password)
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                print("Login failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
}
