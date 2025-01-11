//
//  ViewController.swift
//  LeoLingo
//
//  Created by Sharnabh on 09/01/25.
//

import UIKit

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
        let destinationVC = QuestionnaireViewController() as UIViewController
        navigationController?.pushViewController(destinationVC, animated: true)
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
        DispatchQueue.main.async {
            let exists = CoreDataManager.shared.findUser(byPhone: phone) != nil
            completion(exists)
        }
    }
    
    func signUp(name: String, phone: String, password: String) {
        // Create new user in Core Data
        let context = CoreDataManager.shared.context
        let newUser = User(context: context)
        newUser.parentName = name
        newUser.phoneNumber = phone
        newUser.password = password
        
        do {
            try context.save()
            showAlert(message: "Sign up successful!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.switchToQuestionnaireVC()
            }
        } catch {
            showAlert(message: "Error creating user: \(error.localizedDescription)")
        }
    }
}
