import SwiftUI
import AVFoundation
import Speech
import Combine

// Add MojoPosition enum at file level scope
enum MojoPosition {
    case left
    case right
}

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
    @State private var showFact = false
    @State private var isSpeakingFact = false
    @State private var isListening = false
    @State private var feedbackMessage = ""
    @State private var showFeedback = false
    @State private var pronunciationAccuracy: Double = 0
    @State private var monkeyState: MonkeyInstructorView.MonkeyState = .greeting
    @State private var rainbowHue: Double = 0
    @State private var titleBounce: CGFloat = 1.0
    
    // Speech processing
    private let factSpeechSynthesizer = AVSpeechSynthesizer()
    private let speechProcessor = GameSpeechProcessor()
    @State private var speechSubscription: AnyCancellable?
    
    // Audio player for celebration sound
    @State private var celebrationPlayer: AVAudioPlayer?
    
    // Card properties
    private var currentCard: FlashCard { category.cards[currentIndex] }
    private var hasNextCard: Bool { currentIndex < category.cards.count - 1 }
    private var hasPreviousCard: Bool { currentIndex > 0 }
    
    // Facts for each card - in a real app, these would come from the data model
    private let facts = [
        "Ear": "The ear not only helps you hear but also helps maintain balance.",
        "Palm": "Your palm has about 17,000 touch receptors and sensors.",
        "Lips": "Lips have the thinnest layer of skin on the human body.",
        "Eye": "The human eye can distinguish about 10 million different colors.",
        "Nose": "Humans can remember smells better than any other sense.",
        "Thumb": "The thumb has its own dedicated pulse.",
        "Elephant": "Elephants are the only mammals that can't jump.",
        "Giraffe": "Giraffes sleep for only 30 minutes a day.",
        "Zebra": "Every zebra has a unique pattern of stripes, like fingerprints.",
        "Rhinoceros": "A group of rhinos is called a crash.",
        "Cheetah": "Cheetahs can accelerate from 0 to 60 mph in just 3 seconds.",
        "Gorilla": "Gorillas can catch human colds and other illnesses.",
        "Broccoli": "Broccoli contains more protein than steak per calorie.",
        "Carrot": "Carrots were originally purple, not orange.",
        "Cucumber": "Cucumbers are actually fruits, not vegetables.",
        "Spinach": "Spinach has a natural substance that helps build strong muscles.",
        "Potato": "There are over 4,000 varieties of potatoes worldwide.",
        "Cabbage": "Cabbage is 91% water.",
        "Sunny": "Sunlight takes about 8 minutes to reach Earth from the Sun.",
        "Rainy": "The smell after rain is called 'petrichor'.",
        "Snowy": "No two snowflakes are exactly alike.",
        "Windy": "Wind is caused by differences in atmospheric pressure.",
        "Stormy": "Lightning can be up to five times hotter than the sun's surface.",
        "Foggy": "Fog is actually a cloud that forms at ground level.",
        "Doctor": "The white coat worn by doctors is called a 'lab coat'.",
        "Teacher": "The world's oldest school is in Canterbury, England.",
        "Astronaut": "Astronauts grow about 2 inches taller in space.",
        "Firefighter": "A firefighter's gear can weigh up to 45 pounds.",
        "Chef": "The tall white hat that chefs wear is called a 'toque'.",
        "Pilot": "Pilots and co-pilots eat different meals to avoid food poisoning.",
        "Soccer": "A soccer ball is made up of 32 panels.",
        "Basketball": "Basketball was invented by a Canadian.",
        "Tennis": "Tennis players change sides every odd game to keep play fair.",
        "Swimming": "Humans are the only primates that can swim naturally.",
        "Cycling": "Bicycles are the most efficient form of human transportation.",
        "Gymnastics": "Gymnasts use chalk on their hands to improve grip.",
        "Butterfly": "Butterflies taste with their feet.",
        "Ladybug": "Ladybugs can eat up to 5,000 insects in their lifetime.",
        "Dragonfly": "Dragonflies have been on Earth for 300 million years.",
        "Grasshopper": "Grasshoppers have ears on their bellies.",
        "Beetle": "There are more species of beetles than any other animal.",
        "Firefly": "Firefly light is the most efficient light in the world."
    ]
    
    private var currentFact: String {
        facts[currentCard.word] ?? "Did you know? \(currentCard.word) is a very interesting subject to learn about!"
    }
    
    // Add state variables for Mojo interaction
    @State private var isDragging = false
    @State private var mojoScale: CGFloat = 1.0
    @State private var mojoOpacity: Double = 1.0
    @State private var mojoOffset = CGSize.zero
    @State private var mojoPosition: MojoPosition = .left
    @State private var isDraggingMojo = false
    @State private var cardPosition: CGPoint = .zero
    @State private var mojoInitialPosition: CGPoint = .zero
    @State private var cardScale: CGFloat = 1.0
    @State private var isMojoOnLeft = true  // This will determine Mojo's fixed position
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background with animated gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        category.color.opacity(0.4),
                        .white,
                        category.color.opacity(0.7)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .hueRotation(.degrees(rainbowHue))
                .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: rainbowHue)
                .onAppear {
                    rainbowHue = 10
                }
                
                // Floating bubbles
                FloatingBubblesView(color: category.color)
                
                VStack(spacing: 20) {
                    // Header with back button and title
                    HStack {
                        BackButton {
                            dismiss()
                        }
                        
                        Spacer()
                        
                        // Animated category title
                        Text(category.name)
                            .font(.system(size: 44, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        category.color,
                                        category.color.opacity(0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .white, radius: 2)
                            .shadow(color: .black.opacity(0.3), radius: 4)
                            .onAppear {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.5).repeatForever()) {
                                    titleBounce = 1.05
                                }
                            }
                        
                        Spacer()
                        
                        Color.clear.frame(width: 50, height: 50)
                    }
                    .padding(.horizontal)
                    
                    // Progress indicator
                    HStack(spacing: 5) {
                        ForEach(0..<category.cards.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentIndex ? category.color : category.color.opacity(0.3))
                                .frame(width: 10, height: 10)
                                .scaleEffect(index == currentIndex ? 1.2 : 1.0)
                                .animation(.spring(), value: currentIndex)
                        }
                    }
                    .padding(.vertical, 5)
                    
                    // Main content area with Mojo and Card
                    ZStack {
                        // Card and Mojo Container
                        HStack {
                            if isMojoOnLeft {
                                mojoView(geometry: geometry, position: .left)
                                    .frame(width: geometry.size.width * 0.3)
                                
                                Spacer()
                                
                                cardView(size: geometry.size)
                                    .frame(width: geometry.size.width * 0.5)
                            } else {
                                cardView(size: geometry.size)
                                    .frame(width: geometry.size.width * 0.5)
                                
                                Spacer()
                                
                                mojoView(geometry: geometry, position: .right)
                                    .frame(width: geometry.size.width * 0.3)
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                    .frame(height: geometry.size.height * 0.5)
                    
                    // Fun fact panel with improved design
                    if showFact {
                        FactPanel(
                            fact: currentFact,
                            color: category.color,
                            speakAction: speakFact,
                            isVisible: $showFact,
                            isSpeaking: $isSpeakingFact
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    // Navigation controls with improved design
                    HStack(spacing: 30) {
                        NavigationButton(
                            icon: "arrow.left.circle.fill",
                            isEnabled: hasPreviousCard,
                            action: previousCard
                        )
                        .scaleEffect(hasPreviousCard ? 1.0 : 0.8)
                        
                        // Microphone button with pulse animation
                        ZStack {
                            Circle()
                                .fill(category.color)
                                .frame(width: 70, height: 70)
                                .scaleEffect(isListening ? 1.0 : 0.8)
                                .animation(.spring(), value: isListening)
                            
                            if isListening {
                                ForEach(0..<3) { i in
                                    Circle()
                                        .stroke(category.color.opacity(0.3), lineWidth: 2)
                                        .frame(width: 70 , height: 70 )
                                        .scaleEffect(isListening ? 1.0 : 0.8)
                                        .opacity(isListening ? 0 : 1)
                                        .animation(
                                            Animation.easeInOut(duration: 1)
                                                .repeatForever()
                                                .delay(Double(i) * 0.2),
                                            value: isListening
                                        )
                                }
                            }
                            
                            Image(systemName: isListening ? "waveform.circle.fill" : "mic.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                        .onTapGesture {
                            toggleListening()
                        }
                        
                        NavigationButton(
                            icon: "arrow.right.circle.fill",
                            isEnabled: hasNextCard,
                            action: nextCard
                        )
                        .scaleEffect(hasNextCard ? 1.0 : 0.8)
                    }
                    .padding(.top, 20)
                }
                .padding(.vertical)
                
              
                
                // Visual effects
                if showConfetti { ConfettiView() }
                if showStars { StarParticlesView() }
                
                // Feedback overlay
                if showFeedback {
                    FeedbackOverlay(
                        message: feedbackMessage,
                        accuracy: pronunciationAccuracy,
                        color: feedbackColor()
                    )
                }
            }
        }
        .statusBar(hidden: true)
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            setupInitialState()
        }
        .onReceive(NotificationCenter.default.publisher(for: .speechDidFinish)) { _ in
            // Handle speech completion
            if isSpeakingFact {
                isSpeakingFact = false
            }
        }
    }
    
    private func setupInitialState() {
        // Initial animations and setup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                showFact = true
            }
        }
        
        factSpeechSynthesizer.delegate = SpeechFinishDelegate.shared
        speechProcessor.requestSpeechRecognitionPermission()
        setupCelebrationSound()
    }
    
    // MARK: - Actions
    
    private func feedbackColor() -> Color {
        if pronunciationAccuracy >= 75 {
            return .green.opacity(0.5)
        } else if pronunciationAccuracy >= 40 {
            return .orange.opacity(0.5)
        } else {
            return .red.opacity(0.5)
        }
    }
    
    private func handleSwipe(_ gesture: DragGesture.Value) {
        withAnimation(.spring()) {
            let threshold: CGFloat = 150
            
            if gesture.translation.width < -threshold && hasNextCard {
                // Scrolling left to right
                if !isMojoOnLeft {
                    // If Mojo is on right, just move to next card without changing positions
                    currentIndex += 1
                } else {
                    // If Mojo is on left, swap positions and move to next card
                    isMojoOnLeft.toggle()
                    currentIndex += 1
                }
//                monkeyState = .speaking(text: "Let's see the next card!")
            } else if gesture.translation.width > threshold && hasPreviousCard {
                // Scrolling right to left
                if isMojoOnLeft {
                    // If Mojo is on left, just move to previous card without changing positions
                    currentIndex -= 1
                } else {
                    // If Mojo is on right, swap positions and move to previous card
                    isMojoOnLeft.toggle()
                    currentIndex -= 1
                }
//                monkeyState = .speaking(text: "Going back to the previous card!")
            }
            
            offset = .zero
            cardRotation = 0
        }
    }
    
    private func handleCardTap() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isFlipped.toggle()
            if isFlipped {
                monkeyState = .speaking(text: "Here's how we write \"\(currentCard.word)\"!")
            } else {
                monkeyState = .speaking(text: "Let's practice saying \"\(currentCard.word)\"!")
                speakWord()
            }
        }
    }
    
    private func nextCard() {
        if isSpeakingFact {
            factSpeechSynthesizer.stopSpeaking(at: .immediate)
            isSpeakingFact = false
        }
        
        if isListening {
            stopListening()
        }
        
        withAnimation(.spring()) {
            currentIndex += 1
            isFlipped = false
            monkeyState = .speaking(text: "Let's learn \"\(currentCard.word)\"")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                monkeyState = .thinking
            }
        }
    }
    
    private func previousCard() {
        if isSpeakingFact {
            factSpeechSynthesizer.stopSpeaking(at: .immediate)
            isSpeakingFact = false
        }
        
        if isListening {
            stopListening()
        }
        
        withAnimation(.spring()) {
            currentIndex -= 1
            isFlipped = false
            monkeyState = .speaking(text: "Let's go back to \"\(currentCard.word)\"")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                monkeyState = .thinking
            }
        }
    }
    
    private func speakWord() {
        SwiftUIFlashCardDataManager.shared.speakWord(currentCard.word)
        monkeyState = .speaking(text: "Let's say: \"\(currentCard.word)\"")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                monkeyState = .thinking
            }
        }
    }
    
    private func speakFact() {
        // If already speaking, stop it
        if isSpeakingFact {
            factSpeechSynthesizer.stopSpeaking(at: .immediate)
            isSpeakingFact = false
            return
        }
        
        // Start speaking the fact
        let utterance = AVSpeechUtterance(string: currentFact)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.1
        utterance.volume = 1.0
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        // Start speaking and update state
        isSpeakingFact = true
        factSpeechSynthesizer.speak(utterance)
    }
    
    private func toggleFact() {
        withAnimation {
            if showFact && isSpeakingFact {
                factSpeechSynthesizer.stopSpeaking(at: .immediate)
                isSpeakingFact = false
                monkeyState = .thinking
            } else {
                showFact = true
                monkeyState = .speakingFact(text: currentFact)
            }
        }
    }
    
    // MARK: - Speech Recognition
    
    private func toggleListening() {
        if isListening {
            stopListening()
            monkeyState = .thinking
        } else {
            startListening()
            monkeyState = .listening
        }
    }
    
    private func startListening() {
        // Flip card to word side if not already flipped
        if !isFlipped {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isFlipped = true
            }
        }
        
        isListening = true
        
        // Cancel any existing subscription
        speechSubscription?.cancel()
        
        // Start recording with current word
        speechProcessor.startRecording(word: currentCard.word)
        
        // Handle speech recognition results
        speechSubscription = speechProcessor.$userSpokenText
            .filter { !$0.isEmpty }
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { spokenText in
                self.evaluateUserSpeech(spokenText)
            }
        
        // Set a timeout for speech recognition
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if self.isListening {
                self.stopListening()
                self.showTimeoutFeedback()
            }
        }
    }
    
    private func stopListening() {
        isListening = false
        speechProcessor.stopRecording()
        speechSubscription?.cancel()
    }
    
    private func setupCelebrationSound() {
        if let soundURL = Bundle.main.url(forResource: "celebration", withExtension: "mp3") {
            do {
                celebrationPlayer = try AVAudioPlayer(contentsOf: soundURL)
                celebrationPlayer?.prepareToPlay()
            } catch {
                print("Error loading celebration sound: \(error)")
            }
        }
    }
    
    private func playCelebrationSound() {
        celebrationPlayer?.currentTime = 0
        celebrationPlayer?.play()
    }
    
    private func evaluateUserSpeech(_ spokenText: String) {
        let distance = speechProcessor.levenshteinDistance(spokenText.lowercased(), currentCard.word.lowercased())
        let maxLength = max(spokenText.count, currentCard.word.count)
        let accuracy = max(0, 100.0 - (Double(distance) / Double(maxLength)) * 100.0)
        
        pronunciationAccuracy = accuracy
        
        withAnimation {
            if accuracy >= 80.0 {
                feedbackMessage = "Great job! 🌟\nThat's correct!"
                showStars = true
                showConfetti = true
                monkeyState = .speakingFeedback(text: "Great job! 🌟\nThat's correct!", isGood: true)
                playCelebrationSound()
            } else if accuracy >= 50.0 {
                feedbackMessage = "Good try! 💪\nKeep practicing!"
                monkeyState = .speakingFeedback(text: "Good try! 💪\nKeep practicing!", isGood: true)
            } else {
                feedbackMessage = "Let's try again! 👂\nSay: \"\(currentCard.word)\""
                monkeyState = .speakingFeedback(text: "Let's try again! 👂\nSay: \"\(currentCard.word)\"", isGood: false)
            }
            showFeedback = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                showFeedback = false
                showStars = false
                showConfetti = false
                pronunciationAccuracy = 0
                monkeyState = .thinking
            }
        }
        
        stopListening()
    }
    
    private func showTimeoutFeedback() {
        withAnimation {
            feedbackMessage = "I didn't hear you. Try again!"
            showFeedback = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showFeedback = false
            }
        }
    }
    
    // Helper function to create card view
    private func cardView(size: CGSize) -> some View {
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
            .scaleEffect(cardScale)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                        cardRotation = Double(gesture.translation.height * 0.1)
                        updateMojoInteraction(with: gesture.translation)
                    }
                    .onEnded { gesture in
                        handleSwipe(gesture)
                        resetMojoInteraction()
                    }
            )
            .onTapGesture {
                handleCardTap()
            }
            .zIndex(isDragging ? 2 : 1)
        }
    }
    
    private func mojoView(geometry: GeometryProxy, position: MojoPosition) -> some View {
        MojoWithDialog(
            state: monkeyState,
            size: geometry.size,
            position: position,
            scale: mojoScale,
            opacity: mojoOpacity
        )
        .offset(mojoOffset)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    isDraggingMojo = true
                    mojoOffset = gesture.translation
                    
                    // Check if Mojo is near the card
                    let cardCenter = isMojoOnLeft ? 
                        CGPoint(x: geometry.size.width * 0.7, y: geometry.size.height * 0.25) :
                        CGPoint(x: geometry.size.width * 0.3, y: geometry.size.height * 0.25)
                    
                    let mojoCenter = CGPoint(
                        x: (isMojoOnLeft ? geometry.size.width * 0.3 : geometry.size.width * 0.7) + gesture.translation.width,
                        y: geometry.size.height * 0.25 + gesture.translation.height
                    )
                    
                    let distance = hypot(cardCenter.x - mojoCenter.x, cardCenter.y - mojoCenter.y)
                    
                    if distance < 100 {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            cardScale = 0.9
                            mojoScale = 1.1
                        }
                    } else {
                        withAnimation(.spring()) {
                            cardScale = 1.0
                            mojoScale = 1.0
                        }
                    }
                }
                .onEnded { gesture in
                    isDraggingMojo = false
                    
                    // Check if Mojo should swap with card
                    let cardCenter = isMojoOnLeft ? 
                        CGPoint(x: geometry.size.width * 0.7, y: geometry.size.height * 0.25) :
                        CGPoint(x: geometry.size.width * 0.3, y: geometry.size.height * 0.25)
                    
                    let mojoCenter = CGPoint(
                        x: (isMojoOnLeft ? geometry.size.width * 0.3 : geometry.size.width * 0.7) + gesture.translation.width,
                        y: geometry.size.height * 0.25 + gesture.translation.height
                    )
                    
                    let distance = hypot(cardCenter.x - mojoCenter.x, cardCenter.y - mojoCenter.y)
                    
                    if distance < 100 {
                        // Swap positions
                        withAnimation(.spring()) {
                            isMojoOnLeft.toggle()
                            mojoOffset = .zero
                            cardScale = 1.0
                            mojoScale = 1.0
                        }
                    } else {
                        // Reset position
                        withAnimation(.spring()) {
                            mojoOffset = .zero
                            cardScale = 1.0
                            mojoScale = 1.0
                        }
                    }
                }
        )
        .zIndex(isDraggingMojo ? 2 : 0)
    }
    
    private func updateMojoInteraction(with translation: CGSize) {
        isDragging = true
        
        let isNearMojo: Bool
        if isMojoOnLeft {
            isNearMojo = translation.width < -100
        } else {
            isNearMojo = translation.width > 100
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            if isNearMojo {
                mojoScale = 0.8
                mojoOpacity = 0.0
                cardScale = 1.1
                monkeyState = .thinking
            } else {
                mojoScale = 1.0
                mojoOpacity = 1.0
                cardScale = 1.0
            }
        }
    }
    
    private func resetMojoInteraction() {
        isDragging = false
        withAnimation(.spring()) {
            mojoScale = 1.0
            mojoOpacity = 1.0
            cardScale = 1.0
        }
    }
}

