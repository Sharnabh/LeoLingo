import SwiftUI
import AVFoundation

struct FlashCardView: View {
    let category: FlashCardCategory
    @Environment(\.dismiss) private var dismiss
    
    // View state
    @State private var currentIndex = 0
    @State private var offset = CGSize.zero
    @State private var cardRotation = 0.0
    @State private var isFlipped = false
    @State private var showConfetti = false
    @State private var showStars = false
    
    // Card properties
    private var currentCard: FlashCard { category.cards[currentIndex] }
    private var hasNextCard: Bool { currentIndex < category.cards.count - 1 }
    private var hasPreviousCard: Bool { currentIndex > 0 }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        .white,
                        category.color.opacity(0.6)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Floating bubbles background
                FloatingBubblesView(color: category.color)
                
                VStack(spacing: 20) {
                    // Header with back button and title
                    HStack {
                        BackButton {
                            dismiss()
                        }
                        
                        Spacer()
                        
                        Text(category.name)
                            .font(.system(size: 44, weight: .heavy, design: .rounded))
                            .foregroundColor(category.color)
                            .shadow(color: .white, radius: 2)
                            .shadow(color: .black.opacity(0.3), radius: 4)
                        
                        Spacer()
                        
                        // Invisible view for balance
                        Color.clear.frame(width: 50, height: 50)
                    }
                    .padding(.horizontal)
                    
                    // Card counter
                    CardCounter(current: currentIndex + 1, total: category.cards.count)
                    
                    // Main flashcard
                    ZStack {
                        FlashCardDisplay(
                            word: currentCard.word,
                            image: currentCard.image,
                            color: category.color,
                            isFlipped: isFlipped
                        )
                        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                        .rotation3DEffect(.degrees(cardRotation), axis: (x: 1, y: 0, z: 0))
                        .offset(offset)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    offset = gesture.translation
                                    cardRotation = Double(gesture.translation.height * 0.1)
                                }
                                .onEnded { gesture in
                                    handleSwipe(gesture)
                                }
                        )
                        .onTapGesture {
                            handleCardTap()
                        }
                    }
                    .frame(height: geometry.size.height * 0.6)
                    
                    // Navigation buttons
                    HStack(spacing: 60) {
                        NavigationButton(
                            icon: "arrow.left.circle.fill",
                            isEnabled: hasPreviousCard,
                            action: previousCard
                        )
                        
                        NavigationButton(
                            icon: "speaker.wave.2.fill",
                            isEnabled: true,
                            action: speakWord
                        )
                        
                        NavigationButton(
                            icon: "arrow.right.circle.fill",
                            isEnabled: hasNextCard,
                            action: nextCard
                        )
                    }
                }
                .padding(.vertical)
                
                if showConfetti { ConfettiView() }
                if showStars { StarParticlesView() }
            }
        }
        .statusBar(hidden: true)
        .ignoresSafeArea()
    }
    
    // MARK: - Actions
    
    private func handleSwipe(_ gesture: DragGesture.Value) {
        withAnimation(.spring()) {
            let threshold: CGFloat = 150
            
            if gesture.translation.width < -threshold && hasNextCard {
                nextCard()
            } else if gesture.translation.width > threshold && hasPreviousCard {
                previousCard()
            }
            
            offset = .zero
            cardRotation = 0
        }
    }
    
    private func handleCardTap() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isFlipped.toggle()
            if !isFlipped {
                speakWord()
                showConfetti = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showConfetti = false
                }
            }
        }
    }
    
    private func nextCard() {
        withAnimation(.spring()) {
            currentIndex += 1
            isFlipped = false
        }
    }
    
    private func previousCard() {
        withAnimation(.spring()) {
            currentIndex -= 1
            isFlipped = false
        }
    }
    
    private func speakWord() {
        SwiftUIFlashCardDataManager.shared.speakWord(currentCard.word)
    }
}

// MARK: - Supporting Views

struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.green)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
}

struct CardCounter: View {
    let current: Int
    let total: Int
    
    var body: some View {
        Text("\(current) of \(total)")
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(.white)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.5))
            )
    }
}

struct FlashCardDisplay: View {
    let word: String
    let image: String
    let color: Color
    let isFlipped: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(color, lineWidth: 5)
                )
            
            if isFlipped {
                Text(word)
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                    .multilineTextAlignment(.center)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            } else {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .padding(40)
            }
        }
        .frame(width: 320, height: 400)
    }
}

struct NavigationButton: View {
    let icon: String
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(isEnabled ? .white : .gray)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
    }
}

// MARK: - Animation Views

struct ConfettiView: View {
    @State private var pieces: [ConfettiPiece] = (0..<50).map { _ in ConfettiPiece() }
    
