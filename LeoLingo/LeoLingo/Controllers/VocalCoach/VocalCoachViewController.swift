//
//  VocalCoachViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 16/01/25.
//

import UIKit

//dummy
//var 

class VocalCoachViewController: UIViewController {
    @IBOutlet var practiceCardView: UIView!
    
    @IBOutlet var soundCards: UICollectionView!
    @IBOutlet var WordLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    func updatePracticeCardView() {
        
        practiceCardView.layer.cornerRadius = 21
        practiceCardView.layer.borderWidth = 2
        practiceCardView.layer.borderColor = UIColor(red: 222/255, green: 168/255, blue: 62/255, alpha: 1.0).cgColor
        
        practiceCardView.clipsToBounds = false
        
        practiceCardView.layer.shadowColor = UIColor.black.cgColor
        practiceCardView.layer.shadowOpacity = 0.62
        practiceCardView.layer.shadowOffset = CGSize(width: 0, height: 1)
        practiceCardView.layer.shadowRadius = 10
        
              
    }
    private func registerSoundCardCell() {
        soundCards.register(UINib(nibName: "SoundCardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SoundCardCollectionViewCell")
    }
}
extension VocalCoachViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
        
    }

