//
//  WordReportHeaderCollectionReusableView.swift
//  LeoLingo
//
//  Created by Sharnabh on 18/01/25.
//

import UIKit

protocol WordReportHeaderViewDelegate: AnyObject {
    func didTapAllButton()
    func didTapFilterButton(_ sender: UIButton)
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
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
    
    @objc private func allButtonTapped(){
        self.delegate?.didTapAllButton()
    }
    
    @objc private func filterButtonTapped(_ sender: UIButton) {
        self.delegate?.didTapFilterButton(sender)
    }
    
}
