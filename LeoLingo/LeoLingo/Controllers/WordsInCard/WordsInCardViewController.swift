import UIKit

class WordsInCardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let items = [
        ("Rat", "rat"),
        ("Carrot", "carrot"),
        ("Deer", "deer"),
        ("Rabbit", "rabbit"),
        ("Shirt", "shirt"),
        ("Horse", "horse"),
        ("Earth", "earth"),
        ("Write", "write"),
        ("Correct", "correct")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "CardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CardCell")
        collectionView.register(
            UINib(nibName: "CollectionHeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "HeaderView"
        )

        
        configureFlowLayout()
    }
    
    
    
    private func configureFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.itemSize = CGSize(width: 265, height: 290)
        layout.sectionInset = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        layout.headerReferenceSize = CGSize(width: collectionView.bounds.width, height: 60)
        
        
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
        collectionView.layer.borderColor = UIColor(red: 225/255, green: 168/255, blue: 63/255, alpha: 1.0).cgColor
        collectionView.clipsToBounds = true
        cell.layer.cornerRadius = 21
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.3
        cell.layer.shadowOffset = CGSize(width: 2, height: 2)
        cell.layer.shadowRadius = 4
        return cell
    }
    

}
