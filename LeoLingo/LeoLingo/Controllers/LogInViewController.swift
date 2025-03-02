//
//  LogInViewViewController.swift
//  LeoLingo
//
//  Created by Sharnabh on 10/01/25.
//

import UIKit

class LogInViewController: UIViewController {

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
    
    func checkUserExists(phone: String, completion: @escaping (Bool) -> Void) {
        showLoading()
        Task {
            do {
                let users = try await SupabaseDataController.shared.getAllUsers()
                let exists = users.contains { $0.phone_number == phone }
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
    
    func validateLogin(phone: String, password: String, completion: @escaping (Bool) -> Void) {
        showLoading()
        Task {
            do {
                // Use the existing signIn method which handles validation
                let userData = try await SupabaseDataController.shared.signIn(phoneNumber: phone, password: password)
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoading()
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
}
