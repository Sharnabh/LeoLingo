//
//  WordReportHeaderCollectionReusableView.swift
//  LeoLingo
//
//  Created by Sharnabh on 18/01/25.
//

import UIKit

protocol WordReportHeaderViewDelegate: AnyObject {
    func didTapAllButton()
    func didTapFilterButton(_ filterSettings: FilterSettings)
}

class WordReportHeaderCollectionReusableView: UICollectionReusableView {
    
    static let identifier = "WordReportViewHeader"
    
    weak var delegate: WordReportHeaderViewDelegate?
        
    let allButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("All", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.setTitleColor(UIColor(red: 139/255, green: 89/255, blue: 65/255, alpha: 1), for: .normal)
        return button
    }()
    let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "line.3.horizontal.decrease"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.setTitleColor(UIColor(red: 139/255, green: 89/255, blue: 65/255, alpha: 1), for: .normal)
        return button
    }()
    
// Filter Menu
    private let filterMenuView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.isHidden = true
        return view
    }()
    
    let isPassedSwitch = UISwitch()
    let isPracticedSwitch = UISwitch()
    let accuracySlider = UISlider()
    let accuracyFilterSwitch = UISwitch()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
        setupFilterMenu()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
        setupFilterMenu()
    }
    
    private func setupButton() {
        
        allButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(allButton)
        let allButtonConstraints = [
            allButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            allButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        ]
        NSLayoutConstraint.activate(allButtonConstraints)
        allButton.addTarget(self, action: #selector(allButtonTapped), for: .touchUpInside)
        
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(filterButton)
        let filterButtonConstraints  = [
            filterButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            filterButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10)
        ]
        NSLayoutConstraint.activate(filterButtonConstraints)
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        
    }
    
    private func setupFilterMenu() {
        
        filterMenuView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(filterMenuView)
        
        let filterMenuConstraints = [
            filterMenuView.topAnchor.constraint(equalTo: filterButton.bottomAnchor, constant: 8),
            filterMenuView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            filterMenuView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            filterMenuView.heightAnchor.constraint(equalToConstant: 150)
        ]
        NSLayoutConstraint.activate(filterMenuConstraints)
        
        // Add UI elements to the filter menu
        let isPassedLabel = UILabel()
        isPassedLabel.text = "Is Passed"
        isPassedLabel.font = UIFont.systemFont(ofSize: 16)
        
        let isPracticedLabel = UILabel()
        isPracticedLabel.text = "Is Practiced"
        isPracticedLabel.font = UIFont.systemFont(ofSize: 16)
        
        let accuracySliderLabel = UILabel()
        accuracySliderLabel.text = "Accuracy Filter"
        accuracySliderLabel.font = UIFont.systemFont(ofSize: 16)
        
        let stackView = UIStackView(arrangedSubviews: [
            createFilterRow(label: isPassedLabel, switchControl: isPassedSwitch),
            createFilterRow(label: isPracticedLabel, switchControl: isPracticedSwitch),
            createFilterRow(label: accuracySliderLabel, switchControl: accuracyFilterSwitch),
            accuracySlider
        ])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        filterMenuView.addSubview(stackView)
        filterMenuView.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: filterMenuView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: filterMenuView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: filterMenuView.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: filterMenuView.bottomAnchor, constant: -10)
        ])
        
        isPassedSwitch.addTarget(self, action: #selector(didTogglePassedSwitch(_:)), for: .valueChanged)
        isPracticedSwitch.addTarget(self, action: #selector(didTogglePracticedSwitch(_:)), for: .valueChanged)
        accuracySlider.addTarget(self, action: #selector(didChangeAccuracySlider(_:)), for: .valueChanged)
    }
    
    private func createFilterRow(label: UILabel, switchControl: UISwitch) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [label, switchControl])
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }
    
    @objc private func allButtonTapped(){
        self.delegate?.didTapAllButton()
    }
    
    @objc private func filterButtonTapped() {
        // Toggle the visibility of the filter menu
        filterMenuView.isHidden.toggle()
        
        // If filter menu is being shown, update its state (optional)
        if !filterMenuView.isHidden {
            print("Filter menu is displayed.")
        }
        
        // Pass the current filter settings to the delegate (optional, for immediate updates)
        let filterSettings = FilterSettings(
            isPassed: isPassedSwitch.isOn,
            isPracticed: isPracticedSwitch.isOn,
            accuracyFilterEnabled: accuracyFilterSwitch.isOn,
            accuracyValue: Int(accuracySlider.value)
        )
        delegate?.didTapFilterButton(filterSettings)
    }

    @objc private func didTogglePassedSwitch(_ sender: UISwitch) {
        print("Is Passed Switch: \(sender.isOn)")
        // Update logic or delegate callback
    }

    @objc private func didTogglePracticedSwitch(_ sender: UISwitch) {
        print("Is Practiced Switch: \(sender.isOn)")
        // Update logic or delegate callback
    }

    @objc private func didChangeAccuracySlider(_ sender: UISlider) {
        print("Accuracy Slider Value: \(Int(sender.value))")
        // Update logic or delegate callback
    }
    
}
