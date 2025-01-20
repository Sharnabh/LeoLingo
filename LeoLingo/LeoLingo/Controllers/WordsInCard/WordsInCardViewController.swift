import UIKit

class WordsInCardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet var containerView: UIView!
    
    let items = [
        ("Rat", "image1"),
        ("Carrot", "image1"),
        ("Arm", "image1"),
        ("Deer", "image1"),
        ("Rabbit", "image1"),
        ("Shirt", "image1"),
        ("Horse", "image1"),
        ("Earth", "image1")
    ]
    
    override func viewDidLoad() {
           super.viewDidLoad()
           containerView.layer.cornerRadius = 21
           containerView.layer.masksToBounds = true
           containerView.layer.borderWidth = 5
           containerView.layer.borderColor = UIColor.systemOrange.cgColor
           
           collectionView.dataSource = self
           collectionView.delegate = self
           collectionView.register(UINib(nibName: "CardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CardCell")
        collectionView.setCollectionViewLayout(createCompositionalLayout(), animated: true)
       }
       
    private func createCompositionalLayout() -> UICollectionViewLayout {
           let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
           )
           let item = NSCollectionLayoutItem(layoutSize: itemSize)
           
           let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
           )
           let group = NSCollectionLayoutGroup.horizontal(
               layoutSize: groupSize,
               subitems: [item]
           )
           group.interItemSpacing = .fixed(10)
           
           let section = NSCollectionLayoutSection(group: group)
           section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        section.orthogonalScrollingBehavior = .groupPagingCentered
           
           return UICollectionViewCompositionalLayout(section: section)
       }
       
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return items.count
       }
       
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCollectionViewCell
           let (name, imageName) = items[indexPath.item]
           cell.configure(name: name, imageName: imageName)
           
           cell.layer.cornerRadius = 10
           cell.titleLabel.textColor = .black
           
           cell.layer.shadowColor = UIColor.black.cgColor
           cell.layer.shadowOpacity = 0.3
           cell.layer.shadowOffset = CGSize(width: 2, height: 2)
           cell.layer.shadowRadius = 4
           return cell
       }
   }
