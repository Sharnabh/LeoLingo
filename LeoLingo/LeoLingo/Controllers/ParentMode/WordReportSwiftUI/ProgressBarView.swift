
import SwiftUI
import AVFoundation

struct ProgressBarView: View {
    let attempt: Int
    let progress: Double
    let isSelected: Bool
    let recordingPath: String?
    
    @StateObject private var audioPlayer = AudioPlayerManager.shared
    @State private var animatedProgress: Double = 0
    @State private var displayedPercentage: Int = 0
    
    // Animation properties
    private let animationDuration: Double = 1.5
    
    var body: some View {
        HStack(spacing: 16) {
            // Attempt label
            Text("Attempt \(attempt)")
                .foregroundColor(Color(red: 135/255, green: 89/255, blue: 65/255))
                .font(.system(size: 20))
            
            // Progress bar with percentage
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background bar
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 12) // Increased height

                    // Determine gradient colors based on percentage
                    let gradientColors: [Color] = displayedPercentage < 30 ? [Color(red: 197/255, green: 99/255, blue: 48/255), Color(red: 225/255, green: 127/255, blue: 63/255)] :
                                                  (displayedPercentage < 70 ? [Color(red: 185/255, green: 120/255, blue: 42/255), Color(red: 234/255, green: 178/255, blue: 53/255)] : [Color(red: 56/255, green: 120/255, blue: 34/255), Color(red: 141/255, green: 197/255, blue: 60/255)])

                    // Progress fill
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * animatedProgress, height: 12) // Increased height
                        .animation(.easeOut(duration: animationDuration), value: animatedProgress)

                    // Percentage marker with animated label
                    ZStack {
                        // Pin/teardrop shape
                        Path { path in
                            let width: CGFloat = 40
                            let height: CGFloat = 50
                            let circleRadius: CGFloat = width / 2

                            path.move(to: CGPoint(x: width / 2, y: height))
                            path.addCurve(
                                to: CGPoint(x: width, y: circleRadius),
                                control1: CGPoint(x: width / 2 + 12, y: height - 8),
                                control2: CGPoint(x: width, y: height - 16)
                            )
                            path.addArc(
                                center: CGPoint(x: width / 2, y: circleRadius),
                                radius: circleRadius,
                                startAngle: .degrees(0),
                                endAngle: .degrees(180),
                                clockwise: true
                            )
                            path.addCurve(
                                to: CGPoint(x: width / 2, y: height),
                                control1: CGPoint(x: 0, y: height - 16),
                                control2: CGPoint(x: width / 2 - 12, y: height - 8)
                            )
                        }
                        .fill(Color(red: 249/255, green: 225/255, blue: 139/255))
                        .shadow(color: .black.opacity(0.4), radius: 2, y: 1)

                        // White circle for percentage
                        Circle()
                            .fill(Color(red: 243/255, green: 244/255, blue: 243/255))
                            .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
                            .frame(width: 32, height: 32)
                            .overlay(
                                // Animated percentage text
                                Text("\(displayedPercentage)%")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.black)
                                    .contentTransition(.numericText())
                            )
                    }
                    .frame(width: 40, height: 50)
                    .position(x: max(geometry.size.width * animatedProgress, 20), y: -25)
                    .opacity(animatedProgress > 0 ? 1 : 0)
                    .animation(.easeOut(duration: animationDuration), value: animatedProgress)
                }
            }
            .frame(height: 0) // Increased container height
            .padding(.top, 50)
            .padding(.bottom, 16)
            
            // Play button with dynamic color and state
            Button(action: {
                if let path = recordingPath {
                    audioPlayer.play(recordingPath: path)
                }
            }) {
                Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .foregroundColor(recordingPath != nil ? .green : .gray.opacity(0.5))
                    .font(.system(size: 24))
            }
            .disabled(recordingPath == nil)
            .opacity(recordingPath != nil ? 1 : 0.5)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12) // Increased container padding
        .background(isSelected ? Color.gray.opacity(0.1) : Color.clear)
        .cornerRadius(14) // Slightly rounded edges
        .onAppear {
            // Reset initial values
            animatedProgress = 0
            displayedPercentage = 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: animationDuration)) {
                    animatedProgress = progress
                }
                
                // Animate the percentage increment
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
        .onDisappear {
            audioPlayer.stop()
        }
    }
}

// Preview
#Preview {
    VStack(spacing: 16) {
        ProgressBarView(attempt: 1, progress: 0.22, isSelected: true, recordingPath: nil)
        ProgressBarView(attempt: 2, progress: 0.75, isSelected: false, recordingPath: "/test/path.m4a")
        ProgressBarView(attempt: 3, progress: 0.5, isSelected: false, recordingPath: nil)
    }
    .padding()
}
