import SwiftUI
import UIKit

// This class bridges UIKit and SwiftUI
class SwiftUIFlashCardConnector {
    // Helper to create a UIViewController from a SwiftUI view
    static func createCategorySelectionViewController() -> UIViewController {
        let swiftUIView = CategorySelectionView()
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }
} 