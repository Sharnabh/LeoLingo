//
//  WordCardView.swift
//  LeoLingo
//
//  Created by Sharnabh on 20/02/25.
//

import SwiftUI

struct WordCardView: View {
    let word: String
    let accuracy: Double  // This is now in decimal form (0.0 to 1.0)
    let attempts: String
    let isSelected: Bool
    
    private let circleColor = Color(hex: "99ECCC43") // #ECCC4399
    
    var body: some View {
        VStack(spacing: 8) {
            // Circular progress indicator
            ZStack {
                Circle()
                    .fill(circleColor)  // Fill the circle with #ECCC4399
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: accuracy/100)  // Use accuracy directly since it's already in decimal
                    .stroke(
                        accuracy == 0 ? Color.gray.opacity(0.3) :
                            accuracy/100 >= 0.7 ? Color.green : Color.red,
                        lineWidth: 4
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                DonutTextView(value: word, size: 80)
                    .foregroundColor(.brown)
            }
            
            Text("Accuracy \(String(format: "%.1f%", accuracy))%")  // Convert to percentage for display
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("Attempts \(attempts)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color(hex: "FCF2C0") : Color.white)
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 10,
                    x: 0,
                    y: 4
                )
        )
        .padding(.horizontal, 4) // Add padding to prevent shadow clipping
        .padding(.vertical, 4)
    }
}

struct DonutTextView: View {
    let value: String
    let size: CGFloat
    
    var body: some View {
        Text(value)
            .font(.system(size: 16, weight: .medium))
            .minimumScaleFactor(0.1)  // Allow text to shrink down to 10% of original size
            .lineLimit(1)
            .frame(width: size * 0.7)  // Constrain width to 70% of donut size
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1).ignoresSafeArea()
        WordCardView(
            word: "Example",
            accuracy: 85,
            attempts: "3",
            isSelected: true
        )
        .padding()
    }
}
