//
//  PopoverViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 21/01/25.
//

import UIKit
import Lottie

class PopoverViewController: UIViewController {

    @IBOutlet var congratsLabel: UILabel!
    private var animationView: LottieAnimationView!
    
    var message: String?
    var animationName: String?
    var onProceed: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        congratsLabel.adjustsFontSizeToFitWidth = true
        if let message = message {
            congratsLabel.text = message
        }
        
        setupAnimationView()
    }
    
    private func setupAnimationView() {
        animationView?.removeFromSuperview()
        
        animationView = LottieAnimationView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 700),
            animationView.heightAnchor.constraint(equalToConstant: 700)
        ])
        
        if let animationName = animationName {
            animationView.animation = LottieAnimation.named(animationName)
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .loop
            animationView.play()
        }
    }
    
    @IBAction func proceedButtonTapped(_ sender: UIButton) {
        dismiss(animated: true) {
            self.onProceed?()
        }
    }

    func configurePopover(message: String, animationName: String) {
        self.message = message
        self.animationName = animationName
    }
}
