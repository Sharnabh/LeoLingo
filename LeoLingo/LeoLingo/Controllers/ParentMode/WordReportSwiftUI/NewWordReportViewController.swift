
import UIKit
import SwiftUI

class NewWordReportViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
    }
    
    // MARK: - Private Methods
    
    private func setupSwiftUIView() {
        // Create and configure SwiftUI view
        let swiftUIView = WordReportView()
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        // Add as child view controller
        addChild(hostingController)
        
        // Configure hosting view
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        
        // Add constraints
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
}
