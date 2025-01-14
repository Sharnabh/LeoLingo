//
//  WordSelectionViewController.swift
//  LeoLingo
//
//  Created by Sharnabh on 12/01/25.
//

import UIKit

class WordSelectionViewController: UIViewController {
    
    var letters: [String] = ["A", "B", "C", "D"]
    let letterAndWord: [String: [String]] = [
        "A": ["Apple", "Ant", "Anchor"],
        "B": ["Ball", "Baby", "Tub"],
        "C": ["Cat", "Car", "Candle"],
        "D": ["Dog", "Doll", "Desk"],
        "E": ["Elephant", "Egg", "Engine"],
        "F": ["Fish", "Fan", "Frog"],
        "G": ["Goat", "Giraffe", "Glass"],
        "H": ["Hat", "House", "Horse"],
        "I": ["Ice", "Igloo", "Ink"],
        "J": ["Jug", "Joker", "Jacket"]
    ]
    var keyLetters: [String] {
        return letterAndWord.keys.sorted()
    }
    
    var selectedItems: [String: String] = [:]


    @IBOutlet var searchedWordCollectionView: UICollectionView!
    @IBOutlet var searchBar: UITextField!
    @IBOutlet var selectedWordCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let searchedWordNib = UINib(nibName: "LetterSearchedCollectionViewCell", bundle: nil)
        searchedWordCollectionView.register(searchedWordNib, forCellWithReuseIdentifier: "LetterSearchedCollectionViewCell")
        searchedWordCollectionView.setCollectionViewLayout(searchedWordLayout(), animated: true)
        
        let selectedWordNib = UINib(nibName: "SoundSelectedCollectionViewCell", bundle: nil)
        selectedWordCollectionView.register(selectedWordNib, forCellWithReuseIdentifier: "SoundSelectedCollectionViewCell")
        selectedWordCollectionView.setCollectionViewLayout(selectedWordLayout(), animated: true)
        selectedWordCollectionView.allowsMultipleSelection = true
        
        searchedWordCollectionView.delegate = self
        searchedWordCollectionView.dataSource = self
        
        selectedWordCollectionView.delegate = self
        selectedWordCollectionView.dataSource = self
        
        searchBar.delegate  = self
    }

}

extension WordSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func searchedWordLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.33))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 4)
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func selectedWordLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(20)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case searchedWordCollectionView:
            return letters.count
        case selectedWordCollectionView:
            return letterAndWord.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView{
        case searchedWordCollectionView:
            let cell = searchedWordCollectionView.dequeueReusableCell(withReuseIdentifier: "LetterSearchedCollectionViewCell", for: indexPath) as! LetterSearchedCollectionViewCell
            let word = letters[indexPath.item]
            cell.configureCell(with: word, at: indexPath)
            cell.delegate = self
            cell.layer.cornerRadius = 15
            return cell
            
        case selectedWordCollectionView:
            let cell = selectedWordCollectionView.dequeueReusableCell(withReuseIdentifier: "SoundSelectedCollectionViewCell", for: indexPath) as! SoundSelectedCollectionViewCell
            let letter = keyLetters[indexPath.item]
            let words = letterAndWord[letter] ?? []
            cell.configureCell(with: letter, words: words)
            cell.layer.cornerRadius = 10
            cell.layer.borderWidth = 1
            cell.layer.borderColor = CGColor(red: 146/255, green: 146/255, blue: 146/255, alpha: 1)
            return cell
            
        default:
            let cell = searchedWordCollectionView.dequeueReusableCell(withReuseIdentifier: "LetterSearchedCollectionViewCell", for: indexPath) as! LetterSearchedCollectionViewCell
            let word = letters[indexPath.item]
            cell.configureCell(with: word, at: indexPath)
            cell.delegate = self
            cell.layer.cornerRadius = 15
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = selectedWordCollectionView.dequeueReusableCell(withReuseIdentifier: "SoundSelectedCollectionViewCell", for: indexPath) as! SoundSelectedCollectionViewCell
        let letter = cell.letterLabel.text
        let word = cell.wordLabel.text
        selectedItems[letter!] = word
        
        cell.backgroundColor = UIColor(red: 201/255, green: 233/255, blue: 188/255, alpha: 1)
        cell.layer.borderWidth = 0
        cell.wordLabel.textColor = UIColor(red: 104/255, green: 196/255, blue: 28/255, alpha: 1)
        cell.letterLabel.backgroundColor = UIColor(red: 135/255, green: 228/255, blue: 43/255, alpha: 1)
        
        print(selectedItems)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = selectedWordCollectionView.dequeueReusableCell(withReuseIdentifier: "SoundSelectedCollectionViewCell", for: indexPath) as! SoundSelectedCollectionViewCell
        let letter = cell.letterLabel.text
        selectedItems.removeValue(forKey: letter!)
        
        cell.backgroundColor = UIColor(red: 249/255, green: 242/255, blue: 224/255, alpha: 1)
        cell.wordLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        cell.letterLabel.backgroundColor = UIColor(red: 213/255, green: 213/255, blue: 213/255, alpha: 1)
    }
    
}

extension WordSelectionViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let newSound = textField.text,
              !newSound.isEmpty else { return false }
        letters.append(newSound)
        searchedWordCollectionView.insertItems(at: [IndexPath(item: letters.count - 1, section: 0)])
        searchedWordCollectionView.reloadData()
        
        textField.text = ""
        textField.resignFirstResponder()
        
        return true
    }
    
}

extension WordSelectionViewController: LetterSearchedDelegate {
    func didTapRemoveButton(at indexPath: IndexPath) {
        letters.remove(at: indexPath.item)
        searchedWordCollectionView.deleteItems(at: [indexPath])
        searchedWordCollectionView.reloadData()
    }
    
    
}
