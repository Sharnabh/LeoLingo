//
//  ProgressView.swift
//  LeoLingo
//
//  Created by Batch - 2 on 17/01/25.
//

import UIKit

class ProgressView: UIView {
        
    private let progressLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    private let innerLayer = CAShapeLayer()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupView()
        }
    
    private func setupView() {
        self.backgroundColor = .none
        
        // Title label in the center of the donut chart
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(red: 123/255, green: 67/255, blue: 46/255, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        
        // Constraints to center the label
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configure(title: String, progress: CGFloat, color: UIColor) {
        titleLabel.text = title
        createDonut(progress: progress, color: color)
    }
    
    private func createDonut(progress: CGFloat, color: UIColor) {
        
        let lineWidth: CGFloat = 7
        let radius = min( bounds.width, bounds.height) / 2 - lineWidth
        
        let centerPoint = CGPoint(x: bounds.width / 2, y: bounds.height / 2)

        let innerPath = UIBezierPath(arcCenter: centerPoint, radius: radius + 5, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        innerLayer.path = innerPath.cgPath
        innerLayer.fillColor = CGColor(red: 236/255, green: 204/255, blue: 67/255, alpha: 0.6)
        layer.addSublayer(innerLayer)
        
        // Progress circle
        let progressPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: -.pi / 2, endAngle: (-.pi / 2  - .pi * 2 * progress), clockwise: false)
        progressLayer.path = progressPath.cgPath
        progressLayer.strokeColor = color.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        layer.addSublayer(progressLayer)
        bringSubviewToFront(titleLabel)
    }

    
    
}
