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
    
    @IBOutlet var levelProgress: UIProgressView!
    @IBOutlet var levelView: UIView!
    @IBOutlet var switchModeView: UIView!
    
    @IBOutlet var badgesView: UICollectionView!
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var practicesView: UICollectionView!
    
    
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
          levelView.layer.shadowOpacity = 0.62
          levelView.layer.shadowOffset = CGSize(width: 0, height: 16)  //
          levelView.layer.shadowRadius = 43
          
          
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
          badgesView.layer.shadowOpacity = 0.62
          badgesView.layer.shadowOffset = CGSize(width: 0, height: 1)
          badgesView.layer.shadowRadius = 10
          
          //recent practices
          practicesView.layer.cornerRadius = 21  // Rounded corners
          practicesView.layer.borderWidth = 3    // Border thickness
          practicesView.layer.borderColor = UIColor(red: 78/255, green: 157/255, blue: 50/255, alpha: 1.0).cgColor
          practicesView.clipsToBounds = false  // Clips content to rounded corners

          practicesView.layer.shadowColor = UIColor.black.cgColor
          practicesView.layer.shadowOpacity = 0.62  // 62% opacity
          practicesView.layer.shadowOffset = CGSize(width: 0, height: 1)  // Offset of 16pt downward
          practicesView.layer.shadowRadius = 10  // Blur radius of 43pt
          
          
          //sswitch mode view
          switchModeView.layer.cornerRadius = 25
          switchModeView.layer.opacity = 0.77
          switchModeView.layer.shadowColor = UIColor.black.cgColor
          switchModeView.layer.shadowOpacity = 0.22
          switchModeView.layer.shadowOffset = CGSize(width: 0, height: 0.2)
          switchModeView.layer.shadowRadius = 1
          
          profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
          profileImageView.clipsToBounds = true

      }
     
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
