//
//  ParentModeViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 21/01/25.
//

import UIKit

class WordReportMain: UIViewController {

    @IBOutlet var wordReportView: UIView!

    private lazy var kidsModeButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 46))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white.withAlphaComponent(0.77)
        button.setTitle("Go to Kids Mode", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 23

        let imageConfig = UIImage.SymbolConfiguration(pointSize: 26)
        let personImage = UIImage(systemName: "person.circle.fill", withConfiguration: imageConfig)
        button.setImage(personImage, for: .normal)
        button.tintColor = .black

        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        button.semanticContentAttribute = .forceRightToLeft

        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowRadius = 2
        button.layer.shadowOpacity = 0.2

        button.addTarget(self, action: #selector(switchToKidsMode), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationItem.rightBarButtonItem = nil
        setupKidsModeButton()
        
        wordReportView.layer.borderColor = UIColor(red: 143/255, green: 91/255, blue: 66/255, alpha: 1).cgColor
        wordReportView.layer.borderWidth = 3
        wordReportView.layer.cornerRadius = 20
        wordReportView.clipsToBounds = true
    }

    private func setupKidsModeButton() {
        view.addSubview(kidsModeButton)
        NSLayoutConstraint.activate([
            kidsModeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            kidsModeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            kidsModeButton.widthAnchor.constraint(equalToConstant: 200),
            kidsModeButton.heightAnchor.constraint(equalToConstant: 46)
        ])
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