// Helper class to handle speech synthesis delegate methods
class SpeechFinishDelegate: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = SpeechFinishDelegate()
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .speechDidFinish, object: nil)
        }
    }
}

// Extension to add notification name
extension Notification.Name {
    static let speechDidFinish = Notification.Name("speechDidFinish")
}

// Add id to FlashCardView to track instances
extension FlashCardView: Identifiable {
    var id: UUID {
        // Use the category ID as a base for the view's ID
        return category.id
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
            .foregroundColor(.black)
            .padding(8)
            
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

struct FactPanel: View {
    let fact: String
    let color: Color
    let speakAction: () -> Void
    @Binding var isVisible: Bool
    @Binding var isSpeaking: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Fun Fact")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: speakAction) {
                    Image(systemName: isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(isSpeaking ? color : color.opacity(0.8))
                                .shadow(radius: 2)
                        )
                }
                .scaleEffect(isSpeaking ? 1.1 : 1.0)
                .animation(.spring(response: 0.3), value: isSpeaking)
            }
            
            Text(fact)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.8),
                            color.opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal)
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

// MARK: - New Supporting Views

struct ListeningIndicator: View {
    @State private var waveScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Animated background waves
            ForEach(0..<3) { i in
                Circle()
                    .stroke(Color.red.opacity(0.8), lineWidth: 2)
                    .scaleEffect(waveScale - CGFloat(i) * 0.1)
                    .opacity(1.0 - (waveScale - 1.0) + 0.2 * CGFloat(i))
            }
            
