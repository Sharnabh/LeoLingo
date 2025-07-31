import SwiftUI

struct BadgeAchievementPopupView: View {
    let badgeTitle: String
    let badgeImage: UIImage?
    
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var glowOpacity: Double = 0
    @State private var rotationAngle: Double = 0
    @State private var confettiCounter = 0
    
    // Animation timings
    private let animationDuration = 0.6
    private let delayBetweenAnimations = 0.2
    private let glowPulseDuration = 1.0
    
    // App Theme Colors
    private let creamBackground = Color(red: 255/255, green: 248/255, blue: 240/255)
    private let greenAccent = Color(red: 76/255, green: 141/255, blue: 95/255)
    private let brownAccent = Color(red: 143/255, green: 91/255, blue: 66/255)
    private let orangeAccent = Color(red: 225/255, green: 168/255, blue: 63/255)
    
    var body: some View {
        ZStack {
            // Liquid glass background overlay
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            creamBackground.opacity(0.3),
                            brownAccent.opacity(0.2),
                            creamBackground.opacity(0.4)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(.ultraThinMaterial)
                .blur(radius: 20)
                .edgesIgnoringSafeArea(.all)
                .opacity(opacity)
            
            // Confetti effect (randomly positioned small shapes)
            ForEach(0..<30, id: \.self) { index in
                ConfettiViewBadges(index: index, counter: confettiCounter)
            }
            
            // Main content
            VStack(spacing: 20) {
                // Congratulations text with app theme gradient
                Text("Achievement Unlocked!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [greenAccent, orangeAccent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.bottom, 5)
                    .opacity(opacity)
                    .shadow(color: brownAccent.opacity(0.3), radius: 2, x: 1, y: 1)
                
                // Badge with glow effect
                ZStack {
                    // Star burst behind the badge
                    ForEach(0..<8) { index in
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [greenAccent, orangeAccent.opacity(0.5)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 100, height: 15)
                            .cornerRadius(5)
                            .rotationEffect(.degrees(Double(index) * 45 + rotationAngle))
                            .opacity(glowOpacity * 0.7)
                    }
                    
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [greenAccent, greenAccent.opacity(0)]),
                                center: .center,
                                startRadius: 10,
                                endRadius: 110
                            )
                        )
                        .frame(width: 220, height: 220)
                        .opacity(glowOpacity)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                    
//                     Circular background with liquid glass effect
//                    Circle()
//                        .fill(
//                            LinearGradient(
//                                gradient: Gradient(colors: [
//                                    creamBackground.opacity(0.9),
//                                    creamBackground.opacity(0.7)
//                                ]),
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            )
//                        )
//                        .background(.ultraThinMaterial)
//                        .frame(width: 140, height: 140)
//                        .shadow(color: greenAccent.opacity(0.7), radius: 15, x: 0, y: 0)
//                        .overlay(
//                            Circle()
//                                .stroke(
//                                    LinearGradient(
//                                        colors: [greenAccent.opacity(0.3), orangeAccent.opacity(0.3)],
//                                        startPoint: .topLeading,
//                                        endPoint: .bottomTrailing
//                                    ),
//                                    lineWidth: 1
//                                )
//                        )
                    
                    // Badge image
                    if let badgeImage = badgeImage {
                        Image(uiImage: badgeImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .shadow(color: brownAccent.opacity(0.2), radius: 3, x: 2, y: 2)
                    } else {
                        Image("Newleo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(greenAccent)
                            .frame(width: 120, height: 120)
                            .shadow(color: brownAccent.opacity(0.2), radius: 3, x: 2, y: 2)
                    }
                }
                .scaleEffect(scale)
                .padding(.vertical, 10)
                
                // Badge title with app theme gradient
                Text(badgeTitle)
                    .font(.system(size: 26, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [greenAccent, orangeAccent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.top, 5)
                    .opacity(opacity)
                    .shadow(color: brownAccent.opacity(0.3), radius: 2, x: 1, y: 1)
                
                // Description text with liquid glass effect
                Text("You've earned a new badge!")
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundColor(brownAccent)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(brownAccent.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .opacity(opacity)
                
                // Dismiss button with liquid glass effect
                Button(action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        opacity = 0
                        scale = 0.5
                    }
                    
                    // Add a callback for when animation is done
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("DismissBadgeAchievement"),
                            object: nil
                        )
                    }
                }) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(
                            LinearGradient(
                                colors: [greenAccent, orangeAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .background(.ultraThinMaterial)
                        .cornerRadius(25)
                        .shadow(color: greenAccent.opacity(0.5), radius: 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.6), lineWidth: 1)
                        )
                }
                .padding(.top, 20)
                .opacity(opacity)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(
                                LinearGradient(
                                    colors: [greenAccent.opacity(0.7), greenAccent.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: greenAccent.opacity(0.3), radius: 25)
            )
            .padding(.horizontal, 40)
            .scaleEffect(scale)
        }
        .onAppear {
            animateIn()
            startConfettiAnimation()
        }
    }
    