    var body: some View {
        ZStack {
            ForEach(pieces) { piece in
                ConfettiPieceView(piece: piece)
            }
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let position: CGPoint
    let color: Color
    let rotation: Double
    let size: CGFloat
    
    init() {
        position = CGPoint(
            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
            y: CGFloat.random(in: 0...UIScreen.main.bounds.height/2)
        )
        color = [.red, .blue, .green, .yellow, .purple, .orange].randomElement()!
        rotation = Double.random(in: 0...360)
        size = CGFloat.random(in: 5...15)
    }
}

struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    @State private var position: CGPoint
    @State private var rotation: Double
    
    init(piece: ConfettiPiece) {
        self.piece = piece
        _position = State(initialValue: piece.position)
        _rotation = State(initialValue: piece.rotation)
    }
    
    var body: some View {
        Circle()
            .fill(piece.color)
            .frame(width: piece.size, height: piece.size)
            .position(position)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    position.y += 500
                    rotation += 360
                }
            }
    }
}

struct StarParticlesView: View {
    let count = 20
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<count, id: \.self) { _ in
                StarParticle(size: geometry.size)
            }
        }
    }
}

struct StarParticle: View {
    let size: CGSize
    @State private var position: CGPoint
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    
    init(size: CGSize) {
        self.size = size
        _position = State(initialValue: CGPoint(
            x: CGFloat.random(in: 0...size.width),
            y: CGFloat.random(in: 0...size.height)
        ))
    }
    
    var body: some View {
        Image(systemName: "star.fill")
            .foregroundColor(.yellow)
            .position(position)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    scale = CGFloat.random(in: 0.5...1.5)
                    opacity = 1
                    position = CGPoint(
                        x: position.x + CGFloat.random(in: -50...50),
                        y: position.y + CGFloat.random(in: -50...50)
                    )
                }
                
                withAnimation(.easeIn(duration: 0.5).delay(0.5)) {
                    scale = 0.1
                    opacity = 0
                }
            }
    }
}

struct FloatingBubblesView: View {
    let color: Color
    @State private var bubbles: [BubbleItem] = []
    @State private var flowDirection: Double = 1.0
    @State private var flowStrength: Double = 1.0
    
    // Add constant speed values
    private let baseSpeed: CGFloat = 1.0
    private let horizontalSpeed: CGFloat = 0.8
    private let verticalSpeed: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            ForEach(bubbles) { bubble in
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.6),
                                color.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: bubble.size, height: bubble.size)
                    .overlay(
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: bubble.size * 0.3, height: bubble.size * 0.3)
                            .offset(x: -bubble.size * 0.2, y: -bubble.size * 0.2)
                    )
                    .position(bubble.position)
                    .rotationEffect(.degrees(bubble.rotation))
            }
        }
        .onAppear {
            setupBubbles()
            startBubbleAnimation()
        }
    }
    
    private func setupBubbles() {
        for _ in 0..<15 {
            bubbles.append(BubbleItem())
        }
    }
    
    private func startBubbleAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateBubblePositions()
        }
        
        Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 3.0)) {
                flowDirection = Double.random(in: -1...1)
                flowStrength = 1.0
            }
        }
    }
    
    private func updateBubblePositions() {
        for i in 0..<bubbles.count {
            let time = Date().timeIntervalSince1970
            let flowEffect = sin(time * 0.3 + Double(i)) * flowDirection * flowStrength
            
            // Use constant speeds instead of random values
            let dx = horizontalSpeed * CGFloat(flowEffect) * baseSpeed
            let dy = verticalSpeed * baseSpeed
            
            var newPosition = bubbles[i].position
            newPosition.x += dx
            newPosition.y += dy
            
            if isOffscreen(position: newPosition) {
                bubbles[i] = BubbleItem()
            } else {
                bubbles[i].position = newPosition
                bubbles[i].rotation += CGFloat(flowEffect) * 0.5 // Reduced rotation speed
            }
        }
    }
    
    private func isOffscreen(position: CGPoint) -> Bool {
        return position.y > UIScreen.main.bounds.height + 50 ||
               position.x < -50 ||
               position.x > UIScreen.main.bounds.width + 50
    }
}

struct BubbleItem: Identifiable {
    let id = UUID()
    var position: CGPoint
    let size: CGFloat
    var rotation: CGFloat
    
    init() {
        size = CGFloat.random(in: 15...40)
        rotation = CGFloat.random(in: 0...360)
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        if Bool.random() {
            // Start from sides
            position = CGPoint(
                x: Bool.random() ? -20 : screenWidth + 20,
                y: CGFloat.random(in: 0...screenHeight)
            )
        } else {
            // Start from top
            position = CGPoint(
                x: CGFloat.random(in: 0...screenWidth),
                y: -50
            )
        }
    }
}
