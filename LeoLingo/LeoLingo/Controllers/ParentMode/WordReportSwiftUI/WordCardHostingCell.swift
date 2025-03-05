import UIKit
import SwiftUI

class WordCardHostingCell: UICollectionViewCell {
    static let identifier = "WordCardHostingCell"
    
    private var hostingController: UIHostingController<WordCardView>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with word: Word) {
        // Clean up any existing hosting controller
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        
        guard let appWord = DataController.shared.wordData(by: word.id) else { return }
        
        // Create the SwiftUI view
        let wordCardView = WordCardView(
            word: appWord.wordTitle,
            accuracy: word.avgAccuracy,
            attempts: String(word.record?.attempts ?? 0),
            isSelected: false
        )
        
        // Create and setup hosting controller
        let hostingController = UIHostingController(rootView: wordCardView)
        hostingController.view.backgroundColor = .clear
        
        // Add as child of cell's parent view controller
        if let parentViewController = self.parentViewController {
            parentViewController.addChild(hostingController)
        }
        
        // Add and constrain hosted view
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self.parentViewController)
        self.hostingController = hostingController
    }
}

// Helper extension to find parent view controller
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
} 