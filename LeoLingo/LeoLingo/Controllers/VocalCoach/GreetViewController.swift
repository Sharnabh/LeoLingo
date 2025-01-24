//
//  GreetViewController.swift
//  LeoLingo
//
//  Created by Tarun   on 20/01/25.
//

import UIKit

class GreetViewController: UIViewController {
    
    @IBOutlet var greetLabel: UILabel!
    @IBOutlet var greetEmojiLabel: UILabel!
    @IBOutlet weak var headingTitle: UILabel!
    
    var greetings = ["Hello! Joy", "I am Mojo"]
    var emojis = ["👋","🐵"]

    var greetingIndex = 0
    var emojiIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        greetLabel.adjustsFontSizeToFitWidth = true
        greetEmojiLabel.adjustsFontSizeToFitWidth = true
        
        headingTitle.layer.cornerRadius = 21
        headingTitle.layer.masksToBounds = true
        
        startAnimations()
        // Do any additional setup after loading the view.
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.transitionToNextViewController()
        }
    }
    
    func startAnimations() {
        // Schedule label updates
        Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(updateLabels), userInfo: nil, repeats: true)
    }
    
    @objc func updateLabels() {
        // Update greeting label
        greetLabel.text = greetings[greetingIndex]
        greetingIndex = (greetingIndex + 1) % greetings.count
        
        // Update secondary label
        greetEmojiLabel.text = emojis[emojiIndex]
        emojiIndex = (emojiIndex + 1) % emojis.count
    }
    
    func transitionToNextViewController() {
        // Transition to the next view controller
        let storyboard = UIStoryboard(name: "Tarun", bundle: nil)
        if let nextViewController = storyboard.instantiateViewController(withIdentifier: "VocalCoachNavControl") as? UINavigationController {
            nextViewController.modalPresentationStyle = .fullScreen
            self.present(nextViewController, animated: true, completion: nil)
        }
    }
    
}
