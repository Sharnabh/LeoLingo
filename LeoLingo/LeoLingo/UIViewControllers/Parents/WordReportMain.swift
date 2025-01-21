//
//  ParentModeViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 21/01/25.
//

import UIKit

class WordReportMain: UIViewController {

    @IBOutlet var wordReportView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        wordReportView.layer.borderColor = UIColor(red: 239/255, green: 212/255, blue: 155/255, alpha: 1).cgColor
        wordReportView.layer.borderWidth = 5
        wordReportView.layer.cornerRadius = 20
        wordReportView.clipsToBounds = true
    }
    

}
