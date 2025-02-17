//
//  NewWordReportViewController.swift
//  LeoLingo
//
//  Created by IOS on 11/02/25.
//

import UIKit

class NewWordReportViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var filterButton: UIButton!
    
    @IBOutlet var wordTypeButtons: [UIButton]!
    
    @IBOutlet weak var wordCollectionView: UICollectionView!
    
    @IBOutlet weak var levelAverageAccuracy: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wordCollectionView.delegate = self
        wordCollectionView.dataSource = self

       
    }
    
   
    @IBAction func wordTypeSelected(_ sender: UIButton) {
        sender.tintColor = UIColor(red: 225/255, green: 168/255, blue: 63/255, alpha: 1.0)
        sender.setTitleColor(.white, for: .normal)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordCell", for: indexPath) as? WordReportCollectionViewCell ?? <#default value#>
                
                
                
                
                

                return cell
            }
    }


//extension newWordReportViewController: UICollectionViewDataSource, UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return wordsData.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordCell", for: indexPath) as! WordCell
//        
//        let wordItem = wordsData[indexPath.row]
//        
//        cell.wordLabel.text = wordItem.word
//        cell.attemptsLabel.text = "Attempts \(wordItem.attempts)/5"
//        cell.progressView.progress = wordItem.accuracy
//
//        if wordItem.accuracy < 0.4 {
//            cell.progressView.tintColor = UIColor.red
//        } else {
//            cell.progressView.tintColor = UIColor.green
//        }
//
//        return cell
//    }
//}
