import SwiftUI

struct MonkeyInstructorView: View {
    let state: MonkeyState
    @State private var monkeyOffset: CGFloat = 0
    @State private var monkeyScale: CGFloat = 1
    @State private var isAnimating = false
    @State private var showSpeechBubble = false
    
    enum MonkeyState {
        case greeting
        case listening
        case happy
        case encouraging
        case thinking
        case speaking(text: String)
        case speakingFact(text: String)
        case speakingFeedback(text: String, isGood: Bool)
    }
    
    var body: some View {
        ZStack {
            // Mojo Image
            Image("Mojo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
            
            // Speech Bubble or Effects based on state
            Group {
                switch state {
                case .greeting:
                    mojoSpeechBubble("Hi! Let's learn together!", isLarge: false)
                case .listening:
                    ZStack {
                        ForEach(0..<3) { i in
                            Circle()
                                .stroke(Color.green.opacity(0.6), lineWidth: 2)
                                .frame(width: 40 + CGFloat(i * 20), height: 40 + CGFloat(i * 20))
                                .scaleEffect(isAnimating ? 1.2 : 0.8)
                                .opacity(isAnimating ? 0 : 1)
                                .animation(
                                    Animation.easeInOut(duration: 1)
                                        .repeatForever()
                                        .delay(Double(i) * 0.2),
                                    value: isAnimating
                                )
                        }
                        Image(systemName: "ear")
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                    }
                    .offset(x: 50, y: -30)
                case .happy:
                    ZStack {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .offset(x: CGFloat.random(in: -50...50),
                                        y: CGFloat.random(in: -50...50))
                                .scaleEffect(isAnimating ? 1.2 : 0.8)
                                .animation(
                                    Animation.easeInOut(duration: 0.5)
                                        .repeatForever()
                                        .delay(Double.random(in: 0...0.5)),
                                    value: isAnimating
                                )
                        }
                    }
                case .encouraging:
                    mojoSpeechBubble("You can do it! Try again!", isLarge: false)
                case .thinking:
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                        .offset(x: 50, y: -30)
                        .scaleEffect(isAnimating ? 1.1 : 0.9)
                        .animation(Animation.easeInOut(duration: 1).repeatForever(), value: isAnimating)
                case .speaking(let text):
                    mojoSpeechBubble(text, isLarge: false)
                case .speakingFact(let text):
                    mojoSpeechBubble("Fun Fact: \(text)", isLarge: true)
                case .speakingFeedback(let text, let isGood):
                    mojoSpeechBubble(text, isLarge: false, isSuccess: isGood)
                }
            }
        }
        .offset(y: monkeyOffset)
        .scaleEffect(monkeyScale)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                monkeyOffset = -10
                monkeyScale = 1.1
                showSpeechBubble = true
            }
            
            withAnimation(Animation.easeInOut(duration: 1).repeatForever()) {
                isAnimating = true
            }
            
            // Bounce animation
            Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    monkeyOffset = -10
                    monkeyScale = 1.1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        monkeyOffset = 0
                        monkeyScale = 1.0
                    }
                }
            }
        }
    }
    
    private func mojoSpeechBubble(_ text: String, isLarge: Bool, isSuccess: Bool = true) -> some View {
        let bubbleColor = isSuccess ? Color.white : Color.white.opacity(0.95)
        let textColor = isSuccess ? Color.black : Color.black.opacity(0.8)
        
        return Text(text)
            .font(.system(size: isLarge ? 16 : 14, weight: .medium))
            .foregroundColor(textColor)
            .padding(12)
            .background(
                ZStack {
                    // Main bubble
                    RoundedRectangle(cornerRadius: 15)
                        .fill(bubbleColor)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    // Bottom triangle for speech bubble
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: -15, y: 15))
                        path.addLine(to: CGPoint(x: 15, y: 15))
                        path.closeSubpath()
                    }
                    .fill(bubbleColor)
                    .frame(width: 30, height: 15)
                    .offset(x: -50, y: isLarge ? 35 : 25)
                }
            )
            .offset(x: 80, y: isLarge ? -60 : -40)
            .scaleEffect(showSpeechBubble ? 1 : 0)
            .opacity(showSpeechBubble ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showSpeechBubble)
    }
} 
