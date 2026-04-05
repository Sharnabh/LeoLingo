import UIKit

class ParentModeTabBarController: UITabBarController {

    private lazy var sidebarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.white.withAlphaComponent(0.77)
        button.layer.cornerRadius = 30
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowRadius = 2
        button.layer.shadowOpacity = 0.2

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: "sidebar.left", withConfiguration: symbolConfig)?
            .withTintColor(UIColor(named: "AccentColor") ?? .systemGreen, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)

        button.addTarget(self, action: #selector(handleSidebarToggle(_:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSidebarButton()
    }

    private func setupSidebarButton() {
        view.addSubview(sidebarButton)
        NSLayoutConstraint.activate([
            sidebarButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            sidebarButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            sidebarButton.widthAnchor.constraint(equalToConstant: 60),
            sidebarButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(sidebarButton)
    }

    @objc private func handleSidebarToggle(_ sender: UIButton) {
        if let splitViewController = splitViewController {
            splitViewController.show(.primary)
        }
    }
} 