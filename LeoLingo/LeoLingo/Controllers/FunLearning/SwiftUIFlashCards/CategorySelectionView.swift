import SwiftUI

struct CategorySelectionView: View {
    @State private var selectedCategory: FlashCardCategory?
    @State private var isShowingFlashcards = false
    @State private var animateBackground = false
    @State private var titleScale: CGFloat = 0.5
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 0
    @State private var shimmerOffset: CGFloat = -0.7
    @State private var titleRotation: Double = -5
    @State private var titleBounce: CGFloat = 1.0
    @State private var rainbowHue: Double = 0
    @Environment(\.presentationMode) var presentationMode
    
    // Rainbow gradient colors
    let gradientColors: [Color] = [
        Color(red: 1, green: 0.2, blue: 0.3),  // Red
        Color(red: 1, green: 0.6, blue: 0),    // Orange
        Color(red: 1, green: 0.8, blue: 0),    // Yellow
        Color(red: 0.4, green: 0.8, blue: 0.4),// Green
        Color(red: 0.4, green: 0.6, blue: 1),  // Blue
        Color(red: 0.6, green: 0.4, blue: 0.8) // Purple
    ]
    
    private let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 180), spacing: 20)
    ]
    
    var body: some View {
        ZStack {
            // Background
            Image("flashcard_background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    print("Loading background image: jungle_background")
                }
            
            // Floating leaves animation
            FloatingLeavesView()
            
            // Main content
            VStack {
                // Top section with back button and title
                HStack(alignment: .center) {
                    // Back button
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.green)
                        .cornerRadius(25)
                        .shadow(radius: 5)
                        .scaleEffect(titleBounce)
                    }
                    .padding(.leading, 20)
                    
                    // Enhanced Animated Title
                    ZStack {
                        // Glowing background
                        Text("Flash Cards")
                            .font(.system(size: 55, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                .linearGradient(
                                    colors: gradientColors,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .blur(radius: 20)
                            .opacity(0.7)
                            .scaleEffect(1.2)
                        
                        // Main title with rainbow gradient
                        Text("Flash Cards")
                            .font(.system(size: 50, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                .linearGradient(
                                    colors: gradientColors,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .white, radius: 2, x: 0, y: 0)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 0)
                            .overlay(
                                GeometryReader { geometry in
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .clear,
                                            .white.opacity(0.8),
                                            .clear
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .frame(width: 50)
                                    .offset(x: -50 + (geometry.size.width + 50) * shimmerOffset)
                                    .blendMode(.overlay)
                                }
                            )
                    }
                    .scaleEffect(titleScale * titleBounce)
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)
                    .rotationEffect(.degrees(titleRotation))
                    .frame(maxWidth: .infinity)
                    .onAppear {
                        // Initial animations
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                            titleScale = 1.0
                            titleOpacity = 1
                            titleRotation = 0
                        }
                        
                        // Continuous floating animation
                        withAnimation(
                            .easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true)
                        ) {
                            titleOffset = 10
                        }
                        
                        // Continuous rotation animation
                        withAnimation(
                            .easeInOut(duration: 3.0)
                            .repeatForever(autoreverses: true)
                        ) {
                            titleRotation = 5
                        }
                        
                        // Continuous bounce animation
                        withAnimation(
                            .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                        ) {
                            titleBounce = 1.1
                        }
                        
                        // Continuous shimmer animation
                        withAnimation(
                            .linear(duration: 2.5)
                            .repeatForever(autoreverses: false)
                        ) {
                            shimmerOffset = 1.7
                        }
                        
                        // Rainbow animation
                        withAnimation(
                            .linear(duration: 3)
                            .repeatForever(autoreverses: false)
                        ) {
                            rainbowHue = 1
                        }
                    }
                    
                    // Add invisible back button space to balance the layout
                    Color.clear
                        .frame(width: 50, height: 50)
                        .padding(.trailing, 20)
                }
                .padding(.top, 20)
                
                // Categories grid with staggered animation
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 25) {
                        ForEach(Array(SwiftUIFlashCardDataManager.shared.getAllCategories().enumerated()), id: \.element.id) { index, category in
                            CategoryItemView(
                                category: category,
                                onSelect: {
                                    self.selectedCategory = category
                                    self.isShowingFlashcards = true
                                }
                            )
                            .offset(y: animateBackground ? 0 : 500)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.7)
                                .delay(Double(index) * 0.1),
                                value: animateBackground
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $isShowingFlashcards, content: {
            if let category = selectedCategory {
                FlashCardView(category: category)
                    .preferredColorScheme(.light)
                    .onAppear {
                        // Lock to landscape right
                        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                        UIViewController.attemptRotationToDeviceOrientation()
                    }
                    .onDisappear {
                        // Return to portrait
                        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                        UIViewController.attemptRotationToDeviceOrientation()
                    }
            }
        })
        .onAppear {
            // Ensure portrait orientation for category selection
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
            
            withAnimation {
                animateBackground = true
            }
        }
    }
}

// Add orientation helper
extension CategorySelectionView {
    func setOrientation(to orientation: UIInterfaceOrientation) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let supportedOrientations: UIInterfaceOrientationMask = orientation == .portrait ? .portrait : .landscapeRight
            let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: supportedOrientations)
            try? windowScene.requestGeometryUpdate(geometryPreferences)
            
            DispatchQueue.main.async {
                if let window = windowScene.windows.first {
                    window.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                }
            }
        }
    }
}

