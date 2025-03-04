//
//  FlashCardViewController.swift
//  LeoLingo
//
//  Created by Batch - 2 on 28/02/25.
//

import UIKit
import AVFoundation
import Speech
import Combine

class FlashCardViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var heading: UILabel!
    
    @IBOutlet var diamondsLabel: UILabel!
    
    @IBOutlet var speakButton: UIButton!
    
    var diamondScore: Int = 0
    private var cancellables = Set<AnyCancellable>()
    private let synthesizer = AVSpeechSynthesizer()
    private let speechProcessor = SpeechProcessor()
    private var speechSubscription: AnyCancellable?
    
    var selectedIndex: Int? = 0 // Track selected index for zoom effect
//    
//    private lazy var warningLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textAlignment = .center
//        label.numberOfLines = 0
//        label.font = .systemFont(ofSize: 14, weight: .medium)
//        label.textColor = .systemRed
//        label.alpha = 0
//        return label
//    }()
//    
    private var isListening = false

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Welcome to Flashcards")

        setupCollectionViewLayout()
        heading.text = "Body Parts"
        
        diamondsLabel.text = "💎 \(diamondScore)"
        
        setupSpeakButton()
        heading.font = .systemFont(ofSize: 30, weight: .semibold)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.isUserInteractionEnabled = true
        
        let firstNib = UINib(nibName: "FlashCard", bundle: nil)
        collectionView.register(firstNib, forCellWithReuseIdentifier: "FlashCardCell")

        collectionView.isPagingEnabled = false // Paging should be off since we're controlling snapping manually
        collectionView.decelerationRate = .fast // Smooth snapping effect
    }
    
    func setupSpeakButton() {
        speakButton.layer.cornerRadius = speakButton.frame.size.width / 2
        speakButton.clipsToBounds = true
        speakButton.titleLabel?.font = .systemFont(ofSize: 28, weight: .medium)
        
    }
    
    func setupCollectionViewLayout() {
        let layout = SnappingCollectionViewLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 300
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: 350, height: 512)
        
        let screenWidth = UIScreen.main.bounds.width
        let sideInset = (screenWidth - 350) / 2
        layout.sectionInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
        
        collectionView.collectionViewLayout = layout
    }
    
    @IBAction func speakButtonTapped(_ sender: Any) {
//        if isListening {
//                stopListening()
//            } else {
//                guard let selectedIndex = selectedIndex,
//                      selectedIndex < SampleDataController.shared.getCategoriesData().count else { return }
//
//                let selectedCategory = SampleDataController.shared.getCategoriesData()[selectedIndex]
//                
//                // ✅ Ensure a word is selected
//                guard let selectedWordIndex = collectionView.indexPathsForSelectedItems?.first?.item,
//                      selectedWordIndex < selectedCategory.words.count else { return }
//
//                let currentWord = selectedCategory.words[selectedWordIndex]
//
//                // ✅ Ensure wordId is available (Modify AppWord struct if needed)
//                guard let wordId = currentWord.id else {
//                    print("Error: Word ID is missing")
//                    return
//                }
//
//                isListening = true
//                updateSpeakButtonState(isListening: true)
//
//                speechProcessor.startRecording(
//                    word: currentWord.wordTitle,
//                    wordId: wordId,
//                    attemptNumber: (currentWord.record?.attempts ?? 0) + 1
//                )
//
//                // ✅ Listen to spoken text updates
//                speechProcessor.$userSpokenText
//                    .filter { !$0.isEmpty }
//                    .sink { [weak self] spokenText in
//                        guard let self = self else { return }
//
//                        let distance = self.speechProcessor.levenshteinDistance(spokenText.lowercased(), currentWord.wordTitle.lowercased())
//                        let maxLength = max(spokenText.count, currentWord.wordTitle.count)
//                        let accuracy = max(0, 100.0 - (Double(distance) / Double(maxLength)) * 100.0)
//
//                        DispatchQueue.main.async {
//                            if accuracy >= 70.0 {
//                                self.diamondScore += 1  // ✅ Increase diamond score
//                                self.diamondsLabel.text = "💎 \(self.diamondScore)"  // ✅ Update UI
//                            }
//                            self.stopListening()
//                        }
//                    }
//                    .store(in: &cancellables)
//            }
        
    }
    private func stopListening() {
            isListening = false
            updateSpeakButtonState(isListening: false)
            speechProcessor.stopRecording()
        }
        
        private func updateSpeakButtonState(isListening: Bool) {
            speakButton.backgroundColor = isListening ? .red : .systemBlue
        }
    
}

extension FlashCardViewController: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let selectedIndex = selectedIndex else { return 0 }
        return SampleDataController.shared.countWordsInCategory(at: selectedIndex)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlashCardCell", for: indexPath) as! FlashCardCollectionViewCell
        cell.layer.cornerRadius = 21
        cell.backgroundColor = .clear
        cell.isUserInteractionEnabled = true
        cell.contentView.isUserInteractionEnabled = true

        if let selectedIndex = selectedIndex {
            cell.configureCell(categoryIndex: selectedIndex, wordIndex: indexPath.item)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? FlashCardCollectionViewCell {
            cell.animateTapDown()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? FlashCardCollectionViewCell {
            cell.animateTapUp()
        }
    }

    // ✅ Speak word when a flashcard is tapped
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? FlashCardCollectionViewCell {
            if let wordTitle = cell.title.text {
                cell.speakWord(wordTitle) // Call speakWord function in the cell
            }
        }
    }

    // MARK: - Snapping & Instant Zoom Effect
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scaleVisibleCells()
    }

    private func scaleVisibleCells() {
        let centerPoint = view.convert(collectionView.center, to: collectionView)
        
        for cell in collectionView.visibleCells {
            let indexPath = collectionView.indexPath(for: cell)!
            let cellCenter = collectionView.layoutAttributesForItem(at: indexPath)?.frame.midX ?? 0
            let distance = abs(centerPoint.x - cellCenter)
        
            let scale: CGFloat = distance < 50 ? 1 : 0.75  // Center item = 1.1x, Side items = 0.85x
            
            UIView.animate(withDuration: 0.2) {
                cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }
    
    
    
}
