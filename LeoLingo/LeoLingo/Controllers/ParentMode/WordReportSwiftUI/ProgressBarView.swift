//
//  ProgressBarView.swift
//  LeoLingo
//
//  Created by Sharnabh on 20/02/25.
//

import SwiftUI

struct ProgressBarView: View {
    let attempt: Int
    let progress: Double
    let isSelected: Bool
    
    @State private var isPlaying = false
    @State private var animatedProgress: Double = 0
    @State private var displayedPercentage: Int = 0
    
    // Add animation timing properties
    private let animationDuration: Double = 1.0
    
    var body: some View {
        HStack(spacing: 12) {
            // Attempt label
            Text("Attempt \(attempt)")
                .foregroundColor(.brown)
                .font(.system(size: 16, weight: .medium))
            
            // Progress bar with percentage
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background bar
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.7)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * animatedProgress, height: 8)
                    
                    // Percentage marker with animated label
                    ZStack {
                        // Pin/teardrop shape
                        Path { path in
                            let width: CGFloat = 32
                            let height: CGFloat = 44
                            let circleRadius: CGFloat = width/2
                            
                            // Start from the bottom point
                            path.move(to: CGPoint(x: width/2, y: height))
                            
                            // Right curve
                            path.addCurve(
                                to: CGPoint(x: width, y: circleRadius),
                                control1: CGPoint(x: width/2 + 12, y: height - 8),
                                control2: CGPoint(x: width, y: height - 16)
                            )
                            
                            // Top semi-circle
                            path.addArc(
                                center: CGPoint(x: width/2, y: circleRadius),
                                radius: circleRadius,
                                startAngle: .degrees(0),
                                endAngle: .degrees(180),
                                clockwise: true
                            )
                            
                            // Left curve
                            path.addCurve(
                                to: CGPoint(x: width/2, y: height),
                                control1: CGPoint(x: 0, y: height - 16),
                                control2: CGPoint(x: width/2 - 12, y: height - 8)
                            )
                        }
                        .fill(Color.yellow.opacity(0.25))
                        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                        
                        // White circle for percentage
                        Circle()
                            .fill(Color.white)
                            .frame(width: 28, height: 28)
                            .shadow(color: .black.opacity(0.05), radius: 1)
                        
                        // Animated percentage text
                        Text("\(displayedPercentage)%")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.black)
                            .contentTransition(.numericText())
                    }
                    .frame(width: 32, height: 44)
                    .position(x: max(geometry.size.width * animatedProgress, 20),
                             y: -28)
                    .opacity(animatedProgress > 0 ? 1 : 0)
                    .animation(.easeOut(duration: animationDuration), value: animatedProgress)
                }
            }
            .frame(height: 8)
            .padding(.top, 40)
            .padding(.bottom, 16)
            
            // Play button
            Button(action: {
                isPlaying.toggle()
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 24))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isSelected ? Color.gray.opacity(0.1) : Color.clear)
        .cornerRadius(12)
        .onAppear {
            // Reset initial values
            animatedProgress = 0
            displayedPercentage = 0
            
            // Small delay to ensure the view is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Animate both progress and percentage together
                withAnimation(.easeOut(duration: animationDuration)) {
                    animatedProgress = progress
                }
                
                // Animate the counter more smoothly
                let finalPercentage = Int(progress * 100)
                let numberOfSteps = 60
                let stepDuration = animationDuration / Double(numberOfSteps)
                
                for step in 0...numberOfSteps {
                    let percentage = Int(Double(finalPercentage) * Double(step) / Double(numberOfSteps))
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * stepDuration) {
                        displayedPercentage = percentage
                    }
                }
            }
        }
    }
}

// Preview
#Preview {
    VStack(spacing: 16) {
        ProgressBarView(attempt: 1, progress: 0.22, isSelected: true)
        ProgressBarView(attempt: 2, progress: 0.75, isSelected: false)
        ProgressBarView(attempt: 3, progress: 0.5, isSelected: false)
    }
    .padding()
}
