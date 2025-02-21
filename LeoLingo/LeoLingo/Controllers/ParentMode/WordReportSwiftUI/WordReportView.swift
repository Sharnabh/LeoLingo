//
//  WordReportView.swift
//  LeoLingo
//
//  Created by Sharnabh on 20/02/25.
//

import SwiftUI

struct WordData: Identifiable {
    let id = UUID()
    let word: String
    let accuracy: Double
}

struct WordReportView: View {
    @State private var selectedWord: Word? = nil
    @State private var shouldReloadProgress: Bool = false
    private let dataController = DataController.shared
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                // Left section with filter and word cards
                VStack {
                    FilterOptionsView(
                        selectedWord: $selectedWord,
                        shouldReloadProgress: $shouldReloadProgress
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemGray6))
                
                Divider()
                    .frame(width: 1)
                    .background(Color.brown)
                
                // Right section with progress details
                ProgressDetailSection(
                    selectedWord: selectedWord,
                    shouldReloadProgress: shouldReloadProgress
                )
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Subviews

private struct ProgressDetailSection: View {
    let selectedWord: Word?
    let shouldReloadProgress: Bool
    private let dataController = DataController.shared
    
    private var averageAccuracy: Double {
        guard let word = selectedWord else { return 0 }
        return word.avgAccuracy
    }
    
    var body: some View {
        VStack {
            // Average accuracy header
            VStack(spacing: 8) {
                Text("\(String(format: "%.1f%", averageAccuracy))%")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.green)
                Text("Average Accuracy")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 32)
            
            Divider()
                .frame(height: 1)
                .background(Color.brown)
            
            // Attempts list
            ScrollView {
                VStack(spacing: 16) {
                    if let word = selectedWord,
                       let record = word.record,
                       let accuracies = record.accuracy,
                       !accuracies.isEmpty {
                        ForEach(Array(accuracies.enumerated()), id: \.offset) { index, accuracy in
                            ProgressBarView(
                                attempt: index + 1,
                                progress: accuracy / 100,
                                isSelected: false
                            )
                            .id("\(index)-\(shouldReloadProgress)")
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                            .animation(.easeInOut(duration: 0.3), value: index)
                        }
                    } else {
                        Text("No attempts recorded")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                .padding()
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.4)
        .background(Color.white)
    }
}

#Preview {
    WordReportView()
}
