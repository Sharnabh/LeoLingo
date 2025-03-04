//
//  SingAlongViewController.swift
//  LeoLingo
//
//  Created by Tarun   on 05/03/25.
//

import UIKit

class SingAlongViewController: UIViewController {
    @IBOutlet var poemScrollView: UIScrollView!
    
    @IBOutlet var titleLabel: UILabel!
    private let poems = Poem.poems
    private var poemCards: [PoemCard] = []
    
    private lazy var backButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        button.backgroundColor = .white
        button.layer.cornerRadius = 30
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.2
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium)
        let image = UIImage(systemName: "chevron.left", withConfiguration: symbolConfig)?
            .withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        setupPoemCards()
        titleLabel.layer.cornerRadius = 21
        titleLabel.layer.masksToBounds = true
    }
    
    private func setupBackButton() {
        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            backButton.widthAnchor.constraint(equalToConstant: 60),
            backButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupPoemCards() {
        let cardWidth: CGFloat = 300
        let cardHeight: CGFloat = 400
        let spacing: CGFloat = 30
        var xOffset: CGFloat = 20
        
        for poem in poems {
            let card = PoemCard(frame: CGRect(x: xOffset, y: 20, width: cardWidth, height: cardHeight))
            card.configure(with: poem)
            card.onPlayTapped = { [weak self] in
                self?.navigateToSingView(with: poem)
            }
            
            poemScrollView.addSubview(card)
            poemCards.append(card)
            
            xOffset += cardWidth + spacing
        }
        
        poemScrollView.contentSize = CGSize(width: xOffset, height: cardHeight + 40)
    }
    
    private func navigateToSingView(with poem: Poem) {
        let storyboard = UIStoryboard(name: "SingAlong", bundle: nil)
        if let singVC = storyboard.instantiateViewController(withIdentifier: "SingViewController") as? SingViewController {
            singVC.poem = poem
            singVC.modalPresentationStyle = .fullScreen
            present(singVC, animated: true)
        }
    }
    
    @objc private func backButtonTapped() {
        if let presentingViewController = self.presentingViewController,
           presentingViewController is FunLearningViewController {
            dismiss(animated: true)
        } else {
            let storyboard = UIStoryboard(name: "FunLearning", bundle: nil)
            if let funLearningVC = storyboard.instantiateViewController(withIdentifier: "FunLearningVC") as? FunLearningViewController {
                funLearningVC.modalPresentationStyle = .fullScreen
                dismiss(animated: true) {
                    UIApplication.shared.windows.first?.rootViewController?.present(funLearningVC, animated: true)
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