// Category item view with card and tap handling
struct CategoryItemView: View {
    let category: FlashCardCategory
    let onSelect: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        SwiftUICardView(category: category, isPressed: isPressed)
            .onTapGesture {
                // Simulate press animation
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = true
                }
                
                // Release after a moment
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring()) {
                        isPressed = false
                    }
                    
                    // Navigate after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onSelect()
                    }
                }
            }
    }
}

// Category card view
struct SwiftUICardView: View {
    let category: FlashCardCategory
    let isPressed: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(category.color)
                .shadow(radius: 5)
                .frame(height: 200)
            
            VStack {
                Image(category.image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .padding(.top, 10)
                    // Add fallback for missing images
                    .onAppear {
                        // This is just to handle the initialization - images would need to be manually added to assets
                        print("Loading image: \(category.image)")
                    }
                
                Text(category.name)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 1, y: 1)
                    .padding(.bottom, 10)
            }
        }
        .scaleEffect(isPressed ? 0.85 : 1.0)
        .animation(.spring(), value: isPressed)
    }
}

// Floating leaves animation view
struct FloatingLeavesView: View {
    @State private var leaves: [LeafItem] = []
    @State private var windDirection: Double = 1.0  // Controls wind direction
    @State private var windStrength: Double = 1.0   // Controls wind strength
    
    var body: some View {
        ZStack {
            ForEach(leaves) { leaf in
                Image(systemName: "leaf.fill")
                    .font(.system(size: leaf.size))
                    .foregroundColor(leaf.color.opacity(0.5))
                    .rotationEffect(.degrees(leaf.rotation))
                    .position(leaf.position)
            }
        }
        .onAppear {
            // Create fewer leaves for a less crowded effect
            for _ in 0..<12 {
                addLeaf()
            }
            
            // Change wind direction periodically
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 2.0)) {
                    windDirection = Double.random(in: -1...1)
                    windStrength = Double.random(in: 0.5...1.5)
                }
            }
            
            // Animate leaves with wind-like movement
            Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
                for i in 0..<self.leaves.count {
                    if i < self.leaves.count {
                        let time = Date().timeIntervalSince1970
                        let leaf = self.leaves[i]
                        
                        // Create sinusoidal movement
                        let windEffect = sin(time * 0.5 + Double(i)) * windDirection * windStrength
                        
                        // Horizontal movement affected by wind
                        let dx = CGFloat(windEffect) * 2.0
                        
                        // Vertical movement with slight variation
                        let baseSpeed = CGFloat.random(in: 0.2...0.8)
                        let verticalVariation = sin(time * 0.3 + Double(i)) * 0.5
                        let dy = baseSpeed + CGFloat(verticalVariation)
                        
                        let newPosition = CGPoint(
                            x: leaf.position.x + dx,
                            y: leaf.position.y + dy
                        )
                        
                        // Reset leaf position when it goes off screen
                        if newPosition.y > UIScreen.main.bounds.height + 50 ||
                           newPosition.x < -50 || newPosition.x > UIScreen.main.bounds.width + 50 {
                            // Randomly choose starting edge (top or sides)
                            let startFromSide = Bool.random()
                            if startFromSide {
                                // Start from left or right edge
                                self.leaves[i].position = CGPoint(
                                    x: windDirection > 0 ? -20 : UIScreen.main.bounds.width + 20,
                                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                                )
                            } else {
                                // Start from top
                                self.leaves[i].position = CGPoint(
                                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                    y: -50
                                )
                            }
                            self.leaves[i].rotation = CGFloat.random(in: 0...360)
                        } else {
                            self.leaves[i].position = newPosition
                            // Gentle rotation based on wind
                            self.leaves[i].rotation += CGFloat(windEffect * 2.0)
                        }
                    }
                }
            }
        }
    }
    
    func addLeaf() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Randomly position leaves across the screen
        let startFromSide = Bool.random()
        let position: CGPoint
        if startFromSide {
            position = CGPoint(
                x: windDirection > 0 ? -20 : screenWidth + 20,
                y: CGFloat.random(in: 0...screenHeight)
            )
        } else {
            position = CGPoint(
                x: CGFloat.random(in: 0...screenWidth),
                y: CGFloat.random(in: -300...0)
            )
        }
        
        let leaf = LeafItem(
            id: UUID(),
            position: position,
            size: CGFloat.random(in: 20...35),
            color: [
                .green,
                Color(red: 0.0, green: 0.7, blue: 0.0),
                Color(red: 0.2, green: 0.8, blue: 0.2),
                Color(red: 0.6, green: 0.8, blue: 0.2),
                Color(red: 0.8, green: 0.9, blue: 0.0)
            ].randomElement() ?? .green,
            rotation: CGFloat.random(in: 0...360)
        )
        
        leaves.append(leaf)
    }
}

// Leaf item model
struct LeafItem: Identifiable {
    let id: UUID
    var position: CGPoint
    let size: CGFloat
    let color: Color
    var rotation: CGFloat
}

// Preview for SwiftUI canvas
struct CategorySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        CategorySelectionView()
    }
} 
 