            // Microphone icon
            Image(systemName: "mic.fill")
                .font(.system(size: 30))
                .foregroundColor(.red)
                .padding(10)
                .background(Circle().fill(Color.white.opacity(0.9)))
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                waveScale = 1.3
            }
        }
    }
}

struct AccuracyMeter: View {
    let accuracy: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(1))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                // Filled portion based on accuracy
                RoundedRectangle(cornerRadius: 10)
                    .fill(meterColor())
                    .frame(width: max(geometry.size.width * CGFloat(accuracy) / 100.0, 0), height: geometry.size.height)
                
//
//                // Percentage text
//                Text("\(Int(accuracy))%")
//                    .font(.caption)
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//                    .padding(.leading, 8)
//                    .shadow(color: .black, radius: 1)
            }
        }
    }
    
    private func meterColor() -> Color {
        switch accuracy {
        case 75...100:
            return .green
        case 40..<75:
            return .orange
        default:
            return .red
        }
    }
}

// New Feedback Overlay View
struct FeedbackOverlay: View {
    let message: String
    let accuracy: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 15) {
            Text(message)
                .font(.title2.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            if accuracy > 0 {
                AccuracyMeter(accuracy: accuracy)
                    .frame(height: 20)
                    .padding(.horizontal, 40)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(color)
                .opacity(0.95)
                .shadow(radius: 10)
        )
        .padding(.horizontal, 400)
        .transition(.scale.combined(with: .opacity))
    }
}

