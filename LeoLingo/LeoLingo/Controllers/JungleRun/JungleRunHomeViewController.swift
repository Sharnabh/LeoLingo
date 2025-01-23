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
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "JungleRun", bundle: nil)
        if let vocalCoachVC = storyboard.instantiateViewController(withIdentifier: "JungleRunViewController") as? JungleRunViewController {
            vocalCoachVC.modalPresentationStyle = .fullScreen
            self.present(vocalCoachVC, animated: true, completion: nil)
        }
    }
    

}
