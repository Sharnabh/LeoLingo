import UIKit

class WordsInCardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let items = [
        ("Rat", "image1"),
        ("Carrot", "image1"),
        ("Arm", "image1"),
        ("Deer", "image1"),
        ("Rabbit", "image1"),
        ("Shirt", "image1"),
        ("Horse", "image1"),
        ("Earth", "image1"),
        ("Food", "image1")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "CardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CardCell")
        
        configureFlowLayout()
    }
    
    private func configureFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.itemSize = CGSize(width: 265, height: 290)
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
        
        collectionView.layer.borderWidth = 5
        collectionView.layer.borderColor = UIColor.orange.cgColor
        collectionView.layer.cornerRadius = 27
        cell.layer.cornerRadius = 21
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.3
        cell.layer.shadowOffset = CGSize(width: 2, height: 2)
        cell.layer.shadowRadius = 4
        return cell
    }
}
