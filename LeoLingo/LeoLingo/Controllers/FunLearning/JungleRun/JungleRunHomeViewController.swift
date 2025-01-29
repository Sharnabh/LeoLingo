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
    
    
    
    var coinScore: Int = 0
    var diamondScore: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        coinScoreLabel.text = "💰Coins: \(coinScore)"
                diamondScoreLabel.text = "💎 Diamonds: \(diamondScore)"
        coinScoreLabel.textColor = .systemBrown
        diamondScoreLabel.textColor = .systemBrown
        
        let backButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButtonItem
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
