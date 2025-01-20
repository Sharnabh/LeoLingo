//
//  GreetViewController.swift
//  LeoLingo
//
//  Created by Tarun   on 20/01/25.
//

import UIKit
var greetings = ["Hello! Joy", "I am Mojo"]
var emojis = ["👋","🐵"]

var greetingIndex = 0
var emojiIndex = 0
class GreetViewController: UIViewController {
    @IBOutlet var greetLabel: UILabel!
    
    @IBOutlet var greetEmojiLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            if let nextViewController = storyboard?.instantiateViewController(withIdentifier: "VocalCoachViewController") as? VocalCoachViewController {
                        navigationController?.pushViewController(nextViewController, animated: true)
                    }        }
        
    
}
