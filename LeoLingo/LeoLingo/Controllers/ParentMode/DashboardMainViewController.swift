//
//  BadgesMainViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 22/01/25.
//

import UIKit

class DashboardMainViewController: UIViewController {

    @IBOutlet var dashbaordView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create custom Kids Mode button
        let customButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 46))
        customButton.backgroundColor = .white.withAlphaComponent(0.77)
        customButton.setTitle("Go to Kids Mode", for: .normal)
        customButton.setTitleColor(.black, for: .normal)
        customButton.layer.cornerRadius = 23 // Half of height for capsule shape
        
        // Configure image
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 26)
        let personImage = UIImage(systemName: "person.circle.fill", withConfiguration: imageConfig)
        customButton.setImage(personImage, for: .normal)
        customButton.tintColor = .black
        
        // Set image padding and position
        customButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        customButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        customButton.semanticContentAttribute = .forceRightToLeft // Image on right
        
        // Add shadow
        customButton.layer.shadowColor = UIColor.black.cgColor
        customButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        customButton.layer.shadowRadius = 2
        customButton.layer.shadowOpacity = 0.2
        
        customButton.addTarget(self, action: #selector(switchToKidsMode), for: .touchUpInside)
        
        // Create bar button item with custom button
        let customBarButton = UIBarButtonItem(customView: customButton)
        navigationItem.rightBarButtonItem = customBarButton

        dashbaordView.backgroundColor = .none
        dashbaordView.layer.borderColor = .none
        dashbaordView.layer.borderWidth = 0
    }
    
    @objc private func switchToKidsMode() {
        let alertVC = UIAlertController(title: "Do you want to exit Parent mode", message: nil, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
            if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomePageViewController") as? HomePageViewController {
                homeVC.modalPresentationStyle = .fullScreen
                self.present(homeVC, animated: true, completion: nil)
            }
        }))
        alertVC.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alertVC, animated: true)
    }

    @IBAction func vocalCoachButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
        if let vocalCoachVC = storyboard.instantiateViewController(withIdentifier: "VocalCoachViewController") as? VocalCoachViewController {
            // ... existing code ...
        }
    }
}
