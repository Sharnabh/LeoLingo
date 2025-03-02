//
//  ViewController.swift
//  LeoLingo
//
//  Created by Sharnabh on 09/01/25.
//

import UIKit

class SignUpViewController: UIViewController {

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
        showLoading()
        Task {
            do {
                // Use the existing signUp method from SupabaseDataController
                let userData = try await SupabaseDataController.shared.signUp(
                    name: name,
                    phoneNumber: phone,
                    password: password
                )
                
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoading()
                    // Switch to questionnaire after successful signup
                    let storyBoard = UIStoryboard(name: "Questionnaire", bundle: nil)
                    if let questionnaireVC = storyBoard.instantiateViewController(withIdentifier: "NameAndAgeVC") as? QuestionnaireViewController {
                        questionnaireVC.getPhoneNumber(phone: phone)
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
}
