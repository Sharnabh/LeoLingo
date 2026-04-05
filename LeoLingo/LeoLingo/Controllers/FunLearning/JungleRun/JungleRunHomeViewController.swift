//
//  JungleRunHomeViewController.swift
//  LeoLingo
//
//  Created by Tarun   on 23/01/25.
//

import UIKit

class JungleRunHomeViewController: UIViewController {
    @IBOutlet var coinScoreLabel: UILabel!
    @IBOutlet var diamondScoreLabel: UILabel!
    
    private lazy var backButton: UIButton = {
        let size: CGFloat = 46
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: size, height: size))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = size/2
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 6
        button.layer.shadowOpacity = 0.2
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: "chevron.left", withConfiguration: symbolConfig)?
            .withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .center
        
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var coinScore: Int = 0
    var diamondScore: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        coinScoreLabel.text = "💰Coins: \(coinScore)"
        diamondScoreLabel.text = "💎 Diamonds: \(diamondScore)"
        coinScoreLabel.textColor = .systemBrown
        diamondScoreLabel.textColor = .systemBrown

        navigationItem.leftBarButtonItem = nil
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupBackButton()
    }

    private func setupBackButton() {
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 46),
            backButton.heightAnchor.constraint(equalToConstant: 46)
        ])
    }
    
    func updateScore(coin: Int, diamond: Int) {
        self.coinScore = coin
        self.diamondScore = diamond
    }
    
    @objc private func backButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "JungleRun", bundle: nil)
        if let gameVC = storyboard.instantiateViewController(withIdentifier: "JungleRunViewController") as? JungleRunViewController {
            gameVC.modalPresentationStyle = .fullScreen
            self.present(gameVC, animated: true, completion: nil)
        }
    }
    

}