// New MojoWithDialog component
struct MojoWithDialog: View {
    let state: MonkeyInstructorView.MonkeyState
    let size: CGSize
    let position: MojoPosition
    @State private var isAnimating = false
    let scale: CGFloat
    let opacity: Double
    
    init(state: MonkeyInstructorView.MonkeyState, 
         size: CGSize, 
         position: MojoPosition, 
         scale: CGFloat = 1.0,
         opacity: Double = 1.0) {
        self.state = state
        self.size = size
        self.position = position
        self.scale = scale
        self.opacity = opacity
    }
    
    var body: some View {
        VStack(alignment: .center) {
            // Dialog bubble
            if let message = getMessageForState() {
                Text(message)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    .background(
                        BubbleShape(position: position)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 3)
                    )
                    .padding(.bottom, 10)
                    .transition(.scale.combined(with: .opacity))
                    .opacity(opacity)
            }
            
            // Mojo image
            Image("Mojo")
                .resizable()
                .scaledToFit()
                .frame(height: size.height * 0.4)
                .scaleEffect(isAnimating ? 1.05 * scale : 1.0 * scale)
                .offset(y: isAnimating ? -5 : 0)
                .opacity(opacity)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
                .onAppear {
                    isAnimating = true
                }
        }
        .frame(maxWidth: .infinity)
        .zIndex(0)
    }
    
    private func getMessageForState() -> String? {
        switch state {
        case .greeting:
            return "Hi! Let's learn together! 👋"
        case .listening:
            return "I'm listening... 👂"
        case .happy:
            return "Great job! 🌟\nYou're doing amazing!"
        case .encouraging:
            return "You can do it!\nTry again! 💪"
        case .thinking:
            return "Tap on Card to Flip it! "
        case .speaking(let text):
            return text
        case .speakingFact(let text):
            return "Fun Fact:\n\(text)"
        case .speakingFeedback(let text, _):
            return text
        }
    }
}

