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
    
    @objc private func backButtonTapped() {
        let storyboard = UIStoryboard(name: "Tarun", bundle: nil)
        if let funLearningVC = storyboard.instantiateViewController(withIdentifier: "HomePageViewController") as? HomePageViewController {
            funLearningVC.modalPresentationStyle = .fullScreen
            present(funLearningVC, animated: true)
        }
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "JungleRun", bundle: nil)
        if let vocalCoachVC = storyboard.instantiateViewController(withIdentifier: "JungleRunViewController") as? JungleRunViewController {
            vocalCoachVC.modalPresentationStyle = .fullScreen
            self.present(vocalCoachVC, animated: true, completion: nil)
        }
    }
    

}
