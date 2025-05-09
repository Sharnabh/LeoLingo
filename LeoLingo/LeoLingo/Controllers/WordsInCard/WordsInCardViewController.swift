import UIKit

class WordsInCardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet var headingTitle: UILabel!
    
    var selectedItem: String?
    
    let items = [
        ("Wrist", "wrist"),
        ("Lips", "lips"),
        ("Eye", "eye"),
        ("Ear", "ear"),
        ("Thumb", "thumb"),
        ("Finger", "finger"),
        ("Nose", "nose"),
        ("Palm", "palm"),
        ("Leg", "leg")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        headingTitle.layer.cornerRadius = 21
        headingTitle.layer.masksToBounds = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "CardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CardCell")
        configureFlowLayout()
    }
    
    
    
    private func configureFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 25
        layout.minimumInteritemSpacing = 8
        layout.itemSize = CGSize(width: 220, height: 220)
        layout.sectionInset = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        
        collectionView.collectionViewLayout = layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
        let (name, imageName) = items[indexPath.item]
        cell.configure(name: name, imageName: imageName)
        
        collectionView.layer.cornerRadius = 27
        collectionView.layer.borderWidth = 3
        collectionView.layer.borderColor = UIColor(red: 141/255, green: 91/255, blue: 66/255, alpha: 1.0).cgColor
        collectionView.clipsToBounds = true
        cell.layer.cornerRadius = 21
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.3
        cell.layer.shadowOffset = CGSize(width: 2, height: 2)
        cell.layer.shadowRadius = 4
        return cell
    }
    

}
