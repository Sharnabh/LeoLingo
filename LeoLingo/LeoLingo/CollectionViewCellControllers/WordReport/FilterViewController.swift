//
//  FilterViewController.swift
//  LeoLingo
//
//  Created by Sharnabh on 19/01/25.
//

import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func didApplyFilter(averageAccuracy: Float, isPracticed: Bool, isPassed: Bool)
}

class FilterViewController: UIViewController {

    weak var delegate: FilterViewControllerDelegate?

    private let accuracySlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 50  // Default value
        return slider
    }()

    private let practicedSwitch: UISwitch = {
        let toggle = UISwitch()
        return toggle
    }()

    private let passedSwitch: UISwitch = {
        let toggle = UISwitch()
        return toggle
    }()

    private let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Apply", for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 10

        let stackView = UIStackView(arrangedSubviews: [
            createLabeledView(label: "Avg Accuracy:", control: accuracySlider),
            createLabeledView(label: "Is Practiced:", control: practicedSwitch),
            createLabeledView(label: "Is Passed:", control: passedSwitch),
            applyButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 250)
        ])

        applyButton.addTarget(self, action: #selector(applyFilter), for: .touchUpInside)
    }

    private func createLabeledView(label: String, control: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        let stackView = UIStackView(arrangedSubviews: [labelView, control])
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }

    @objc private func applyFilter() {
        let avgAccuracy = accuracySlider.value
        let isPracticed = practicedSwitch.isOn
        let isPassed = passedSwitch.isOn

        delegate?.didApplyFilter(averageAccuracy: avgAccuracy, isPracticed: isPracticed, isPassed: isPassed)
        dismiss(animated: true)
    }
}

