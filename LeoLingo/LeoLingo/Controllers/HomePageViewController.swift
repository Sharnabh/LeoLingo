//
//  HomePageViewController.swift
//  LeoLingo
//
//  Created by Tarun   on 15/01/25.
//

import UIKit

class HomePageViewController: UIViewController {
    
    @IBOutlet var remainingTimeView: UIView!
    @IBOutlet var timeLeft: UILabel!
    @IBOutlet var timeLeftBar: UIProgressView!
    
    @IBOutlet var practicesView: UIView!
    @IBOutlet var badgesView: UIView!
    @IBOutlet var levelProgress: UIProgressView!
    @IBOutlet var levelView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLevelView()

        // Do any additional setup after loading the view.
    }
    
  
      func updateLevelView() {
          // Corner radius and border
          levelView.layer.cornerRadius = 21
          levelView.layer.borderWidth = 3
          levelView.layer.borderColor = UIColor(red: 78/255, green: 157/255, blue: 50/255, alpha: 1.0).cgColor
          levelView.clipsToBounds = false

          // Drop shadow
          levelView.layer.shadowColor = UIColor.black.cgColor
          levelView.layer.shadowOpacity = 0.6
          levelView.layer.shadowOffset = CGSize(width: 0, height: 10)  //
          levelView.layer.shadowRadius = 20
          
          
          // Level progress
          levelProgress.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
          
          // remaining time
          remainingTimeView.layer.cornerRadius = 25
          remainingTimeView.layer.borderWidth = 3
          remainingTimeView.layer.borderColor = UIColor(red: 222/255, green: 168/255, blue: 62/255, alpha: 1.0).cgColor
          timeLeftBar.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)

          // badges
          badgesView.layer.cornerRadius = 21
          badgesView.layer.borderWidth = 3
          badgesView.layer.borderColor = UIColor(red: 78/255, green: 157/255, blue: 50/255, alpha: 1.0).cgColor
          badgesView.clipsToBounds = false

          badgesView.layer.shadowColor = UIColor.black.cgColor
          badgesView.layer.shadowOpacity = 0.4
          badgesView.layer.shadowOffset = CGSize(width: 0, height: 1)
          badgesView.layer.shadowRadius = 5
          
          //recent practices
          practicesView.layer.cornerRadius = 21  // Rounded corners
          practicesView.layer.borderWidth = 3    // Border thickness
          practicesView.layer.borderColor = UIColor(red: 78/255, green: 157/255, blue: 50/255, alpha: 1.0).cgColor
          practicesView.clipsToBounds = false  // Clips content to rounded corners

          practicesView.layer.shadowColor = UIColor.black.cgColor
          practicesView.layer.shadowOpacity = 0.4  // 62% opacity
          practicesView.layer.shadowOffset = CGSize(width: 0, height: 1)  // Offset of 16pt downward
          practicesView.layer.shadowRadius = 5  // Blur radius of 43pt
          
          
          //switch mode view
//          switchModeView.layer.cornerRadius = 25
//          switchModeView.layer.opacity = 0.77
//          switchModeView.layer.shadowColor = UIColor.black.cgColor
//          switchModeView.layer.shadowOpacity = 0.22
//          switchModeView.layer.shadowOffset = CGSize(width: 0, height: 0.2)
//          switchModeView.layer.shadowRadius = 1
//          
//          profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
//          profileImageView.clipsToBounds = true

      }
     
    @IBAction func kidsModeButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "ParentMode", bundle: nil)
        if let parentHomeVC = storyboard.instantiateViewController(withIdentifier: "ParentModeLockScreen") as? LockScreenViewController {
            parentHomeVC.modalPresentationStyle = .fullScreen
            self.present(parentHomeVC, animated: true, completion: nil)
        }
    }
    @IBAction func vocalCoachButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Tarun", bundle: nil)
        if let vocalCoachVC = storyboard.instantiateViewController(withIdentifier: "VocalCoachGreeting") as? GreetViewController {
            vocalCoachVC.modalPresentationStyle = .fullScreen
            self.present(vocalCoachVC, animated: true, completion: nil)
        }
    }
    @IBAction func funLearningButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "FunLearning", bundle: nil)
        if let funLearningVC = storyboard.instantiateViewController(withIdentifier: "FunLearningVC") as? FunLearningViewController {
            funLearningVC.modalPresentationStyle = .fullScreen
            self.present(funLearningVC, animated: true, completion: nil)
        }
    }
    
}
