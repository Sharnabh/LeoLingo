//
//  GreetViewController.swift
//  LeoLingo
//
//  Created by Tarun   on 20/01/25.
//

import UIKit
import AVFoundation

class GreetViewController: UIViewController {
    
    @IBOutlet var greetLabel: UILabel!
    @IBOutlet var greetEmojiLabel: UILabel!
    @IBOutlet weak var headingTitle: UILabel!
    
    var greetings = ["Hello! Joy", "I am Mojo"]
    var emojis = ["👋","🐵"]
    let synthesizer = AVSpeechSynthesizer()

    var greetingIndex = 0
    var emojiIndex = 0
    
    static let greetingShownKey = "hasShownVocalCoachGreeting"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        greetLabel.adjustsFontSizeToFitWidth = true
        greetEmojiLabel.adjustsFontSizeToFitWidth = true
        
        headingTitle.layer.cornerRadius = 21
        headingTitle.layer.masksToBounds = true
        
        // Fetch child's name and update greetings
        Task {
            do {
                if let userId = SupabaseDataController.shared.userId {
                    let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                    DispatchQueue.main.async { [weak self] in
                        self?.greetings = ["Hello \(userData.name)!", "I am Mojo"]
                        self?.startAnimations()
                    }
                }
            } catch {
                print("Error fetching user data: \(error)")
                startAnimations()
            }
        }
        
        // Do any additional setup after loading the view.
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.transitionToNextViewController()
        }
    }
    
    func startAnimations() {
        // Schedule label updates
        Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(updateLabels), userInfo: nil, repeats: true)
        // Initial update
        updateLabels()
    }
    
    @objc func updateLabels() {
        // Update greeting label
        let greeting = greetings[greetingIndex]
        greetLabel.text = greeting
        greetingIndex = (greetingIndex + 1) % greetings.count
        
        // Update secondary label
        greetEmojiLabel.text = emojis[emojiIndex]
        emojiIndex = (emojiIndex + 1) % emojis.count
        
        // Speak the greeting
        let utterance = AVSpeechUtterance(string: greeting)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.2
        utterance.volume = 1.0
        synthesizer.speak(utterance)
    }
    
    func transitionToNextViewController() {
        let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
        if let vocalCoachVC = storyboard.instantiateViewController(withIdentifier: "VocalCoachViewController") as? VocalCoachViewController {
            vocalCoachVC.modalPresentationStyle = .fullScreen
            // Present the VocalCoachVC and dismiss self
            if let presentingVC = self.presentingViewController {
                self.dismiss(animated: false) {
                    presentingVC.present(vocalCoachVC, animated: true)
                }
            }
        }
    }
    
    @objc private func dismissGreeting() {
        dismiss(animated: true)
    }
    
}