// Custom bubble shape for dialog
struct BubbleShape: Shape {
    let position: MojoPosition
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Main bubble rectangle with more rounded corners
        let cornerRadius: CGFloat = 20
        let bubbleRect = CGRect(
            x: rect.minX,
            y: rect.minY,
            width: rect.width,
            height: rect.height - 15
        )
        
        // Create rounded rectangle
        path.addRoundedRect(
            in: bubbleRect,
            cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
        )
        
        // Tail of the bubble
        let tailWidth: CGFloat = 20
        let tailHeight: CGFloat = 15
        
        let tailPoints: [CGPoint]
        if position == .left {
            tailPoints = [
                CGPoint(x: bubbleRect.minX + 30, y: bubbleRect.maxY),
                CGPoint(x: bubbleRect.minX + 40, y: rect.maxY),
                CGPoint(x: bubbleRect.minX + 50, y: bubbleRect.maxY)
            ]
        } else {
            tailPoints = [
                CGPoint(x: bubbleRect.maxX - 50, y: bubbleRect.maxY),
                CGPoint(x: bubbleRect.maxX - 40, y: rect.maxY),
                CGPoint(x: bubbleRect.maxX - 30, y: bubbleRect.maxY)
            ]
        }
        
        // Add tail with smooth curve
        path.move(to: tailPoints[0])
        path.addQuadCurve(
            to: tailPoints[2],
            control: tailPoints[1]
        )
        
        return path
    }
}
