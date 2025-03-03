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
    
    private let synthesizer = AVSpeechSynthesizer()
    private var childName: String = "Joy" // Default name
    
    var greetings: [String] = []
    var emojis = ["👋","🐵"]

    var greetingIndex = 0
    var emojiIndex = 0
    
    static let greetingShownKey = "hasShownVocalCoachGreeting"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        greetLabel.adjustsFontSizeToFitWidth = true
        greetEmojiLabel.adjustsFontSizeToFitWidth = true
        
        headingTitle.layer.cornerRadius = 21
        headingTitle.layer.masksToBounds = true
        
        // Fetch child name and setup greetings
        fetchChildNameAndSetupGreetings()
        
        // Do any additional setup after loading the view.
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.transitionToNextViewController()
        }
    }
    
    private func fetchChildNameAndSetupGreetings() {
        Task {
            do {
                let userData = try await SupabaseDataController.shared.getUser(byPhone: SupabaseDataController.shared.phoneNumber ?? "")
                
                // Update child name from Supabase
                if let name = userData.childName {
                    self.childName = name
                }
                
                // Update greetings with child's name
                DispatchQueue.main.async {
                    self.greetings = ["Hello \(self.childName)!", "I am Mojo"]
                    self.startAnimations()
                }
            } catch {
                print("Error fetching child name: \(error)")
                // Use default greetings if fetch fails
                self.greetings = ["Hello \(self.childName)!", "I am Mojo"]
                self.startAnimations()
            }
        }
    }
    
    func startAnimations() {
        // Schedule label updates
        Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(updateLabels), userInfo: nil, repeats: true)
    }
    
    @objc func updateLabels() {
        // Update greeting label
        greetLabel.text = greetings[greetingIndex]
        pronounceGreeting(greetings[greetingIndex])
        greetingIndex = (greetingIndex + 1) % greetings.count
        
        // Update secondary label
        greetEmojiLabel.text = emojis[emojiIndex]
        emojiIndex = (emojiIndex + 1) % emojis.count
    }
    
    private func pronounceGreeting(_ text: String) {
        // Stop any ongoing speech
        synthesizer.stopSpeaking(at: .immediate)
        
        let utterance = AVSpeechUtterance(string: text)
        
        // Configure voice for kid-friendly speech
        if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_female_en-US_compact") {
            utterance.voice = voice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        
        // Adjust speech parameters for kid-friendly voice
        utterance.rate = 0.5  // Slower rate
        utterance.pitchMultiplier = 1.2  // Slightly higher pitch
        utterance.volume = 1.0
        
        // Add slight delay before speaking
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.synthesizer.speak(utterance)
        }
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop any ongoing speech when view disappears
        synthesizer.stopSpeaking(at: .immediate)
    }
}