    private func animateIn() {
        // Initial appearance animation with a bounce effect
        withAnimation(.spring(response: animationDuration, dampingFraction: 0.6, blendDuration: 0.2)) {
            scale = 1.0
        }
        
        // Fade in elements with a slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeIn(duration: animationDuration)) {
                opacity = 1.0
            }
        }
        
        // Start glow pulsing with a slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(Animation.easeInOut(duration: glowPulseDuration).repeatForever(autoreverses: true)) {
                glowOpacity = 0.8
                isAnimating = true
            }
            
            // Start rotating the star burst
            withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
        
        // Add a small wiggle animation after the main animation
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + 0.2) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.2, blendDuration: 0.2)) {
                scale = 1.05
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    scale = 1.0
                }
            }
        }
    }
    
    private func startConfettiAnimation() {
        // Periodically update the confetti counter to trigger redraws
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.confettiCounter += 1
            
            // Stop the timer when the view is dismissed
            if self.opacity < 0.1 {
                timer.invalidate()
            }
        }
    }
}

// Confetti piece that animates across the screen
struct ConfettiViewBadges: View {
    let index: Int
    let counter: Int
    
    // Random properties for each confetti piece
    private let color: Color
    private let rotation: Double
    private let scale: CGFloat
    private let speed: Double
    private let xOffset: CGFloat
    
    init(index: Int, counter: Int) {
        self.index = index
        self.counter = counter
        
        // Generate random properties with app theme colors
        let colors: [Color] = [
            Color(red: 76/255, green: 141/255, blue: 95/255), // Green accent
            Color(red: 225/255, green: 168/255, blue: 63/255), // Orange accent
            Color(red: 143/255, green: 91/255, blue: 66/255), // Brown accent
            Color(red: 255/255, green: 248/255, blue: 240/255), // Cream
            Color.white,
            Color(red: 76/255, green: 141/255, blue: 95/255).opacity(0.7) // Light green
        ]
        self.color = colors[index % colors.count]
        self.rotation = Double.random(in: 0...360)
        self.scale = CGFloat.random(in: 0.5...1.5)
        self.speed = Double.random(in: 2...5)
        self.xOffset = CGFloat.random(in: -180...180)
    }
    
    var body: some View {
        // Use either circle, rectangle, or star shape
        Group {
            if index % 3 == 0 {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            } else if index % 3 == 1 {
                Rectangle()
                    .fill(color)
                    .frame(width: 8, height: 8)
            } else {
                Text("★")
                    .font(.system(size: 12))
                    .foregroundColor(color)
            }
        }
        .rotationEffect(.degrees(rotation + Double(counter * 2)))
        .scaleEffect(scale)
        .position(
            x: UIScreen.main.bounds.width / 2 + xOffset,
            y: calculateYPosition(counter: counter, speed: speed)
        )
        .opacity(calculateOpacity(counter: counter))
    }
    
    // Helper method to calculate Y position
    private func calculateYPosition(counter: Int, speed: Double) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let counterEffect = CGFloat(counter * Int(speed))
        let moduloValue = counterEffect.truncatingRemainder(dividingBy: screenHeight * 2)
        return screenHeight / 2 - moduloValue + screenHeight
    }
    
    // Helper method to calculate opacity
    private func calculateOpacity(counter: Int) -> Double {
        return 1.0 - (Double(counter) * 0.01).truncatingRemainder(dividingBy: 1.0)
    }
}

#Preview {
    BadgeAchievementPopupView(badgeTitle: "Master Speaker", badgeImage: nil)
}
