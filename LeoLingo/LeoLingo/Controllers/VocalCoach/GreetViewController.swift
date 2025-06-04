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
    
    private var greetings: [String] = []
    private var tips = [
        "Remember to speak clearly and confidently! 🎯",
        "Take your time with each word. 🌟",
        "Practice makes perfect! ⭐️",
        "Listen carefully before speaking. 👂",
        "Don't worry about mistakes, they help you learn! 🌈"
    ]
    private var emojis = ["👋", "🐵", "🎯", "🌟", "⭐️"]
    private var greetingIndex = 0
    private var emojiIndex = 0
    private var userName: String = "User"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchUserDataAndStartGreeting()
    }
        
    private func setupUI() {
        greetLabel.adjustsFontSizeToFitWidth = true
        greetEmojiLabel.adjustsFontSizeToFitWidth = true
        headingTitle.layer.cornerRadius = 21
        headingTitle.layer.masksToBounds = true
        
        // Add fade in animation
        greetLabel.alpha = 0
        greetEmojiLabel.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.greetLabel.alpha = 1
            self.greetEmojiLabel.alpha = 1
        }
    }
    
    private func fetchUserDataAndStartGreeting() {
        Task {
            do {
                if let userId = SupabaseDataController.shared.userId {
                    let userData = try await SupabaseDataController.shared.getUser(byId: userId)
                    userName = userData.childName ?? "User"
                    
                    // Check if this is the first time or returning user
                    let isFirstTime = !UserDefaults.standard.bool(forKey: "hasSeenGreeting")
                    UserDefaults.standard.set(true, forKey: "hasSeenGreeting")
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.setupGreetings(isFirstTime: isFirstTime)
                        self?.startAnimations()
                        
                        // Schedule transition after 5 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            self?.transitionToNextViewController()
                        }
                    }
                }
            } catch {
                print("Error fetching user data: \(error)")
                setupGreetings(isFirstTime: true)
                startAnimations()
            }
        }
    }
    
    private func setupGreetings(isFirstTime: Bool) {
        if isFirstTime {
            greetings = [
                "Hello \(userName)!",
                "I am Mojo",
                "Let's learn together!"
            ]
        } else {
            let hour = Calendar.current.component(.hour, from: Date())
            let timeBasedGreeting: String
            
            switch hour {
            case 5..<12:
                timeBasedGreeting = "Good morning \(userName)!"
            case 12..<17:
                timeBasedGreeting = "Good afternoon \(userName)!"
            case 17..<21:
                timeBasedGreeting = "Good evening \(userName)!"
            default:
                timeBasedGreeting = "Hi \(userName)!"
            }
            
            greetings = [
                timeBasedGreeting,
                "Ready to practice?",
                tips.randomElement() ?? "Let's get started!"
            ]
        }
    }
    
    private func startAnimations() {
        updateLabels(withSpeech: true)
        
        // Schedule subsequent label updates
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(updateLabelsWithoutSpeech), userInfo: nil, repeats: true)
    }
    
    @objc private func updateLabelsWithoutSpeech() {
        updateLabels(withSpeech: false)
    }
    
    private func updateLabels(withSpeech: Bool) {
        guard greetingIndex < greetings.count else { return }
        
        let greeting = greetings[greetingIndex]
        
        UIView.animate(withDuration: 0.3, animations: {
            self.greetLabel.alpha = 0
            self.greetEmojiLabel.alpha = 0
        }) { _ in
            self.greetLabel.text = greeting
            self.greetEmojiLabel.text = self.emojis[self.emojiIndex]
            
            UIView.animate(withDuration: 0.3) {
                self.greetLabel.alpha = 1
                self.greetEmojiLabel.alpha = 1
            }
        }
        
        if withSpeech {
            VoiceManager.shared.speak(greeting)
        }
        
        greetingIndex = (greetingIndex + 1) % greetings.count
        emojiIndex = (emojiIndex + 1) % emojis.count
    }
    
    private func transitionToNextViewController() {
        let storyboard = UIStoryboard(name: "VocalCoach", bundle: nil)
        if let vocalCoachVC = storyboard.instantiateViewController(withIdentifier: "VocalCoachViewController") as? VocalCoachViewController {
            vocalCoachVC.modalPresentationStyle = .fullScreen
            
            // Ensure we stop any ongoing speech before transitioning
            VoiceManager.shared.stopSpeaking()
            
            // Present the VocalCoachVC and dismiss self
            if let presentingVC = self.presentingViewController {
                self.dismiss(animated: false) {
                    presentingVC.present(vocalCoachVC, animated: true)
                }
            }
        }
    }
}
