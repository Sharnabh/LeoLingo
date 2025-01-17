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
        // Title label in the center of the donut chart
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.brown
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
        
        let lineWidth: CGFloat = 10
        let radius = min( bounds.width, bounds.height) / 2 - lineWidth
        
        let centerPoint = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        
//         Background circle
        let backgroundPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: -.pi / 2, endAngle: .pi * 1.5, clockwise: true)
        backgroundLayer.path = backgroundPath.cgPath
        backgroundLayer.strokeColor = UIColor.lightGray.cgColor
        backgroundLayer.lineWidth = lineWidth
        backgroundLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(backgroundLayer)
        
        // Progress circle
        let progressPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: -.pi / 2, endAngle: (-.pi / 2  - .pi * 2 * progress), clockwise: false)
        progressLayer.path = progressPath.cgPath
        progressLayer.strokeColor = color.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        layer.addSublayer(progressLayer)
        
        let innerPath = UIBezierPath(arcCenter: centerPoint, radius: radius - lineWidth, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        innerLayer.path = innerPath.cgPath
        innerLayer.fillColor = UIColor.black.cgColor
        layer.addSublayer(innerLayer)
    }

    
    
}
