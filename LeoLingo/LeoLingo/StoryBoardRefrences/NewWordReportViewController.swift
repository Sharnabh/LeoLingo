//
//  NewWordReportViewController.swift
//  LeoLingo
//
//  Created by IOS on 11/02/25.
//

import UIKit

class NewWordReportViewController: UIViewController {
    
    @IBOutlet weak var filterButton: UIButton!
    
    @IBOutlet var wordTypeButtons: [UIButton]!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func wordTypeSelected(_ sender: UIButton) {
        sender.tintColor = UIColor(red: 225/255, green: 168/255, blue: 63/255, alpha: 1.0)
        sender.setTitleColor(.white, for: .normal)

        
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
