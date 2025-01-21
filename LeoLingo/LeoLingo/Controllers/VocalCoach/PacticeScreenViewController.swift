//
//  PacticeScreenViewController.swift
//  LeoLingo
//
//  Created by Tarun   on 20/01/25.
//

import UIKit
struct VoacalCoachData {
    var wordName: String
    var wordImage: String
    var direction: String
}
let mojoData: [VoacalCoachData] = [VoacalCoachData(wordName: "Rabbit", wordImage: "bunny", direction: "This is \(VocalCoachData.wordName) Say \(VoacalCoachData.wordName)"),
                                   VoacalCoachData(wordName: "Cat", wordImage: "cat", direction: "This is \(VocalCoachData.wordName) Say \(VoacalCoachData.wordName)"),
                                   VoacalCoachData(wordName: "Dog", wordImage: "dog", direction: "This is \(VocalCoachData.wordName) Say \(VoacalCoachData.wordName)"),
                                   VoacalCoachData(wordName: "Elephant", wordImage: "elephant", direction: "This is \(VocalCoachData.wordName) Say \(VoacalCoachData.wordName)"),
                                   VoacalCoachData(wordName: "Bee", wordImage: "bee", direction: "This is \(VocalCoachData.wordName) Say \(VoacalCoachData.wordName)")
                                   VoacalCoachData(wordName: "Owl", wordImage: "owl", direction: "This is \(VocalCoachData.wordName) Say \(VoacalCoachData.wordName)"),
                                   
                                  ]
print(VocalCoachData[1])
    
var mojoImageData = ["mojo2","mojoHearing"]
class PacticeScreenViewController: UIViewController {
    @IBOutlet var directionLabel: UILabel!
    
    @IBOutlet var mojoImage: UIImageView!
    @IBOutlet var wordImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        // Do any additional setup after loading the view.
    }
    
    func updateUI() {
           let currentData = mojoData[currentIndex]
           directionLabel.text = ""
           wordImage.image = UIImage(named: currentData.wordImage)
           mojoImage.image = UIImage(named: "mojo2") // Update as needed

           animateWordImage()
           typeEffect(text: currentData.direction, label: directionLabel)
       }

       func animateWordImage() {
           // Anvil effect animation
           wordImage.transform = CGAffineTransform(translationX: 0, y: -500)
           UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
               self.wordImage.transform = .identity
           }, completion: nil)
       }

       func typeEffect(text: String, label: UILabel) {
           label.text = ""
           var characterIndex = 0.0
           for letter in text {
               Timer.scheduledTimer(withTimeInterval: 0.05 * characterIndex, repeats: false) { _ in
                   label.text?.append(letter)
               }
               characterIndex += 1
           }
       }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        currentIndex = (currentIndex + 1) % mojoData.count
                updateUI()
    }
    
}
